import 'package:admin/services/article_service_couple_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../../../models/service.dart';
import '../../../../../models/service_type.dart';
import '../../../../../services/api_service.dart';

class ServiceSelectionStep extends StatefulWidget {
  @override
  State<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends State<ServiceSelectionStep> {
  final controller = Get.find<OrdersController>();
  final api = Get.find<ApiService>();

  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Map<String, dynamic>> couples = [];
  Map<String, int> selectedArticles = {};
  void _syncSelectedItemsToController() {
    final controller = Get.find<OrdersController>();
    // On enrichit chaque item avec les infos du couple (nom, prix, etc.)
    controller.selectedItems.value =
        selectedArticles.entries.where((e) => e.value > 0).map((e) {
      final couple = couples.firstWhereOrNull((c) => c['article_id'] == e.key);
      return {
        'articleId': e.key,
        'quantity': e.value,
        'articleName': couple != null ? couple['article_name'] : null,
        'articleDescription':
            couple != null ? couple['article_description'] : null,
        'price': couple != null
            ? (showPremiumSwitch && isPremium
                ? double.tryParse(couple['premium_price'].toString()) ?? 0.0
                : double.tryParse(couple['base_price'].toString()) ?? 0.0)
            : 0.0,
        'serviceId': selectedService?.id,
        'serviceName': selectedService?.name,
        'serviceTypeId': selectedServiceType?.id,
        'serviceTypeName': selectedServiceType?.name,
        'serviceTypePricing': selectedServiceType?.pricingType,
        'weight': weight,
        'isPremium': showPremiumSwitch && isPremium,
      };
    }).toList();
  }

  ServiceType? selectedServiceType;
  Service? selectedService;
  bool isLoading = false;
  bool isPremium = false;
  double? weight;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get('/api/service-types');
      serviceTypes = (response.data['data'] as List)
          .map((json) => ServiceType.fromJson(json))
          .toList();
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      couples = [];
      selectedArticles.clear();
      weight = null;
      isPremium = false;
    });
    if (type != null) {
      setState(() => isLoading = true);
      try {
        final response = await api.get('/api/services/all');
        services = (response.data['data'] as List)
            .map((json) => Service.fromJson(json))
            .where((service) => service.serviceTypeId == type.id)
            .toList();
      } catch (_) {}
      setState(() => isLoading = false);
    }
  }

  Future<void> _onServiceChanged(Service? service) async {
    final controller = Get.find<OrdersController>();
    setState(() {
      selectedService = service;
      controller.selectedService.value = service;
      controller.selectedServiceId.value = service?.id;
      couples = [];
      selectedArticles.clear();
      weight = null;
      isPremium = false;
    });
    if (service != null && selectedServiceType != null) {
      setState(() => isLoading = true);
      try {
        couples = await ArticleServiceCoupleService.getCouplesForServiceType(
          serviceTypeId: selectedServiceType!.id,
          serviceId: selectedService!.id,
        );
      } catch (_) {}
      setState(() => isLoading = false);
    }
  }

  bool get showWeightField => selectedServiceType?.requiresWeight == true;
  bool get showPremiumSwitch => selectedServiceType?.supportsPremium == true;
  String? get pricingType => selectedServiceType?.pricingType;

  List<Widget> _buildArticleCatalog() {
    Map<String, List<Map<String, dynamic>>> couplesByCategory = {};
    for (var couple in couples) {
      final catId = couple['article_category_id'] ?? 'Autres';
      couplesByCategory.putIfAbsent(catId, () => []).add(couple);
    }
    List<Widget> widgets = [];
    couplesByCategory.forEach((catId, couplesList) {
      String? categoryName = couplesList.isNotEmpty
          ? couplesList.first['article_category_name']
          : null;
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          categoryName ?? catId,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ));
      for (var couple in couplesList) {
        final articleId = couple['article_id'];
        final articleName = couple['article_name'] ?? '';
        final articleDescription = couple['article_description'] ?? '';
        final basePrice =
            double.tryParse(couple['base_price'].toString()) ?? 0.0;
        final premiumPrice =
            double.tryParse(couple['premium_price'].toString()) ?? 0.0;
        final displayPrice =
            showPremiumSwitch && isPremium ? premiumPrice : basePrice;
        widgets.add(Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(articleName,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      if (articleDescription.isNotEmpty)
                        Text(articleDescription,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                      Text('Prix: ${displayPrice} F CFA',
                          style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          selectedArticles[articleId] =
                              (selectedArticles[articleId] ?? 0) - 1;
                          if (selectedArticles[articleId]! < 0)
                            selectedArticles[articleId] = 0;
                          _syncSelectedItemsToController();
                        });
                      },
                    ),
                    Text('${selectedArticles[articleId] ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          selectedArticles[articleId] =
                              (selectedArticles[articleId] ?? 0) + 1;
                          _syncSelectedItemsToController();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      }
    });
    // Estimation du total avec les bons prix
    double sum = 0;
    for (var couple in couples) {
      final qty = selectedArticles[couple['article_id']] ?? 0;
      final basePrice = double.tryParse(couple['base_price'].toString()) ?? 0.0;
      final premiumPrice =
          double.tryParse(couple['premium_price'].toString()) ?? 0.0;
      final price = showPremiumSwitch && isPremium ? premiumPrice : basePrice;
      sum += price * qty;
    }
    widgets.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        'Estimation totale : ${sum.toStringAsFixed(2)} F CFA',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.orange,
        ),
      ),
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type de service', style: AppTextStyles.h3),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<ServiceType>(
                  value: selectedServiceType,
                  decoration: InputDecoration(
                      labelText: 'Sélectionner le type de service'),
                  items: serviceTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          ))
                      .toList(),
                  onChanged: _onServiceTypeChanged,
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<Service>(
                  value: selectedService,
                  decoration:
                      InputDecoration(labelText: 'Sélectionner le service'),
                  items: services
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text(service.name),
                          ))
                      .toList(),
                  onChanged: _onServiceChanged,
                ),
                SizedBox(height: AppSpacing.md),
                if (selectedServiceType != null &&
                    pricingType == 'FIXED' &&
                    couples.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildArticleCatalog(),
                      ),
                    ),
                  ),
                if (selectedServiceType != null &&
                    pricingType == 'WEIGHT_BASED') ...[
                  Text('Poids (kg)', style: AppTextStyles.h3),
                  SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    initialValue: weight?.toString() ?? '',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      setState(() {
                        weight = double.tryParse(val);
                      });
                    },
                  ),
                ],
                if (showPremiumSwitch) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: isPremium,
                        onChanged: (val) {
                          setState(() {
                            isPremium = val;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text('Premium'),
                    ],
                  ),
                ],
              ],
            ),
          );
  }
}

import 'package:admin/constants.dart';
import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/models/service.dart';
import 'package:admin/services/service_type_service.dart';
import 'package:admin/services/service_service.dart';
import 'package:admin/services/article_service_couple_service.dart';

class FlashServiceStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashServiceStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashServiceStep> createState() => _FlashServiceStepState();
}

class _FlashServiceStepState extends State<FlashServiceStep> {
  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Map<String, dynamic>> couples = [];
  ServiceType? selectedServiceType;
  Service? selectedService;
  bool isLoading = false;
  bool isPremium = false;
  double? weight;

  void _onQuantityChanged(String articleId, int value,
      {bool? isPremium, String? serviceId}) {
    widget.controller.updateDraftItemQuantity(
      articleId,
      value,
      isPremium: isPremium ?? this.isPremium,
      serviceId: serviceId,
    );
    widget.controller.syncSelectedItemsFrom(couples: couples);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchServiceTypes();
  }

  Future<void> _fetchServiceTypes() async {
    setState(() => isLoading = true);
    serviceTypes = await ServiceTypeService.getAllServiceTypes();
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      couples = [];
      isPremium = false;
      weight = null;
    });
    widget.controller.setDraftField('serviceTypeId', type?.id);
    if (type != null) {
      setState(() => isLoading = true);
      services = await ServiceService.getAllServices();
      services = services.where((s) => s.serviceTypeId == type.id).toList();
      setState(() => isLoading = false);
    }
  }

  Future<void> _onServiceChanged(Service? service) async {
    setState(() {
      selectedService = service;
      couples = [];
      isPremium = false;
      weight = null;
    });
    widget.controller.setDraftField('serviceId', service?.id);
    if (service != null && selectedServiceType != null) {
      setState(() => isLoading = true);
      couples = await ArticleServiceCoupleService.getCouplesForServiceType(
        serviceTypeId: selectedServiceType!.id,
        serviceId: service.id,
      );
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
                        final currentQty = widget.controller.draft.value.items
                                .firstWhereOrNull(
                                    (i) => i.articleId == articleId)
                                ?.quantity ??
                            0;
                        final newQty = (currentQty - 1).clamp(0, 999);
                        _onQuantityChanged(articleId, newQty,
                            isPremium: showPremiumSwitch ? isPremium : null,
                            serviceId: couple['service_id']);
                      },
                    ),
                    Text(
                        '${widget.controller.draft.value.items.firstWhereOrNull((i) => i.articleId == articleId)?.quantity ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        final currentQty = widget.controller.draft.value.items
                                .firstWhereOrNull(
                                    (i) => i.articleId == articleId)
                                ?.quantity ??
                            0;
                        final newQty = (currentQty + 1).clamp(0, 999);
                        _onQuantityChanged(articleId, newQty,
                            isPremium: showPremiumSwitch ? isPremium : null,
                            serviceId: couple['service_id']);
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
    int sum = 0;
    for (var item in widget.controller.draft.value.items) {
      final couple =
          couples.firstWhereOrNull((c) => c['article_id'] == item.articleId);
      if (couple != null) {
        final basePrice =
            double.tryParse(couple['base_price'].toString()) ?? 0.0;
        final premiumPrice =
            double.tryParse(couple['premium_price'].toString()) ?? 0.0;
        final displayPrice =
            showPremiumSwitch && isPremium ? premiumPrice : basePrice;
        sum += item.quantity * displayPrice.toInt();
      }
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
                // Suppression du bouton redondant ici
              ],
            ),
          );
  }
}

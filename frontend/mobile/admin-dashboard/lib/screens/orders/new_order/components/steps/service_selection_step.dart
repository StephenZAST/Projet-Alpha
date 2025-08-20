import 'package:admin/services/article_service_couple_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../../../models/service.dart';
import '../../../../../models/service_type.dart';
import '../../../../../models/article.dart';
import '../../../../../services/api_service.dart';

class ServiceSelectionStep extends StatefulWidget {
  @override
  State<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends State<ServiceSelectionStep> {
  void _addArticleToControllerIfMissing(Map<String, dynamic> couple) {
    final articleId = couple['article_id'];
    if (articleId == null) return;
    final alreadyExists = controller.articles.any((a) => a.id == articleId);
    if (!alreadyExists) {
      controller.articles.add(
        Article(
          id: articleId,
          name: couple['article_name'] ?? 'Article inconnu',
          description: couple['article_description'],
          basePrice: double.tryParse(couple['base_price'].toString()) ?? 0.0,
          premiumPrice: double.tryParse(couple['premium_price'].toString()),
          categoryId: couple['article_category_id'],
          category: couple['article_category_name'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  final controller = Get.find<OrdersController>();
  final api = Get.find<ApiService>();

  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Map<String, dynamic>> couples = [];
  Map<String, int> selectedArticles =
      {}; // (Gardé pour l'affichage, mais la source de vérité devient le controller)
  void _syncSelectedItemsToController() {
    // Ajoute tous les articles sélectionnés dans la liste articles du controller si absents
    for (final couple in couples) {
      if (selectedArticles.containsKey(couple['article_id'])) {
        _addArticleToControllerIfMissing(couple);
      }
    }
    // Stocke la sélection courante dans le controller pour accès global
    controller.lastSelectedArticles = Map<String, int>.from(selectedArticles);
    controller.lastCouples = List<Map<String, dynamic>>.from(couples);
    controller.lastIsPremium = isPremium;
    controller.lastSelectedService = selectedService;
    controller.lastSelectedServiceType = selectedServiceType;
    controller.lastWeight = weight;
    controller.lastShowPremiumSwitch = showPremiumSwitch;
    controller.syncSelectedItemsFrom(
      selectedArticles: selectedArticles,
      couples: couples,
      isPremium: isPremium,
      selectedService: selectedService,
      selectedServiceType: selectedServiceType,
      weight: weight,
      showPremiumSwitch: showPremiumSwitch,
    );
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
      // MAJ OrderDraft avec le serviceType sélectionné
      if (type != null) {
        print(
            '[ServiceSelectionStep] ServiceType sélectionné : id=${type.id}, name=${type.name}');
        controller.orderDraft.update((draft) {
          draft?.serviceTypeId = type.id;
        });
        print(
            '[ServiceSelectionStep] Draft après sélection serviceType : serviceTypeId=${controller.orderDraft.value.serviceTypeId}');
        controller.update();
      }
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
      if (service != null) {
        controller.setSelectedService(service.id); // MAJ OrderDraft
      }
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
                Obx(() => Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            final currentQty = controller.orderDraft.value.items
                                    .firstWhereOrNull(
                                        (i) => i.articleId == articleId)
                                    ?.quantity ??
                                0;
                            final newQty = (currentQty - 1).clamp(0, 999);
                            controller.updateDraftItemQuantity(
                                articleId, newQty,
                                isPremium: showPremiumSwitch && isPremium);
                          },
                        ),
                        Text(
                            '${controller.orderDraft.value.items.firstWhereOrNull((i) => i.articleId == articleId)?.quantity ?? 0}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            final currentQty = controller.orderDraft.value.items
                                    .firstWhereOrNull(
                                        (i) => i.articleId == articleId)
                                    ?.quantity ??
                                0;
                            final newQty = (currentQty + 1).clamp(0, 999);
                            controller.updateDraftItemQuantity(
                                articleId, newQty,
                                isPremium: showPremiumSwitch && isPremium);
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ));
      }
    });
    // Estimation du total avec les bons prix
    double sum = 0;
    for (var item in controller.orderDraft.value.items) {
      // On retrouve le couple pour le prix
      final couple =
          couples.firstWhereOrNull((c) => c['article_id'] == item.articleId);
      final basePrice = couple != null
          ? double.tryParse(couple['base_price'].toString()) ?? 0.0
          : 0.0;
      final premiumPrice = couple != null
          ? double.tryParse(couple['premium_price'].toString()) ?? 0.0
          : 0.0;
      final price = (item.isPremium ? premiumPrice : basePrice);
      sum += price * item.quantity;
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
                      child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildArticleCatalog(),
                          )),
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

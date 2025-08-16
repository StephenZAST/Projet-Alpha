import 'package:admin/services/article_price_service.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/article.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:get/get.dart';

class OrderItemEditDialog extends StatefulWidget {
  final OrderItem? item;
  final List<Article> availableArticles;
  final List<Service> availableServices;
  const OrderItemEditDialog({
    Key? key,
    this.item,
    required this.availableArticles,
    required this.availableServices,
  }) : super(key: key);

  @override
  State<OrderItemEditDialog> createState() => _OrderItemEditDialogState();
}

class _OrderItemEditDialogState extends State<OrderItemEditDialog> {
  // Fonction pour construire le catalogue d'articles trié par catégorie
  // Nouvelle version : utilise les prix du couple article/service
  List<Widget> _buildArticleCatalog() {
    Map<String, List<Article>> articlesByCategory = {};
    for (var article in articles) {
      final catId = article.categoryId ?? 'Autres';
      articlesByCategory.putIfAbsent(catId, () => []).add(article);
    }
    List<Widget> widgets = [];
    articlesByCategory.forEach((catId, articlesList) {
      String? categoryName =
          articlesList.isNotEmpty ? articlesList.first.category : null;
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          categoryName ?? _getCategoryName(catId),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ));
      for (var article in articlesList) {
        widgets.add(FutureBuilder<Map<String, dynamic>?>(
          future: (selectedServiceType != null)
              ? ArticlePriceService.getArticleServicePrice(
                  articleId: article.id,
                  serviceTypeId: selectedServiceType!.id,
                )
              : Future.value(null),
          builder: (context, snapshot) {
            final priceData = snapshot.data;
            final basePrice =
                priceData != null && priceData['base_price'] != null
                    ? priceData['base_price'] as num
                    : article.basePrice;
            final premiumPrice =
                priceData != null && priceData['premium_price'] != null
                    ? priceData['premium_price'] as num
                    : article.premiumPrice;
            final displayPrice =
                showPremiumSwitch && isPremium && premiumPrice != null
                    ? premiumPrice
                    : basePrice;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.name,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          if (article.description != null)
                            Text(article.description!,
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
                              selectedArticles[article.id] =
                                  (selectedArticles[article.id] ?? 0) - 1;
                              if (selectedArticles[article.id]! < 0)
                                selectedArticles[article.id] = 0;
                            });
                          },
                        ),
                        Text('${selectedArticles[article.id] ?? 0}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              selectedArticles[article.id] =
                                  (selectedArticles[article.id] ?? 0) + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ));
      }
    });
    // Estimation du total avec les bons prix
    Future<double> totalEstimateFuture = (() async {
      double sum = 0;
      for (var article in articles) {
        final qty = selectedArticles[article.id] ?? 0;
        Map<String, dynamic>? priceData;
        if (selectedServiceType != null) {
          priceData = await ArticlePriceService.getArticleServicePrice(
            articleId: article.id,
            serviceTypeId: selectedServiceType!.id,
          );
        }
        final basePrice = priceData != null && priceData['base_price'] != null
            ? priceData['base_price'] as num
            : article.basePrice;
        final premiumPrice =
            priceData != null && priceData['premium_price'] != null
                ? priceData['premium_price'] as num
                : article.premiumPrice;
        final price = showPremiumSwitch && isPremium && premiumPrice != null
            ? premiumPrice
            : basePrice;
        sum += price * qty;
      }
      return sum;
    })();
    widgets.add(FutureBuilder<double>(
      future: totalEstimateFuture,
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text('Estimation totale : ${total.toStringAsFixed(2)} F CFA',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        );
      },
    ));
    return widgets;
  }

  // Fonction utilitaire pour obtenir le nom de la catégorie (à adapter si tu as la liste des catégories)
  String _getCategoryName(String catId) {
    return catId == 'Autres' ? 'Autres' : catId;
  }

  // Map pour stocker la quantité sélectionnée par article
  Map<String, int> selectedArticles = {};
  bool get showWeightField {
    return selectedServiceType?.requiresWeight == true;
  }

  bool get showPremiumSwitch {
    return selectedServiceType?.supportsPremium == true;
  }

  ServiceType? selectedServiceType;
  Service? selectedService;
  Article? selectedArticle;
  bool isLoading = false;
  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Article> articles = [];
  final api = Get.find<ApiService>();

  double? weight;
  int quantity = 1;
  bool isPremium = false;
  double? price;

  Future<void> _updatePrice() async {
    if (selectedServiceType == null || selectedService == null) {
      setState(() => price = null);
      return;
    }
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> data = {
        'serviceTypeId': selectedServiceType!.id,
        'serviceId': selectedService!.id,
        'premium': isPremium,
      };
      if (selectedServiceType?.pricingType == 'FIXED') {
        if (selectedArticle == null || quantity < 1) {
          setState(() => price = null);
          return;
        }
        data['articleId'] = selectedArticle!.id;
        data['quantity'] = quantity;
      } else if (selectedServiceType?.pricingType == 'WEIGHT_BASED') {
        if (weight == null || weight! <= 0) {
          setState(() => price = null);
          return;
        }
        data['weight'] = weight;
      }
      final response = await api.post(
        '/api/services/calculate-price',
        data: data,
      );
      price = response.data['data']?['price']?.toDouble();
    } catch (e) {
      price = null;
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    setState(() => isLoading = true);
    final response = await api.get('/api/service-types');
    serviceTypes = (response.data['data'] as List)
        .map((json) => ServiceType.fromJson(json))
        .toList();
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      selectedArticle = null;
      services = [];
      articles = [];
      weight = null; // Réinitialise le poids
    });
    if (type != null) {
      setState(() => isLoading = true);
      final response = await api.get('/api/services/all');
      services = (response.data['data'] as List)
          .map((json) => Service.fromJson(json))
          .where((service) => service.serviceTypeId == type.id)
          .toList();
      setState(() => isLoading = false);
    }
  }

  Future<void> _onServiceChanged(Service? service) async {
    setState(() {
      selectedService = service;
      selectedArticle = null;
      articles = [];
      weight = null; // Réinitialise le poids
    });
    if (service != null) {
      setState(() => isLoading = true);
      final response = await api.get('/api/articles?serviceId=${service.id}');
      articles = (response.data['data'] as List)
          .map((json) => Article.fromJson(json))
          .toList();
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

  Future<void> _validateAndSubmit() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    if (selectedServiceType == null) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Veuillez sélectionner un type de service.');
      return;
    }
    if (selectedService == null) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Veuillez sélectionner un service.');
      return;
    }

    List<Map<String, dynamic>> itemsPayload = [];

    if (selectedServiceType?.pricingType == 'FIXED') {
      final articlesToAdd =
          selectedArticles.entries.where((e) => e.value > 0).toList();
      if (articlesToAdd.isEmpty) {
        setState(() => isLoading = false);
        _showErrorSnackbar('Veuillez sélectionner au moins un article.');
        return;
      }
      for (var entry in articlesToAdd) {
        itemsPayload.add({
          'articleId': entry.key,
          'serviceId': selectedService!.id,
          'quantity': entry.value,
          'isPremium': isPremium,
        });
      }
    } else if (selectedServiceType?.pricingType == 'WEIGHT_BASED') {
      if (weight == null || weight! <= 0) {
        setState(() => isLoading = false);
        _showErrorSnackbar('Veuillez renseigner un poids valide (> 0).');
        return;
      }
      itemsPayload.add({
        'serviceId': selectedService!.id,
        'weight': weight,
        'isPremium': isPremium,
      });
    }

    if (itemsPayload.isEmpty) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Aucun item à ajouter.');
      return;
    }

    Navigator.of(context).pop(itemsPayload);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item == null
                        ? 'Ajouter un article/service'
                        : 'Modifier l\'article/service',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ServiceType>(
                    value: selectedServiceType,
                    decoration: InputDecoration(labelText: 'Type de service'),
                    items: serviceTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            ))
                        .toList(),
                    onChanged: _onServiceTypeChanged,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Service>(
                    value: selectedService,
                    decoration: InputDecoration(labelText: 'Service'),
                    items: services
                        .map((service) => DropdownMenuItem(
                              value: service,
                              child: Text(service.name),
                            ))
                        .toList(),
                    onChanged: _onServiceChanged,
                  ),
                  const SizedBox(height: 12),
                  if (selectedServiceType?.pricingType == 'FIXED')
                    // Affichage catalogue e-commerce scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildArticleCatalog(),
                        ),
                      ),
                    ),
                  if (selectedServiceType?.pricingType == 'WEIGHT_BASED')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          'Ce service est tarifé au poids. Aucun article à sélectionner.'),
                    ),
                  if (selectedServiceType?.pricingType == 'SUBSCRIPTION' ||
                      selectedServiceType?.pricingType == 'CUSTOM')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Ce service est lié à un abonnement.'),
                    ),
                  if (selectedServiceType != null) ...[
                    if (showWeightField) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Poids (kg)'),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        initialValue: weight?.toString() ?? '',
                        onChanged: (val) {
                          setState(() {
                            weight = double.tryParse(val);
                          });
                          _updatePrice();
                        },
                      ),
                    ],
                    // Suppression du champ quantité résiduelle
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
                              _updatePrice();
                            },
                          ),
                          const SizedBox(width: 8),
                          Text('Premium'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (price != null)
                      Text('Prix estimé : ${price!.toStringAsFixed(2)} F CFA',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassButton(
                        label: 'Annuler',
                        variant: GlassButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      GlassButton(
                        label: widget.item == null ? 'Ajouter' : 'Enregistrer',
                        variant: GlassButtonVariant.primary,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () async => await _validateAndSubmit(),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

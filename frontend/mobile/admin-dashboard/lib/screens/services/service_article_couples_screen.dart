// Import legacy supprimé
import 'package:flutter/material.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/models/article.dart';
import 'package:admin/services/article_service.dart';
import 'package:admin/services/service_type_service.dart';
import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/services/article_service_service.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/models/service.dart';
import 'package:admin/services/service_service.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

class ServiceArticleCouplesScreen extends StatefulWidget {
  const ServiceArticleCouplesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceArticleCouplesScreen> createState() =>
      _ServiceArticleCouplesScreenState();
}

class _ServiceArticleCouplesScreenState
    extends State<ServiceArticleCouplesScreen> {
  // Notification standardisée (succès)
  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
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
      backgroundColor: Colors.green.withOpacity(0.85),
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

  // Notification standardisée (erreur)
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

  List<ArticleServiceCouple> couples = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCouples();
  }

  Future<void> _fetchCouples() async {
    setState(() => isLoading = true);
    final rawList =
        await ArticleServiceCoupleService.getAllServiceArticleCouples();
    final List<ArticleServiceCouple> mappedCouples = rawList.map((json) {
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      // Récupération des sous-objets
      final serviceType = json['service_types'] ?? {};
      final article = json['articles'] ?? {};
      // DEBUG: Affiche les IDs reçus pour chaque couple
      print(
          'COUPLE DEBUG => id: \\${json['id']}, articleId: \\${json['article_id']}, serviceId: \\${json['service_id']}');
      return ArticleServiceCouple(
        id: json['id']?.toString() ?? '',
        serviceTypeName: serviceType['name'] ?? '',
        serviceTypeDescription: serviceType['description'] ?? '',
        serviceTypePricingType: serviceType['pricing_type'] ?? '',
        serviceTypeRequiresWeight: serviceType['requires_weight'] ?? false,
        serviceTypeSupportsPremium: serviceType['supports_premium'] ?? false,
        serviceName: json['service_name'] ?? '',
        articleName: article['name'] ?? '',
        articleDescription: article['description'] ?? '',
        basePrice: parseDouble(json['base_price']),
        premiumPrice: parseDouble(json['premium_price']),
        pricePerKg: parseDouble(json['price_per_kg']),
        isAvailable: json['is_available'] ?? false,
        articleId: json['article_id']?.toString() ?? '', // Ajouté
        serviceId:
            json['service_id']?.toString() ?? '', // Correction compatibilité
      );
    }).toList();
    setState(() {
      couples = mappedCouples;
      isLoading = false;
    });
    setState(() => isLoading = false);
  }

  void _openAddCoupleDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ServiceArticleCoupleDialog(),
    );
    if (result == true) {
      await _fetchCouples();
      _showSuccessSnackbar('Couple ajouté avec succès');
    }
  }

  void _openEditCoupleDialog(ArticleServiceCouple couple) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ServiceArticleCoupleDialog(editCouple: couple),
    );
    if (result == true) {
      await _fetchCouples();
      _showSuccessSnackbar('Couple modifié avec succès');
    }
  }

  void _deleteCouple(ArticleServiceCouple couple) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ce couple ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => isLoading = true);
    final success =
        await ArticleServiceCoupleService.deleteServiceArticleCouple(couple.id);
    if (success) {
      await _fetchCouples();
      _showSuccessSnackbar('Couple supprimé avec succès');
    } else {
      setState(() => isLoading = false);
      _showErrorSnackbar('Erreur lors de la suppression');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couples Service/Article'),
        actions: [
          GlassButton(
            label: 'Ajouter un couple',
            variant: GlassButtonVariant.primary,
            onPressed: _openAddCoupleDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView.builder(
                itemCount: couples.length,
                itemBuilder: (context, index) {
                  final couple = couples[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                              child: Text(couple.serviceTypeName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(couple.serviceName)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(couple.articleName)),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Service
                              Text('Service',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              SizedBox(height: 6),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Type : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: couple.serviceTypeName),
                              ])),
                              if (couple.serviceTypeDescription.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: 'Description : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: couple.serviceTypeDescription),
                                  ])),
                                ),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Tarification : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        couple.serviceTypePricingType.isNotEmpty
                                            ? couple.serviceTypePricingType
                                            : "Non renseigné"),
                              ])),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Service : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: couple.serviceName.isNotEmpty
                                        ? couple.serviceName
                                        : "Non renseigné"),
                              ])),
                              if (couple.serviceTypeRequiresWeight)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('Ce service nécessite le poids.',
                                      style: TextStyle(color: Colors.blueGrey)),
                                ),
                              if (couple.serviceTypeSupportsPremium)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('Ce service supporte le premium.',
                                      style: TextStyle(color: Colors.blueGrey)),
                                ),
                              SizedBox(height: 12),
                              // Section Article
                              Text('Article',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              SizedBox(height: 6),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Nom : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: couple.articleName.isNotEmpty
                                        ? couple.articleName
                                        : "Non renseigné"),
                              ])),
                              if (couple.articleDescription.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: 'Description : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: couple.articleDescription),
                                  ])),
                                ),
                              SizedBox(height: 12),
                              // Section Disponibilité
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Disponible : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: couple.isAvailable ? "Oui" : "Non"),
                              ])),
                              SizedBox(height: 12),
                              // Section Prix
                              Text('Prix',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              SizedBox(height: 6),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Base : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: couple.basePrice > 0
                                        ? '${couple.basePrice} FCFA'
                                        : 'Non renseigné'),
                              ])),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Premium : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: couple.premiumPrice > 0
                                        ? '${couple.premiumPrice} FCFA'
                                        : 'Non renseigné'),
                              ])),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Au kilo : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: couple.pricePerKg > 0
                                        ? '${couple.pricePerKg} FCFA'
                                        : 'Non renseigné'),
                              ])),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _openEditCoupleDialog(couple),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteCouple(couple),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// Modèle simplifié pour la table (à adapter selon le backend)
class ArticleServiceCouple {
  final String id;
  final String serviceTypeName;
  final String serviceTypeDescription;
  final String serviceTypePricingType;
  final bool serviceTypeRequiresWeight;
  final bool serviceTypeSupportsPremium;
  final String serviceName;
  final String articleName;
  final String articleDescription;
  final double basePrice;
  final double premiumPrice;
  final double pricePerKg;
  final bool isAvailable;
  final String articleId; // Ajouté
  final String serviceId; // Ajouté

  ArticleServiceCouple({
    required this.id,
    required this.serviceTypeName,
    required this.serviceTypeDescription,
    required this.serviceTypePricingType,
    required this.serviceTypeRequiresWeight,
    required this.serviceTypeSupportsPremium,
    required this.serviceName,
    required this.articleName,
    required this.articleDescription,
    required this.basePrice,
    required this.premiumPrice,
    required this.pricePerKg,
    required this.isAvailable,
    required this.articleId,
    required this.serviceId,
  });
}

// Dialog pour ajout/édition d'un couple service/article
class ServiceArticleCoupleDialog extends StatefulWidget {
  final ArticleServiceCouple? editCouple;
  const ServiceArticleCoupleDialog({Key? key, this.editCouple})
      : super(key: key);

  @override
  State<ServiceArticleCoupleDialog> createState() =>
      _ServiceArticleCoupleDialogState();
}

class _ServiceArticleCoupleDialogState
    extends State<ServiceArticleCoupleDialog> {
  // Notification standardisée (succès)
  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
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
      backgroundColor: Colors.green.withOpacity(0.85),
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

  // Notification standardisée (erreur)
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

  final _formKey = GlobalKey<FormState>();
  String? _selectedServiceTypeId;
  String? _selectedServiceId;
  String? _selectedArticleId;
  double? _basePrice;
  double? _premiumPrice;
  double? _pricePerKg;
  bool _isLoading = false;
  List<Service> _services = [];
  List<Service> _compatibleServices = [];
  List<Article> _articles = [];
  List<ServiceType> _serviceTypes = [];
  List<Article> _compatibleArticles = [];

  // Génère dynamiquement les champs selon le type de service sélectionné
  List<Widget> _buildDynamicFields() {
    final selectedType = _serviceTypes.firstWhere(
      (t) => t.id == _selectedServiceTypeId,
      orElse: () => ServiceType(id: '', name: ''),
    );
    List<Widget> fields = [];
    // FIXED: prix base et premium, pas de prix/kg
    if (selectedType.pricingType == 'FIXED') {
      fields.add(TextFormField(
        initialValue: _basePrice?.toString(),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Prix base'),
        validator: (v) =>
            (v == null || double.tryParse(v) == null || double.parse(v) < 0)
                ? 'Prix invalide'
                : null,
        onSaved: (v) => _basePrice = double.tryParse(v ?? ''),
      ));
      fields.add(const SizedBox(height: 12));
      if (selectedType.supportsPremium == true) {
        fields.add(TextFormField(
          initialValue: _premiumPrice?.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Prix premium'),
          validator: (v) =>
              (v == null || double.tryParse(v) == null || double.parse(v) < 0)
                  ? 'Prix invalide'
                  : null,
          onSaved: (v) => _premiumPrice = double.tryParse(v ?? ''),
        ));
        fields.add(const SizedBox(height: 12));
      }
    }
    // WEIGHT_BASED: uniquement prix/kg
    else if (selectedType.pricingType == 'WEIGHT_BASED') {
      fields.add(TextFormField(
        initialValue: _pricePerKg?.toString(),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Prix/kg'),
        validator: (v) =>
            (v == null || double.tryParse(v) == null || double.parse(v) < 0)
                ? 'Prix invalide'
                : null,
        onSaved: (v) => _pricePerKg = double.tryParse(v ?? ''),
      ));
      fields.add(const SizedBox(height: 12));
    }
    // SUBSCRIPTION/CUSTOM: champs abonnement à compléter
    else if (selectedType.pricingType == 'SUBSCRIPTION' ||
        selectedType.pricingType == 'CUSTOM') {
      fields.add(const Text('Champs abonnement à ajouter ici'));
      fields.add(const SizedBox(height: 12));
    }
    return fields;
  }

  @override
  void initState() {
    super.initState();
    _fetchDropdowns();
    if (widget.editCouple != null) {
      _basePrice = widget.editCouple!.basePrice;
      _premiumPrice = widget.editCouple!.premiumPrice;
      _pricePerKg = widget.editCouple!.pricePerKg;
      // Les IDs ne sont pas dans le modèle simplifié, donc on laisse vide (à adapter si besoin)
    }
  }

  Future<void> _fetchDropdowns() async {
    setState(() => _isLoading = true);
    try {
      final articles = await ArticleService.getAllArticles();
      final serviceTypesRaw = await ServiceTypeService.getAllServiceTypes();
      // Filtrer pour n'afficher que les services types actifs dans le dropdown
      final serviceTypes =
          serviceTypesRaw.where((t) => t.isActive == true).toList();
      final servicesRaw = await ServiceService.getAllServices();
      setState(() {
        _articles = articles;
        _serviceTypes = serviceTypes;
        _services = servicesRaw;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final selectedType = _serviceTypes.firstWhere(
      (t) => t.id == _selectedServiceTypeId,
      orElse: () => ServiceType(id: '', name: ''),
    );
    // Validation avancée
    if (selectedType.requiresWeight == true &&
        (_pricePerKg == null || _pricePerKg! <= 0)) {
      _showErrorSnackbar(
          'Le prix au kilo est obligatoire pour ce type de service.');
      return;
    }
    if (selectedType.supportsPremium == true &&
        (_premiumPrice == null || _premiumPrice! <= 0)) {
      _showErrorSnackbar(
          'Le prix premium est obligatoire pour ce type de service.');
      return;
    }
    if (_basePrice == null || _basePrice! <= 0) {
      _showErrorSnackbar('Le prix de base est obligatoire.');
      return;
    }
    setState(() => _isLoading = true);
    final data = {
      'service_type_id': _selectedServiceTypeId,
      'article_id': _selectedArticleId,
      'base_price': _basePrice,
      'premium_price': _premiumPrice,
      'price_per_kg': _pricePerKg,
      'is_available': true,
    };
    bool success = false;
    try {
      if (widget.editCouple == null) {
        success =
            await ArticleServiceCoupleService.addServiceArticleCouple(data);
      } else {
        success = await ArticleServiceCoupleService.updateServiceArticleCouple(
            widget.editCouple!.id, data);
      }
    } catch (e) {
      _showErrorSnackbar('Erreur technique: ${e.toString()}');
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      _showSuccessSnackbar(widget.editCouple == null
          ? 'Couple ajouté avec succès'
          : 'Couple modifié avec succès');
    } else {
      _showErrorSnackbar('Erreur lors de l\'enregistrement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editCouple == null
          ? 'Ajouter un couple'
          : 'Modifier le couple'),
      content: _isLoading
          ? const SizedBox(
              height: 120, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedServiceTypeId,
                        items: _serviceTypes
                            .map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.name),
                                ))
                            .toList(),
                        onChanged: (v) async {
                          setState(() {
                            _selectedServiceTypeId = v;
                            _selectedServiceId = null;
                            _selectedArticleId = null;
                            _compatibleServices = [];
                            _compatibleArticles = [];
                          });
                          if (v != null) {
                            final compatibleServices =
                                _services.where((s) => s.typeId == v).toList();
                            print(
                                '--- DEBUG: compatibleServices for ServiceTypeId=$v ---');
                            for (var s in compatibleServices) {
                              print(
                                  '  id: ${s.id}, name: ${s.name}, typeId: ${s.typeId}');
                            }
                            setState(() {
                              _compatibleServices = compatibleServices;
                            });
                          }
                        },
                        validator: (v) => v == null
                            ? 'Sélectionnez un type de service'
                            : null,
                        decoration:
                            const InputDecoration(labelText: 'Type de service'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedServiceId,
                        items: (_compatibleServices.isNotEmpty
                                ? _compatibleServices
                                : _services)
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.name),
                                ))
                            .toList(),
                        onChanged: (v) async {
                          setState(() {
                            _selectedServiceId = v;
                            _selectedArticleId = null;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Sélectionnez un service' : null,
                        decoration: const InputDecoration(labelText: 'Service'),
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final selectedType = _serviceTypes.firstWhere(
                            (t) => t.id == _selectedServiceTypeId,
                            orElse: () => ServiceType(id: '', name: ''),
                          );
                          if (selectedType.pricingType == 'FIXED') {
                            // Afficher tous les articles disponibles
                            return DropdownButtonFormField<String>(
                              value: _selectedArticleId,
                              items: _articles
                                  .map((a) => DropdownMenuItem(
                                        value: a.id,
                                        child: Text(a.name),
                                      ))
                                  .toList(),
                              onChanged: (v) async {
                                setState(() => _selectedArticleId = v);
                                if (_selectedServiceTypeId != null &&
                                    _selectedServiceId != null &&
                                    v != null) {
                                  try {
                                    final prices =
                                        await ArticleServiceCoupleService
                                            .getPricesForCouple(
                                      serviceTypeId: _selectedServiceTypeId!,
                                      serviceId: _selectedServiceId!,
                                      articleId: v,
                                    );
                                    setState(() {
                                      _basePrice =
                                          prices['basePrice']?.toDouble();
                                      _premiumPrice =
                                          prices['premiumPrice']?.toDouble();
                                      _pricePerKg =
                                          prices['pricePerKg']?.toDouble();
                                    });
                                  } catch (e) {
                                    _showErrorSnackbar(
                                        'Erreur lors de la récupération des prix');
                                  }
                                }
                              },
                              validator: (v) =>
                                  v == null ? 'Sélectionnez un article' : null,
                              decoration:
                                  const InputDecoration(labelText: 'Article'),
                            );
                          } else if (selectedType.pricingType ==
                              'WEIGHT_BASED') {
                            // Afficher uniquement le champ poids, masquer articles
                            return const Text(
                                'Ce service est tarifé au poids. Aucun article à sélectionner.');
                          } else if (selectedType.pricingType == 'CUSTOM' ||
                              selectedType.pricingType == 'SUBSCRIPTION') {
                            // Afficher infos abonnement, masquer articles
                            return const Text(
                                'Ce service est lié à un abonnement.');
                          } else {
                            // Cas par défaut
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_selectedServiceTypeId != null)
                        ..._buildDynamicFields(),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        GlassButton(
          label: widget.editCouple == null ? 'Ajouter' : 'Enregistrer',
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}

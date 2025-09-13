import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../models/service_type.dart';
import '../../models/article.dart';
import '../../models/service.dart';
import '../../services/article_service.dart';
import '../../services/service_type_service.dart';
import '../../services/article_service_couple_service.dart';
import '../../services/service_service.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import 'components/couple_stats_grid.dart';
import 'components/couple_table.dart';
import 'components/couple_filters.dart';

class ServiceArticleCouplesScreen extends StatefulWidget {
  const ServiceArticleCouplesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceArticleCouplesScreen> createState() =>
      _ServiceArticleCouplesScreenState();
}

class _ServiceArticleCouplesScreenState
    extends State<ServiceArticleCouplesScreen> {
  List<ArticleServiceCouple> couples = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCouples();
  }

  Future<void> _fetchCouples() async {
    setState(() => isLoading = true);
    try {
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

        return ArticleServiceCouple(
          id: json['id']?.toString() ?? '',
          serviceTypeName: json['service_type_name'] ?? '',
          serviceTypeDescription: json['service_type_description'] ?? '',
          serviceTypePricingType: json['service_type_pricing_type'] ?? '',
          serviceTypeRequiresWeight:
              json['service_type_requires_weight'] ?? false,
          serviceTypeSupportsPremium:
              json['service_type_supports_premium'] ?? false,
          serviceName: json['service_name'] ?? '',
          articleName: json['article_name'] ?? '',
          articleDescription: json['article_description'] ?? '',
          basePrice: parseDouble(json['base_price']),
          premiumPrice: parseDouble(json['premium_price']),
          pricePerKg: parseDouble(json['price_per_kg']),
          isAvailable: json['is_available'] ?? false,
          articleId: json['article_id']?.toString() ?? '',
          serviceId: json['service_id']?.toString() ?? '',
        );
      }).toList();
      setState(() {
        couples = mappedCouples;
      });
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des couples');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              SizedBox(height: AppSpacing.lg),

              // Statistiques
              CoupleStatsGrid(
                totalCouples: couples.length,
                availableCouples: couples.where((c) => c.isAvailable).length,
                fixedPriceCouples: couples.where((c) => c.serviceTypePricingType == 'FIXED').length,
                weightBasedCouples: couples.where((c) => c.serviceTypePricingType == 'WEIGHT_BASED').length,
              ),
              SizedBox(height: AppSpacing.lg),

              // Filtres et recherche
              CoupleFilters(
                onSearchChanged: (query) {
                  // TODO: Implémenter la recherche
                },
                onServiceTypeChanged: (typeId) {
                  // TODO: Implémenter le filtre par type de service
                },
                onAvailabilityChanged: (available) {
                  // TODO: Implémenter le filtre par disponibilité
                },
                onClearFilters: () {
                  // TODO: Effacer les filtres
                },
              ),
              SizedBox(height: AppSpacing.md),

              // Table des couples
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Chargement des couples service/article...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : couples.isEmpty
                        ? _buildEmptyState(context, isDark)
                        : CoupleTable(
                            couples: couples,
                            onEdit: (couple) => _openEditCoupleDialog(couple),
                            onDelete: _showDeleteDialog,
                            onToggleAvailability: (couple) => _toggleAvailability(couple),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Couples Service/Article',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              isLoading
                  ? 'Chargement...'
                  : '${couples.length} couple${couples.length > 1 ? 's' : ''} • ${couples.where((c) => c.isAvailable).length} disponible${couples.where((c) => c.isAvailable).length > 1 ? 's' : ''}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Nouveau Couple',
              icon: Icons.add_link_outlined,
              variant: GlassButtonVariant.primary,
              onPressed: () => _openAddCoupleDialog(),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: _fetchCouples,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.link_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun couple service/article trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Créez des associations entre vos services et articles pour définir les tarifications',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Créer un couple',
            icon: Icons.add_link_outlined,
            variant: GlassButtonVariant.primary,
            onPressed: () => _openAddCoupleDialog(),
          ),
        ],
      ),
    );
  }

  void _openAddCoupleDialog() async {
    final result = await Get.dialog<bool>(
      ServiceArticleCoupleDialog(),
    );
    if (result == true) {
      await _fetchCouples();
      _showSuccessSnackbar('Couple ajouté avec succès');
    }
  }

  void _openEditCoupleDialog(ArticleServiceCouple couple) async {
    final result = await Get.dialog<bool>(
      ServiceArticleCoupleDialog(editCouple: couple),
    );
    if (result == true) {
      await _fetchCouples();
      _showSuccessSnackbar('Couple modifié avec succès');
    }
  }

  void _showDeleteDialog(ArticleServiceCouple couple) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: AppColors.warning),
              SizedBox(height: AppSpacing.md),
              Text(
                'Confirmer la suppression',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Êtes-vous sûr de vouloir supprimer ce couple service/article ?',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Supprimer',
                      variant: GlassButtonVariant.error,
                      onPressed: () async {
                        Get.back();
                        await _deleteCouple(couple);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCouple(ArticleServiceCouple couple) async {
    setState(() => isLoading = true);
    try {
      final success =
          await ArticleServiceCoupleService.deleteServiceArticleCouple(couple.id);
      if (success) {
        await _fetchCouples();
        _showSuccessSnackbar('Couple supprimé avec succès');
      } else {
        _showErrorSnackbar('Erreur lors de la suppression');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la suppression: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleAvailability(ArticleServiceCouple couple) async {
    // TODO: Implémenter le toggle de disponibilité
    _showSuccessSnackbar('Disponibilité modifiée');
  }

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
      backgroundColor: AppColors.success.withOpacity(0.85),
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
      backgroundColor: AppColors.error.withOpacity(0.85),
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
  final String articleId;
  final String serviceId;

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

  @override
  void initState() {
    super.initState();
    _fetchDropdowns();
    if (widget.editCouple != null) {
      _basePrice = widget.editCouple!.basePrice;
      _premiumPrice = widget.editCouple!.premiumPrice;
      _pricePerKg = widget.editCouple!.pricePerKg;
    }
  }

  Future<void> _fetchDropdowns() async {
    setState(() => _isLoading = true);
    try {
      final articles = await ArticleService.getAllArticles();
      final serviceTypesRaw = await ServiceTypeService.getAllServiceTypes();
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
    
    setState(() => _isLoading = true);
    final data = <String, dynamic>{
      'service_type_id': _selectedServiceTypeId,
      'service_id': _selectedServiceId,
      'article_id': _selectedArticleId,
      'is_available': true,
      'base_price': _basePrice ?? 0,
      'premium_price': _premiumPrice ?? 0,
      'price_per_kg': _pricePerKg ?? 0,
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
      setState(() => _isLoading = false);
      return;
    }
    
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.editCouple != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: GlassContainer(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec icône
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_outlined : Icons.add_link_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Modifier le couple' : 'Créer un couple service/article',
                                style: AppTextStyles.h3.copyWith(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isEdit 
                                    ? 'Modifiez l\'association entre le service et l\'article'
                                    : 'Associez un service à un article avec sa tarification',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Contenu scrollable
                    Flexible(
                      child: SingleChildScrollView(
                        child: _isLoading
                            ? Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(color: AppColors.primary),
                                    SizedBox(height: AppSpacing.md),
                                    Text('Chargement...'),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Service
                                  _buildSectionHeader('Configuration du Service', Icons.build_outlined, isDark),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedServiceTypeId,
                                          decoration: _inputDecoration('Type de service', isDark: isDark),
                                          dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                                          style: TextStyle(
                                            color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                          ),
                                          items: _serviceTypes
                                              .map((t) => DropdownMenuItem(
                                                    value: t.id,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.category, size: 16, color: AppColors.primary),
                                                        SizedBox(width: AppSpacing.xs),
                                                        Text(t.name),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (v) {
                                            setState(() {
                                              _selectedServiceTypeId = v;
                                              _selectedServiceId = null;
                                              _compatibleServices = _services
                                                  .where((s) => s.serviceTypeId == v)
                                                  .toList();
                                            });
                                          },
                                          validator: (v) => v == null
                                              ? 'Sélectionnez un type de service'
                                              : null,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedServiceId,
                                          decoration: _inputDecoration('Service', isDark: isDark),
                                          dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                                          style: TextStyle(
                                            color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                          ),
                                          items: (_compatibleServices.isNotEmpty
                                                  ? _compatibleServices
                                                  : _services)
                                              .map((s) => DropdownMenuItem(
                                                    value: s.id,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.cleaning_services, size: 16, color: AppColors.info),
                                                        SizedBox(width: AppSpacing.xs),
                                                        Expanded(child: Text(s.name)),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (v) {
                                            setState(() => _selectedServiceId = v);
                                          },
                                          validator: (v) => v == null || v.isEmpty
                                              ? 'Sélectionnez un service'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: AppSpacing.xl),
                                  
                                  // Section Article
                                  _buildSectionHeader('Sélection de l\'Article', Icons.inventory_2_outlined, isDark),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  DropdownButtonFormField<String>(
                                    value: _selectedArticleId,
                                    decoration: _inputDecoration('Article', isDark: isDark),
                                    dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                    ),
                                    items: _articles
                                        .map((a) => DropdownMenuItem(
                                              value: a.id,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.inventory, size: 16, color: AppColors.success),
                                                  SizedBox(width: AppSpacing.xs),
                                                  Expanded(child: Text(a.name)),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() => _selectedArticleId = v);
                                    },
                                    validator: (v) => v == null ? 'Sélectionnez un article' : null,
                                  ),
                                  
                                  SizedBox(height: AppSpacing.xl),
                                  
                                  // Section Tarification
                                  _buildSectionHeader('Tarification', Icons.monetization_on_outlined, isDark),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _basePrice?.toString(),
                                          decoration: _inputDecoration('Prix de base (FCFA)', 
                                              isDark: isDark, 
                                              prefixIcon: Icons.attach_money),
                                          keyboardType: TextInputType.number,
                                          onSaved: (v) => _basePrice = double.tryParse(v ?? '0') ?? 0,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _premiumPrice?.toString(),
                                          decoration: _inputDecoration('Prix premium (FCFA)', 
                                              isDark: isDark, 
                                              prefixIcon: Icons.star),
                                          keyboardType: TextInputType.number,
                                          onSaved: (v) => _premiumPrice = double.tryParse(v ?? '0') ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: AppSpacing.md),
                                  
                                  TextFormField(
                                    initialValue: _pricePerKg?.toString(),
                                    decoration: _inputDecoration('Prix au kilo (FCFA/kg)', 
                                        isDark: isDark, 
                                        prefixIcon: Icons.scale),
                                    keyboardType: TextInputType.number,
                                    onSaved: (v) => _pricePerKg = double.tryParse(v ?? '0') ?? 0,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GlassButton(
                          label: 'Annuler',
                          variant: GlassButtonVariant.secondary,
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                        ),
                        SizedBox(width: AppSpacing.md),
                        GlassButton(
                          label: isEdit ? 'Mettre à jour' : 'Créer le couple',
                          variant: GlassButtonVariant.primary,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: AppSpacing.md),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label,
      {bool isDark = false, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      labelStyle: TextStyle(
        color: isDark ? AppColors.gray300 : AppColors.gray700,
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.gray800.withOpacity(0.5)
          : AppColors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }
}

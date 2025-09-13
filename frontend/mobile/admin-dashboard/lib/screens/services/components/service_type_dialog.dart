import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../models/service_type.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../widgets/shared/glass_container.dart';

class ServiceTypeDialog extends StatefulWidget {
  final ServiceType? editType;
  const ServiceTypeDialog({Key? key, this.editType}) : super(key: key);

  @override
  State<ServiceTypeDialog> createState() => _ServiceTypeDialogState();
}

class _ServiceTypeDialogState extends State<ServiceTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _description;
  bool _requiresWeight = false;
  bool _supportsPremium = false;
  bool _isDefault = false;
  bool _isActive = true;
  String? _pricingType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editType != null) {
      _name = widget.editType!.name;
      _description = widget.editType!.description;
      _requiresWeight = widget.editType!.requiresWeight ?? false;
      _supportsPremium = widget.editType!.supportsPremium ?? false;
      _isDefault = widget.editType!.isDefault ?? false;
      _isActive = widget.editType!.isActive ?? true;
      _pricingType = widget.editType!.pricingType;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    final data = {
      'name': _name,
      'description': _description,
      'requires_weight': _requiresWeight,
      'supports_premium': _supportsPremium,
      'is_default': _isDefault,
      'is_active': _isActive,
      'pricing_type': _pricingType,
    };
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.editType != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: BoxConstraints(
          maxWidth: 600,
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
                            isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
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
                                isEdit ? 'Modifier le type de service' : 'Créer un type de service',
                                style: AppTextStyles.h3.copyWith(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isEdit 
                                    ? 'Modifiez les paramètres du type de service'
                                    : 'Définissez un nouveau type de service pour organiser vos offres',
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
                                    Text('Enregistrement en cours...'),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Informations générales
                                  _buildSectionHeader('Informations générales', Icons.info_outline, isDark),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  TextFormField(
                                    initialValue: _name,
                                    decoration: _inputDecoration('Nom du type de service', isDark: isDark),
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? 'Nom obligatoire'
                                        : null,
                                    onSaved: (v) => _name = v?.trim(),
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  TextFormField(
                                    initialValue: _description,
                                    decoration: _inputDecoration('Description (optionnelle)', isDark: isDark),
                                    maxLines: 2,
                                    onSaved: (v) => _description = v?.trim(),
                                  ),
                                  
                                  SizedBox(height: AppSpacing.xl),
                                  
                                  // Section Tarification
                                  _buildSectionHeader('Configuration de tarification', Icons.monetization_on_outlined, isDark),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  DropdownButtonFormField<String>(
                                    value: _pricingType,
                                    decoration: _inputDecoration('Type de tarification', isDark: isDark),
                                    dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'FIXED',
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_money, size: 16, color: AppColors.success),
                                            SizedBox(width: AppSpacing.xs),
                                            Text('Prix fixe'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'WEIGHT_BASED',
                                        child: Row(
                                          children: [
                                            Icon(Icons.scale, size: 16, color: AppColors.warning),
                                            SizedBox(width: AppSpacing.xs),
                                            Text('Basé sur le poids'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'SUBSCRIPTION',
                                        child: Row(
                                          children: [
                                            Icon(Icons.subscriptions, size: 16, color: AppColors.info),
                                            SizedBox(width: AppSpacing.xs),
                                            Text('Abonnement'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'CUSTOM',
                                        child: Row(
                                          children: [
                                            Icon(Icons.tune, size: 16, color: AppColors.violet),
                                            SizedBox(width: AppSpacing.xs),
                                            Text('Personnalisé'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) => setState(() => _pricingType = v),
                                    validator: (v) => v == null
                                        ? 'Type de tarification obligatoire'
                                        : null,
                                  ),
                                  
                                  SizedBox(height: AppSpacing.xl),
                                  
                                  // Section Caractéristiques
                                  _buildSectionHeader('Caractéristiques', Icons.settings_outlined, isDark),
                                  SizedBox(height: AppSpacing.md),
                                  
                                  _buildSwitchTile(
                                    'Nécessite le poids',
                                    'Ce type de service nécessite la saisie du poids',
                                    Icons.scale,
                                    _requiresWeight,
                                    (v) => setState(() => _requiresWeight = v),
                                    isDark,
                                  ),
                                  
                                  _buildSwitchTile(
                                    'Supporte le premium',
                                    'Ce type de service propose une option premium',
                                    Icons.star,
                                    _supportsPremium,
                                    (v) => setState(() => _supportsPremium = v),
                                    isDark,
                                  ),
                                  
                                  _buildSwitchTile(
                                    'Type par défaut',
                                    'Ce type sera sélectionné par défaut',
                                    Icons.flag,
                                    _isDefault,
                                    (v) => setState(() => _isDefault = v),
                                    isDark,
                                  ),
                                  
                                  _buildSwitchTile(
                                    'Actif',
                                    'Ce type de service est disponible',
                                    Icons.toggle_on,
                                    _isActive,
                                    (v) => setState(() => _isActive = v),
                                    isDark,
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
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: AppSpacing.md),
                        GlassButton(
                          label: isEdit ? 'Mettre à jour' : 'Créer le type',
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.3)
            : AppColors.white.withOpacity(0.5),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: value
              ? AppColors.primary.withOpacity(0.3)
              : isDark
                  ? AppColors.gray700.withOpacity(0.3)
                  : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.gray500.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              icon,
              size: 16,
              color: value ? AppColors.primary : AppColors.gray500,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {bool isDark = false}) {
    return InputDecoration(
      labelText: label,
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

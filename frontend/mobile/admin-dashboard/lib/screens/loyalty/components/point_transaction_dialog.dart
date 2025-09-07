import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/loyalty.dart';
import '../../../widgets/shared/glass_button.dart';

class PointTransactionDialog extends StatefulWidget {
  final Function(
          String userId, int points, PointSource source, String referenceId)
      onAddPoints;
  final Function(
          String userId, int points, PointSource source, String referenceId)
      onDeductPoints;

  const PointTransactionDialog({
    Key? key,
    required this.onAddPoints,
    required this.onDeductPoints,
  }) : super(key: key);

  @override
  State<PointTransactionDialog> createState() => _PointTransactionDialogState();
}

class _PointTransactionDialogState extends State<PointTransactionDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _userIdController = TextEditingController();
  final _pointsController = TextEditingController();
  final _referenceController = TextEditingController();
  PointSource _selectedSource = PointSource.REWARD;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userIdController.dispose();
    _pointsController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.swap_horiz_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Gestion des Points',
                    style: AppTextStyles.h3,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(
                  color: isDark
                      ? AppColors.gray700.withOpacity(0.3)
                      : AppColors.gray200.withOpacity(0.5),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMD,
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor:
                    isDark ? AppColors.gray300 : AppColors.textSecondary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Ajouter'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_circle_outline, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Déduire'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAddPointsForm(context, isDark),
                    _buildDeductPointsForm(context, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPointsForm(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.success,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Ajoutez des points au compte d\'un utilisateur',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // User ID field
          TextFormField(
            controller: _userIdController,
            decoration: InputDecoration(
              labelText: 'ID Utilisateur *',
              hintText: 'Entrez l\'ID de l\'utilisateur',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'L\'ID utilisateur est requis';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Points field
          TextFormField(
            controller: _pointsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nombre de Points *',
              hintText: 'Ex: 100',
              prefixIcon: Icon(Icons.stars_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nombre de points est requis';
              }
              final points = int.tryParse(value);
              if (points == null || points <= 0) {
                return 'Veuillez entrer un nombre valide';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Source dropdown
          DropdownButtonFormField<PointSource>(
            value: _selectedSource,
            decoration: InputDecoration(
              labelText: 'Source *',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
            items: PointSource.values
                .map((source) => DropdownMenuItem(
                      value: source,
                      child: Row(
                        children: [
                          Icon(source.icon, size: 16, color: source.color),
                          SizedBox(width: AppSpacing.sm),
                          Text(_getSourceLabel(source)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSource = value!;
              });
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Reference field
          TextFormField(
            controller: _referenceController,
            decoration: InputDecoration(
              labelText: 'Référence (optionnel)',
              hintText: 'ID de commande, code promo, etc.',
              prefixIcon: Icon(Icons.tag_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Actions
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
                  label: 'Ajouter Points',
                  icon: Icons.add_circle_outline,
                  variant: GlassButtonVariant.success,
                  onPressed: _handleAddPoints,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeductPointsForm(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning card
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Attention: Cette action déduira des points du compte utilisateur',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // User ID field
          TextFormField(
            controller: _userIdController,
            decoration: InputDecoration(
              labelText: 'ID Utilisateur *',
              hintText: 'Entrez l\'ID de l\'utilisateur',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'L\'ID utilisateur est requis';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Points field
          TextFormField(
            controller: _pointsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nombre de Points à Déduire *',
              hintText: 'Ex: 50',
              prefixIcon: Icon(Icons.remove_circle_outline),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nombre de points est requis';
              }
              final points = int.tryParse(value);
              if (points == null || points <= 0) {
                return 'Veuillez entrer un nombre valide';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Source dropdown
          DropdownButtonFormField<PointSource>(
            value: _selectedSource,
            decoration: InputDecoration(
              labelText: 'Source *',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
            items: PointSource.values
                .map((source) => DropdownMenuItem(
                      value: source,
                      child: Row(
                        children: [
                          Icon(source.icon, size: 16, color: source.color),
                          SizedBox(width: AppSpacing.sm),
                          Text(_getSourceLabel(source)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSource = value!;
              });
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Reference field
          TextFormField(
            controller: _referenceController,
            decoration: InputDecoration(
              labelText: 'Référence (optionnel)',
              hintText: 'ID de récompense, motif, etc.',
              prefixIcon: Icon(Icons.tag_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Actions
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
                  label: 'Déduire Points',
                  icon: Icons.remove_circle_outline,
                  variant: GlassButtonVariant.warning,
                  onPressed: _handleDeductPoints,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSourceLabel(PointSource source) {
    switch (source) {
      case PointSource.ORDER:
        return 'Commande';
      case PointSource.REFERRAL:
        return 'Parrainage';
      case PointSource.REWARD:
        return 'Récompense';
    }
  }

  void _handleAddPoints() {
    if (_formKey.currentState!.validate()) {
      final userId = _userIdController.text.trim();
      final points = int.parse(_pointsController.text);
      final reference = _referenceController.text.isNotEmpty
          ? _referenceController.text.trim()
          : 'MANUAL_ADD_${DateTime.now().millisecondsSinceEpoch}';

      widget.onAddPoints(userId, points, _selectedSource, reference);
      Get.back();
    }
  }

  void _handleDeductPoints() {
    if (_formKey.currentState!.validate()) {
      // Confirmation dialog for deduction
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.warning),
              SizedBox(width: AppSpacing.sm),
              Text('Confirmer la Déduction'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Êtes-vous sûr de vouloir déduire ces points ?'),
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Utilisateur: ${_userIdController.text}'),
                    Text('Points à déduire: ${_pointsController.text}'),
                    Text('Source: ${_getSourceLabel(_selectedSource)}'),
                    if (_referenceController.text.isNotEmpty)
                      Text('Référence: ${_referenceController.text}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final userId = _userIdController.text.trim();
                final points = int.parse(_pointsController.text);
                final reference = _referenceController.text.isNotEmpty
                    ? _referenceController.text.trim()
                    : 'MANUAL_DEDUCT_${DateTime.now().millisecondsSinceEpoch}';

                widget.onDeductPoints(
                    userId, points, _selectedSource, reference);
                Get.back(); // Close confirmation dialog
                Get.back(); // Close main dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: Text('Confirmer'),
            ),
          ],
        ),
      );
    }
  }
}

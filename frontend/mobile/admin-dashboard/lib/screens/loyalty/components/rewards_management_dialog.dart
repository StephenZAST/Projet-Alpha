import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/loyalty.dart';
import '../../../widgets/shared/glass_button.dart';

class RewardsManagementDialog extends StatefulWidget {
  final RxList<Reward> rewards;
  final Function(String name, String description, int pointsCost, RewardType type,
      double? discountValue, String? discountType, int? maxRedemptions) onCreateReward;
  final Function(String rewardId, String? name, String? description, int? pointsCost,
      RewardType? type, double? discountValue, String? discountType, bool? isActive,
      int? maxRedemptions) onUpdateReward;
  final Function(String rewardId) onDeleteReward;

  const RewardsManagementDialog({
    Key? key,
    required this.rewards,
    required this.onCreateReward,
    required this.onUpdateReward,
    required this.onDeleteReward,
  }) : super(key: key);

  @override
  State<RewardsManagementDialog> createState() => _RewardsManagementDialogState();
}

class _RewardsManagementDialogState extends State<RewardsManagementDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  RewardType? _filterType;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.card_giftcard_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Gestion des Récompenses',
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
                color: isDark
                    ? AppColors.gray800.withOpacity(0.5)
                    : Colors.white.withOpacity(0.8),
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
                        Icon(Icons.list_outlined, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Liste des Récompenses'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Créer Récompense'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRewardsList(context, isDark),
                  _buildCreateRewardForm(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Filters
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une récompense...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<RewardType>(
                value: _filterType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Tous les types'),
                  ),
                  ...RewardType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 16, color: type.color),
                            SizedBox(width: AppSpacing.xs),
                            Text(_getRewardTypeLabel(type)),
                          ],
                        ),
                      )),
                ],
                onChanged: (value) => setState(() => _filterType = value),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            GlassButton(
              label: _showActiveOnly ? 'Actives' : 'Toutes',
              icon: _showActiveOnly ? Icons.visibility : Icons.visibility_off,
              variant: _showActiveOnly
                  ? GlassButtonVariant.success
                  : GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () => setState(() => _showActiveOnly = !_showActiveOnly),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Rewards list
        Expanded(
          child: Obx(() {
            final filteredRewards = _getFilteredRewards();

            if (filteredRewards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_giftcard_outlined,
                      size: 64,
                      color: AppColors.gray400,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Aucune récompense trouvée',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredRewards.length,
              itemBuilder: (context, index) {
                final reward = filteredRewards[index];
                return _buildRewardCard(context, isDark, reward);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRewardCard(BuildContext context, bool isDark, Reward reward) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reward.type.color.withOpacity(0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Icon(
                reward.type.icon,
                color: reward.type.color,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reward.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: reward.isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Text(
                          reward.isActive ? 'Active' : 'Inactive',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: reward.isActive
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    reward.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Text(
                          reward.formattedPointsCost,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (reward.formattedDiscountValue.isNotEmpty) ...[
                        SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Text(
                            reward.formattedDiscountValue,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      Spacer(),
                      Text(
                        reward.availabilityText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditRewardDialog(context, reward);
                    break;
                  case 'toggle':
                    widget.onUpdateReward(
                      reward.id,
                      null,
                      null,
                      null,
                      null,
                      null,
                      null,
                      !reward.isActive,
                      null,
                    );
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, reward);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.info),
                      SizedBox(width: AppSpacing.sm),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        reward.isActive ? Icons.visibility_off : Icons.visibility,
                        color: reward.isActive ? AppColors.warning : AppColors.success,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(reward.isActive ? 'Désactiver' : 'Activer'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRewardForm(BuildContext context, bool isDark) {
    return _RewardForm(
      onSubmit: (name, description, pointsCost, type, discountValue, discountType, maxRedemptions) {
        widget.onCreateReward(name, description, pointsCost, type, discountValue, discountType, maxRedemptions);
        _tabController.animateTo(0); // Switch back to list tab
      },
    );
  }

  List<Reward> _getFilteredRewards() {
    var filtered = widget.rewards.toList();

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((reward) =>
          reward.name.toLowerCase().contains(query) ||
          reward.description.toLowerCase().contains(query)).toList();
    }

    // Filter by type
    if (_filterType != null) {
      filtered = filtered.where((reward) => reward.type == _filterType).toList();
    }

    // Filter by active status
    if (_showActiveOnly) {
      filtered = filtered.where((reward) => reward.isActive).toList();
    }

    return filtered;
  }

  String _getRewardTypeLabel(RewardType type) {
    switch (type) {
      case RewardType.DISCOUNT:
        return 'Remise';
      case RewardType.FREE_DELIVERY:
        return 'Livraison gratuite';
      case RewardType.CASHBACK:
        return 'Cashback';
      case RewardType.GIFT:
        return 'Cadeau';
    }
  }

  void _showEditRewardDialog(BuildContext context, Reward reward) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: AppColors.info),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Modifier la Récompense',
                      style: AppTextStyles.h4,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _RewardForm(
                  reward: reward,
                  onSubmit: (name, description, pointsCost, type, discountValue, discountType, maxRedemptions) {
                    widget.onUpdateReward(
                      reward.id,
                      name,
                      description,
                      pointsCost,
                      type,
                      discountValue,
                      discountType,
                      null, // Don't change active status here
                      maxRedemptions,
                    );
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Reward reward) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Supprimer la Récompense'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer cette récompense ?'),
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
                  Text(
                    reward.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(reward.description),
                  Text('Coût: ${reward.formattedPointsCost}'),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Cette action est irréversible.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
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
              widget.onDeleteReward(reward.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _RewardForm extends StatefulWidget {
  final Reward? reward;
  final Function(String name, String description, int pointsCost, RewardType type,
      double? discountValue, String? discountType, int? maxRedemptions) onSubmit;

  const _RewardForm({
    Key? key,
    this.reward,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<_RewardForm> createState() => _RewardFormState();
}

class _RewardFormState extends State<_RewardForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsCostController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _maxRedemptionsController;
  late RewardType _selectedType;
  String? _discountType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reward?.name ?? '');
    _descriptionController = TextEditingController(text: widget.reward?.description ?? '');
    _pointsCostController = TextEditingController(text: widget.reward?.pointsCost.toString() ?? '');
    _discountValueController = TextEditingController(text: widget.reward?.discountValue?.toString() ?? '');
    _maxRedemptionsController = TextEditingController(text: widget.reward?.maxRedemptions?.toString() ?? '');
    _selectedType = widget.reward?.type ?? RewardType.DISCOUNT;
    _discountType = widget.reward?.discountType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsCostController.dispose();
    _discountValueController.dispose();
    _maxRedemptionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom de la récompense *',
                hintText: 'Ex: Remise de 10%',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Décrivez la récompense...',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Points cost field
            TextFormField(
              controller: _pointsCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Coût en points *',
                hintText: 'Ex: 100',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le coût en points est requis';
                }
                final points = int.tryParse(value);
                if (points == null || points <= 0) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Type dropdown
            DropdownButtonFormField<RewardType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Type de récompense *',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                ),
              ),
              items: RewardType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(type.icon, size: 16, color: type.color),
                    SizedBox(width: AppSpacing.sm),
                    Text(_getRewardTypeLabel(type)),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  // Reset discount fields when type changes
                  if (value != RewardType.DISCOUNT && value != RewardType.CASHBACK) {
                    _discountValueController.clear();
                    _discountType = null;
                  }
                });
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Discount fields (only for DISCOUNT and CASHBACK types)
            if (_selectedType == RewardType.DISCOUNT || _selectedType == RewardType.CASHBACK) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Valeur de la remise',
                        hintText: 'Ex: 10',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null || discount <= 0) {
                            return 'Valeur invalide';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _discountType,
                      decoration: InputDecoration(
                        labelText: 'Type de remise',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusSM,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Sélectionner...'),
                        ),
                        DropdownMenuItem(
                          value: 'PERCENTAGE',
                          child: Text('Pourcentage (%)'),
                        ),
                        DropdownMenuItem(
                          value: 'FIXED',
                          child: Text('Montant fixe (FCFA)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _discountType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
            ],

            // Max redemptions field
            TextFormField(
              controller: _maxRedemptionsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nombre maximum d\'échanges (optionnel)',
                hintText: 'Laissez vide pour illimité',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final max = int.tryParse(value);
                  if (max == null || max <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                }
                return null;
              },
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
                    label: widget.reward != null ? 'Modifier' : 'Créer',
                    icon: widget.reward != null ? Icons.edit : Icons.add,
                    variant: GlassButtonVariant.primary,
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRewardTypeLabel(RewardType type) {
    switch (type) {
      case RewardType.DISCOUNT:
        return 'Remise';
      case RewardType.FREE_DELIVERY:
        return 'Livraison gratuite';
      case RewardType.CASHBACK:
        return 'Cashback';
      case RewardType.GIFT:
        return 'Cadeau';
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final pointsCost = int.parse(_pointsCostController.text);
      final discountValue = _discountValueController.text.isNotEmpty
          ? double.parse(_discountValueController.text)
          : null;
      final maxRedemptions = _maxRedemptionsController.text.isNotEmpty
          ? int.parse(_maxRedemptionsController.text)
          : null;

      widget.onSubmit(
        name,
        description,
        pointsCost,
        _selectedType,
        discountValue,
        _discountType,
        maxRedemptions,
      );
    }
  }
}
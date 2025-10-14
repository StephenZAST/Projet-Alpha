import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../components/glass_components.dart';
import '../../../../shared/providers/order_draft_provider.dart';

/// 📋 Étape d'Informations Complémentaires - Alpha Client App
///
/// Quatrième étape du workflow : dates, notes et options avancées.
/// Interface optimisée pour mobile avec sélecteurs de dates.
class OrderInfoStep extends StatefulWidget {
  const OrderInfoStep({Key? key}) : super(key: key);

  @override
  State<OrderInfoStep> createState() => _OrderInfoStepState();
}

class _OrderInfoStepState extends State<OrderInfoStep> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _noteController = TextEditingController();
  DateTime? _collectionDate;
  DateTime? _deliveryDate;
  String _paymentMethod = 'CASH';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadExistingData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeIn,
    ));

    _fadeController.forward();
  }

  void _loadExistingData() {
    final provider = Provider.of<OrderDraftProvider>(context, listen: false);
    final draft = provider.orderDraft;
    
    _noteController.text = draft.note ?? '';
    
    // Dates par défaut si non définies
    _collectionDate = draft.collectionDate ?? DateTime.now().add(const Duration(days: 1));
    _deliveryDate = draft.deliveryDate ?? DateTime.now().add(const Duration(days: 3));
    
    _paymentMethod = draft.paymentMethod ?? 'CASH';
    
    // Mettre à jour le draft avec les dates par défaut
    if (draft.collectionDate == null) {
      provider.orderDraft.collectionDate = _collectionDate;
    }
    if (draft.deliveryDate == null) {
      provider.orderDraft.deliveryDate = _deliveryDate;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDraftProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context),
                const SizedBox(height: 24),
                
                // Dates de collecte et livraison
                _buildDatesSection(context, provider),
                const SizedBox(height: 24),
                
                // Méthode de paiement
                _buildPaymentSection(context, provider),
                const SizedBox(height: 24),
                
                // Notes
                _buildNotesSection(context, provider),
                const SizedBox(height: 24),
                
                // Options avancées
                _buildAdvancedOptionsSection(context, provider),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📋 En-tête de l'étape
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations Complémentaires',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personnalisez votre commande avec des dates spécifiques et des notes.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 📅 Section des dates
  Widget _buildDatesSection(BuildContext context, OrderDraftProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Dates de Service',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date de collecte
          _buildDateSelector(
            context,
            'Date de Collecte',
            'Quand souhaitez-vous que nous récupérions vos articles ?',
            _collectionDate,
            Icons.schedule,
            AppColors.info,
            (date) {
              setState(() {
                _collectionDate = date;
              });
              provider.orderDraft.collectionDate = date;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Date de livraison
          _buildDateSelector(
            context,
            'Date de Livraison',
            'Quand souhaitez-vous recevoir vos articles ?',
            _deliveryDate,
            Icons.local_shipping_outlined,
            AppColors.success,
            (date) {
              setState(() {
                _deliveryDate = date;
              });
              provider.orderDraft.deliveryDate = date;
            },
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Si aucune date n\'est spécifiée, nous utiliserons nos créneaux standards.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📅 Sélecteur de date
  Widget _buildDateSelector(
    BuildContext context,
    String title,
    String subtitle,
    DateTime? selectedDate,
    IconData icon,
    Color color,
    Function(DateTime?) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context, selectedDate, onDateSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedDate != null ? color : AppColors.border(context),
            width: selectedDate != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selectedDate != null
                          ? color
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selectedDate != null ? Icons.event : Icons.calendar_today,
              color: selectedDate != null ? color : AppColors.textSecondary(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 💳 Section méthode de paiement
  Widget _buildPaymentSection(BuildContext context, OrderDraftProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment_outlined,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Méthode de Paiement',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Options de paiement
          _buildPaymentOption(
            context,
            'Espèces',
            'Paiement en espèces à la livraison',
            Icons.money,
            'CASH',
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            context,
            'Orange Money',
            'Paiement mobile sécurisé',
            Icons.phone_android,
            'ORANGE_MONEY',
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  /// 💳 Option de paiement
  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String value,
    Color color,
  ) {
    final isSelected = _paymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
        final provider = Provider.of<OrderDraftProvider>(context, listen: false);
        provider.orderDraft.paymentMethod = value;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : AppColors.textSecondary(context),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 📝 Section notes
  Widget _buildNotesSection(BuildContext context, OrderDraftProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Notes Spéciales',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Ajoutez des instructions spéciales pour votre commande...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant(context),
            ),
            onChanged: (value) {
              provider.orderDraft.note = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
    );
  }

  /// ⚙️ Section options avancées
  Widget _buildAdvancedOptionsSection(BuildContext context, OrderDraftProvider provider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppColors.purple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Options Avancées',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Commande récurrente
          _buildRecurringSection(context, provider),
          const SizedBox(height: 16),
          
          // Code affilié
          _buildAffiliateCodeSection(context, provider),
        ],
      ),
    );
  }

  /// 🔄 Section récurrence
  Widget _buildRecurringSection(BuildContext context, OrderDraftProvider provider) {
    final isRecurring = provider.orderDraft.recurrenceType != null && 
                        provider.orderDraft.recurrenceType != 'NONE';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle récurrence
        GestureDetector(
          onTap: () {
            setState(() {
              if (isRecurring) {
                provider.orderDraft.recurrenceType = 'NONE';
              } else {
                provider.orderDraft.recurrenceType = 'WEEKLY';
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRecurring 
                  ? AppColors.purple.withOpacity(0.1) 
                  : AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRecurring 
                    ? AppColors.purple 
                    : AppColors.border(context),
                width: isRecurring ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: isRecurring ? AppColors.purple : AppColors.textSecondary(context),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande Récurrente',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Répéter cette commande automatiquement',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isRecurring ? Icons.toggle_on : Icons.toggle_off,
                  color: isRecurring ? AppColors.purple : AppColors.textSecondary(context),
                  size: 40,
                ),
              ],
            ),
          ),
        ),
        
        // Options de récurrence
        if (isRecurring) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRecurrenceChip(context, provider, 'WEEKLY', 'Hebdomadaire'),
              _buildRecurrenceChip(context, provider, 'BIWEEKLY', 'Bi-hebdomadaire'),
              _buildRecurrenceChip(context, provider, 'MONTHLY', 'Mensuel'),
            ],
          ),
        ],
      ],
    );
  }

  /// 🏷️ Chip de récurrence
  Widget _buildRecurrenceChip(
    BuildContext context,
    OrderDraftProvider provider,
    String value,
    String label,
  ) {
    final isSelected = provider.orderDraft.recurrenceType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          provider.orderDraft.recurrenceType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.purple 
              : AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.purple 
                : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected 
                ? Colors.white 
                : AppColors.textPrimary(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 🎁 Section code affilié
  Widget _buildAffiliateCodeSection(BuildContext context, OrderDraftProvider provider) {
    final TextEditingController _affiliateController = TextEditingController(
      text: provider.orderDraft.affiliateCode ?? '',
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.card_giftcard,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Code Affilié',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _affiliateController,
          decoration: InputDecoration(
            hintText: 'Entrez un code affilié (optionnel)',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
            prefixIcon: Icon(
              Icons.loyalty,
              color: AppColors.warning,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.warning,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant(context),
          ),
          onChanged: (value) {
            provider.orderDraft.affiliateCode = value.isEmpty ? null : value;
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Utilisez le code d\'un affilié pour lui faire bénéficier d\'une commission.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📅 Sélectionner une date
  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  /// 📅 Formater une date
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/affiliate_provider.dart';
import '../widgets/glass_container.dart';

/// 💸 Écran Retrait - Alpha Affiliate App
///
/// Interface pour demander un retrait avec validation et confirmation

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isAmountValid = false;
  double _enteredAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final text = _amountController.text.replaceAll(' ', '');
    final amount = double.tryParse(text) ?? 0.0;
    
    setState(() {
      _enteredAmount = amount;
      _isAmountValid = amount >= AffiliateConfig.minWithdrawalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Demander un Retrait',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: Consumer<AffiliateProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(provider),
                  const SizedBox(height: 24),
                  _buildAmountSection(provider),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 💰 Carte du solde disponible
  Widget _buildBalanceCard(AffiliateProvider provider) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde Disponible',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatNumber(provider.availableBalance)} FCFA',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (!provider.canWithdraw) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusSM,
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Montant minimum requis: ${formatNumber(AffiliateConfig.minWithdrawalAmount)} FCFA',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 💵 Section montant
  Widget _buildAmountSection(AffiliateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant à retirer',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        GlassContainer(
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textTertiary(context),
                  ),
                  suffixText: 'FCFA',
                  suffixStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un montant';
                  }
                  
                  final amount = double.tryParse(value.replaceAll(' ', '')) ?? 0.0;
                  
                  if (amount < AffiliateConfig.minWithdrawalAmount) {
                    return 'Montant minimum: ${formatNumber(AffiliateConfig.minWithdrawalAmount)} FCFA';
                  }
                  
                  if (amount > provider.availableBalance) {
                    return 'Montant supérieur au solde disponible';
                  }
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Boutons de montant rapide
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAmountButton(
                      '25%',
                      provider.availableBalance * 0.25,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickAmountButton(
                      '50%',
                      provider.availableBalance * 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickAmountButton(
                      '75%',
                      provider.availableBalance * 0.75,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickAmountButton(
                      'Tout',
                      provider.availableBalance,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        if (_enteredAmount > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _isAmountValid ? Icons.check_circle : Icons.error,
                color: _isAmountValid ? AppColors.success : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isAmountValid 
                    ? 'Montant valide'
                    : 'Montant minimum: ${formatNumber(AffiliateConfig.minWithdrawalAmount)} FCFA',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _isAmountValid ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 📝 Section notes
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optionnel)',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        GlassContainer(
          child: TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'Informations supplémentaires pour le retrait...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary(context),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  /// ℹ️ Section informations
  Widget _buildInfoSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations importantes',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildInfoItem(
            'Montant minimum: ${formatNumber(AffiliateConfig.minWithdrawalAmount)} FCFA',
          ),
          _buildInfoItem(
            'Délai de traitement: 1-3 jours ouvrables',
          ),
          _buildInfoItem(
            'Cooldown entre retraits: ${AffiliateConfig.withdrawalCooldownDays} jours',
          ),
          _buildInfoItem(
            'Les retraits sont traités du lundi au vendredi',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Bouton de montant rapide
  Widget _buildQuickAmountButton(String label, double amount) {
    final isEnabled = amount >= AffiliateConfig.minWithdrawalAmount;
    
    return GestureDetector(
      onTap: isEnabled ? () {
        _amountController.text = amount.toInt().toString();
        _validateAmount();
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.gray200.withOpacity(0.5),
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(
            color: isEnabled 
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.gray300,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isEnabled ? AppColors.primary : AppColors.textTertiary(context),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 🚀 Bouton de soumission
  Widget _buildSubmitButton(AffiliateProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: PremiumButton(
        text: 'Demander le Retrait',
        icon: Icons.send,
        isLoading: provider.isRequestingWithdrawal,
        onPressed: provider.canWithdraw && _isAmountValid && !provider.isRequestingWithdrawal
            ? () => _submitWithdrawal(provider)
            : null,
      ),
    );
  }

  /// 📤 Soumettre la demande de retrait
  void _submitWithdrawal(AffiliateProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    final success = await provider.requestWithdrawal(_enteredAmount);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de retrait envoyée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.withdrawalError ?? 'Erreur lors de la demande'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// ❓ Dialog de confirmation
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLG,
        ),
        title: Text(
          'Confirmer le Retrait',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous êtes sur le point de demander un retrait de :',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_enteredAmount.toFormattedString()} FCFA',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cette action ne peut pas être annulée.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Confirmer',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;
  }
}

/// 🔢 Formateur de séparateur de milliers
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(' ', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = number.toFormattedString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
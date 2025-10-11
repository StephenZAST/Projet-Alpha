import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';

/// 🌍 Dialog des Préférences de Langue - Alpha Client App
///
/// Dialog pour la sélection de la langue de l'application
/// Note: Actuellement seul le français est disponible
class LanguagePreferencesDialog extends StatefulWidget {
  const LanguagePreferencesDialog({Key? key}) : super(key: key);

  @override
  State<LanguagePreferencesDialog> createState() =>
      _LanguagePreferencesDialogState();
}

class _LanguagePreferencesDialogState
    extends State<LanguagePreferencesDialog> {
  String _selectedLanguage = 'fr'; // Français par défaut

  // Langues disponibles (pour l'instant uniquement français)
  final List<LanguageOption> _languages = [
    LanguageOption(
      code: 'fr',
      name: 'Français',
      nativeName: 'Français',
      flag: '🇫🇷',
      isAvailable: true,
    ),
    LanguageOption(
      code: 'en',
      name: 'Anglais',
      nativeName: 'English',
      flag: '🇬🇧',
      isAvailable: false,
    ),
    LanguageOption(
      code: 'ar',
      name: 'Arabe',
      nativeName: 'العربية',
      flag: '🇸🇦',
      isAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildLanguageList(),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoNote(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 En-tête du dialog
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.language_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Langue de l\'application',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Choisissez votre langue préférée',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// 🌍 Liste des langues
  Widget _buildLanguageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langues disponibles',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _languages.asMap().entries.map((entry) {
              final index = entry.key;
              final language = entry.value;
              final isLast = index == _languages.length - 1;

              return Column(
                children: [
                  _buildLanguageItem(language),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppColors.border(context),
                      indent: 72,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 🌍 Élément de langue
  Widget _buildLanguageItem(LanguageOption language) {
    final isSelected = _selectedLanguage == language.code;
    final canSelect = language.isAvailable;

    return InkWell(
      onTap: canSelect
          ? () => setState(() => _selectedLanguage = language.code)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Drapeau
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.border(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: canSelect
                              ? AppColors.textPrimary(context)
                              : AppColors.textTertiary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!canSelect) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Bientôt',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    language.nativeName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: canSelect
                          ? AppColors.textSecondary(context)
                          : AppColors.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (canSelect)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border(context),
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  /// ℹ️ Note informative
  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À propos de la traduction',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'L\'application est actuellement disponible uniquement en français. '
                  'D\'autres langues seront ajoutées prochainement selon la demande.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Actions du dialog
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 🌍 Modèle d'option de langue
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isAvailable;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.isAvailable,
  });
}

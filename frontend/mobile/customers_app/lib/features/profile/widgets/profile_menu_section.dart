import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';

/// 📋 Section de Menu de Profil - Alpha Client App
///
/// Widget pour organiser les éléments de menu du profil
/// en sections avec titre et éléments.
class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<ProfileMenuItem> items;

  const ProfileMenuSection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Conteneur des éléments
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              return Column(
                children: [
                  _ProfileMenuTile(item: item),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppColors.border(context),
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// 🎯 Élément de Menu de Profil
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });
}

/// 🎯 Tuile de Menu de Profil
class _ProfileMenuTile extends StatelessWidget {
  final ProfileMenuItem item;

  const _ProfileMenuTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          item.onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isDestructive 
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.surfaceVariant(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.isDestructive 
                      ? AppColors.error
                      : AppColors.textSecondary(context),
                  size: 22,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: item.isDestructive 
                            ? AppColors.error
                            : AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Trailing
              item.trailing ?? Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary(context),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎛️ Switch de Menu de Profil
class ProfileMenuSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfileMenuSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withOpacity(0.3),
      inactiveThumbColor: AppColors.textTertiary(context),
      inactiveTrackColor: AppColors.surfaceVariant(context),
    );
  }
}

/// 🏷️ Badge de Menu de Profil
class ProfileMenuBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const ProfileMenuBadge({
    Key? key,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
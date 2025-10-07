import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/notification_system.dart';

/// 🆘 Écran Support & Aide - Alpha Affiliate App
///
/// Centre d'aide et de support pour les affiliés

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildFAQSection(context),
            const SizedBox(height: 24),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Support & Aide',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  /// 🎯 En-tête
  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centre d\'Aide',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nous sommes là pour vous aider à réussir',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ⚡ Actions rapides
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Chat en Direct',
                subtitle: 'Parlez à un agent',
                icon: Icons.chat_bubble_outline,
                color: AppColors.success,
                onTap: () => _startLiveChat(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Appeler',
                subtitle: 'Support téléphonique',
                icon: Icons.phone_outlined,
                color: AppColors.info,
                onTap: () => _makePhoneCall(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🎯 Carte d'action
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        child: Column(
          children: [
            GlassContainer(
              width: 48,
              height: 48,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              color: color.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ❓ Section FAQ
  Widget _buildFAQSection(BuildContext context) {
    final faqItems = [
      {
        'question': 'Comment fonctionne le programme d\'affiliation ?',
        'answer':
            'Vous gagnez des commissions sur chaque commande passée par vos filleuls. Plus vous parrainez de clients, plus vous gagnez !',
      },
      {
        'question': 'Quand puis-je demander un retrait ?',
        'answer':
            'Vous pouvez demander un retrait dès que votre solde atteint ${formatNumber(AffiliateConfig.minWithdrawalAmount)} FCFA.',
      },
      {
        'question': 'Comment partager mon code affilié ?',
        'answer':
            'Utilisez le bouton "Partager" dans votre dashboard ou copiez votre code depuis votre profil.',
      },
      {
        'question': 'Comment puis-je suivre mes gains ?',
        'answer':
            'Consultez l\'onglet "Commissions" pour voir toutes vos transactions et gains en détail.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions Fréquentes',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...faqItems.map((item) => _buildFAQItem(context, item)).toList(),
      ],
    );
  }

  /// ❓ Item FAQ
  Widget _buildFAQItem(BuildContext context, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              item['question']!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  item['answer']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ],
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  /// 📞 Section contact
  Widget _buildContactSection(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nous Contacter',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@alphalaundry.com',
            onTap: () => _sendEmail(context),
          ),
          _buildContactItem(
            context,
            icon: Icons.phone_outlined,
            title: 'Téléphone',
            subtitle: '+225 01 02 03 04 05',
            onTap: () => _makePhoneCall(context),
          ),
          _buildContactItem(
            context,
            icon: Icons.schedule_outlined,
            title: 'Horaires',
            subtitle: 'Lun-Ven: 8h-18h, Sam: 9h-15h',
            onTap: null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notre équipe support répond généralement sous 2 heures pendant les heures ouvrables.',
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

  /// 📞 Item de contact
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    // Couleurs selon la nature du contact pour effet glassy moderne
    Color _getContactIconColor(IconData icon) {
      switch (icon) {
        case Icons.phone:
          return AppColors.success; // Vert pour téléphone
        case Icons.email:
          return AppColors.primary; // Bleu pour email
        case Icons.chat:
          return AppColors.secondary; // Violet pour chat
        default:
          return AppColors.primary;
      }
    }

    final iconColor = _getContactIconColor(icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GlassContainer(
                width: 40,
                height: 40,
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
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

  /// 💬 Démarrer chat en direct
  void _startLiveChat(BuildContext context) {
    NotificationManager().showInfo(
      context,
      title: 'Chat en Direct',
      message: 'Fonctionnalité bientôt disponible',
    );
  }

  /// 📞 Appeler le support
  void _makePhoneCall(BuildContext context) async {
    const phoneNumber = 'tel:+2250102030405';
    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        throw 'Could not launch $phoneNumber';
      }
    } catch (e) {
      NotificationManager().showError(
        context,
        title: 'Erreur',
        message: 'Impossible d\'ouvrir l\'application téléphone',
      );
    }
  }

  /// 📧 Envoyer un email
  void _sendEmail(BuildContext context) async {
    const emailAddress =
        'mailto:support@alphalaundry.com?subject=Support Affilié';
    try {
      if (await canLaunchUrl(Uri.parse(emailAddress))) {
        await launchUrl(Uri.parse(emailAddress));
      } else {
        throw 'Could not launch $emailAddress';
      }
    } catch (e) {
      NotificationManager().showError(
        context,
        title: 'Erreur',
        message: 'Impossible d\'ouvrir l\'application email',
      );
    }
  }
}

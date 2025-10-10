import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';

/// 🆘 Écran Centre d'Aide - Alpha Laundry
///
/// FAQ et informations utiles pour les clients
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Centre d\'aide',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // En-tête
            _buildHeader(context),
            
            const SizedBox(height: 32),
            
            // Nos Services
            _buildSection(
              context,
              'Nos Services',
              Icons.local_laundry_service,
              AppColors.primary,
              [
                _buildServiceItem(context, 'Nettoyage à sec', 'Nettoyage profond avec élimination des taches tenaces'),
                _buildServiceItem(context, 'Lavé et repassé', 'Service complet de lavage et repassage professionnel'),
                _buildServiceItem(context, 'Laver et plier', 'Lavage soigné suivi d\'un pliage impeccable'),
                _buildServiceItem(context, 'Laver et repasser', 'Lavage et repassage pour un rendu parfait'),
                _buildServiceItem(context, 'Ramassage et livraison', 'Collecte et livraison gratuite à domicile'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Services Complémentaires
            _buildSection(
              context,
              'Services Complémentaires',
              Icons.star_outline,
              AppColors.warning,
              [
                _buildServiceItem(context, 'Service personnalisé', 'Traitement adapté à vos besoins spécifiques'),
                _buildServiceItem(context, 'Blanchiment spécial', 'Restauration de l\'éclat des linges blancs'),
                _buildServiceItem(context, 'Conseil spécialisé', 'Expertise pour l\'entretien de vos vêtements'),
                _buildServiceItem(context, 'Retouche express', 'Réparations rapides et soignées'),
                _buildServiceItem(context, 'Désodorisation', 'Élimination des odeurs tenaces'),
                _buildServiceItem(context, 'Amidonnage', 'Pour un linge impeccable et structuré'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // FAQ
            _buildSection(
              context,
              'Questions Fréquentes',
              Icons.help_outline,
              AppColors.info,
              [
                _buildFAQItem(
                  context,
                  'Quels sont vos délais de service ?',
                  'Nos délais varient de 3 à 72 heures selon le type de service choisi. Le service express est disponible pour les demandes urgentes.',
                ),
                _buildFAQItem(
                  context,
                  'Comment fonctionne la collecte et livraison ?',
                  'Nous collectons vos vêtements à votre domicile, les nettoyons selon vos préférences, et vous les livrons repassés et prêts à porter. Le service est gratuit !',
                ),
                _buildFAQItem(
                  context,
                  'Quels produits utilisez-vous ?',
                  'Nous utilisons des produits de qualité supérieure, sélectionnés avec soin pour préserver les couleurs et les fibres de vos vêtements.',
                ),
                _buildFAQItem(
                  context,
                  'Proposez-vous des offres spéciales ?',
                  'Oui ! Bénéficiez jusqu\'à 50% de réduction sur vos premières commandes pendant 3 mois. Des offres promotionnelles régulières sont également disponibles.',
                ),
                _buildFAQItem(
                  context,
                  'Comment garantissez-vous la qualité ?',
                  'Nous utilisons des technologies de pointe et offrons une garantie satisfaction : si vous n\'êtes pas satisfait, nous refaisons le service sans frais.',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Nos Atouts
            _buildSection(
              context,
              'Pourquoi Choisir Alpha Laundry ?',
              Icons.verified_outlined,
              AppColors.success,
              [
                _buildFeatureItem(context, Icons.precision_manufacturing, 'Technologie de Pointe', 'Machines de dernière génération'),
                _buildFeatureItem(context, Icons.thumb_up_outlined, 'Satisfaction Garantie', 'Service refait gratuitement si nécessaire'),
                _buildFeatureItem(context, Icons.workspace_premium, 'Expertise Reconnue', 'Plus de 10 ans d\'expérience'),
                _buildFeatureItem(context, Icons.person_outline, 'Service Personnalisé', 'Attention particulière à chaque pièce'),
                _buildFeatureItem(context, Icons.attach_money, 'Tarifs Compétitifs', 'Qualité supérieure à prix abordable'),
              ],
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.medium,
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Comment pouvons-nous vous aider ?',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez toutes les informations sur nos services et notre fonctionnement',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
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

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.success, size: 22),
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
        ],
      ),
    );
  }
}
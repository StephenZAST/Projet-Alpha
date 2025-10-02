import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../screens/create_order_screen.dart';

/// 📊 Indicateur de Progression du Stepper - Alpha Client App
///
/// Affiche la progression dans le workflow de création de commande
/// avec un design premium adapté pour mobile.
class OrderStepperIndicator extends StatelessWidget {
  final List<StepInfo> steps;
  final int currentStep;
  final Function(int)? onStepTapped;

  const OrderStepperIndicator({
    Key? key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Barre de progression
          _buildProgressBar(context),
          const SizedBox(height: 16),
          
          // Informations de l'étape actuelle
          _buildCurrentStepInfo(context),
          const SizedBox(height: 16),
          
          // Mini indicateurs
          _buildMiniIndicators(context),
        ],
      ),
    );
  }

  /// 📊 Barre de progression
  Widget _buildProgressBar(BuildContext context) {
    final progress = (currentStep + 1) / steps.length;
    
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// 📋 Informations de l'étape actuelle
  Widget _buildCurrentStepInfo(BuildContext context) {
    final step = steps[currentStep];
    
    return Row(
      children: [
        // Icône de l'étape
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [step.color, step.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: step.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            step.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        
        // Texte de l'étape
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étape ${currentStep + 1} sur ${steps.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                step.title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                step.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔘 Mini indicateurs des étapes
  Widget _buildMiniIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final step = steps[index];
        
        return GestureDetector(
          onTap: onStepTapped != null && index < currentStep 
              ? () => onStepTapped!(index)
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 24,
            height: isActive ? 32 : 24,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? step.color
                  : AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(isActive ? 16 : 12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: step.color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isActive ? 16 : 12,
                    )
                  : isActive
                      ? Icon(
                          step.icon,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
                          '${index + 1}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          ),
        );
      }),
    );
  }
}
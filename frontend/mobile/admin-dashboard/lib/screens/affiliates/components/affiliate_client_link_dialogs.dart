import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../models/affiliate.dart';
import '../../../models/user.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../widgets/shared/glass_container.dart';
import 'affiliate_client_links.dart';

/// 🆕 Boîte de dialogue pour créer une liaison affilié-client
void showCreateAffiliateClientLinkDialog(BuildContext context) async {
  final AffiliatesController controller = Get.find<AffiliatesController>();

  // Charger les données pour les dropdowns si nécessaire
  if (controller.availableClients.isEmpty ||
      controller.availableAffiliates.isEmpty) {
    await controller.loadDropdownData();
  }

  // Variables d'état déclarées à l'extérieur du StatefulBuilder
  AffiliateProfile? selectedAffiliate;
  User? selectedClient;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 30));

  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, setState) {
          return GlassContainer(
            padding: EdgeInsets.all(AppSpacing.lg),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle liaison affilié-client',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Sélection affilié
                Text(
                  'Affilié',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Obx(() {
                  if (controller.isLoadingDropdowns.value &&
                      controller.availableAffiliates.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return SearchableDropdown<AffiliateProfile>(
                    hintText: 'Sélectionner un affilié',
                    items: controller.availableAffiliates,
                    value: selectedAffiliate,
                    displayText: (affiliate) =>
                        '${affiliate.user?.firstName ?? ''} ${affiliate.user?.lastName ?? ''} (${affiliate.affiliateCode})',
                    searchText: (affiliate) =>
                        '${affiliate.user?.firstName ?? ''} ${affiliate.user?.lastName ?? ''} ${affiliate.affiliateCode}',
                    onChanged: (value) {
                      setState(() {
                        selectedAffiliate = value;
                      });
                    },
                  );
                }),
                SizedBox(height: AppSpacing.md),

                // Sélection client
                Text(
                  'Client',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Obx(() {
                  if (controller.isLoadingDropdowns.value &&
                      controller.availableClients.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return SearchableDropdown<User>(
                    hintText: 'Sélectionner un client',
                    items: controller.availableClients,
                    value: selectedClient,
                    displayText: (user) =>
                        '${user.firstName} ${user.lastName} (${user.email})',
                    searchText: (user) =>
                        '${user.firstName} ${user.lastName} ${user.email}',
                    onChanged: (value) {
                      setState(() {
                        selectedClient = value;
                      });
                    },
                  );
                }),
                SizedBox(height: AppSpacing.md),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date début',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() {
                                  startDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.cardBgDark
                                    : AppColors.cardBgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.gray700.withOpacity(0.3)
                                      : AppColors.gray200.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                '${startDate.day}/${startDate.month}/${startDate.year}',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date fin',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() {
                                  endDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.cardBgDark
                                    : AppColors.cardBgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.gray700.withOpacity(0.3)
                                      : AppColors.gray200.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                '${endDate.day}/${endDate.month}/${endDate.year}',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Boutons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Annuler'),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Obx(() => GlassButton(
                          label: 'Créer',
                          onPressed: controller.isLoadingLinks.value
                              ? null
                              : () async {
                                  if (selectedAffiliate == null ||
                                      selectedClient == null) {
                                    Get.snackbar(
                                      'Erreur',
                                      'Veuillez sélectionner un affilié et un client',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor:
                                          AppColors.error.withOpacity(0.1),
                                      colorText: AppColors.error,
                                    );
                                    return;
                                  }

                                  try {
                                    // Créer la liaison
                                    await controller.createAffiliateClientLink(
                                      affiliateId: selectedAffiliate!.id,
                                      clientId: selectedClient!.id,
                                      startDate: startDate,
                                      endDate: endDate,
                                    );

                                    // Recharger les données après la création réussie
                                    await controller.fetchAffiliateClientLinks(
                                        resetPage: true);
                                    print('[Dialog] Data reloaded after create');

                                    // Fermer le dialogue automatiquement après succès
                                    Get.back();

                                    // Afficher un message de succès
                                    Get.snackbar(
                                      'Succès',
                                      'Liaison créée avec succès !',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor:
                                          AppColors.success.withOpacity(0.1),
                                      colorText: AppColors.success,
                                      duration: Duration(seconds: 3),
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                      ),
                                    );
                                  } catch (e) {
                                    // En cas d'erreur, ne pas fermer le dialogue
                                    print('[Dialog] Error creating link: $e');
                                    Get.snackbar(
                                      'Erreur',
                                      'Impossible de créer la liaison: ${e.toString()}',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor:
                                          AppColors.error.withOpacity(0.1),
                                      colorText: AppColors.error,
                                      duration: Duration(seconds: 5),
                                      icon: Icon(
                                        Icons.error,
                                        color: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                          size: GlassButtonSize.small,
                          isLoading: controller.isLoadingLinks.value,
                        )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

/// ✏️ Boîte de dialogue pour modifier une liaison affilié-client
void showEditAffiliateClientLinkDialog(
    BuildContext context, AffiliateClientLink link) async {
  final AffiliatesController controller = Get.find<AffiliatesController>();

  // Charger les données pour les dropdowns si nécessaire
  if (controller.availableClients.isEmpty ||
      controller.availableAffiliates.isEmpty) {
    await controller.loadDropdownData();
  }

  // Variables d'état déclarées à l'extérieur du StatefulBuilder
  AffiliateProfile? selectedAffiliate = controller.availableAffiliates
      .firstWhereOrNull((a) => a.id == link.affiliateId);
  User? selectedClient = controller.availableClients
      .firstWhereOrNull((c) => c.id == link.clientId);
  DateTime startDate = link.startDate;
  DateTime endDate = link.endDate ?? DateTime.now().add(Duration(days: 30));

  Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(builder: (context, setState) {
        return GlassContainer(
          padding: EdgeInsets.all(AppSpacing.lg),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier liaison affilié-client',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Sélection affilié
              Text(
                'Affilié',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Obx(() {
                if (controller.isLoadingDropdowns.value &&
                    controller.availableAffiliates.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return SearchableDropdown<AffiliateProfile>(
                  hintText: 'Sélectionner un affilié',
                  items: controller.availableAffiliates,
                  value: selectedAffiliate,
                  displayText: (affiliate) =>
                      '${affiliate.user?.firstName ?? ''} ${affiliate.user?.lastName ?? ''} (${affiliate.affiliateCode})',
                  searchText: (affiliate) =>
                      '${affiliate.user?.firstName ?? ''} ${affiliate.user?.lastName ?? ''} ${affiliate.affiliateCode}',
                  onChanged: (value) {
                    setState(() {
                      selectedAffiliate = value;
                    });
                  },
                );
              }),
              SizedBox(height: AppSpacing.md),

              // Sélection client
              Text(
                'Client',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Obx(() {
                if (controller.isLoadingDropdowns.value &&
                    controller.availableClients.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return SearchableDropdown<User>(
                  hintText: 'Sélectionner un client',
                  items: controller.availableClients,
                  value: selectedClient,
                  displayText: (user) =>
                      '${user.firstName} ${user.lastName} (${user.email})',
                  searchText: (user) =>
                      '${user.firstName} ${user.lastName} ${user.email}',
                  onChanged: (value) {
                    setState(() {
                      selectedClient = value;
                    });
                  },
                );
              }),
              SizedBox(height: AppSpacing.md),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date début',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.cardBgDark
                                  : AppColors.cardBgLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.gray700.withOpacity(0.3)
                                    : AppColors.gray200.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              '${startDate.day}/${startDate.month}/${startDate.year}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date fin',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.cardBgDark
                                  : AppColors.cardBgLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.gray700.withOpacity(0.3)
                                    : AppColors.gray200.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              '${endDate.day}/${endDate.month}/${endDate.year}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Obx(() => GlassButton(
                        label: 'Mettre à jour',
                        onPressed: controller.isLoadingLinks.value
                            ? null
                            : () async {
                                if (selectedAffiliate == null ||
                                    selectedClient == null) {
                                  Get.snackbar(
                                    'Erreur',
                                    'Veuillez sélectionner un affilié et un client',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor:
                                        AppColors.error.withOpacity(0.1),
                                    colorText: AppColors.error,
                                  );
                                  return;
                                }

                                try {
                                  // Mettre à jour la liaison
                                  await controller.updateAffiliateClientLink(
                                    linkId: link.id,
                                    affiliateId: selectedAffiliate!.id,
                                    clientId: selectedClient!.id,
                                    startDate: startDate,
                                    endDate: endDate,
                                  );

                                  // Recharger les données après la mise à jour réussie
                                  await controller.fetchAffiliateClientLinks(
                                      resetPage: true);
                                  print('[Dialog] Data reloaded after update');

                                  // Fermer le dialogue automatiquement après succès
                                  Get.back();

                                  // Afficher un message de succès
                                  Get.snackbar(
                                    'Succès',
                                    'Liaison mise à jour avec succès !',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor:
                                        AppColors.success.withOpacity(0.1),
                                    colorText: AppColors.success,
                                    duration: Duration(seconds: 3),
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                    ),
                                  );
                                } catch (e) {
                                  // En cas d'erreur, ne pas fermer le dialogue
                                  print('[Dialog] Error updating link: $e');
                                  Get.snackbar(
                                    'Erreur',
                                    'Impossible de mettre à jour la liaison: ${e.toString()}',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor:
                                        AppColors.error.withOpacity(0.1),
                                    colorText: AppColors.error,
                                    duration: Duration(seconds: 5),
                                    icon: Icon(
                                      Icons.error,
                                      color: AppColors.error,
                                    ),
                                  );
                                }
                              },
                        size: GlassButtonSize.small,
                        isLoading: controller.isLoadingLinks.value,
                      )),
                ],
              ),
            ],
          ),
        );
      })));
}

/// 🗑️ Boîte de dialogue de confirmation de suppression
void showDeleteAffiliateClientLinkDialog(
    BuildContext context, AffiliateClientLink link) {
  final AffiliatesController controller = Get.find<AffiliatesController>();

  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: EdgeInsets.all(AppSpacing.lg),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              size: 48,
              color: AppColors.warning,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Confirmer la suppression',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textLight
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Êtes-vous sûr de vouloir supprimer cette liaison ? Cette action est irréversible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Annuler'),
                ),
                SizedBox(width: AppSpacing.sm),
                Obx(() => GlassButton(
                      label: 'Supprimer',
                      onPressed: controller.isLoadingLinks.value
                          ? null
                          : () async {
                              try {
                                // Supprimer la liaison
                                await controller
                                    .deleteAffiliateClientLink(link.id);

                                // Fermer le dialogue automatiquement après succès
                                Get.back();

                                // Afficher un message de succès
                                Get.snackbar(
                                  'Succès',
                                  'Liaison supprimée avec succès !',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor:
                                      AppColors.success.withOpacity(0.1),
                                  colorText: AppColors.success,
                                  duration: Duration(seconds: 3),
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  ),
                                );
                              } catch (e) {
                                // En cas d'erreur, fermer quand même le dialogue
                                Get.back();
                                
                                // Afficher un message d'erreur
                                Get.snackbar(
                                  'Erreur',
                                  'Impossible de supprimer la liaison: ${e.toString()}',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor:
                                      AppColors.error.withOpacity(0.1),
                                  colorText: AppColors.error,
                                  duration: Duration(seconds: 5),
                                  icon: Icon(
                                    Icons.error,
                                    color: AppColors.error,
                                  ),
                                );
                              }
                            },
                      variant: GlassButtonVariant.error,
                      size: GlassButtonSize.small,
                      isLoading: controller.isLoadingLinks.value,
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

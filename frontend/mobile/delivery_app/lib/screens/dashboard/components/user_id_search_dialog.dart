import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/user_search.dart';
import '../../../services/user_id_search_service.dart';
import '../../../widgets/shared/glass_container.dart';
import 'user_detail_dialog.dart';

/// 🔍 Dialog de recherche d'utilisateurs par ID
///
/// Permet aux livreurs de rechercher rapidement un utilisateur
/// en tapant un extrait de son ID UUID (minimum 4 caractères)
class UserIdSearchDialog extends StatefulWidget {
  final Function(User) onUserSelected;
  final Function(User)? onUserDetailsRequested;

  const UserIdSearchDialog({
    Key? key,
    required this.onUserSelected,
    this.onUserDetailsRequested,
  }) : super(key: key);

  @override
  State<UserIdSearchDialog> createState() => _UserIdSearchDialogState();
}

class _UserIdSearchDialogState extends State<UserIdSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<User> _suggestions = <User>[].obs;
  final RxBool _isSearching = false.obs;
  final RxBool _hasSearched = false.obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _suggestions.clear();
      _hasSearched.value = false;
      return;
    }

    if (query.length < 4) {
      _suggestions.clear();
      _hasSearched.value = false;
      return;
    }

    _performSearch(query);
  }

  Future<void> _performSearch(String idFragment) async {
    try {
      _isSearching.value = true;
      _hasSearched.value = true;

      final results = await UserIdSearchService.searchUsersByIdFragment(
        idFragment,
        limit: 10,
      );

      _suggestions.value = results;
    } catch (e) {
      print('[UserIdSearchDialog] Search error: $e');
      _suggestions.clear();
      Get.rawSnackbar(
        message: 'Erreur lors de la recherche',
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: GlassContainer(
        width: 500,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppColors.textLight,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rechercher un utilisateur par ID',
                        style: AppTextStyles.h4.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Entrez au moins 4 caractères de l\'ID UUID',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.gray300
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ex: 2c8e, 4033, aeb3, 8acb98fe1d1c...',
                prefixIcon: Icon(
                  Icons.fingerprint,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
                fillColor: isDark ? AppColors.gray800 : AppColors.gray100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Results Section
            Obx(() {
              if (!_hasSearched.value) {
                return Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Tapez au moins 4 caractères pour commencer la recherche',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_isSearching.value) {
                return Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Recherche en cours...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_suggestions.isEmpty) {
                return Container(
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
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Aucun utilisateur trouvé avec cet ID',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Results List
              return Container(
                constraints: BoxConstraints(
                  maxHeight: 300,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        '${_suggestions.length} résultat${_suggestions.length > 1 ? 's' : ''} trouvé${_suggestions.length > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.gray300
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      ..._suggestions
                          .map((user) => _buildUserResultTile(user, isDark)),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: AppSpacing.lg),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserResultTile(User user, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : Colors.white.withOpacity(0.5),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Name and Role
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.gray300
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: user.role.color.withOpacity(0.2),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Text(
                  user.role.label,
                  style: AppTextStyles.caption.copyWith(
                    color: user.role.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ID Display with Copy Button
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray900 : AppColors.gray50,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 16,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SelectableText(
                    user.id,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    // Copy to clipboard
                    final data = ClipboardData(text: user.id);
                    Clipboard.setData(data);
                    Get.rawSnackbar(
                      messageText: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'ID copié',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success.withOpacity(0.85),
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 1),
                      borderRadius: 8,
                      margin: EdgeInsets.all(AppSpacing.md),
                    );
                  },
                  child: Tooltip(
                    message: 'Copier l\'ID',
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Phone if available
          if (user.phone != null && user.phone!.isNotEmpty)
            Text(
              'Tél: ${user.phone}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),

          SizedBox(height: AppSpacing.sm),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Bouton Voir les détails
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    UserDetailDialog(user: user),
                    barrierDismissible: true,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: AppRadius.radiusSM,
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.info,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Détails',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Bouton Sélectionner
              GestureDetector(
                onTap: () {
                  widget.onUserSelected(user);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: AppRadius.radiusSM,
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Sélectionner',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

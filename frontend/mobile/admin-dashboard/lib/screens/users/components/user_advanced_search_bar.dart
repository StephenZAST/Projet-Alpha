import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../types/user_search_filter.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../constants.dart';

class UserAdvancedSearchBar extends StatefulWidget {
  const UserAdvancedSearchBar({Key? key}) : super(key: key);

  @override
  State<UserAdvancedSearchBar> createState() => _UserAdvancedSearchBarState();
}

class _UserAdvancedSearchBarState extends State<UserAdvancedSearchBar> {
  final controller = Get.find<UsersController>();
  final searchController = TextEditingController();
  UserSearchFilter selectedFilter = UserSearchFilter.all;
  bool get _hasSearch => searchController.text.isNotEmpty;

  Widget _glassyIconButton({
    required IconData icon,
    required VoidCallback onTap,
    GlassButtonVariant variant = GlassButtonVariant.secondary,
    String? tooltip,
  }) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: GlassButtonVariant.primary == variant
                ? AppColors.primary.withOpacity(0.12)
                : variant == GlassButtonVariant.info
                    ? AppColors.info.withOpacity(0.10)
                    : AppColors.gray100.withOpacity(0.90),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: _getIconColor(variant), size: 20),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip, child: button) : button;
  }

  Color _getIconColor(GlassButtonVariant variant) {
    switch (variant) {
      case GlassButtonVariant.primary:
        return AppColors.primary;
      case GlassButtonVariant.info:
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  void _showFilterOptions() async {
    final filter = await showMenu<UserSearchFilter>(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: UserSearchFilter.all,
          child: Text('Tous'),
        ),
        PopupMenuItem(
          value: UserSearchFilter.name,
          child: Text('Nom'),
        ),
        PopupMenuItem(
          value: UserSearchFilter.email,
          child: Text('Email'),
        ),
        PopupMenuItem(
          value: UserSearchFilter.phone,
          child: Text('Téléphone'),
        ),
      ],
    );
    if (filter != null) {
      setState(() {
        selectedFilter = filter;
      });
      _onSearchChanged();
    }
  }

  void _onSearchChanged() {
    // Met à jour le filtre de recherche et le filtre avancé dans le contrôleur
    controller.searchQuery.value = searchController.text;
    controller.selectedFilter.value = selectedFilter;
    controller.fetchUsersOrSearch(resetPage: true);
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      selectedFilter = UserSearchFilter.all;
    });
    controller.searchQuery.value = '';
    controller.selectedFilter.value = UserSearchFilter.all;
    controller.fetchUsersOrSearch(resetPage: true);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un utilisateur...',
                            prefixIcon: _glassyIconButton(
                              icon: Icons.search_rounded,
                              onTap: _onSearchChanged,
                              variant: GlassButtonVariant.primary,
                              tooltip: 'Rechercher',
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _glassyIconButton(
                                  icon: Icons.filter_alt_outlined,
                                  onTap: _showFilterOptions,
                                  variant: GlassButtonVariant.info,
                                  tooltip: 'Filtrer la recherche',
                                ),
                                if (_hasSearch)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: _glassyIconButton(
                                      icon: Icons.close_rounded,
                                      onTap: _clearSearch,
                                      variant: GlassButtonVariant
                                          .info, // Utilise le même fond glassy bleu que le filtre
                                      tooltip: 'Effacer la recherche',
                                    ),
                                  ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(
                                () {}); // Pour afficher/masquer l'icône close
                          },
                          onSubmitted: (value) => _onSearchChanged(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  GlassButton(
                    label: 'Rechercher',
                    icon: Icons.search,
                    variant: GlassButtonVariant.primary,
                    onPressed: _onSearchChanged,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Obx(() {
                // Affiche le filtre actif de façon claire
                final filter = controller.selectedFilter.value;
                String label;
                switch (filter) {
                  case UserSearchFilter.name:
                    label = 'Recherche par : Nom';
                    break;
                  case UserSearchFilter.email:
                    label = 'Recherche par : Email';
                    break;
                  case UserSearchFilter.phone:
                    label = 'Recherche par : Téléphone';
                    break;
                  case UserSearchFilter.all:
                  default:
                    label = 'Recherche sur tous les champs';
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

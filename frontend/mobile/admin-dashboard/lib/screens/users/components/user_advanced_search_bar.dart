import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';
import '../../../types/user_search_filter.dart';
import '../../../widgets/shared/glass_button.dart';

class UserAdvancedSearchBar extends StatefulWidget {
  const UserAdvancedSearchBar({Key? key}) : super(key: key);

  @override
  State<UserAdvancedSearchBar> createState() => _UserAdvancedSearchBarState();
}

class _UserAdvancedSearchBarState extends State<UserAdvancedSearchBar> {
  final controller = Get.find<UsersController>();
  final searchController = TextEditingController();
  UserSearchFilter selectedFilter = UserSearchFilter.all;

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
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un utilisateur...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.filter_list),
                          tooltip: 'Filtrer la recherche',
                          onPressed: _showFilterOptions,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {},
                      onSubmitted: (value) => _onSearchChanged(),
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

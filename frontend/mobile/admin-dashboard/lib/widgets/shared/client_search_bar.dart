import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import 'glass_button.dart';

class ClientSearchBar extends StatefulWidget {
  final Function(String query, String filter) onSearch;
  final bool isLoading;

  const ClientSearchBar({
    Key? key,
    required this.onSearch,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ClientSearchBar> createState() => _ClientSearchBarState();
}

class _ClientSearchBarState extends State<ClientSearchBar> {
  final searchController = TextEditingController();
  String selectedFilter = 'name';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un client...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          _buildFilterDropdown(),
          SizedBox(width: AppSpacing.sm),
          GlassButton(
            label: 'Rechercher',
            icon: Icons.search,
            variant: GlassButtonVariant.primary,
            isLoading: widget.isLoading,
            onPressed: () {
              widget.onSearch(
                searchController.text.trim(),
                selectedFilter,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: selectedFilter,
      items: [
        DropdownMenuItem(value: 'name', child: Text('Nom')),
        DropdownMenuItem(value: 'email', child: Text('Email')),
        DropdownMenuItem(value: 'phone', child: Text('Téléphone')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => selectedFilter = value);
        }
      },
    );
  }
}

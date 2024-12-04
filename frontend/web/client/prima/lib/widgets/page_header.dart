import 'package:flutter/material.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final bool showAddressSection;
  final VoidCallback? onMenuPressed;

  const PageHeader({
    super.key,
    this.title = '',
    this.showAddressSection = true,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBarComponent(
          title: title,
          onMenuPressed: onMenuPressed ?? () {
            Scaffold.of(context).openDrawer();
          },
        ),
        if (showAddressSection) const AddressSectionComponent(),
      ],
    );
  }
}

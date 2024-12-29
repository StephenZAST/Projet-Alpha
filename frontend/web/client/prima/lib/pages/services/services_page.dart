import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/home-components/address_section.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarComponent(
              title: 'Services',
              onMenuPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            const AddressSectionComponent(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nos Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
            ),
            // TODO: Add services grid or list here
          ],
        ),
      ),
    );
  }
}

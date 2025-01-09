import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class CustomMapMarker extends StatelessWidget {
  const CustomMapMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: const Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

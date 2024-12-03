import 'package:flutter/material.dart';
import 'ReductionSection.dart';
import 'ServiceSection.dart';

class LaundryPage extends StatelessWidget {
  const LaundryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReductionSection(),
            ServiceSection(),
          ],
        ),
      ),
    );
  }
}

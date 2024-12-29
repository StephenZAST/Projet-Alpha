import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:prima/widgets/custom_sidebar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      drawer: const CustomSidebar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarComponent(
                title: 'Messages',
                onMenuPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              Center(
                child: Text('Chat Page Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

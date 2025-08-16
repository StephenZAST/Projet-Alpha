import 'package:flutter/material.dart';
import 'subscription_plans_tab.dart';
import 'subscribed_users_tab.dart';

class SubscriptionManagementPage extends StatelessWidget {
  const SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des abonnements'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Recharger',
              onPressed: () {
                // On force le rebuild des tabs en changeant la clé
                // (solution simple pour relancer le fetch)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const SubscriptionManagementPage()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Plans d\'abonnement'),
              Tab(text: 'Utilisateurs abonnés'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SubscriptionPlansTab(),
            SubscribedUsersTab(),
          ],
        ),
      ),
    );
  }
}

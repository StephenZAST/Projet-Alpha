import 'package:flutter/material.dart';
import 'package:prima/main.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:prima/navigation/navigation_provider.dart';
import 'package:prima/providers/auth_provider.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class DrawerSection extends StatelessWidget {
  final String title;
  final List<DrawerItem> items;

  const DrawerSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
          ),
          ...items.map((item) => _buildDrawerItem(
                context: context,
                icon: item.icon,
                text: item.title,
                isSelected: navigationProvider.isRouteActive(item.route),
                onTap: () {
                  Navigator.pop(context);
                  if (NavigationProvider.mainRoutes.contains(item.route)) {
                    navigationProvider.navigateToMainRoute(context, item.route);
                  } else {
                    navigationProvider.navigateToSecondaryRoute(
                        context, item.route);
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.gray600,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.gray600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Future<void> handleNavigation(String route) async {
      Navigator.pop(context); // Ferme le drawer
      if (NavigationProvider.mainRoutes.contains(route)) {
        // Utilise MaterialPageRoute pour une transition propre
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          (route) => false,
        );
        navigationProvider.setRoute(route);
      } else {
        await navigationProvider.navigateToSecondaryRoute(context, route);
      }
    }

    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/AlphaLogo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  'Mr ZAKANE',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const DrawerSection(
            title: 'Navigation principale',
            items: [
              DrawerItem(icon: Icons.home, title: 'Accueil', route: '/home'),
              DrawerItem(
                  icon: Icons.local_offer, title: 'Offres', route: '/offers'),
              DrawerItem(
                  icon: Icons.cleaning_services,
                  title: 'Services',
                  route: '/services'),
              DrawerItem(icon: Icons.chat, title: 'Messages', route: '/chat'),
              DrawerItem(
                  icon: Icons.person, title: 'Profile', route: '/profile'),
            ],
          ),
          const Divider(),
          const DrawerSection(
            title: 'Activité',
            items: [
              DrawerItem(
                  icon: Icons.receipt, title: 'Commandes', route: '/orders'),
              DrawerItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  route: '/notifications'),
            ],
          ),
          const Divider(),
          const DrawerSection(
            title: 'Autres',
            items: [
              DrawerItem(
                  icon: Icons.people, title: 'Parrainage', route: '/referral'),
              DrawerItem(
                  icon: Icons.settings,
                  title: 'Paramètres',
                  route: '/settings'),
            ],
          ),
          const Divider(height: 1, color: AppColors.gray200),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.gray600),
            title: const Text('Déconnexion'),
            onTap: () async {
              try {
                Navigator.pop(context); // Ferme le drawer
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                // Même en cas d'erreur, rediriger vers la page de connexion
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.gray600,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.gray600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

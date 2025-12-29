import 'package:admin/constants.dart';
import 'package:admin/controllers/article_controller.dart';
import 'package:admin/screens/articles/articles_screen.dart';
import 'package:admin/screens/orders/flash_orders/flash_order_update_screen.dart';
import 'package:admin/screens/orders/flash_orders/flash_orders_screen.dart';
import 'package:admin/screens/orders/new_order/new_order_screen.dart';
import 'package:get/get.dart';
import '../screens/main/main_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/delivery/delivery_screen.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_app_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/service_type_controller.dart';
import '../controllers/article_service_controller.dart';
import '../controllers/blog_article_controller.dart';
import '../services/blog_article_service.dart';
import '../screens/services/service_types_screen.dart';
import '../screens/services/service_article_couples_screen.dart';
import '../screens/affiliates/affiliate_management_screen.dart';
import '../screens/client_managers/client_managers_screen.dart';
import '../screens/blog/blog_management_screen.dart';
import '../bindings/client_managers_binding.dart';
import '../middleware/auth_middleware.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    print('[AdminBinding] Initializing bindings');

    // S'assurer que les contrôleurs sont initialisés dans le bon ordre
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Initialiser le DashboardController de manière permanente
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController(), permanent: true);
    }

    // Ne réinitialiser les contrôleurs permanents que s'ils n'existent pas déjà
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<MenuAppController>()) {
      Get.put(MenuAppController(), permanent: true);
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }

    // Les contrôleurs qui peuvent être réinitialisés
    Get.lazyPut(() => OrdersController(), fenix: true);
    Get.lazyPut(() => ServiceController(), fenix: true);
    Get.lazyPut(() => ArticleController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);

    print('[AdminBinding] Dependencies initialization completed');
  }
}

class AdminRoutes {
  // Routes définies
  static const String login = '/login';
  static const String main = '/';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String services = '/services';
  static const String categories = '/categories';
  static const String users = '/users';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String subscriptions = '/subscriptions';
  static const String loyalty = '/loyalty';
  static const String delivery = '/delivery';
  static const String affiliates = '/affiliates';
  static const String clientManagers = '/client-managers';

  // Ajouter les routes pour les commandes flash
  static const String flashOrders = '/orders/flash';
  static const String flashOrderUpdate = '/orders/flash/:id';
  static const String blog = '/blog';

  // Mapping index -> route
  static String getRouteByIndex(int index) {
    switch (index) {
      case MenuIndices.dashboard:
        return dashboard;
      case MenuIndices.orders:
        return orders;
      case MenuIndices.services:
        return services;
      case MenuIndices.categories:
        return categories;
      case MenuIndices.articles:
        return '/articles'; // Ajout de la route articles
      // Supprimer le case pour serviceTypes
      // case MenuIndices.serviceTypes:
      //   return '/service-types'; // Ajout de la route service-types
      case MenuIndices.users:
        return users;
      case MenuIndices.affiliates:
        return affiliates;
      case MenuIndices.loyalty:
        return loyalty;
      case MenuIndices.delivery:
        return delivery;
      case MenuIndices.profile:
        return profile;
      case MenuIndices.notifications:
        return notifications;
      case MenuIndices.subscriptions:
        return subscriptions;
      case MenuIndices.clientManagers:
        return clientManagers;
      case MenuIndices.blog:
        return blog;
      default:
        return dashboard;
    }
  }

  // Mapping route -> index
  static int getIndexByRoute(String route) {
    switch (route) {
      case dashboard:
        return MenuIndices.dashboard;
      case orders:
        return MenuIndices.orders;
      case services:
        return MenuIndices.services;
      case categories:
        return MenuIndices.categories;
      case '/articles':
        return MenuIndices.articles;
      case '/service-types':
        return MenuIndices.serviceTypes;
      case '/service-article-couples':
        return MenuIndices.serviceArticleCouples;
      case users:
        return MenuIndices.users;
      case affiliates:
        return MenuIndices.affiliates;
      case loyalty:
        return MenuIndices.loyalty;
      case delivery:
        return MenuIndices.delivery;
      case profile:
        return MenuIndices.profile;
      case notifications:
        return MenuIndices.notifications;
      case subscriptions:
        return MenuIndices.subscriptions;
      case clientManagers:
        return MenuIndices.clientManagers;
      case blog:
        return MenuIndices.blog;
      default:
        return MenuIndices.dashboard;
    }
  }

  static final routes = [
    // Route de login
    GetPage(
      name: login,
      page: () => AdminLoginScreen(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),

    // Route principale avec MainScreen qui gère la navigation interne
    GetPage(
      name: main,
      page: () => MainScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Routes pour les commandes flash
    GetPage(
      name: flashOrders,
      page: () => FlashOrdersScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: flashOrderUpdate,
      page: () {
        final orderId = Get.parameters['id']!;
        final controller = Get.find<OrdersController>();
        controller.initFlashOrderUpdate(orderId);
        return FlashOrderUpdateScreen();
      },
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/articles',
      page: () => ArticlesScreen(),
      binding: BindingsBuilder(() {
        Get.put(ArticleController());
        if (!Get.isRegistered<CategoryController>()) {
          Get.put(CategoryController());
        }
      }),
    ),
    GetPage(
      name: delivery,
      page: () => DeliveryScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MenuAppController>()) {
          Get.put(MenuAppController());
        }
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/orders/create',
      page: () => NewOrderScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<OrdersController>()) {
          Get.put(OrdersController());
        }
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    // Routes pour les services
    GetPage(
      name: '/service-types',
      page: () => ServiceTypesScreen(),
      binding: BindingsBuilder(() {
        Get.put(ServiceTypeController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/service-article-couples',
      page: () => ServiceArticleCouplesScreen(),
      binding: BindingsBuilder(() {
        Get.put(ArticleServiceController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: affiliates,
      page: () => AffiliateManagementScreen(),
      binding: BindingsBuilder(() {
        // Aucune dépendance spécifique à initialiser pour cette page
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: clientManagers,
      page: () => ClientManagersScreen(),
      binding: ClientManagersBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: blog,
      page: () => BlogManagementScreen(),
      binding: BindingsBuilder(() {
        Get.put(BlogArticleController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
  ];

  // Navigation helpers
  static bool canGoBack() {
    return Get.previousRoute.isNotEmpty;
  }

  static void goBack() {
    if (canGoBack()) {
      Get.back();
    }
  }

  static void navigateByIndex(int index) {
    final menuController = Get.find<MenuAppController>();
    menuController.updateIndex(index);
  }

  static void navigateByRoute(String route) {
    final menuController = Get.find<MenuAppController>();
    menuController.updateIndex(getIndexByRoute(route));
  }

  static void goToDashboard() {
    navigateByIndex(0);
  }

  static void goToOrders() {
    navigateByIndex(1);
  }

  static void goToServices() {
    navigateByIndex(2);
  }

  static void goToCategories() {
    navigateByIndex(3);
  }

  static void goToUsers() {
    navigateByIndex(4);
  }

  static void goToProfile() {
    navigateByIndex(5);
  }

  static void goToLogin() {
    Get.offAllNamed(login);
  }

  static void goToNotifications() {
    navigateByIndex(MenuIndices.notifications);
  }

  static void goToLoyalty() {
    navigateByIndex(MenuIndices.loyalty);
  }

  static void goToAffiliates() {
    navigateByIndex(MenuIndices.affiliates);
  }

  static void goToClientManagers() {
    navigateByIndex(MenuIndices.clientManagers);
  }

  // Ajouter les méthodes de navigation
  static void goToFlashOrders() {
    Get.toNamed(flashOrders);
  }

  static void goToFlashOrderUpdate(String orderId) {
    Get.toNamed('$flashOrderUpdate/$orderId');
  }
}

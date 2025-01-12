import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/redux/actions/order_actions.dart';
import 'package:prima/redux/actions/service_actions.dart';
import 'package:prima/redux/store.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/providers/order_state.dart';

class Service {
  final String id;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      return Service(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        description: json['description'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing service JSON: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}

class ArticleCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  ArticleCategory({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing category with data: $json'); // Ajout de log
      return ArticleCategory(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        createdAt:
            json['created_at'] != null // Changé de createdAt à created_at
                ? DateTime.parse(json['created_at'])
                : DateTime.now(),
      );
    } catch (e, stack) {
      print('Error parsing category: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}

class Article {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final double premiumPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    required this.premiumPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing article with data: $json'); // Ajout de log
      return Article(
        id: json['id'] ?? '',
        categoryId: json['categoryId'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        basePrice: (json['basePrice'] ?? 0).toDouble(),
        premiumPrice: (json['premiumPrice'] ?? 0).toDouble(),
        createdAt:
            json['created_at'] != null // Changé de createdAt à created_at
                ? DateTime.parse(json['created_at'])
                : DateTime.now(),
        updatedAt:
            json['updated_at'] != null // Changé de updatedAt à updated_at
                ? DateTime.parse(json['updated_at'])
                : DateTime.now(),
      );
    } catch (e, stack) {
      print('Error parsing article: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}

class OrderBottomSheet extends ConsumerStatefulWidget {
  final Service? initialService;

  const OrderBottomSheet({
    Key? key,
    this.initialService,
  }) : super(key: key);

  @override
  ConsumerState<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends ConsumerState<OrderBottomSheet>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  TabController? _articleTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Utiliser StoreProvider au lieu de Provider
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(LoadServicesAction());

      // Utiliser les actions Redux pour charger les articles
      if (widget.initialService != null) {
        store.dispatch(SelectServiceAction(widget.initialService!));
      }
    });

    // Si un service initial est fourni, le sélectionner
    if (widget.initialService != null) {
      StoreProvider.of<AppState>(context).dispatch(
        SelectServiceAction(widget.initialService!),
      );
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _articleTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          TabBar(
            controller: _mainTabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.primaryShadow],
            ),
            tabs: const [
              Tab(text: 'Service'),
              Tab(text: 'Articles'),
              Tab(text: 'Dates'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildServiceSelectionTab(),
                _buildArticleSelectionTab(),
                _buildDateSelectionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Nouvelle commande',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionTab() {
    return StoreConnector<AppState, _ServiceViewModel>(
      converter: (store) => _ServiceViewModel.fromStore(store),
      builder: (context, vm) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: vm.services.length,
                itemBuilder: (context, index) {
                  final service = vm.services[index];
                  return ListTile(
                    title: Text(service.name),
                    subtitle: Text('\$${service.price}'),
                    selected: vm.selectedService == service,
                    selectedTileColor: AppColors.gray100,
                    onTap: () => vm.selectService(service),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildNextButton(
                onNext: () {
                  final authProvider = provider.Provider.of<AuthProvider>(
                      context,
                      listen: false);
                  ref.read(orderProvider.notifier).fetchArticles(authProvider);
                  _mainTabController.animateTo(1);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleSelectionTab() {
    return StoreConnector<AppState, _ArticleViewModel>(
      converter: (store) => _ArticleViewModel.fromStore(store),
      builder: (context, vm) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(child: Text('Error: ${vm.error}'));
        }

        if (vm.articleCategories.isEmpty) {
          return const Center(child: Text('Aucune catégorie disponible'));
        }

        return Column(
          children: [
            TabBar(
              controller: _articleTabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              tabs: vm.articleCategories
                  .map((category) => Tab(text: category.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _articleTabController,
                children: vm.articleCategories.map((category) {
                  final articlesInCategory =
                      vm.getArticlesForCategory(category.id);
                  return _buildArticleList(articlesInCategory, vm);
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildNextButton(
                onNext: () => _mainTabController.animateTo(2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelectionTab() {
    return StoreConnector<AppState, _DateViewModel>(
      converter: (store) => _DateViewModel.fromStore(store),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Date de collecte',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    vm.setDates(collectionDate: pickedDate);
                  }
                },
                controller:
                    TextEditingController(text: vm.collectionDate?.toString()),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Date de livraison',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    vm.setDates(deliveryDate: pickedDate);
                  }
                },
                controller:
                    TextEditingController(text: vm.deliveryDate?.toString()),
              ),
              const SizedBox(height: 24),
              _buildConfirmationButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmationButton() {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Text(
          'Confirmer la commande',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      onTap: () {
        _createOrder(context);
      },
      scaleCoefficient: 0.95,
    );
  }

  Widget _buildNextButton({required VoidCallback onNext}) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Text(
          'Suivant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      onTap: onNext,
      scaleCoefficient: 0.95,
    );
  }

  Future<void> _createOrder(BuildContext context) async {
    final authProvider =
        provider.Provider.of<AuthProvider>(context, listen: false);
    final result =
        await ref.read(orderProvider.notifier).createOrder(authProvider);

    result.when(
      success: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande créée avec succès')),
        );
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  Widget _buildArticleList(List<Article> articles, _ArticleViewModel vm) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          title: Text(article.name),
          subtitle: Text('\$${article.basePrice}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
                onTap: () => vm.updateQuantity(article.id, -1),
              ),
              const SizedBox(width: 8),
              Text(vm.selectedArticles[article.id]?.toString() ?? '0'),
              const SizedBox(width: 8),
              SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16),
                ),
                onTap: () => vm.updateQuantity(article.id, 1),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Ajouter un ViewModel pour les services
class _ServiceViewModel {
  final List<Service> services;
  final Service? selectedService;
  final bool isLoading;
  final Function(Service) selectService;

  _ServiceViewModel({
    required this.services,
    this.selectedService,
    required this.isLoading,
    required this.selectService,
  });

  static _ServiceViewModel fromStore(Store<AppState> store) {
    return _ServiceViewModel(
      services: store.state.serviceState.services,
      selectedService: store.state.serviceState.selectedService,
      isLoading: store.state.serviceState.isLoading,
      selectService: (service) => store.dispatch(SelectServiceAction(service)),
    );
  }
}

class _ArticleViewModel {
  final List<ArticleCategory> articleCategories;
  final List<Article> articles;
  final Map<String, int> selectedArticles;
  final bool isLoading;
  final String? error;
  final Function(String, int) updateQuantity;

  _ArticleViewModel({
    required this.articleCategories,
    required this.articles,
    required this.selectedArticles,
    required this.isLoading,
    this.error,
    required this.updateQuantity,
  });

  List<Article> getArticlesForCategory(String categoryId) {
    return articles
        .where((article) => article.categoryId == categoryId)
        .toList();
  }

  static _ArticleViewModel fromStore(Store<AppState> store) {
    return _ArticleViewModel(
      articleCategories: store.state.articleState.categories,
      articles: store.state.articleState.articles,
      selectedArticles: store.state.orderState.selectedArticles,
      isLoading: store.state.articleState.isLoading,
      error: store.state.articleState.error,
      updateQuantity: (articleId, quantity) =>
          store.dispatch(UpdateOrderArticleQuantityAction(articleId, quantity)),
    );
  }
}

class _DateViewModel {
  final DateTime? collectionDate;
  final DateTime? deliveryDate;
  final Function({DateTime? collectionDate, DateTime? deliveryDate}) setDates;

  _DateViewModel({
    this.collectionDate,
    this.deliveryDate,
    required this.setDates,
  });

  static _DateViewModel fromStore(Store<AppState> store) {
    return _DateViewModel(
      collectionDate: store.state.orderState.collectionDate,
      deliveryDate: store.state.orderState.deliveryDate,
      setDates: ({collectionDate, deliveryDate}) => store.dispatch(
          SetOrderDatesAction(
              collectionDate: collectionDate, deliveryDate: deliveryDate)),
    );
  }
}

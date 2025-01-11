import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:spring_button/spring_button.dart';

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

class OrderBottomSheet extends StatefulWidget {
  const OrderBottomSheet({super.key});

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  TabController? _articleTabController;
  List<Service> _services = [];
  List<ArticleCategory> _articleCategories = [];
  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;
  Service? _selectedService;
  Map<String, int> _selectedArticles = {};
  DateTime? _selectedCollectionDate;
  DateTime? _selectedDeliveryDate;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);

    print('Fetching services...');
    _fetchServices().then((_) {
      print('Services fetched: ${_services.length}');
    }).catchError((error) {
      print('Error fetching services: $error');
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _articleTabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('Making API call to /services/all');
      final response = await authProvider.dio.get('/api/services/all');
      print('Response received: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        print('Raw data: $data'); // Ajoutez ce log

        _services = data
            .map((e) {
              try {
                print('Processing service data: $e'); // Ajoutez ce log
                return Service.fromJson(e);
              } catch (e, stack) {
                print('Error parsing service: $e');
                print('Stack trace: $stack');
                return null;
              }
            })
            .whereType<Service>()
            .toList();

        print('Services parsed: ${_services.length}');
      } else {
        _error = 'Failed to load services';
      }
    } catch (e, stack) {
      print('Exception details: $e');
      print('Stack trace: $stack');
      _error = 'Connection error: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Test d'abord la disponibilité des endpoints
      print('Testing API endpoints...');
      try {
        final testResponse = await authProvider.dio.get('/api/articles');
        print('Test response code: ${testResponse.statusCode}');
        print('Test response full data: ${testResponse.data}');
      } catch (e) {
        print('Test request failed: $e');
      }

      // Récupération des données en série plutôt qu'en parallèle
      try {
        print('Fetching categories...');
        final categoriesResponse =
            await authProvider.dio.get('/api/article-categories');
        print('Categories response: ${categoriesResponse.data}');

        if (categoriesResponse.statusCode != 200) {
          throw Exception(
              'Failed to load categories: ${categoriesResponse.statusCode}');
        }

        final List<dynamic> categoriesData =
            categoriesResponse.data['data'] ?? [];
        _articleCategories =
            categoriesData.map((e) => ArticleCategory.fromJson(e)).toList();
        print('Parsed ${_articleCategories.length} categories');

        print('Fetching articles...');
        final articlesResponse = await authProvider.dio.get('/api/articles');
        print('Articles response: ${articlesResponse.data}');

        if (articlesResponse.statusCode != 200) {
          throw Exception(
              'Failed to load articles: ${articlesResponse.statusCode}');
        }

        final List<dynamic> articlesData = articlesResponse.data['data'] ?? [];
        _articles = articlesData.map((e) => Article.fromJson(e)).toList();
        print('Parsed ${_articles.length} articles');

        // Mise à jour du TabController seulement si nous avons des données
        if (_articleCategories.isNotEmpty) {
          setState(() {
            _articleTabController?.dispose();
            _articleTabController = TabController(
              length: _articleCategories.length,
              vsync: this,
            );
          });
          print(
              'Created tab controller with ${_articleCategories.length} tabs');
        }
      } catch (e) {
        print('Data fetching error: $e');
        throw e;
      }
    } catch (e, stack) {
      print('Top level error: $e');
      print('Stack trace: $stack');
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return Center(child: Text('Error: $_error'));
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return ListTile(
                  title: Text(service.name),
                  subtitle: Text('\$${service.price}'),
                  selected: _selectedService == service,
                  selectedTileColor: AppColors.gray100,
                  onTap: () {
                    setState(() {
                      _selectedService = service;
                    });
                    print('Selected service: ${service.name}');
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildNextButton(
              onNext: () {
                _fetchArticles();
                _mainTabController.animateTo(1);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildArticleSelectionTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return Center(child: Text('Error: $_error'));
    } else if (_articleCategories.isEmpty) {
      return const Center(child: Text('Aucune catégorie disponible'));
    } else if (_articleTabController == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          TabBar(
            controller: _articleTabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            tabs: _articleCategories
                .map((category) => Tab(text: category.name))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _articleTabController,
              children: _articleCategories.map((category) {
                final articlesInCategory = _articles
                    .where((article) => article.categoryId == category.id)
                    .toList();
                return ListView.builder(
                  itemCount: articlesInCategory.length,
                  itemBuilder: (context, index) {
                    final article = articlesInCategory[index];
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
                            onTap: () {
                              setState(() {
                                _selectedArticles.update(
                                    article.id, (value) => value - 1,
                                    ifAbsent: () => 0);
                                if (_selectedArticles[article.id] == 0) {
                                  _selectedArticles.remove(article.id);
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                              _selectedArticles[article.id]?.toString() ?? '0'),
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
                            onTap: () {
                              setState(() {
                                _selectedArticles.update(
                                    article.id, (value) => value + 1,
                                    ifAbsent: () => 1);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
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
    }
  }

  Widget _buildDateSelectionTab() {
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
                setState(() {
                  _selectedCollectionDate = pickedDate;
                });
              }
            },
            controller: TextEditingController(
                text: _selectedCollectionDate?.toString()),
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
                setState(() {
                  _selectedDeliveryDate = pickedDate;
                });
              }
            },
            controller:
                TextEditingController(text: _selectedDeliveryDate?.toString()),
          ),
          const SizedBox(height: 24),
          _buildConfirmationButton(),
        ],
      ),
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final items = _selectedArticles.entries
          .map((e) => ({'articleId': e.key, 'quantity': e.value}))
          .toList();
      final response = await authProvider.dio.post('/orders', data: {
        'serviceId': _selectedService!.id,
        'items': items,
        'collectionDate': _selectedCollectionDate?.toIso8601String(),
        'deliveryDate': _selectedDeliveryDate?.toIso8601String(),
      });
      if (response.statusCode == 200) {
        Navigator.pop(context);
        log('Order created successfully');
      } else {
        _error = 'Failed to create order';
      }
    } on DioException catch (e) {
      _error = 'Connection error: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

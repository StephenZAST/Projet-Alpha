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
    return Service(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
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
    return ArticleCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
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
    return Article(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
      description: json['description'],
      basePrice: json['basePrice'].toDouble(),
      premiumPrice: json['premiumPrice'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class OrderBottomSheet extends StatefulWidget {
  const OrderBottomSheet({super.key});

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
    _fetchServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.dio.get('/services/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _services = data.map((e) => Service.fromJson(e)).toList();
      } else {
        _error = 'Failed to load services';
      }
    } on DioException catch (e) {
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
      final categoriesResponse =
          await authProvider.dio.get('/article-categories/');
      final articlesResponse = await authProvider.dio.get('/articles/');
      if (categoriesResponse.statusCode == 200 &&
          articlesResponse.statusCode == 200) {
        final List<dynamic> categoriesData = categoriesResponse.data;
        _articleCategories =
            categoriesData.map((e) => ArticleCategory.fromJson(e)).toList();
        final List<dynamic> articlesData = articlesResponse.data;
        _articles = articlesData.map((e) => Article.fromJson(e)).toList();
      } else {
        _error = 'Failed to load articles or categories';
      }
    } on DioException catch (e) {
      _error = 'Connection error: $e';
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
            controller: _tabController,
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
              controller: _tabController,
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
      return Stack(
        children: [
          ListView.builder(
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
                  log('Selected service: ${service.name}');
                },
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildNextButton(onNext: () {
              _fetchArticles();
              _tabController.animateTo(1);
            }),
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
    } else {
      return DefaultTabController(
        length: _articleCategories.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppColors.primaryShadow],
              ),
              tabs: _articleCategories
                  .map((category) => Tab(text: category.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
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
                            Text(_selectedArticles[article.id]?.toString() ??
                                '0'),
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
                        onTap: () {
                          // TODO: Implement article selection
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child:
                  _buildNextButton(onNext: () => _tabController.animateTo(2)),
            ),
          ],
        ),
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

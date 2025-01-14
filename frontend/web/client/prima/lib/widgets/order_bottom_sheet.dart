import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';

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

class OrderBottomSheet extends StatefulWidget {
  @override
  _OrderBottomSheetState createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet>
    with TickerProviderStateMixin {
  late TabController _articleTabController;
  Service? _selectedService;
  Map<String, int> _selectedArticles = {};

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with a default length
    _articleTabController = TabController(length: 1, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articleProvider =
          Provider.of<ArticleProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      articleProvider.loadCategories().then((_) {
        // Update the length of the TabController once categories are loaded
        _articleTabController.dispose(); // Dispose the old controller
        _articleTabController = TabController(
          length: articleProvider.categories.length,
          vsync: this,
        );
        if (mounted) setState(() {});
      });

      serviceProvider.loadServices();
    });
  }

  @override
  void dispose() {
    _articleTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ArticleProvider, ServiceProvider>(
      builder: (context, articleProvider, serviceProvider, child) {
        if (articleProvider.isLoading || serviceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (articleProvider.error != null || serviceProvider.error != null) {
          return Center(
            child: Text(articleProvider.error ??
                serviceProvider.error ??
                'Error loading data'),
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildServiceSelection(serviceProvider),
                  _buildCategoryTabs(articleProvider),
                  _buildArticleList(articleProvider, scrollController),
                  _buildOrderSummary(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceSelection(ServiceProvider serviceProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: DropdownButton<Service>(
        isExpanded: true,
        value: _selectedService,
        hint: const Text('Select a service'),
        items: serviceProvider.services.map((service) {
          return DropdownMenuItem<Service>(
            value: service,
            child: Text('${service.name} - ${service.price}€'),
          );
        }).toList(),
        onChanged: (Service? service) {
          setState(() => _selectedService = service);
        },
      ),
    );
  }

  Widget _buildCategoryTabs(ArticleProvider articleProvider) {
    return TabBar(
      controller: _articleTabController,
      isScrollable: true,
      tabs: articleProvider.categories.map((category) {
        return Tab(text: category.name);
      }).toList(),
    );
  }

  Widget _buildArticleList(
      ArticleProvider articleProvider, ScrollController scrollController) {
    return Expanded(
      child: TabBarView(
        controller: _articleTabController,
        children: articleProvider.categories.map((category) {
          return ListView.builder(
            controller: scrollController,
            itemCount:
                articleProvider.getArticlesForCategory(category.id).length,
            itemBuilder: (context, index) {
              final article =
                  articleProvider.getArticlesForCategory(category.id)[index];
              return _buildArticleItem(article);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArticleItem(Article article) {
    final quantity = _selectedArticles[article.id] ?? 0;

    return ListTile(
      title: Text(article.name),
      subtitle: Text('${article.basePrice}€'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: quantity > 0
                ? () {
                    setState(() {
                      if (quantity > 1) {
                        _selectedArticles[article.id] = quantity - 1;
                      } else {
                        _selectedArticles.remove(article.id);
                      }
                    });
                  }
                : null,
          ),
          Text('$quantity'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _selectedArticles[article.id] = quantity + 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Total Items: ${_selectedArticles.values.fold(0, (sum, quantity) => sum + quantity)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedService != null && _selectedArticles.isNotEmpty
                ? () => _proceedToCheckout()
                : null,
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    // Implement checkout logic
  }
}

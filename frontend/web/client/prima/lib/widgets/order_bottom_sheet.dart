import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';
import 'package:prima/models/order.dart';

import 'package:prima/models/article_category.dart';

class OrderBottomSheet extends StatefulWidget {
  final Function(Order)? onOrderCreated;

  const OrderBottomSheet({Key? key, this.onOrderCreated}) : super(key: key);
  @override
  _OrderBottomSheetState createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  Service? _selectedService;
  ArticleCategory? _selectedCategory;
  final Map<String, int> _selectedArticles = {};
  DateTime? _collectionDate;
  DateTime? _deliveryDate;
  bool _isLoading = false;

  int _currentStep = 0;
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final articleProvider = context.read<ArticleProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    setState(() => _isLoading = true);
    try {
      await Future.wait([
        articleProvider.loadCategories(),
        serviceProvider.loadServices(),
      ]);

      _categoryTabController = TabController(
        length: articleProvider.categories.length,
        vsync: this,
      );
    } catch (e) {
      _showError('Erreur de chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildServiceSelection(),
                _buildArticleSelection(),
                _buildDateSelection(),
                _buildOrderSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Consumer<ServiceProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.services.length,
          itemBuilder: (context, index) {
            final service = provider.services[index];
            return _buildServiceCard(service);
          },
        );
      },
    );
  }

  Widget _buildServiceCard(Service service) {
    final isSelected = _selectedService?.id == service.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectService(service),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_laundry_service,
                    color: isSelected ? AppColors.primary : AppColors.gray500,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (service.price != null)
                    Text(
                      '${service.price}€',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray600,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
              if (service.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  service.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Text(
            'Nouvelle commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStepItem(0, 'Service', Icons.local_laundry_service),
          _buildStepDivider(_currentStep > 0),
          _buildStepItem(1, 'Articles', Icons.category),
          _buildStepDivider(_currentStep > 1),
          _buildStepItem(2, 'Date', Icons.calendar_today),
          _buildStepDivider(_currentStep > 2),
          _buildStepItem(3, 'Résumé', Icons.receipt_long),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    final isCompleted = _currentStep > step;
    final isActive = _currentStep == step;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: isCompleted || isActive
                  ? AppColors.primary
                  : AppColors.gray400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.gray400,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDivider(bool isCompleted) {
    return Container(
      width: 30,
      height: 1,
      color: isCompleted ? AppColors.primary : AppColors.gray300,
    );
  }

  Widget _buildArticleSelection() {
    return Consumer<ArticleProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie disponible'));
        }

        return Column(
          children: [
            TabBar(
              controller: _categoryTabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              tabs: provider.categories
                  .map((category) => Tab(text: category.name))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _categoryTabController,
                children: provider.categories.map((category) {
                  return _buildArticleList(category, provider);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleList(ArticleCategory category, ArticleProvider provider) {
    final articles = provider.getArticlesForCategory(category.id);

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              'Aucun article dans cette catégorie',
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) => _buildArticleCard(articles[index]),
    );
  }

  Widget _buildArticleCard(Article article) {
    final quantity = _selectedArticles[article.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${article.basePrice}€',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantityControls(article.id, quantity),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(String articleId, int quantity) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: quantity > 0
              ? () => setState(() {
                    if (quantity == 1) {
                      _selectedArticles.remove(articleId);
                    } else {
                      _selectedArticles[articleId] = quantity - 1;
                    }
                  })
              : null,
          color: quantity > 0 ? AppColors.primary : AppColors.gray400,
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => setState(() {
            _selectedArticles[articleId] = quantity + 1;
          }),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateField(
            label: 'Date de collecte',
            value: _collectionDate,
            onSelect: (date) {
              setState(() {
                _collectionDate = date;
                // Proposer une date de livraison automatique (+3 jours)
                _deliveryDate = date?.add(const Duration(days: 3));
              });
            },
            minDate: DateTime.now(),
          ),
          const SizedBox(height: 24),
          _buildDateField(
            label: 'Date de livraison',
            value: _deliveryDate,
            onSelect: (date) => setState(() => _deliveryDate = date),
            minDate: _collectionDate?.add(const Duration(days: 1)) ??
                DateTime.now().add(const Duration(days: 1)),
          ),
          const Spacer(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onSelect,
    required DateTime minDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray700,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, value, onSelect, minDate),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  value?.toString().split(' ')[0] ?? 'Sélectionner une date',
                  style: TextStyle(
                    color:
                        value != null ? AppColors.gray800 : AppColors.gray500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onSelect,
    DateTime minDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onSelect(picked);
  }

  Widget _buildOrderSummary() {
    final totalItems = _selectedArticles.values
        .fold<int>(0, (sum, quantity) => sum + quantity);
    double totalAmount = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(
            title: 'Service sélectionné',
            child: ListTile(
              leading:
                  Icon(Icons.local_laundry_service, color: AppColors.primary),
              title: Text(_selectedService?.name ?? ''),
              subtitle: Text(_selectedService?.description ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Articles sélectionnés',
            child: Column(
              children: [
                ..._selectedArticles.entries.map((entry) {
                  final article = _findArticle(entry.key);
                  if (article == null) return const SizedBox();
                  final itemTotal = article.basePrice * entry.value;
                  totalAmount += itemTotal;

                  return ListTile(
                    title: Text(article.name),
                    trailing: Text(
                      '${entry.value}x - ${itemTotal.toStringAsFixed(2)}€',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                const Divider(),
                ListTile(
                  title: const Text('Total'),
                  trailing: Text(
                    '${totalAmount.toStringAsFixed(2)}€',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Dates',
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.upload, color: AppColors.primary),
                  title: const Text('Collecte'),
                  subtitle: Text(_collectionDate?.toString().split(' ')[0] ??
                      'Non sélectionnée'),
                ),
                ListTile(
                  leading: Icon(Icons.download, color: AppColors.primary),
                  title: const Text('Livraison'),
                  subtitle: Text(_deliveryDate?.toString().split(' ')[0] ??
                      'Non sélectionnée'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildConfirmOrderButton(totalAmount),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.gray700,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildConfirmOrderButton(double totalAmount) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _createOrder(totalAmount),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Confirmer la commande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Article? _findArticle(String articleId) {
    final articleProvider =
        Provider.of<ArticleProvider>(context, listen: false);
    return articleProvider.articles.firstWhere(
      (article) => article.id == articleId,
      orElse: () => throw Exception('Article non trouvé'),
    );
  }

  Future<void> _createOrder(double totalAmount) async {
    // Implémenter la création de la commande
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            setState(() => _currentStep--);
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: const Text('Retour'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_collectionDate != null && _deliveryDate != null) {
              setState(() => _currentStep++);
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  void _selectService(Service service) {
    setState(() {
      _selectedService = service;
      _currentStep = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Continue with other widget implementations...
  // Add methods for date selection, article selection, and order creation
  // I'll provide these in the next response to keep this organized
}

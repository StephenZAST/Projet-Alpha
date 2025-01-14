import 'package:flutter/material.dart';
import 'package:prima/models/article.dart';
import 'package:prima/models/service.dart';
import 'package:prima/models/order.dart'
    hide OrderItem; // Masquer OrderItem de order.dart
import 'package:prima/models/order_item.dart'; // Utiliser OrderItem de ce fichier
import 'package:prima/models/order_item_summary.dart';
import 'package:prima/widgets/order_progress_stepper.dart';
import 'package:prima/widgets/animated_tab_view.dart';
import 'package:prima/widgets/article_selection_view.dart';
import 'package:prima/widgets/order_summary.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewOrderBottomSheet extends ConsumerStatefulWidget {
  const NewOrderBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<NewOrderBottomSheet> createState() =>
      _NewOrderBottomSheetState();
}

class _NewOrderBottomSheetState extends ConsumerState<NewOrderBottomSheet> {
  late TabController _tabController;
  int _currentStep = 0;

  Service?
      _selectedService; // Ajout de la variable pour stocker le service sélectionné
  String? _selectedServiceId;
  Map<String, int> _selectedArticles = {};
  DateTime? _collectionDate;
  DateTime? _deliveryDate;

  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );

    // Modification du chargement initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!_mounted) return;

    try {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      await provider.loadServices();

      if (_mounted) {
        setState(() {
          // Force rebuild after services are loaded
        });
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              OrderProgressStepper(currentStep: _currentStep),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AnimatedTabView(
                        controller: _tabController,
                        children: [
                          _buildServiceSelection(),
                          _buildArticleSelection(),
                          _buildDateSelection(),
                          _buildConfirmation(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Nouvelle Commande',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Pour équilibrer le layout
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return ref.watch(servicesNotifierProvider).when(
          data: (services) {
            if (services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Aucun service disponible'),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(servicesNotifierProvider.notifier)
                            .loadServices();
                      },
                      child: const Text('Rafraîchir'),
                    ),
                  ],
                ),
              );
            }
            return _buildServicesList(services);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () {
                    ref.read(servicesNotifierProvider.notifier).loadServices();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildEmptyServicesView(ArticleProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Aucun service disponible',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.loadServices(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<Service> services) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<ArticleProvider>().loadServices();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedServiceId = service.id;
                        _selectedService = service;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedServiceId == service.id
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Radio<String>(
                                value: service.id,
                                groupValue: _selectedServiceId,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedServiceId = value;
                                      _selectedService = service;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          if (service.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              service.description!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Prix: \$${service.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_selectedService != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNextButton(
              onNext: () {
                _fetchArticles();
                _tabController.animateTo(1);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildArticleSelection() {
    return ArticleSelectionView(
      onArticlesSelected: (selectedArticles) {
        setState(() {
          _selectedArticles = selectedArticles;
        });
      },
      initialSelection: _selectedArticles,
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sélectionnez vos dates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Date de collecte',
            value: _collectionDate,
            onTap: () => _selectDate(isCollection: true),
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Date de livraison',
            value: _deliveryDate,
            onTap: () => _selectDate(isCollection: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value != null
                  ? '${value.day}/${value.month}/${value.year}'
                  : 'Sélectionner une date',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmation() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrderSummary(
                serviceName:
                    _selectedService?.name ?? 'Service non sélectionné',
                items: _selectedArticles.entries.map((e) {
                  // Récupérer l'article correspondant à partir du provider
                  final article =
                      context.read<ArticleProvider>().findArticleById(e.key);

                  return OrderItemSummary(
                    name: article?.name ?? 'Article inconnu',
                    quantity: e.value,
                    unitPrice: article?.basePrice ?? 0,
                  );
                }).toList(),
                collectionDate: _collectionDate,
                deliveryDate: _deliveryDate,
                totalAmount: _calculateTotal(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Confirmer la commande',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate({required bool isCollection}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        if (isCollection) {
          _collectionDate = picked;
        } else {
          _deliveryDate = picked;
        }
      });
    }
  }

  Future<void> _createOrder() async {
    if (_selectedServiceId == null ||
        _collectionDate == null ||
        _deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final orderProvider = context.read<OrderProvider>();
      final articleProvider = context.read<ArticleProvider>();

      // Créer une structure de données simple pour l'API
      final orderItems = _selectedArticles.entries.map((e) {
        final article = articleProvider.findArticleById(e.key);
        return {
          'articleId': e.key,
          'serviceId': _selectedServiceId!,
          'quantity': e.value,
          'unitPrice': article?.basePrice ?? 0,
        };
      }).toList();

      await orderProvider.createOrder(
        serviceId: _selectedServiceId!,
        addressId: '...', // À implémenter
        collectionDate: _collectionDate!,
        deliveryDate: _deliveryDate!,
        items: orderItems,
      );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande créée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  // Ajout d'une méthode pour calculer le total
  double _calculateTotal() {
    double total = 0;
    for (var entry in _selectedArticles.entries) {
      final article =
          context.read<ArticleProvider>().findArticleById(entry.key);
      if (article != null) {
        total += article.basePrice * entry.value;
      }
    }
    return total;
  }

  Future<void> _fetchArticles() async {
    try {
      final articleProvider = context.read<ArticleProvider>();
      await articleProvider.loadCategories();
      if (articleProvider.categories.isNotEmpty) {
        for (var category in articleProvider.categories) {
          await articleProvider.loadArticlesForCategory(category.id);
        }
      }
      _tabController
          .animateTo(1); // Passer à l'onglet suivant après le chargement
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des articles: $e')),
      );
    }
  }

  Widget _buildNextButton({required VoidCallback onNext}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
        ),
        child: const Text(
          'Suivant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

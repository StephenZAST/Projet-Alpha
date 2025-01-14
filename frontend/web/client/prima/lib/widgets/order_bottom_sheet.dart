import 'package:flutter/material.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/models/order.dart';
import 'package:prima/models/service.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/models/article_category.dart';
import 'package:prima/widgets/order/service_selection.dart';
import 'package:prima/widgets/order/article_selection.dart';
import 'package:prima/widgets/order/date_selection.dart';
import 'package:prima/widgets/order/order_summary.dart';
import 'package:prima/widgets/order/bottom_sheet_header.dart';
import 'package:prima/widgets/order/order_stepper.dart';

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
        articleProvider.loadData(),
        serviceProvider.loadServices(),
      ]);

      if (mounted) {
        setState(() {
          _categoryTabController = TabController(
            length: articleProvider.categories.length,
            vsync: this,
          );
        });
      }
    } catch (e) {
      _showError('Erreur de chargement: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          const BottomSheetHeader(),
          OrderStepper(currentStep: _currentStep),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ServiceSelection(
                  selectedService: _selectedService,
                  onServiceSelected: _selectService,
                ),
                ArticleSelection(
                  selectedArticles: _selectedArticles,
                  categoryTabController: _categoryTabController,
                  onArticleQuantityChanged: (articleId, quantity) {
                    setState(() {
                      if (quantity == 0) {
                        _selectedArticles.remove(articleId);
                      } else {
                        _selectedArticles[articleId] = quantity;
                      }
                    });
                  },
                ),
                DateSelection(
                  collectionDate: _collectionDate,
                  deliveryDate: _deliveryDate,
                  onCollectionDateSelected: (date) {
                    setState(() {
                      _collectionDate = date;
                    });
                  },
                  onDeliveryDateSelected: (date) {
                    setState(() {
                      _deliveryDate = date;
                    });
                  },
                  onNext: () {
                    setState(() => _currentStep++);
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onPrevious: () {
                    setState(() => _currentStep--);
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                OrderSummary(
                  selectedService: _selectedService,
                  selectedArticles: _selectedArticles,
                  collectionDate: _collectionDate,
                  deliveryDate: _deliveryDate,
                  isLoading: _isLoading,
                  onConfirmOrder: () => _createOrder(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder(double totalAmount) async {
    setState(() => _isLoading = true);
    try {
      // Implémenter la création de la commande
      await Future.delayed(const Duration(seconds: 1));
      if (widget.onOrderCreated != null) {
        widget.onOrderCreated!(Order(
          id: '123',
          service: _selectedService!,
          articles: _selectedArticles.entries
              .map((e) => MapEntry(
                  context
                      .read<ArticleProvider>()
                      .articles
                      .firstWhere((element) => element.id == e.key),
                  e.value))
              .toList(),
          collectionDate: _collectionDate!,
          deliveryDate: _deliveryDate!,
          totalAmount: totalAmount,
          serviceId: _selectedService!.id,
          addressId: 'addressId',
          status: 'pending',
          isRecurring: false,
          recurrenceType: '',
        ));
      }
      Navigator.pop(context);
    } catch (e) {
      _showError('Erreur de création de la commande: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
}

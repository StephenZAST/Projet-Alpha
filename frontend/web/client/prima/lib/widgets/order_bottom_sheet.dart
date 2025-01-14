import 'package:flutter/material.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/models/order.dart';
import 'package:prima/models/service.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:prima/widgets/order/service_selection.dart';
import 'package:prima/widgets/order/article_selection.dart';
import 'package:prima/widgets/order/date_selection.dart';
import 'package:prima/widgets/order/order_summary.dart';
import 'package:prima/widgets/order/bottom_sheet_header.dart';

class OrderBottomSheet extends StatefulWidget {
  final Function(Order)? onOrderCreated;

  const OrderBottomSheet({Key? key, this.onOrderCreated}) : super(key: key);

  @override
  _OrderBottomSheetState createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet>
    with TickerProviderStateMixin {
  late PageController _pageController;
  Service? _selectedService;
  final Map<String, int> _selectedArticles = {};
  DateTime? _collectionDate;
  DateTime? _deliveryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() => _initData());
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ServiceSelection(
                  selectedService: _selectedService,
                  onServiceSelected: _handleServiceSelection,
                ),
                ArticleSelection(
                  selectedArticles: _selectedArticles,
                  onArticleQuantityChanged: _handleArticleQuantityChanged,
                ),
                DateSelection(
                  collectionDate: _collectionDate,
                  deliveryDate: _deliveryDate,
                  onCollectionDateSelected: _handleCollectionDateSelected,
                  onDeliveryDateSelected: _handleDeliveryDateSelected,
                  onNext: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  onPrevious: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
                OrderSummary(
                  selectedService: _selectedService,
                  selectedArticles: _selectedArticles,
                  collectionDate: _collectionDate,
                  deliveryDate: _deliveryDate,
                  onConfirmOrder: _handleConfirmOrder,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleServiceSelection(Service service) {
    setState(() {
      _selectedService = service;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleArticleQuantityChanged(String articleId, int quantity) {
    setState(() {
      if (quantity == 0) {
        _selectedArticles.remove(articleId);
      } else {
        _selectedArticles[articleId] = quantity;
      }
    });
  }

  void _handleCollectionDateSelected(DateTime? date) {
    setState(() => _collectionDate = date);
  }

  void _handleDeliveryDateSelected(DateTime? date) {
    setState(() => _deliveryDate = date);
  }

  Future<void> _handleConfirmOrder() async {
    // Implement order confirmation logic
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/order/service_selection_step.dart';
import 'package:prima/widgets/order/article_selection_step.dart';
import 'package:prima/widgets/order/date_selection_step.dart';
import 'package:prima/widgets/order/order_summary_step.dart';
import 'package:prima/models/service.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/providers/order_provider.dart';
import 'package:prima/widgets/order/components/step_indicator.dart';
import 'package:provider/provider.dart';

class OrderBottomSheet extends StatefulWidget {
  final Function(String)? onOrderCreated;

  const OrderBottomSheet({
    Key? key,
    this.onOrderCreated,
  }) : super(key: key);

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  Service? _selectedService;
  Map<String, int> _selectedArticles = {};
  DateTime? _collectionDate;
  DateTime? _deliveryDate;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    if (addressProvider.addresses.isEmpty) {
      await addressProvider.loadAddresses();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectService(Service service) {
    setState(() {
      _selectedService = service;
      _goToNextStep();
    });
  }

  void _updateArticles(Map<String, int> articles) {
    setState(() {
      _selectedArticles = articles;
    });
  }

  void _updateDates({DateTime? collection, DateTime? delivery}) {
    setState(() {
      _collectionDate = collection;
      _deliveryDate = delivery;
      if (collection != null && delivery != null) {
        _goToNextStep();
      }
    });
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _createOrder(double totalAmount) async {
    if (_selectedService == null ||
        _selectedArticles.isEmpty ||
        _collectionDate == null ||
        _deliveryDate == null) {
      _showError('Veuillez remplir tous les champs requis');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final addressProvider =
          Provider.of<AddressProvider>(context, listen: false);
      final defaultAddress = addressProvider.addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addressProvider.addresses.first,
      );

      if (defaultAddress == null) {
        throw Exception('Aucune adresse disponible');
      }

      final items = _selectedArticles.entries
          .map((entry) => {
                'articleId': entry.key,
                'quantity': entry.value,
              })
          .toList();

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.createOrder(
        serviceId: _selectedService!.id,
        addressId: defaultAddress.id,
        collectionDate: _collectionDate!,
        deliveryDate: _deliveryDate!,
        items: items,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Commande créée avec succès'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onOrderCreated?.call(orderProvider.currentOrder!.id);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
          const SizedBox(height: 8),
          OrderStepIndicator(
            currentStep: _currentStep,
            totalSteps: 4,
            stepTitles: const ['Service', 'Articles', 'Date', 'Résumé'],
            stepIcons: const [
              Icons.local_laundry_service,
              Icons.shopping_basket,
              Icons.calendar_today,
              Icons.receipt_long,
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ServiceSelectionStep(
                  onServiceSelected: _selectService,
                  selectedService: _selectedService,
                ),
                ArticleSelectionStep(
                  selectedArticles: _selectedArticles,
                  onArticlesUpdated: _updateArticles,
                ),
                DateSelectionStep(
                  collectionDate: _collectionDate,
                  deliveryDate: _deliveryDate,
                  onDatesSelected: _updateDates,
                  onNext: _goToNextStep,
                  onBack: _goToPreviousStep,
                ),
                OrderSummaryStep(
                  service: _selectedService,
                  articles: _selectedArticles,
                  collectionDate: _collectionDate,
                  deliveryDate: _deliveryDate,
                  onConfirm: _createOrder,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: AppColors.gray600,
          ),
          Text(
            'Nouvelle commande',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gray800,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 40), // Pour l'équilibre visuel
        ],
      ),
    );
  }
}

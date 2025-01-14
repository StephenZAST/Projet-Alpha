import 'package:flutter/material.dart';
import 'package:prima/widgets/order/service_selection_step.dart';
import 'package:prima/widgets/order/article_selection_step.dart';
import 'package:prima/widgets/order/date_selection_step.dart';
import 'package:prima/widgets/order/order_summary_step.dart';
// ...autres imports...

class OrderBottomSheet extends StatefulWidget {
  // ...existing code...
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
                ServiceSelectionStep(
                  onServiceSelected: _selectService,
                  selectedService: _selectedService,
                ),
                ArticleSelectionStep(
                  selectedArticles: _selectedArticles,
                  onArticlesUpdated: (articles) =>
                      setState(() => _selectedArticles = articles),
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

  // Méthodes de navigation et de gestion d'état
  void _selectService(Service service) {
    setState(() {
      _selectedService = service;
      _currentStep = 1;
    });
    _goToNextStep();
  }

  void _updateDates({DateTime? collection, DateTime? delivery}) {
    setState(() {
      _collectionDate = collection;
      _deliveryDate = delivery;
    });
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _goToPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep--);
  }

  // ...autres méthodes utilitaires...
}

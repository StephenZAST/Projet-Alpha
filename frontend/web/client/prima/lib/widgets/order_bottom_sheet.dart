import 'package:flutter/material.dart';
import 'package:prima/navigation/navigation_provider.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:prima/services/order_service.dart';
import 'package:prima/widgets/order/order_stepper.dart';
import 'package:prima/widgets/order/recurrence_selection.dart';
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
import 'package:spring_button/spring_button.dart';
import 'package:prima/widgets/order/order_confirmation_popup.dart';

class OrderBottomSheet extends StatefulWidget {
  final Function(Order)? onOrderCreated;

  const OrderBottomSheet({Key? key, this.onOrderCreated}) : super(key: key);

  @override
  _OrderBottomSheetState createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  int _currentStep = 0;
  Service? _selectedService;
  final Map<String, int> _selectedArticles = {};
  DateTime? _collectionDate;
  DateTime? _deliveryDate;
  bool _isLoading = false;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  String? _selectedAddressId;
  TimeOfDay? _collectionTime;
  TimeOfDay? _deliveryTime;

  @override
  void initState() {
    super.initState();
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

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return _selectedArticles.isNotEmpty;
      case 2:
        return _collectionDate != null && _deliveryDate != null;
      default:
        return true;
    }
  }

  void _goToNextStep() {
    if (_currentStep < 3 && _canProceedToNextStep()) {
      setState(() => _currentStep++);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ServiceSelection(
          selectedService: _selectedService,
          onServiceSelected: (service) {
            setState(() {
              _selectedService = service;
              _goToNextStep();
            });
          },
        );
      case 1:
        return ArticleSelection(
          selectedArticles: _selectedArticles,
          onArticleQuantityChanged: _handleArticleQuantityChanged,
        );
      case 2:
        return DateSelection(
          collectionDate: _collectionDate,
          deliveryDate: _deliveryDate,
          onCollectionDateSelected: _handleCollectionDateSelected,
          onDeliveryDateSelected: _handleDeliveryDateSelected,
          onNext: _goToNextStep,
          onPrevious: _goToPreviousStep,
          selectedRecurrence: _selectedRecurrence,
          onRecurrenceSelected: (type) =>
              setState(() => _selectedRecurrence = type),
          collectionTime: _collectionTime,
          deliveryTime: _deliveryTime,
          onCollectionTimeSelected: _handleCollectionTimeSelected,
          onDeliveryTimeSelected: _handleDeliveryTimeSelected,
        );
      case 3:
        return Consumer<AddressProvider>(
          builder: (context, addressProvider, _) => OrderSummary(
            selectedService: _selectedService,
            selectedArticles: _selectedArticles,
            collectionDate: _collectionDate,
            deliveryDate: _deliveryDate,
            collectionTime: _collectionTime,
            deliveryTime: _deliveryTime,
            selectedRecurrence: _selectedRecurrence,
            onConfirmOrder: _handleConfirmOrder,
            isLoading: _isLoading,
            selectedAddress: addressProvider.selectedAddress,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
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
          OrderStepper(currentStep: _currentStep),
          Expanded(child: _buildStepContent()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  SpringButton(
                    SpringButtonType.OnlyScale,
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Retour',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    onTap: _goToPreviousStep,
                    scaleCoefficient: 0.95,
                    useCache: false,
                  ),
                const Spacer(),
                if (_currentStep < 3)
                  SpringButton(
                    SpringButtonType.OnlyScale,
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [AppColors.primaryShadow],
                      ),
                      child: Center(
                        child: Text(
                          'Suivant',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    onTap: _canProceedToNextStep() ? _goToNextStep : null,
                    scaleCoefficient: 0.95,
                    useCache: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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

  void _handleCollectionTimeSelected(TimeOfDay? time) {
    setState(() => _collectionTime = time);
  }

  void _handleDeliveryTimeSelected(TimeOfDay? time) {
    setState(() => _deliveryTime = time);
  }

  Future<void> _handleConfirmOrder() async {
    print('🚀 Début de _handleConfirmOrder');

    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    final selectedAddress = addressProvider.selectedAddress;
    final rootContext = Navigator.of(context).context;

    print('📍 Adresse sélectionnée: ${selectedAddress?.name}');
    print('📍 Service sélectionné: ${_selectedService?.name}');
    print('📍 Articles sélectionnés: ${_selectedArticles.length}');
    print('📍 Date collecte: $_collectionDate');
    print('📍 Date livraison: $_deliveryDate');

    // Validation checks
    if (_selectedService == null ||
        _collectionDate == null ||
        _deliveryDate == null ||
        selectedAddress == null) {
      print('❌ Validation échouée');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    try {
      print('🔄 Début de la création de commande');
      setState(() => _isLoading = true);

      final items = _selectedArticles.entries.map((entry) {
        return {
          'articleId': entry.key,
          'quantity': entry.value,
        };
      }).toList();

      final dio = Provider.of<AuthProvider>(context, listen: false).dio;

      print('📤 Envoi de la requête API');
      final order = await OrderService(dio).createOrder(
        serviceId: _selectedService!.id,
        addressId: selectedAddress.id,
        collectionDate: _collectionDate!,
        deliveryDate: _deliveryDate!,
        items: items,
        affiliateCode: null,
        collectionTime: _collectionTime,
        deliveryTime: _deliveryTime,
        isRecurring: _selectedRecurrence != RecurrenceType.none,
        recurrenceType: _selectedRecurrence,
      );
      print('✅ Commande créée avec succès');

      if (!mounted) {
        print('❌ Widget non monté après création de commande');
        return;
      }

      print('🔄 Fermeture du bottom sheet');
      Navigator.of(context).pop();

      print('⏳ Attente après fermeture du bottom sheet');
      await Future.delayed(const Duration(milliseconds: 200));

      if (!rootContext.mounted) {
        print('❌ Context racine non monté');
        return;
      }

      print('🔄 Affichage du dialog de confirmation');
      await showDialog(
        context: rootContext,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (dialogContext) {
          print('🔄 Construction du dialog');
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: OrderConfirmationPopup(
                    onTrackOrder: () {
                      print('👆 Clic sur Suivre commande');
                      Navigator.of(dialogContext).pop();
                      Navigator.of(rootContext).pushNamed('/orders');
                    },
                    onContinueShopping: () {
                      print('👆 Clic sur Continuer');
                      Navigator.of(dialogContext).pop();
                      Provider.of<NavigationProvider>(rootContext,
                              listen: false)
                          .navigateToMainRoute(rootContext, '/home');
                    },
                  ),
                );
              },
            ),
          );
        },
      );
      print('✅ Dialog affiché avec succès');
    } catch (e) {
      print('❌ Erreur lors du processus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('🏁 Fin de _handleConfirmOrder');
    }
  }
}

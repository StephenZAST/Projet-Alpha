import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/redux/store.dart';
import 'package:prima/redux/actions/service_actions.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';
import 'package:prima/widgets/order_bottom_sheet.dart' as widgets;
import 'package:redux/redux.dart';
import 'package:prima/models/service.dart';

class ServiceSection extends StatefulWidget {
  const ServiceSection({Key? key}) : super(key: key);

  @override
  State<ServiceSection> createState() => _ServiceSectionState();
}

class _ServiceSectionState extends State<ServiceSection> {
  @override
  void initState() {
    super.initState();
    // Charger les services au montage du composant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context).dispatch(LoadServicesAction());
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (vm.error != null) {
          return Center(
            child: Text('Error: ${vm.error}'),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.services.length,
            itemBuilder: (context, index) {
              final service = vm.services[index];
              return GestureDetector(
                onTap: () {
                  // Sélectionner le service
                  vm.selectService(service);

                  // Afficher le bottom sheet avec le service sélectionné
                  BottomSheetManager().showCustomBottomSheet(
                    context: context,
                    builder: (context) => widgets.OrderBottomSheet(
                      initialService: service,
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/${service.name}.png',
                          width: 24,
                          height: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final List<Service> services;
  final bool isLoading;
  final String? error;
  final Function(Service) selectService;

  _ViewModel({
    required this.services,
    required this.isLoading,
    this.error,
    required this.selectService,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      services: store.state.serviceState.services,
      isLoading: store.state.serviceState.isLoading,
      error: store.state.serviceState.error,
      selectService: (service) => store.dispatch(SelectServiceAction(service)),
    );
  }
}

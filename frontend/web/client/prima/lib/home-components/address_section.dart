import 'package:flutter/material.dart';
import 'package:prima/models/address.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';
import 'package:redux/redux.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prima/widgets/address_bottom_sheet.dart';
import 'package:prima/widgets/address_list_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/redux/actions/address_actions.dart';

class AddressSectionComponent extends StatelessWidget {
  const AddressSectionComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(LoadAddressesAction()),
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAddressBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.labelColor),
                        const SizedBox(width: 12),
                        Text(
                          vm.selectedAddress?.name ?? 'Ajouter une adresse',
                          style: TextStyle(
                            color: AppColors.labelColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [AppColors.primaryShadow],
                  ),
                  child: const Icon(Icons.map, color: AppColors.white),
                ),
                onTap: () => _showAddressBottomSheet(context),
                scaleCoefficient: 0.9,
                useCache: false,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    // Utiliser BottomSheetManager au lieu de showModalBottomSheet
    BottomSheetManager().showCustomBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) => const AddressListBottomSheet(),
    );
  }
}

class _ViewModel {
  final Address? selectedAddress;

  _ViewModel({
    this.selectedAddress,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      selectedAddress: store.state.addressState.selectedAddress,
    );
  }
}

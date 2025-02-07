import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/app_button.dart';
import '../../../controllers/address_controller.dart';

class AddressSelectionMap extends StatefulWidget {
  final Address? initialAddress;
  final Function(Address) onAddressSelected;
  final VoidCallback? onAddNewAddress;

  const AddressSelectionMap({
    Key? key,
    this.initialAddress,
    required this.onAddressSelected,
    this.onAddNewAddress,
  }) : super(key: key);

  @override
  _AddressSelectionMapState createState() => _AddressSelectionMapState();
}

class _AddressSelectionMapState extends State<AddressSelectionMap> {
  final MapController _mapController = MapController();
  Address? _selectedAddress;
  final addressController = Get.find<AddressController>();

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
  }

  void _centerOnAddress(Address address) {
    if (address.gpsLatitude != null && address.gpsLongitude != null) {
      _mapController.move(
        LatLng(address.gpsLatitude!, address.gpsLongitude!),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.borderLight,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLG,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedAddress?.gpsLatitude != null
                        ? LatLng(
                            _selectedAddress!.gpsLatitude!,
                            _selectedAddress!.gpsLongitude!,
                          )
                        : const LatLng(5.3484, -4.0305), // Abidjan
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.alpha.admin',
                    ),
                    MarkerLayer(
                      markers: addressController.addresses
                          .map((address) {
                            if (address.gpsLatitude == null ||
                                address.gpsLongitude == null) {
                              return null;
                            }
                            return Marker(
                              point: LatLng(
                                address.gpsLatitude!,
                                address.gpsLongitude!,
                              ),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAddress = address;
                                  });
                                  widget.onAddressSelected(address);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: address.id == _selectedAddress?.id
                                        ? AppColors.primary
                                        : AppColors.gray400,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: address.id == _selectedAddress?.id
                                        ? 24
                                        : 20,
                                  ),
                                ),
                              ),
                            );
                          })
                          .whereType<Marker>()
                          .toList(),
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      if (widget.onAddNewAddress != null)
                        AppButton(
                          icon: Icons.add_location_alt,
                          label: 'Nouvelle adresse',
                          onPressed: widget.onAddNewAddress!,
                          variant: AppButtonVariant.secondary,
                        ),
                      if (_selectedAddress != null) ...[
                        const SizedBox(height: 8),
                        AppButton(
                          icon: Icons.center_focus_strong,
                          label: 'Centrer',
                          onPressed: () => _centerOnAddress(_selectedAddress!),
                          variant: AppButtonVariant.secondary,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_selectedAddress != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.radiusMD,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedAddress?.name ?? 'Sans nom',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 4),
                          if (_selectedAddress?.street != null)
                            Text(
                              _selectedAddress!.street,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          Text(
                            [
                              _selectedAddress?.city,
                              _selectedAddress?.postalCode,
                            ].where((e) => e != null).join(' '),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Obx(() {
          final addresses = addressController.addresses;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                title: Text(address.name ?? 'Sans nom'),
                subtitle: Text(address.fullAddress),
                selected: _selectedAddress?.id == address.id,
                onTap: () {
                  setState(() => _selectedAddress = address);
                  widget.onAddressSelected(address);
                },
              );
            },
          );
        }),
      ],
    );
  }
}

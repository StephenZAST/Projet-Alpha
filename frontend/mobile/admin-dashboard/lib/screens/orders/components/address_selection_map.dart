import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../constants.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/app_button.dart';

class AddressSelectionMap extends StatefulWidget {
  final Address? selectedAddress;
  final List<Address> addresses;
  final Function(Address) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const AddressSelectionMap({
    Key? key,
    this.selectedAddress,
    required this.addresses,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  }) : super(key: key);

  @override
  State<AddressSelectionMap> createState() => _AddressSelectionMapState();
}

class _AddressSelectionMapState extends State<AddressSelectionMap> {
  late MapController _mapController;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedAddress = widget.selectedAddress;
    if (_selectedAddress != null) {
      _centerOnAddress(_selectedAddress!);
    }
  }

  void _centerOnAddress(Address address) {
    if (address.gpsLatitude != null && address.gpsLongitude != null) {
      _mapController.move(
        LatLng(address.gpsLatitude!, address.gpsLongitude!),
        15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.alpha.admin',
                ),
                MarkerLayer(
                  markers: widget.addresses
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
                  AppButton(
                    icon: Icons.add_location_alt,
                    label: 'Nouvelle adresse',
                    onPressed: widget.onAddNewAddress,
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
                        _selectedAddress!.name,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedAddress!.street,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_selectedAddress!.city} ${_selectedAddress!.postalCode}',
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
    );
  }
}

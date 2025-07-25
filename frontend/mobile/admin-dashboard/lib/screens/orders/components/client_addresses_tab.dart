import 'package:admin/services/address_service.dart';
import 'package:flutter/material.dart';
import '../../../models/address.dart';
import '../../../widgets/shared/app_button.dart';

class ClientAddressesTab extends StatelessWidget {
  final String? userId;
  final Function(Address) onAddressSelected;
  final VoidCallback? onAddNewAddress;
  final Address? selectedAddress;

  const ClientAddressesTab({
    Key? key,
    required this.userId,
    required this.onAddressSelected,
    this.onAddNewAddress,
    this.selectedAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Address>>(
      future: userId != null
          ? AddressService.getAddressesByUser(userId!)
          : Future.value([]),
      builder: (context, snapshot) {
        final addresses = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adresses du client',
                    style: Theme.of(context).textTheme.titleMedium),
                if (onAddNewAddress != null)
                  AppButton(
                    icon: Icons.add_location_alt,
                    label: 'Nouvelle adresse',
                    onPressed: onAddNewAddress!,
                    variant: AppButtonVariant.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : addresses.isEmpty
                      ? Center(child: Text('Aucune adresse enregistrée.'))
                      : ListView.separated(
                          itemCount: addresses.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final address = addresses[index];
                            final isSelected = selectedAddress != null &&
                                address.id == selectedAddress!.id;
                            return ListTile(
                              title: Text(address.name ?? 'Sans nom'),
                              subtitle: Text(address.fullAddress),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color:
                                          Theme.of(context).colorScheme.primary)
                                  : Icon(Icons.chevron_right),
                              selected: isSelected,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08),
                              onTap: () => onAddressSelected(address),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

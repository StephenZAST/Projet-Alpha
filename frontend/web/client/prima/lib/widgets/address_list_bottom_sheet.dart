import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/address_bottom_sheet.dart';
import 'package:prima/widgets/address_card.dart';
import 'package:prima/providers/address_provider.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

class AddressListBottomSheet extends StatelessWidget {
  const AddressListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<AddressProvider>(
              builder: (context, addressProvider, child) {
                if (addressProvider.addresses.isEmpty) {
                  return const Center(
                    child: Text('Aucune adresse enregistrée'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addressProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    return AddressCard(
                      address: address,
                      onEdit: () {
                        // TODO: Implement edit functionality
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer l\'adresse'),
                            content: const Text(
                                'Êtes-vous sûr de vouloir supprimer cette adresse ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Supprimer',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await addressProvider.deleteAddress(address.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          BackButton(color: AppColors.white),
          const Text(
            'Mes adresses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [AppColors.primaryShadow],
          ),
          child: const Center(
            child: Text(
              'Ajouter une nouvelle adresse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddressBottomSheet(),
          );
        },
      ),
    );
  }
}

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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Consumer<AddressProvider>(
                  builder: (context, addressProvider, child) {
                    if (addressProvider.addresses.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: addressProvider.addresses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final address = addressProvider.addresses[index];
                        return Dismissible(
                          key: Key(address.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 24,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer l\'adresse'),
                                content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer cette adresse ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Supprimer',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            return confirm ?? false;
                          },
                          onDismissed: (direction) async {
                            await addressProvider.deleteAddress(address.id);
                          },
                          child: AddressCard(
                            address: address,
                            onEdit: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => AddressBottomSheet(
                                  address: address,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildAddButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          BackButton(color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Mes adresses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_off_outlined,
          size: 48,
          color: AppColors.gray400,
        ),
        const SizedBox(height: 16),
        Text(
          'Aucune adresse enregistrée',
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        _buildAddButtonInline(context),
      ],
    );
  }

  Widget _buildAddButtonInline(BuildContext context) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [AppColors.primaryShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Ajouter une adresse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onTap: () => _showAddressBottomSheet(context),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Hero(
      tag: 'addAddressButton',
      child: SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [AppColors.primaryShadow],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
        onTap: () => _showAddressBottomSheet(context),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddressBottomSheet(),
    );
  }
}

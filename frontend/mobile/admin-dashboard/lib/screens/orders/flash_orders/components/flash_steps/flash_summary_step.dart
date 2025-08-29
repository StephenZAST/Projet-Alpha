import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:admin/models/flash_order_draft.dart';
import 'package:admin/models/user.dart';
import 'package:admin/models/address.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/services/user_service.dart';
import 'package:admin/services/address_service.dart';
import 'package:admin/services/service_service.dart';
import 'package:admin/services/service_type_service.dart';
import 'package:flutter/material.dart';

class FlashSummaryStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashSummaryStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashSummaryStep> createState() => _FlashSummaryStepState();
}

class _FlashSummaryStepState extends State<FlashSummaryStep> {
  User? user;
  Address? address;
  Service? service;
  ServiceType? serviceType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllInfos();
  }

  @override
  void didUpdateWidget(covariant FlashSummaryStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchAllInfos();
  }

  List<Map<String, dynamic>> couples = [];
  Future<void> _fetchAllInfos() async {
    final draft = widget.controller.draft.value;
    setState(() => isLoading = true);
    try {
      if (draft.userId != null) {
        user = await UserService.getUserById(draft.userId!);
      }
      if (draft.addressId != null) {
        address = await AddressService.getAddressById(draft.addressId!);
      }
      if (draft.serviceId != null) {
        final services = await ServiceService.getAllServices();
        service = services.isNotEmpty
            ? services.firstWhere((s) => s.id == draft.serviceId,
                orElse: () => services.first)
            : null;
      }
      if (draft.serviceTypeId != null) {
        final types = await ServiceTypeService.getAllServiceTypes();
        serviceType = types.isNotEmpty
            ? types.firstWhere((t) => t.id == draft.serviceTypeId,
                orElse: () => types.first)
            : null;
      }
      // Récupérer les couples pour le calcul du total
      if (draft.serviceTypeId != null && draft.serviceId != null) {
        couples = await ArticleServiceCoupleService.getCouplesForServiceType(
          serviceTypeId: draft.serviceTypeId!,
          serviceId: draft.serviceId!,
        );
        // Synchronise les articles avec les couples de prix
        widget.controller.syncSelectedItemsFrom(couples: couples);
      }
    } catch (e) {
      // TODO: Afficher un snackbar d'erreur
    }
    setState(() => isLoading = false);
  }

  int _calculateTotal() {
    final draft = widget.controller.draft.value;
    int total = 0;
    for (var item in draft.items) {
      final couple = couples.firstWhere(
        (c) => c['article_id'] == item.articleId,
        orElse: () => <String, dynamic>{},
      );
      final basePrice = (couple['base_price'] ?? 0) as num;
      final premiumPrice = (couple['premium_price'] ?? basePrice) as num;
      final isPremium = item.isPremium;
      final quantity = item.quantity;
      total +=
          quantity * (isPremium ? premiumPrice.toInt() : basePrice.toInt());
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.controller.draft.value;
    // Log du payload pour debug
    print('[RECAP] Payload draft au recap:');
    print(draft.toPayload());
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Récapitulatif de la commande flash',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 16),
                _buildClientSummary(),
                Divider(),
                _buildAddressSummary(),
                Divider(),
                _buildServiceSummary(),
                Divider(),
                _buildArticlesSummary(draft),
                Divider(),
                _buildExtraFieldsSummary(draft),
                SizedBox(height: 16),
                _buildTotalSection(),
              ],
            ),
          );
  }

  Widget _buildClientSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client associé', style: TextStyle(fontWeight: FontWeight.w600)),
        if (user != null) ...[
          Text('Nom : ${user!.firstName} ${user!.lastName}'),
          Text('Email : ${user!.email}'),
          if (user!.phone != null) Text('Téléphone : ${user!.phone}'),
        ] else ...[
          Text('ID : -'),
        ],
      ],
    );
  }

  Widget _buildAddressSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adresse', style: TextStyle(fontWeight: FontWeight.w600)),
        if (address != null) ...[
          Text('Nom : ${address!.name ?? '-'}'),
          Text('Ville : ${address!.city}'),
          Text('Rue : ${address!.street}'),
        ] else ...[
          Text('ID : -'),
        ],
      ],
    );
  }

  Widget _buildServiceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service', style: TextStyle(fontWeight: FontWeight.w600)),
        if (serviceType != null) Text('Type : ${serviceType!.name}'),
        if (service != null) Text('Service : ${service!.name}'),
      ],
    );
  }

  Widget _buildArticlesSummary(FlashOrderDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Articles/Services',
            style: TextStyle(fontWeight: FontWeight.w600)),
        ...draft.items.map((item) {
          final couple = couples.firstWhere(
            (c) => c['article_id'] == item.articleId,
            orElse: () => <String, dynamic>{},
          );
          final name = couple['article_name'] ?? item.articleId;
          final price = item.isPremium
              ? (couple['premium_price'] ?? 0)
              : (couple['base_price'] ?? 0);
          return Text('$name x${item.quantity} - ${price} FCFA');
        }),
      ],
    );
  }

  Widget _buildExtraFieldsSummary(FlashOrderDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations complémentaires',
            style: TextStyle(fontWeight: FontWeight.w600)),
        Text(
            'Date collecte: ${draft.collectionDate != null ? draft.collectionDate!.toLocal().toString().split(' ')[0] : '-'}'),
        Text(
            'Date livraison: ${draft.deliveryDate != null ? draft.deliveryDate!.toLocal().toString().split(' ')[0] : '-'}'),
        if (draft.note != null && draft.note!.trim().isNotEmpty)
          Text('Note: ${draft.note}'),
      ],
    );
  }

  Widget _buildTotalSection() {
    final total = _calculateTotal();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total estimé',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('$total F CFA',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange)),
        ],
      ),
    );
  }
}

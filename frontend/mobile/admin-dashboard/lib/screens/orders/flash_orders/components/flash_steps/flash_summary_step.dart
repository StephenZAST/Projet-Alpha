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
import 'package:admin/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  List<Address> addresses = [];
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
      // Récupérer toutes les adresses de l'utilisateur une seule fois
      if (draft.userId != null) {
        addresses = await AddressService.getAddressesByUser(draft.userId!);
      }
      // Sélectionner l'adresse à partir de la liste locale
      if (draft.addressId != null && addresses.isNotEmpty) {
        address = addresses.firstWhere(
          (a) => a.id == draft.addressId,
          orElse: () => addresses.first,
        );
      } else {
        address = null;
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
        setState(() {}); // Forcer le rafraîchissement après la synchro
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
      total += (item.unitPrice * item.quantity).toInt();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.controller.draft.value;
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Récapitulatif de la commande',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 20),
                _buildSection('Informations client', _buildClientSummary()),
                _buildDivider(),
                _buildSection('Adresse', _buildAddressSummary()),
                _buildDivider(),
                _buildSection('Service', _buildServiceSummary()),
                _buildDivider(),
                _buildSection('Articles', _buildArticlesSummary(draft)),
                _buildDivider(),
                _buildSection('Informations complémentaires',
                    _buildExtraFieldsSummary(draft)),
                SizedBox(height: 16),
                _buildTotalSection(),
              ],
            ),
          );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1),
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
        if (draft.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Aucun article/service sélectionné',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...draft.items.map((item) {
            final name = item.articleName ?? item.articleId;
            final price = item.unitPrice;
            final premiumLabel = item.isPremium ? ' (Premium)' : '';
            return Text(
                '$name x${item.quantity}$premiumLabel - ${(price * item.quantity).toStringAsFixed(0)} FCFA');
          }),
      ],
    );
  }

  Widget _buildExtraFieldsSummary(FlashOrderDraft draft) {
    String? statusLabel;
    Color? statusColor;
    IconData? statusIcon;
    if (draft.status != null) {
      final statusEnum =
          OrderStatus.values.firstWhereOrNull((s) => s.name == draft.status);
      statusLabel = statusEnum?.label;
      statusColor = statusEnum?.color;
      statusIcon = statusEnum?.icon;
    }
    String? paymentLabel;
    if (draft.paymentMethod != null) {
      final paymentEnum = PaymentMethod.values
          .firstWhereOrNull((p) => p.name == draft.paymentMethod);
      paymentLabel = paymentEnum?.label;
    }
    String? recurrenceLabel;
    if (draft.recurrenceType != null) {
      switch (draft.recurrenceType) {
        case 'WEEKLY':
          recurrenceLabel = 'Hebdomadaire';
          break;
        case 'BIWEEKLY':
          recurrenceLabel = 'Toutes les 2 semaines';
          break;
        case 'MONTHLY':
          recurrenceLabel = 'Mensuelle';
          break;
        default:
          recurrenceLabel = 'Aucune';
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations complémentaires',
            style: TextStyle(fontWeight: FontWeight.w600)),
        _buildInfoRow(
            'Date de collecte',
            draft.collectionDate != null
                ? draft.collectionDate!.toLocal().toString().split(' ')[0]
                : ''),
        _buildInfoRow(
            'Date de livraison',
            draft.deliveryDate != null
                ? draft.deliveryDate!.toLocal().toString().split(' ')[0]
                : ''),
        if (draft.note != null && draft.note!.trim().isNotEmpty)
          _buildInfoRow('Note de commande', draft.note!),
        if (statusLabel != null)
          Row(
            children: [
              if (statusIcon != null)
                Icon(statusIcon, color: statusColor, size: 18),
              SizedBox(width: 6),
              _buildInfoRow('Statut', statusLabel),
            ],
          ),
        if (paymentLabel != null)
          _buildInfoRow('Méthode de paiement', paymentLabel),
        if (draft.affiliateCode != null && draft.affiliateCode!.isNotEmpty)
          _buildInfoRow('Code affilié', draft.affiliateCode!),
        if (recurrenceLabel != null && recurrenceLabel != 'Aucune')
          _buildInfoRow('Type de récurrence', recurrenceLabel),
        if (draft.nextRecurrenceDate != null &&
            draft.recurrenceType != null &&
            draft.recurrenceType != 'NONE')
          _buildInfoRow('Prochaine récurrence',
              draft.nextRecurrenceDate!.toLocal().toString().split(' ')[0]),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
        ],
      ),
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

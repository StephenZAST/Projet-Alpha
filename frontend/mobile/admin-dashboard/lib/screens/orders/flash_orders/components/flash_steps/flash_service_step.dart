import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/models/service.dart';
import 'package:admin/services/service_type_service.dart';
import 'package:admin/services/service_service.dart';
import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/models/flash_order_draft.dart';

class FlashServiceStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashServiceStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashServiceStep> createState() => _FlashServiceStepState();
}

class _FlashServiceStepState extends State<FlashServiceStep> {
  List<ServiceType> serviceTypes = [];
  List<Service> services = [];
  List<Map<String, dynamic>> couples = [];
  ServiceType? selectedServiceType;
  Service? selectedService;
  bool isLoading = false;

  // Local state for quantities and premium selection
  Map<String, int> quantities = {};
  Map<String, bool> premiums = {};

  @override
  void initState() {
    super.initState();
    _fetchServiceTypes();
    // Restore draft if already selected
    final draft = widget.controller.draft.value;
    if (draft.serviceTypeId != null && serviceTypes.isNotEmpty) {
      selectedServiceType = serviceTypes.firstWhere(
        (t) => t.id == draft.serviceTypeId,
        orElse: () => serviceTypes.first,
      );
    }
    if (draft.serviceId != null && services.isNotEmpty) {
      selectedService = services.firstWhere(
        (s) => s.id == draft.serviceId,
        orElse: () => services.first,
      );
    }
  }

  Future<void> _fetchServiceTypes() async {
    setState(() => isLoading = true);
    serviceTypes = await ServiceTypeService.getAllServiceTypes();
    setState(() => isLoading = false);
  }

  Future<void> _onServiceTypeChanged(ServiceType? type) async {
    setState(() {
      selectedServiceType = type;
      selectedService = null;
      couples = [];
      quantities.clear();
      premiums.clear();
    });
    widget.controller.setDraftField('serviceTypeId', type?.id);
    if (type != null) {
      setState(() => isLoading = true);
      services = await ServiceService.getAllServices();
      services = services.where((s) => s.serviceTypeId == type.id).toList();
      setState(() => isLoading = false);
    }
  }

  Future<void> _onServiceChanged(Service? service) async {
    setState(() {
      selectedService = service;
      couples = [];
      quantities.clear();
      premiums.clear();
    });
    widget.controller.setDraftField('serviceId', service?.id);
    if (service != null && selectedServiceType != null) {
      setState(() => isLoading = true);
      couples = await ArticleServiceCoupleService.getCouplesForServiceType(
        serviceTypeId: selectedServiceType!.id,
        serviceId: service.id,
      );
      // Initialize quantities and premiums for each couple
      for (var couple in couples) {
        final articleId = couple['article_id'];
        quantities[articleId] = 0;
        premiums[articleId] = false;
      }
      setState(() => isLoading = false);
      _updateDraftItems();
    }
  }

  void _onQuantityChanged(String articleId, int value) {
    setState(() {
      quantities[articleId] = value;
    });
    _updateDraftItems();
  }

  void _onPremiumChanged(String articleId, bool value) {
    setState(() {
      premiums[articleId] = value;
    });
    _updateDraftItems();
  }

  void _updateDraftItems() {
    final items = <FlashOrderDraftItem>[];
    for (var couple in couples) {
      final articleId = couple['article_id'];
      final quantity = quantities[articleId] ?? 0;
      final isPremium = premiums[articleId] ?? false;
      if (quantity > 0) {
        items.add(FlashOrderDraftItem(
          articleId: articleId,
          quantity: quantity,
          isPremium: isPremium,
          serviceId: selectedService?.id,
          unitPrice: isPremium
              ? (couple['premium_price'] ?? couple['base_price'] ?? 0)
              : (couple['base_price'] ?? 0),
          articleName: couple['article_name'] ?? articleId,
        ));
      }
    }
    widget.controller.setDraftField('items', items);
  }

  int _calculateTotal() {
    int total = 0;
    for (var couple in couples) {
      final articleId = couple['article_id'];
      final quantity = quantities[articleId] ?? 0;
      final basePrice = (couple['base_price'] ?? 0) as num;
      final premiumPrice = (couple['premium_price'] ?? basePrice) as num;
      final isPremium = premiums[articleId] ?? false;
      if (quantity > 0) {
        total +=
            quantity * (isPremium ? premiumPrice.toInt() : basePrice.toInt());
      }
    }
    return total;
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text('Type de service',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 12),
                  DropdownButton<ServiceType>(
                    value: selectedServiceType,
                    hint: Text('Sélectionner le type de service'),
                    items: serviceTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            ))
                        .toList(),
                    onChanged: _onServiceTypeChanged,
                  ),
                  SizedBox(height: 16),
                  Text('Service',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 12),
                  DropdownButton<Service>(
                    value: selectedService,
                    hint: Text('Sélectionner le service'),
                    items: services
                        .map((service) => DropdownMenuItem(
                              value: service,
                              child: Text(service.name),
                            ))
                        .toList(),
                    onChanged: _onServiceChanged,
                  ),
                  SizedBox(height: 16),
                  Text('Articles / Couples',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 12),
                  if (couples.isNotEmpty)
                    ...couples.map((couple) {
                      final articleId = couple['article_id'];
                      return Card(
                        elevation: 0,
                        color: Colors.white.withOpacity(0.12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(couple['article_name'] ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(
                                        'Prix: ${couple['base_price'] ?? ''} F CFA'),
                                    if (couple['premium_price'] != null)
                                      Text(
                                          'Premium: ${couple['premium_price']} F CFA',
                                          style: TextStyle(
                                              color: Colors.blueAccent)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        onPressed: () {
                                          final current =
                                              quantities[articleId] ?? 0;
                                          if (current > 0)
                                            _onQuantityChanged(
                                                articleId, current - 1);
                                        },
                                      ),
                                      Text('${quantities[articleId] ?? 0}',
                                          style: TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          final current =
                                              quantities[articleId] ?? 0;
                                          _onQuantityChanged(
                                              articleId, current + 1);
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Switch(
                                        value: premiums[articleId] ?? false,
                                        onChanged: (val) =>
                                            _onPremiumChanged(articleId, val),
                                        activeColor: Colors.blueAccent,
                                      ),
                                      Text('Premium',
                                          style: TextStyle(
                                              color: Colors.blueAccent)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  SizedBox(height: 16),
                  _buildTotalSection(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
  }
}

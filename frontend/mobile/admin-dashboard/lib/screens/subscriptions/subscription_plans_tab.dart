import 'package:flutter/material.dart';
import '../../models/subscription_plan.dart';
import '../../widgets/shared/glass_button.dart';
import '../../services/api_service.dart';
import 'package:get/get.dart';
import '../../models/user_subscription.dart';

class SubscriptionPlansTab extends StatefulWidget {
  const SubscriptionPlansTab({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansTab> createState() => _SubscriptionPlansTabState();
}

class _SubscriptionPlansTabState extends State<SubscriptionPlansTab> {
  List<SubscriptionPlan> plans = [];
  bool isLoading = false;
  final api = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get('/admin/subscriptions/plans');
      final data =
          response.data is List ? response.data : response.data['data'];
      plans = (data as List)
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les plans');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createOrUpdatePlan(SubscriptionPlan plan,
      {bool isEdit = false}) async {
    setState(() => isLoading = true);
    try {
      final endpoint = isEdit
          ? '/admin/subscriptions/plans/${plan.id}'
          : '/admin/subscriptions/plans';
      final method = isEdit ? api.put : api.post;
      final response = await method(endpoint, data: plan.toJson());
      final data = response.data is Map ? response.data : response.data['data'];
      final newPlan = SubscriptionPlan.fromJson(data);
      setState(() {
        if (isEdit) {
          final idx = plans.indexWhere((p) => p.id == plan.id);
          if (idx != -1) plans[idx] = newPlan;
        } else {
          plans.add(newPlan);
        }
      });
      Get.snackbar('Succès', isEdit ? 'Plan modifié' : 'Plan créé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer le plan');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deletePlan(SubscriptionPlan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le plan'),
        content: Text('Confirmer la suppression du plan "${plan.name}" ?'),
        actions: [
          GlassButton(
            label: 'Annuler',
            onPressed: () => Navigator.pop(context, false),
            variant: GlassButtonVariant.secondary,
          ),
          GlassButton(
            label: 'Supprimer',
            onPressed: () => Navigator.pop(context, true),
            variant: GlassButtonVariant.error,
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => isLoading = true);
    try {
      await api.delete('/admin/subscriptions/plans/${plan.id}');
      setState(() {
        plans.removeWhere((p) => p.id == plan.id);
      });
      Get.snackbar('Succès', 'Plan supprimé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le plan');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showPlanForm({SubscriptionPlan? plan}) async {
    final result = await showDialog<SubscriptionPlan>(
      context: context,
      builder: (_) => _PlanFormDialog(plan: plan),
    );
    if (result != null) {
      await _createOrUpdatePlan(result, isEdit: plan != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plans d\'abonnement',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                GlassButton(
                  label: 'Ajouter un plan',
                  icon: Icons.add,
                  variant: GlassButtonVariant.success,
                  onPressed: () => _showPlanForm(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : plans.isEmpty
                      ? Center(child: Text('Aucun plan d\'abonnement'))
                      : ListView.separated(
                          itemCount: plans.length,
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder: (context, index) {
                            final plan = plans[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(plan.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    'Prix: ${plan.price} FCFA | Durée: ${plan.durationDays} jours | Max commandes: ${plan.maxOrdersPerMonth}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GlassButton(
                                      label: 'Abonnés',
                                      icon: Icons.people,
                                      variant: GlassButtonVariant.primary,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              _SubscriptionUsersDialog(
                                                  plan: plan),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    GlassButton(
                                      label: 'Modifier',
                                      icon: Icons.edit,
                                      variant: GlassButtonVariant.info,
                                      onPressed: () =>
                                          _showPlanForm(plan: plan),
                                    ),
                                    const SizedBox(width: 8),
                                    GlassButton(
                                      label: 'Supprimer',
                                      icon: Icons.delete,
                                      variant: GlassButtonVariant.error,
                                      onPressed: () => _deletePlan(plan),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.05),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _PlanFormDialog extends StatefulWidget {
  final SubscriptionPlan? plan;
  const _PlanFormDialog({Key? key, this.plan}) : super(key: key);

  @override
  State<_PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends State<_PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late double price;
  late int durationDays;
  late int maxOrdersPerMonth;
  late double maxWeightPerOrder;
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    name = widget.plan?.name ?? '';
    description = widget.plan?.description ?? '';
    price = widget.plan?.price ?? 0.0;
    durationDays = widget.plan?.durationDays ?? 30;
    maxOrdersPerMonth = widget.plan?.maxOrdersPerMonth ?? 10;
    maxWeightPerOrder = widget.plan?.maxWeightPerOrder ?? 0.0;
    isPremium = widget.plan?.isPremium ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.plan == null ? 'Ajouter un plan' : 'Modifier le plan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Nom du plan'),
                validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                onChanged: (v) => name = v,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => description = v,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Prix (FCFA)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Prix requis'
                    : null,
                onChanged: (v) => price = double.tryParse(v) ?? 0.0,
              ),
              TextFormField(
                initialValue: durationDays.toString(),
                decoration: const InputDecoration(labelText: 'Durée (jours)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Durée requise'
                    : null,
                onChanged: (v) => durationDays = int.tryParse(v) ?? 30,
              ),
              TextFormField(
                initialValue: maxOrdersPerMonth.toString(),
                decoration:
                    const InputDecoration(labelText: 'Max commandes/mois'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Valeur requise'
                    : null,
                onChanged: (v) => maxOrdersPerMonth = int.tryParse(v) ?? 10,
              ),
              TextFormField(
                initialValue: maxWeightPerOrder.toString(),
                decoration:
                    const InputDecoration(labelText: 'Poids max/commande (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => maxWeightPerOrder = double.tryParse(v) ?? 0.0,
              ),
              SwitchListTile(
                title: const Text('Premium'),
                value: isPremium,
                onChanged: (v) => setState(() => isPremium = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          label: 'Annuler',
          variant: GlassButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
        ),
        GlassButton(
          label: widget.plan == null ? 'Créer' : 'Enregistrer',
          variant: GlassButtonVariant.success,
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final newPlan = SubscriptionPlan(
                id: widget.plan?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                description: description,
                price: price,
                durationDays: durationDays,
                maxOrdersPerMonth: maxOrdersPerMonth,
                maxWeightPerOrder: maxWeightPerOrder,
                isPremium: isPremium,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context, newPlan);
            }
          },
        ),
      ],
    );
  }
}

class _SubscriptionUsersDialog extends StatefulWidget {
  final SubscriptionPlan plan;
  const _SubscriptionUsersDialog({Key? key, required this.plan})
      : super(key: key);

  @override
  State<_SubscriptionUsersDialog> createState() =>
      _SubscriptionUsersDialogState();
}

class _SubscriptionUsersDialogState extends State<_SubscriptionUsersDialog> {
  List<UserSubscription> users = [];
  List<UserSubscription> filteredUsers = [];
  bool isLoading = false;
  final api = Get.find<ApiService>();
  String statusFilter = 'ALL';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response =
          await api.get('/admin/subscriptions/plans/${widget.plan.id}/users');
      final data =
          response.data is List ? response.data : response.data['data'];
      users = (data as List)
          .map((json) => UserSubscription.fromJson(json))
          .toList();
      _applyFilters();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les abonnés');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        final matchesStatus =
            statusFilter == 'ALL' || user.status == statusFilter;
        final matchesSearch = searchQuery.isEmpty ||
            (user.userName?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false) ||
            (user.userId.toLowerCase().contains(searchQuery.toLowerCase()));
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    _applyFilters();
  }

  void _onStatusChanged(String? value) {
    statusFilter = value ?? 'ALL';
    _applyFilters();
  }

  Future<void> _unsubscribeUser(UserSubscription user) async {
    setState(() => isLoading = true);
    try {
      await api.patch('/admin/subscriptions/${user.id}/cancel');
      Get.snackbar('Succès', 'Abonnement annulé');
      await _fetchUsers();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'annuler l\'abonnement');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Abonnés du plan "${widget.plan.name}"'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Recherche par nom ou ID',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: statusFilter,
                  items: [
                    DropdownMenuItem(value: 'ALL', child: Text('Tous')),
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Actif')),
                    DropdownMenuItem(value: 'CANCELLED', child: Text('Annulé')),
                    DropdownMenuItem(value: 'EXPIRED', child: Text('Expiré')),
                  ],
                  onChanged: _onStatusChanged,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? const Text('Aucun utilisateur abonné à ce plan')
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(user.userName ?? user.userId),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${user.userId}'),
                                    Text('Plan: ${widget.plan.name}'),
                                    Text('Début: ${user.startDate.toLocal()}'),
                                    Text('Fin: ${user.endDate.toLocal()}'),
                                    Text('Statut: ${user.status}'),
                                    Text(
                                        'Commandes restantes: ${user.remainingOrders}'),
                                    if (user.remainingWeight != null)
                                      Text(
                                          'Poids restant: ${user.remainingWeight} kg'),
                                  ],
                                ),
                                trailing: GlassButton(
                                  label: 'Désabonner',
                                  variant: GlassButtonVariant.warning,
                                  onPressed: () => _unsubscribeUser(user),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        GlassButton(
          label: 'Fermer',
          onPressed: () => Navigator.pop(context),
          variant: GlassButtonVariant.secondary,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_subscription.dart';
import '../../services/api_service.dart';
import '../../widgets/shared/glass_button.dart';

class SubscribedUsersTab extends StatefulWidget {
  const SubscribedUsersTab({Key? key}) : super(key: key);

  @override
  State<SubscribedUsersTab> createState() => _SubscribedUsersTabState();
}

class _SubscribedUsersTabState extends State<SubscribedUsersTab> {
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
      // Utilise le premier plan trouvé pour la démo, à adapter si besoin
      final plansResponse = await api.get('/admin/subscriptions/plans');
      final plansData = plansResponse.data is List
          ? plansResponse.data
          : plansResponse.data['data'];
      if (plansData.isEmpty) {
        users = [];
        _applyFilters();
        setState(() => isLoading = false);
        return;
      }
      final planId = plansData[0]['id'];
      final response =
          await api.get('/admin/subscriptions/plans/$planId/users');
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
                    ? const Text('Aucun utilisateur abonné')
                    : ListView.separated(
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
                                  Text('Plan: ${user.planId}'),
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
    );
  }
}

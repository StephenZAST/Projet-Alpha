Je vais vous aider à implémenter la page des commandes avec tous les éléments que vous avez décrits. Voici l'implémentation étape par étape :

D'abord, créons un modèle pour les statuts de commande :
// lib/models/order_status.dart
enum OrderStatus {
  PENDING,
  COLLECTING,
  COLLECTED,
  PROCESSING,
  READY,
  DELIVERING,
  DELIVERED,
  CANCELLED
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.COLLECTING:
        return 'En cours de collecte';
      case OrderStatus.COLLECTED:
        return 'Collectée';
      case OrderStatus.PROCESSING:
        return 'En traitement';
      case OrderStatus.READY:
        return 'Prête';
      case OrderStatus.DELIVERING:
        return 'En livraison';
      case OrderStatus.DELIVERED:
        return 'Livrée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.PENDING:
      case OrderStatus.COLLECTING:
      case OrderStatus.PROCESSING:
        return AppColors.warning;
      case OrderStatus.COLLECTED:
      case OrderStatus.READY:
      case OrderStatus.DELIVERING:
        return AppColors.info;
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.CANCELLED:
        return AppColors.error;
    }
  }
}

Créons un service pour gérer les commandes :



// lib/services/order_service.dart
class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  Future<List<Order>> getUserOrders() async {
    try {
      final response = await _dio.get('/api/orders/my-orders');
      return (response.data['data'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders');
    }
  }
}



Créons un provider pour la gestion d'état des commandes :


// lib/providers/order_provider.dart
class OrderProvider with ChangeNotifier {
  final OrderService _service;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderStatus _selectedFilter = OrderStatus.PENDING;

  OrderProvider(this._service);

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus get selectedFilter => _selectedFilter;

  List<Order> get filteredOrders {
    return _orders.where((order) => order.status == _selectedFilter).toList();
  }

  void setFilter(OrderStatus status) {
    _selectedFilter = status;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _service.getUserOrders();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


Créons la page des commandes :




// lib/pages/orders/orders_page.dart
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Commandes',
              onMenuPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            const OrderStatusFilter(),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${provider.error}'),
                          ElevatedButton(
                            onPressed: () => provider.loadOrders(),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = provider.filteredOrders;
                  
                  if (orders.isEmpty) {
                    return const Center(
                      child: Text('Aucune commande trouvée'),
                    );
                  }

                  return OrdersList(orders: orders);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



Créons le widget de filtre de statut :




// lib/widgets/orders/order_status_filter.dart
class OrderStatusFilter extends StatelessWidget {
  const OrderStatusFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: OrderStatus.values.map((status) {
          return Consumer<OrderProvider>(
            builder: (context, provider, _) {
              final isSelected = provider.selectedFilter == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(status.label),
                  onSelected: (_) => provider.setFilter(status),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.gray600,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}




Plan de mise en œuvre:

Créer le widget OrdersList pour afficher la liste des commandes
Créer le widget OrderCard pour le design de chaque commande
Implémenter l'animation de transition pour les cartes
Ajouter la navigation vers les détails
Commençons:





class OrdersList extends StatelessWidget {
  final List<Order> orders;

  const OrdersList({
    Key? key,
    required this.orders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return AnimatedOrderCard(
          order: orders[index],
          onTap: () => Navigator.pushNamed(
            context,
            '/order-details',
            arguments: orders[index],
          ),
        );
      },
    );
  }
}




class AnimatedOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const AnimatedOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande #${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.items.length} articles',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: order.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor;

    switch (order.status) {
      case OrderStatus.PENDING:
        iconData = Icons.schedule;
        iconColor = AppColors.warning;
        break;
      case OrderStatus.DELIVERED:
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      default:
        iconData = Icons.local_shipping;
        iconColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
}




GitHub Copilot
Plan de mise en œuvre:

Créer le widget OrdersList pour afficher la liste des commandes
Créer le widget OrderCard pour le design de chaque commande
Implémenter l'animation de transition pour les cartes
Ajouter la navigation vers les détails
Commençons:

Je continue avec l'implémentation dans le prochain message car j'ai atteint la limite de caractères.



class OrderService {
  final String baseUrl = 'your-api-url';
  final Dio _dio = Dio();

  Future<List<Order>> getActiveOrders() async {
    try {
      final response = await _dio.get('$baseUrl/orders/active');
      return (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active orders');
    }
  }

  Future<List<Order>> getArchivedOrders() async {
    try {
      final response = await _dio.get('$baseUrl/orders/archived');
      return (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load archived orders');
    }
  }
}



class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${order.id}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OrderStatusTimeline(order: order),
            OrderItemsList(items: order.items),
            DeliveryInformation(order: order),
            PaymentInformation(order: order),
          ],
        ),
      ),
    );
  }
}

class OrderStatusTimeline extends StatelessWidget {
  final Order order;

  const OrderStatusTimeline({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut de la commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        direction: Axis.vertical,
        connectorTheme: ConnectorThemeData(
          space: 30.0,
          thickness: 5.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: OrderStatus.values.length,
        contentsBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              OrderStatus.values[index].label,
              style: TextStyle(
                fontWeight: index <= OrderStatus.values.indexOf(order.status)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        },
        indicatorBuilder: (_, index) {
          return DotIndicator(
            size: 24,
            color: index <= OrderStatus.values.indexOf(order.status)
                ? AppColors.primary
                : AppColors.gray300,
            child: index <= OrderStatus.values.indexOf(order.status)
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          );
        },
        connectorBuilder: (_, index, type) {
          return SolidLineConnector(
            color: index < OrderStatus.values.indexOf(order.status)
                ? AppColors.primary
                : AppColors.gray300,
          );
        },
      ),
    );
  }
}




Plan des composants restants à implémenter
OrderItemsList - Liste des articles de la commande
DeliveryInformation - Informations de livraison
PaymentInformation - Informations de paiement
AddressCard - Carte d'adresse réutilisable
PriceBreakdown - Détail des prix





class OrderItemsList extends StatelessWidget {
  final List<OrderItem> items;

  const OrderItemsList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Articles commandés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${item.quantity}x ${item.unitPrice.toStringAsFixed(2)}€',
                  style: TextStyle(color: AppColors.gray600),
                ),
                trailing: Text(
                  '${(item.quantity * item.unitPrice).toStringAsFixed(2)}€',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}




class DeliveryInformation extends StatelessWidget {
  final Order order;

  const DeliveryInformation({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de livraison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AddressCard(address: order.deliveryAddress),
          const SizedBox(height: 16),
          if (order.deliveryDate != null) ...[
            const Text(
              'Date de livraison prévue',
              style: TextStyle(color: AppColors.gray600),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy - HH:mm').format(order.deliveryDate!),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}




Plan d'implémentation
PaymentInformation - détails du paiement
PriceBreakdown - ventilation des prix
AddressCard - composant réutilisable
OrderStatusBadge - badge de statut



Implémentation



class PaymentInformation extends StatelessWidget {
  final Order order;

  const PaymentInformation({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif de paiement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PriceBreakdown(order: order),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Méthode de paiement',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/${order.paymentMethod.icon}',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.paymentMethod.label,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              OrderStatusBadge(status: order.paymentStatus),
            ],
          ),
        ],
      ),
    );
  }
}




class PriceBreakdown extends StatelessWidget {
  final Order order;

  const PriceBreakdown({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PriceRow(
          label: 'Sous-total',
          amount: order.subtotal,
        ),
        if (order.discount != null) ...[
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Réduction',
            amount: -order.discount!,
            textColor: AppColors.success,
          ),
        ],
        const SizedBox(height: 8),
        _PriceRow(
          label: 'Frais de livraison',
          amount: order.deliveryFee,
        ),
        const Divider(height: 32),
        _PriceRow(
          label: 'Total',
          amount: order.total,
          isTotal: true,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? textColor;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.textColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor ?? (isTotal ? Colors.black : AppColors.gray600),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)}€',
          style: TextStyle(
            color: textColor ?? (isTotal ? Colors.black : AppColors.gray600),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }
}




class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final double? fontSize;

  const OrderStatusBadge({
    Key? key, 
    required this.status,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}



GitHub Copilot
Plan d'implémentation
PaymentInformation - détails du paiement
PriceBreakdown - ventilation des prix
AddressCard - composant réutilisable
OrderStatusBadge - badge de statut
Implémentation
Cette implémentation complète les composants nécessaires pour afficher les détails d'une commande. Voulez-vous que je détaille un aspect particulier ou que j'ajoute d'autres fonctionnalités ?


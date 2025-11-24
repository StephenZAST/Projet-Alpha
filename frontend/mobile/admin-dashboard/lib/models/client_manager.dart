/// Statistiques d'un agent (SVA)
class AgentStats {
  final String id;
  final String name;
  final String email;
  final int totalClients;
  final int totalOrders;
  final double totalRevenue;
  final double avgOrderValue;
  final int inactiveClientsCount;
  final int rank;
  final DateTime lastUpdated;

  AgentStats({
    required this.id,
    required this.name,
    required this.email,
    required this.totalClients,
    required this.totalOrders,
    required this.totalRevenue,
    required this.avgOrderValue,
    required this.inactiveClientsCount,
    required this.rank,
    required this.lastUpdated,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      id: json['agent']?['id'] ?? '',
      name: json['agent']?['name'] ?? 'N/A',
      email: json['agent']?['email'] ?? 'N/A',
      totalClients: json['stats']?['total_clients'] ?? 0,
      totalOrders: json['stats']?['total_orders'] ?? 0,
      totalRevenue: (json['stats']?['total_revenue'] ?? 0).toDouble(),
      avgOrderValue: (json['stats']?['avg_order_value'] ?? 0).toDouble(),
      inactiveClientsCount: json['stats']?['inactive_clients_count'] ?? 0,
      rank: json['rank'] ?? 0,
      lastUpdated: json['stats']?['last_updated'] != null
          ? DateTime.parse(json['stats']['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'agent': {
      'id': id,
      'name': name,
      'email': email,
    },
    'stats': {
      'total_clients': totalClients,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'avg_order_value': avgOrderValue,
      'inactive_clients_count': inactiveClientsCount,
      'last_updated': lastUpdated.toIso8601String(),
    },
    'rank': rank,
  };
}

/// Informations d'un client assigné à un agent
class ClientInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final int? daysSinceLastOrder;
  final bool isInactive;
  final DateTime assignedAt;
  final String? notes;

  ClientInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.totalOrders,
    required this.totalSpent,
    this.lastOrderDate,
    this.daysSinceLastOrder,
    required this.isInactive,
    required this.assignedAt,
    this.notes,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'],
      totalOrders: json['total_orders'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'])
          : null,
      daysSinceLastOrder: json['days_since_last_order'],
      isInactive: json['is_inactive'] ?? false,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'total_orders': totalOrders,
    'total_spent': totalSpent,
    'last_order_date': lastOrderDate?.toIso8601String(),
    'days_since_last_order': daysSinceLastOrder,
    'is_inactive': isInactive,
    'assigned_at': assignedAt.toIso8601String(),
    'notes': notes,
  };
}

/// Client inactif (>7 jours sans commande)
class InactiveClient {
  final String id;
  final String name;
  final String email;
  final DateTime? lastOrderDate;
  final int? daysSinceLastOrder;

  InactiveClient({
    required this.id,
    required this.name,
    required this.email,
    this.lastOrderDate,
    this.daysSinceLastOrder,
  });

  factory InactiveClient.fromJson(Map<String, dynamic> json) {
    return InactiveClient(
      id: json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'])
          : null,
      daysSinceLastOrder: json['days_since_last_order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'last_order_date': lastOrderDate?.toIso8601String(),
    'days_since_last_order': daysSinceLastOrder,
  };
}

/// Client top (meilleur client par revenu)
class TopClient {
  final String id;
  final String name;
  final String email;
  final int totalOrders;
  final double totalSpent;

  TopClient({
    required this.id,
    required this.name,
    required this.email,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory TopClient.fromJson(Map<String, dynamic> json) {
    return TopClient(
      id: json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      totalOrders: json['total_orders'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'total_orders': totalOrders,
    'total_spent': totalSpent,
  };
}

/// Agent (informations de base)
class Agent {
  final String id;
  final String name;
  final String email;

  Agent({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}

/// Dashboard complet d'un agent
class AgentDashboard {
  final Agent agent;
  final AgentStats stats;
  final List<InactiveClient> inactiveClients;
  final List<TopClient> topClients;

  AgentDashboard({
    required this.agent,
    required this.stats,
    required this.inactiveClients,
    required this.topClients,
  });

  factory AgentDashboard.fromJson(Map<String, dynamic> json) {
    final agentData = json['agent'] ?? {};
    final statsData = json['stats'] ?? {};
    final inactiveClientsData = json['inactive_clients'] ?? [];
    final topClientsData = json['top_clients'] ?? [];

    return AgentDashboard(
      agent: Agent.fromJson(agentData),
      stats: AgentStats.fromJson({
        'agent': agentData,
        'stats': statsData,
        'rank': 0,
      }),
      inactiveClients: (inactiveClientsData as List)
          .map((client) => InactiveClient.fromJson(client))
          .toList(),
      topClients: (topClientsData as List)
          .map((client) => TopClient.fromJson(client))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'agent': agent.toJson(),
    'stats': stats.toJson(),
    'inactive_clients': inactiveClients.map((c) => c.toJson()).toList(),
    'top_clients': topClients.map((c) => c.toJson()).toList(),
  };
}

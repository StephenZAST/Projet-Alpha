import 'package:admin/constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

enum DeliveryStatus {
  PENDING_PICKUP,
  PICKED_UP,
  IN_TRANSIT,
  PENDING_DELIVERY,
  DELIVERED,
  FAILED;

  String get label {
    switch (this) {
      case DeliveryStatus.PENDING_PICKUP:
        return 'En attente de collecte';
      case DeliveryStatus.PICKED_UP:
        return 'Collecté';
      case DeliveryStatus.IN_TRANSIT:
        return 'En transit';
      case DeliveryStatus.PENDING_DELIVERY:
        return 'En attente de livraison';
      case DeliveryStatus.DELIVERED:
        return 'Livré';
      case DeliveryStatus.FAILED:
        return 'Échec de livraison';
    }
  }

  Color get color {
    switch (this) {
      case DeliveryStatus.PENDING_PICKUP:
        return AppColors.warning;
      case DeliveryStatus.PICKED_UP:
        return AppColors.info;
      case DeliveryStatus.IN_TRANSIT:
        return AppColors.primary;
      case DeliveryStatus.PENDING_DELIVERY:
        return AppColors.accent;
      case DeliveryStatus.DELIVERED:
        return AppColors.success;
      case DeliveryStatus.FAILED:
        return AppColors.error;
    }
  }
}

class Delivery {
  final String id;
  final String orderId;
  final DeliveryStatus status;
  final DateTime createdAt;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final DeliveryLocation pickupLocation;
  final DeliveryLocation deliveryLocation;
  final String? notes;
  final double? distance;
  final String? customerName;
  final String? customerPhone;
  final double? amount;

  Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
    this.pickupDate,
    this.deliveryDate,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.notes,
    this.distance,
    this.customerName,
    this.customerPhone,
    this.amount,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      orderId: json['orderId'],
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'])
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      pickupLocation: DeliveryLocation.fromJson(json['pickupLocation']),
      deliveryLocation: DeliveryLocation.fromJson(json['deliveryLocation']),
      notes: json['notes'],
      distance: json['distance']?.toDouble(),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      amount: json['amount']?.toDouble(),
    );
  }

  LatLng get pickupLatLng =>
      LatLng(pickupLocation.latitude, pickupLocation.longitude);
  LatLng get deliveryLatLng =>
      LatLng(deliveryLocation.latitude, deliveryLocation.longitude);
}

class DeliveryLocation {
  final double latitude;
  final double longitude;
  final String address;

  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}

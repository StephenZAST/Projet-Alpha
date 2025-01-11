import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/services/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prima/providers/order_state.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState());

  Future<void> fetchServices(AuthProvider authProvider) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await authProvider.dio.get('/api/services/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final services = data.map((e) => Service.fromJson(e)).toList();
        state = state.copyWith(services: services, isLoading: false);
      } else {
        state = state.copyWith(
          error: 'Failed to load services',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Connection error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> fetchArticles(AuthProvider authProvider) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categoriesResponse =
          await authProvider.dio.get('/api/article-categories');
      final articlesResponse = await authProvider.dio.get('/api/articles');

      if (categoriesResponse.statusCode == 200 &&
          articlesResponse.statusCode == 200) {
        final categories = (categoriesResponse.data['data'] as List)
            .map((e) => ArticleCategory.fromJson(e))
            .toList();
        final articles = (articlesResponse.data['data'] as List)
            .map((e) => Article.fromJson(e))
            .toList();

        state = state.copyWith(
          categories: categories,
          articles: articles,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: 'Failed to load articles data',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Connection error: $e',
        isLoading: false,
      );
    }
  }

  void selectService(Service? service) {
    state = state.copyWith(selectedService: service);
  }

  void updateArticleQuantity(String articleId, int change) {
    final currentQuantity = state.selectedArticles[articleId] ?? 0;
    final newQuantity = currentQuantity + change;

    final updatedArticles = Map<String, int>.from(state.selectedArticles);
    if (newQuantity <= 0) {
      updatedArticles.remove(articleId);
    } else {
      updatedArticles[articleId] = newQuantity;
    }

    state = state.copyWith(selectedArticles: updatedArticles);
  }

  void setDates({DateTime? collectionDate, DateTime? deliveryDate}) {
    state = state.copyWith(
      collectionDate: collectionDate ?? state.collectionDate,
      deliveryDate: deliveryDate ?? state.deliveryDate,
    );
  }

  Future<OrderResult> createOrder(AuthProvider authProvider) async {
    if (state.selectedService == null) {
      return const OrderResult.error('Veuillez sélectionner un service');
    }

    if (state.selectedArticles.isEmpty) {
      return const OrderResult.error(
          'Veuillez sélectionner au moins un article');
    }

    if (state.collectionDate == null || state.deliveryDate == null) {
      return const OrderResult.error('Veuillez sélectionner les dates');
    }

    try {
      final response = await authProvider.dio.post('/orders', data: {
        'serviceId': state.selectedService!.id,
        'items': state.selectedArticles.entries
            .map((e) => {'articleId': e.key, 'quantity': e.value})
            .toList(),
        'collectionDate': state.collectionDate!.toIso8601String(),
        'deliveryDate': state.deliveryDate!.toIso8601String(),
      });

      if (response.statusCode == 200) {
        return const OrderResult.success();
      } else {
        return OrderResult.error(
            response.data['message'] ?? 'Error creating order');
      }
    } catch (e) {
      return OrderResult.error(e.toString());
    }
  }

  void reset() {
    state = const OrderState();
  }
}

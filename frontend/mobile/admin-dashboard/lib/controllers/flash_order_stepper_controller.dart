import 'package:admin/services/address_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/flash_order_draft.dart';

class FlashOrderStepperController extends GetxController {
  // Synchronise les articles du draft avec les couples de prix
  void syncSelectedItemsFrom({
    required List<Map<String, dynamic>> couples,
  }) {
    final items = draft.value.items;
    for (final item in items) {
      final couple = couples.firstWhere(
        (c) => c['article_id'] == item.articleId,
        orElse: () => <String, dynamic>{},
      );
      item.unitPrice = item.isPremium
          ? (couple['premium_price'] ?? couple['base_price'] ?? 0)
          : (couple['base_price'] ?? 0);
      item.articleName = couple['article_name'] ?? item.articleId;
      // Ajout d'autres champs si besoin (ex: description, serviceName...)
      // Si le modèle FlashOrderDraftItem évolue, ajouter ici
    }
    draft.refresh();
    // Log de synchronisation des articles
    print('[SYNC] Articles du draft après enrichissement :');
    for (final item in draft.value.items) {
      print(
          'Article: ${item.articleName}, Prix: ${item.unitPrice}, Qte: ${item.quantity}, Premium: ${item.isPremium}');
    }
  }

  // Initialise le draft à partir d'une commande flash
  void initDraftFromFlashOrder(dynamic flashOrder) {
    draft.value = FlashOrderDraft(
      orderId: flashOrder.id,
      userId: flashOrder.userId,
      addressId: flashOrder.addressId,
      serviceId: flashOrder.serviceId,
      serviceTypeId: flashOrder.service?.serviceTypeId,
      items: (flashOrder.items != null)
          ? flashOrder.items
              .map<FlashOrderDraftItem>((item) => FlashOrderDraftItem(
                    articleId: item.articleId ?? item.article_id,
                    quantity: item.quantity,
                    isPremium: item.isPremium ?? false,
                    serviceId: item.serviceId ?? item.service_id,
                  ))
              .toList()
          : [],
      collectionDate: flashOrder.collectionDate,
      deliveryDate: flashOrder.deliveryDate,
      note: flashOrder.note,
    );
    // Log complet du payload reçu pour debug
    print('[DEBUG] Payload commande flash sélectionnée :');
    print('ID: [33m${flashOrder.id}[0m');
    print('Adresse: [36m${flashOrder.addressId}[0m');
    print('Items: ${flashOrder.items}');
    print('Note: [35m${flashOrder.note}[0m');
    print('Raw: ${flashOrder}');
    draft.refresh();
  }

  // Méthode pour rafraîchir les adresses du client sélectionné
  List<dynamic> _clientAddresses = [];
  List<dynamic> get clientAddresses => _clientAddresses;

  Future<void> refreshAddresses(String userId) async {
    try {
      final fetchedAddresses = await AddressService.getAddressesByUser(userId);
      _clientAddresses = fetchedAddresses;
      // Sélection automatique de l'adresse par défaut
      final defaultAddress = _clientAddresses.firstWhere(
        (a) => a.isDefault == true,
        orElse: () => null,
      );
      if (defaultAddress != null) {
        draft.value.addressId = defaultAddress.id;
      } else if (_clientAddresses.isNotEmpty) {
        draft.value.addressId = _clientAddresses.first.id;
      } else {
        draft.value.addressId = null;
      }
      draft.refresh();
      update();
    } catch (e) {
      print(
          '[FlashOrderStepperController] Erreur lors du chargement des adresses: $e');
    }
  }

  final draft = FlashOrderDraft().obs;
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Ancien getter addresses supprimé, utiliser clientAddresses

  void setDraftField(String key, dynamic value) {
    draft.value.setField(key, value);
    draft.refresh();
  }

  void nextStep() {
    if (currentStep.value < stepCount - 1) {
      currentStep.value++;
      print('[STEPPER] Navigation vers l\'étape: ${currentStep.value}');
      print('[STEPPER] Draft actuel:');
      print(draft.value.toPayload());
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      print('[STEPPER] Retour à l\'étape: ${currentStep.value}');
      print('[STEPPER] Draft actuel:');
      print(draft.value.toPayload());
    }
  }

  int get stepCount => 6; // Nombre d'étapes du stepper

  Future<void> submitConversion() async {
    isLoading.value = true;
    errorMessage.value = '';
    final d = draft.value;
    // Validation des champs obligatoires
    if (d.userId == null ||
        d.userId!.isEmpty ||
        d.addressId == null ||
        d.addressId!.isEmpty ||
        d.serviceId == null ||
        d.serviceId!.isEmpty ||
        d.serviceTypeId == null ||
        d.serviceTypeId!.isEmpty ||
        d.items.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'Veuillez remplir tous les champs obligatoires.';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {
      // TODO: Appeler l'API de conversion avec draft.value.toPayload()
      // await FlashOrderService.completeFlashOrder(draft.value.toPayload());
      Get.snackbar(
        'Succès',
        'Commande flash convertie avec succès !',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Reset le stepper après succès
      draft.value = FlashOrderDraft();
      currentStep.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

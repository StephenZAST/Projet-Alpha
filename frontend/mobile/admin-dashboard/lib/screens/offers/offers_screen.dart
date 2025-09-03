import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/custom_header.dart';
import '../../constants.dart';
import '../../services/offer_service.dart';
import 'offer_list.dart';
import 'components/offer_form_dialog.dart';
import '../../widgets/shared/glass_button.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Map<String, dynamic>> offers = [];
  bool showForm = false;
  Map<String, dynamic>? editingOffer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => isLoading = true);
    try {
      final result = await OfferService.getAllOffersAsMap();
      setState(() => offers = result);
    } catch (e) {
      Get.rawSnackbar(message: 'Erreur chargement des offres: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addOffer(Map<String, dynamic> data) async {
    try {
      final created = await OfferService.createOfferFromMap(data);
      if (created != null) {
        Get.rawSnackbar(
            message: 'Offre créée avec succès',
            backgroundColor: AppColors.success);
        setState(() {
          showForm = false;
          editingOffer = null;
        });
        await _loadOffers();
      } else {
        Get.rawSnackbar(
            message: 'Erreur création offre', backgroundColor: AppColors.error);
      }
    } catch (e) {
      Get.rawSnackbar(
          message: 'Erreur création offre: $e', backgroundColor: AppColors.error);
    }
  }

  void _editOffer(Map<String, dynamic> offer) {
    // Vérifier que l'offre a bien un ID
    if (offer['id'] == null) {
      Get.rawSnackbar(
        message: 'Erreur: Offre sans identifiant',
        backgroundColor: AppColors.error,
      );
      return;
    }

    final String offerId = offer['id'];

    Get.dialog(
      OfferFormDialog(
        initialData: offer,
        onSubmit: (data) async {
          await _updateOffer(offerId, data);
        },
      ),
    );
  }

  Future<void> _updateOffer(String offerId, Map<String, dynamic> data) async {
    try {
      final updated = await OfferService.updateOfferFromMap(offerId, data);

      if (updated != null) {
        Get.rawSnackbar(
            message: 'Offre modifiée avec succès',
            backgroundColor: AppColors.success);
        await _loadOffers();
      } else {
        Get.rawSnackbar(
            message: 'Erreur: Aucune donnée retournée du serveur',
            backgroundColor: AppColors.error);
      }
    } catch (e) {
      Get.rawSnackbar(
          message: 'Erreur modification offre: $e',
          backgroundColor: AppColors.error);
    }
  }

  Future<void> _deleteOffer(Map<String, dynamic> offer) async {
    try {
      final ok = await OfferService.deleteOffer(offer['id']);
      if (ok) {
        Get.rawSnackbar(
            message: 'Offre supprimée', backgroundColor: AppColors.success);
        await _loadOffers();
      } else {
        Get.rawSnackbar(
            message: 'Erreur suppression offre',
            backgroundColor: AppColors.error);
      }
    } catch (e) {
      Get.rawSnackbar(
          message: 'Erreur suppression offre: $e',
          backgroundColor: AppColors.error);
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> offer) async {
    try {
      final ok = await OfferService.toggleOfferStatus(
          offer['id'], !(offer['isActive'] ?? true));
      if (ok) {
        Get.rawSnackbar(
            message: 'Statut modifié', backgroundColor: AppColors.success);
        await _loadOffers();
      } else {
        Get.rawSnackbar(
            message: 'Erreur modification statut',
            backgroundColor: AppColors.error);
      }
    } catch (e) {
      Get.rawSnackbar(
          message: 'Erreur modification statut: $e',
          backgroundColor: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomHeader(
          title: "Gestion des Offres",
          showBackButton: false,
          actions: [
            GlassButton(
              label: "Ajouter une offre",
              icon: Icons.add,
              variant: GlassButtonVariant.primary,
              onPressed: () => Get.dialog(
                OfferFormDialog(
                  onSubmit: (data) async {
                    await _addOffer(data);
                  },
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : OfferList(
                    offers: offers,
                    onEdit: _editOffer,
                    onDelete: _deleteOffer,
                    onToggleStatus: _toggleStatus,
                  ),
          ),
        ),
      ],
    );
  }
}

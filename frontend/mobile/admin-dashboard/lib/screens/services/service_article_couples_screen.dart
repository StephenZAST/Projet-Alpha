import 'package:flutter/material.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/article.dart';
import 'package:admin/services/article_service.dart';
import 'package:admin/services/service_service.dart';
import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/widgets/shared/glass_button.dart';

class ServiceArticleCouplesScreen extends StatefulWidget {
  const ServiceArticleCouplesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceArticleCouplesScreen> createState() =>
      _ServiceArticleCouplesScreenState();
}

class _ServiceArticleCouplesScreenState
    extends State<ServiceArticleCouplesScreen> {
  List<ArticleServiceCouple> couples = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCouples();
  }

  Future<void> _fetchCouples() async {
    setState(() => isLoading = true);
    final rawList =
        await ArticleServiceCoupleService.getAllServiceArticleCouples();
    couples = rawList
        .map((json) => ArticleServiceCouple(
              id: json['id'].toString(),
              serviceName: json['serviceName'] ?? '',
              articleName: json['articleName'] ?? '',
              basePrice: (json['basePrice'] ?? 0).toDouble(),
              premiumPrice: (json['premiumPrice'] ?? 0).toDouble(),
              pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
            ))
        .toList();
    setState(() => isLoading = false);
  }

  void _openAddCoupleDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ServiceArticleCoupleDialog(),
    );
    if (result == true) {
      await _fetchCouples();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couple ajouté avec succès')),
      );
    }
  }

  void _openEditCoupleDialog(ArticleServiceCouple couple) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ServiceArticleCoupleDialog(editCouple: couple),
    );
    if (result == true) {
      await _fetchCouples();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couple modifié avec succès')),
      );
    }
  }

  void _deleteCouple(ArticleServiceCouple couple) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ce couple ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => isLoading = true);
    final success =
        await ArticleServiceCoupleService.deleteServiceArticleCouple(couple.id);
    if (success) {
      await _fetchCouples();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couple supprimé avec succès')),
      );
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couples Service/Article'),
        actions: [
          GlassButton(
            label: 'Ajouter un couple',
            variant: GlassButtonVariant.primary,
            onPressed: _openAddCoupleDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Article')),
                  DataColumn(label: Text('Prix base')),
                  DataColumn(label: Text('Prix premium')),
                  DataColumn(label: Text('Prix/kg')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: couples.map((couple) {
                  return DataRow(cells: [
                    DataCell(Text(couple.serviceName)),
                    DataCell(Text(couple.articleName)),
                    DataCell(Text('${couple.basePrice} FCFA')),
                    DataCell(Text('${couple.premiumPrice} FCFA')),
                    DataCell(Text('${couple.pricePerKg} FCFA')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openEditCoupleDialog(couple),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCouple(couple),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}

// Modèle simplifié pour la table (à adapter selon le backend)
class ArticleServiceCouple {
  final String id;
  final String serviceName;
  final String articleName;
  final double basePrice;
  final double premiumPrice;
  final double pricePerKg;

  ArticleServiceCouple({
    required this.id,
    required this.serviceName,
    required this.articleName,
    required this.basePrice,
    required this.premiumPrice,
    required this.pricePerKg,
  });
}

// Dialog pour ajout/édition d'un couple service/article
class ServiceArticleCoupleDialog extends StatefulWidget {
  final ArticleServiceCouple? editCouple;
  const ServiceArticleCoupleDialog({Key? key, this.editCouple})
      : super(key: key);

  @override
  State<ServiceArticleCoupleDialog> createState() =>
      _ServiceArticleCoupleDialogState();
}

class _ServiceArticleCoupleDialogState
    extends State<ServiceArticleCoupleDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedServiceId;
  String? _selectedArticleId;
  double? _basePrice;
  double? _premiumPrice;
  double? _pricePerKg;
  bool _isLoading = false;
  List<Service> _services = [];
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdowns();
    if (widget.editCouple != null) {
      _basePrice = widget.editCouple!.basePrice;
      _premiumPrice = widget.editCouple!.premiumPrice;
      _pricePerKg = widget.editCouple!.pricePerKg;
      // Les IDs ne sont pas dans le modèle simplifié, donc on laisse vide (à adapter si besoin)
    }
  }

  Future<void> _fetchDropdowns() async {
    setState(() => _isLoading = true);
    try {
      final articles = await ArticleService.getAllArticles();
      final services = await ServiceService.getAllServices();
      setState(() {
        _articles = articles;
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    final data = {
      'service_type_id': _selectedServiceId,
      'article_id': _selectedArticleId,
      'base_price': _basePrice,
      'premium_price': _premiumPrice,
      'price_per_kg': _pricePerKg,
      'is_available': true,
    };
    bool success = false;
    if (widget.editCouple == null) {
      success = await ArticleServiceCoupleService.addServiceArticleCouple(data);
    } else {
      success = await ArticleServiceCoupleService.updateServiceArticleCouple(
          widget.editCouple!.id, data);
    }
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de l\'enregistrement'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editCouple == null
          ? 'Ajouter un couple'
          : 'Modifier le couple'),
      content: _isLoading
          ? const SizedBox(
              height: 120, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedServiceId,
                        items: _services
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedServiceId = v),
                        validator: (v) =>
                            v == null ? 'Sélectionnez un service' : null,
                        decoration: const InputDecoration(labelText: 'Service'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedArticleId,
                        items: _articles
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedArticleId = v),
                        validator: (v) =>
                            v == null ? 'Sélectionnez un article' : null,
                        decoration: const InputDecoration(labelText: 'Article'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _basePrice?.toString(),
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prix base'),
                        validator: (v) => (v == null ||
                                double.tryParse(v) == null ||
                                double.parse(v) < 0)
                            ? 'Prix invalide'
                            : null,
                        onSaved: (v) => _basePrice = double.tryParse(v ?? ''),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _premiumPrice?.toString(),
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prix premium'),
                        validator: (v) => (v == null ||
                                double.tryParse(v) == null ||
                                double.parse(v) < 0)
                            ? 'Prix invalide'
                            : null,
                        onSaved: (v) =>
                            _premiumPrice = double.tryParse(v ?? ''),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _pricePerKg?.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Prix/kg'),
                        validator: (v) => (v == null ||
                                double.tryParse(v) == null ||
                                double.parse(v) < 0)
                            ? 'Prix invalide'
                            : null,
                        onSaved: (v) => _pricePerKg = double.tryParse(v ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        GlassButton(
          label: widget.editCouple == null ? 'Ajouter' : 'Enregistrer',
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../services/article_service.dart' as article_service;

class OfferFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic>) onSubmit;

  const OfferFormDialog({Key? key, this.initialData, required this.onSubmit})
      : super(key: key);

  @override
  State<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountValueController;
  late TextEditingController _minPurchaseController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _pointsController;
  late bool _isCumulative;
  late bool _isActive;
  List<dynamic> _selectedArticles = [];
  List<dynamic> _allArticles = [];
  bool _articlesLoading = false;
  String discountType = 'PERCENTAGE';

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialData?['name'] ?? '');
    _startDateController =
        TextEditingController(text: widget.initialData?['startDate'] ?? '');
    _endDateController =
        TextEditingController(text: widget.initialData?['endDate'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialData?['description'] ?? '');
    _discountValueController = TextEditingController(
        text: widget.initialData?['discountValue']?.toString() ??
            widget.initialData?['discount']?.toString() ??
            '');
    _minPurchaseController = TextEditingController(
        text: widget.initialData?['minPurchaseAmount']?.toString() ?? '');
    _maxDiscountController = TextEditingController(
        text: widget.initialData?['maxDiscountAmount']?.toString() ?? '');
    _pointsController = TextEditingController(
        text: widget.initialData?['pointsRequired']?.toString() ?? '');
    _isCumulative = widget.initialData?['isCumulative'] ?? false;
    _isActive = widget.initialData?['isActive'] ??
        widget.initialData?['is_active'] ??
        true;
    final rawType = widget.initialData?['discountType'] ?? 'PERCENTAGE';
    if (rawType == 'PERCENTAGE' || rawType == 'percent') {
      discountType = 'PERCENTAGE';
    } else if (rawType == 'FIXED_AMOUNT' || rawType == 'fixed') {
      discountType = 'FIXED_AMOUNT';
    } else if (rawType == 'POINTS_EXCHANGE' || rawType == 'points') {
      discountType = 'POINTS_EXCHANGE';
    } else {
      discountType = 'PERCENTAGE';
    }
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _articlesLoading = true);
    try {
      final articles = await article_service.ArticleService.getAllArticles();
      setState(() {
        _allArticles = articles;
        // Pré-sélection si édition
        if (widget.initialData?['articles'] != null) {
          final initialIds = widget.initialData!['articles']
              .map((a) => a is String ? a : a['id'])
              .toList();
          _selectedArticles =
              articles.where((a) => initialIds.contains(a.id)).toList();
        }
      });
    } catch (e) {
      // Optionnel: afficher une erreur
    } finally {
      setState(() => _articlesLoading = false);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Préparer les données avec validation
      final submitData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'discountType': discountType,
        'discountValue': double.tryParse(_discountValueController.text) ?? 0.0,
        'isCumulative': _isCumulative,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'isActive': _isActive,
      };

      // Ajouter les champs optionnels seulement s'ils ont une valeur
      final minPurchase = double.tryParse(_minPurchaseController.text);
      if (minPurchase != null && minPurchase > 0) {
        submitData['minPurchaseAmount'] = minPurchase;
      }

      final maxDiscount = double.tryParse(_maxDiscountController.text);
      if (maxDiscount != null && maxDiscount > 0) {
        submitData['maxDiscountAmount'] = maxDiscount;
      }

      final points = int.tryParse(_pointsController.text);
      if (points != null && points > 0) {
        submitData['pointsRequired'] = points;
      }

      // Ajouter les articles sélectionnés
      if (_selectedArticles.isNotEmpty) {
        submitData['articles'] = _selectedArticles.map((article) => article.id).toList();
      }

      // Fermer le dialog AVANT d'appeler le callback
      Navigator.of(context).pop();
      
      // Appeler le callback parent
      widget.onSubmit(submitData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialData == null
                      ? 'Créer une offre'
                      : 'Modifier l\'offre',
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nom de l\'offre'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDateController.text.isNotEmpty
                          ? DateTime.tryParse(_startDateController.text) ??
                              DateTime.now()
                          : DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(picked),
                      );
                      final dateTime = DateTime(picked.year, picked.month,
                          picked.day, time?.hour ?? 0, time?.minute ?? 0);
                      setState(() {
                        _startDateController.text = dateTime.toIso8601String();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                          labelText: 'Date de début (YYYY-MM-DD HH:mm)'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDateController.text.isNotEmpty
                          ? DateTime.tryParse(_endDateController.text) ??
                              DateTime.now()
                          : DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(picked),
                      );
                      final dateTime = DateTime(picked.year, picked.month,
                          picked.day, time?.hour ?? 0, time?.minute ?? 0);
                      setState(() {
                        _endDateController.text = dateTime.toIso8601String();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                          labelText: 'Date de fin (YYYY-MM-DD HH:mm)'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Remplace la sélection directe par un bouton qui ouvre un modal
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Articles liés', style: AppTextStyles.bodyBold),
                    ),
                    TextButton(
                      onPressed: _articlesLoading
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: 400, maxHeight: 500),
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Sélectionner les articles',
                                                  style:
                                                      AppTextStyles.bodyBold),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (_selectedArticles
                                                            .length ==
                                                        _allArticles.length) {
                                                      _selectedArticles.clear();
                                                    } else {
                                                      _selectedArticles =
                                                          List.from(
                                                              _allArticles);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                    _selectedArticles.length ==
                                                            _allArticles.length
                                                        ? 'Tout désélectionner'
                                                        : 'Tout sélectionner'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: _allArticles.length,
                                              itemBuilder: (context, index) {
                                                final article =
                                                    _allArticles[index];
                                                final selected =
                                                    _selectedArticles.any((a) =>
                                                        a.id == article.id);
                                                return CheckboxListTile(
                                                  value: selected,
                                                  title: Text(article.name),
                                                  onChanged: (checked) {
                                                    setState(() {
                                                      if (checked == true) {
                                                        _selectedArticles
                                                            .add(article);
                                                      } else {
                                                        _selectedArticles
                                                            .removeWhere((a) =>
                                                                a.id ==
                                                                article.id);
                                                      }
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: GlassButton(
                                              label: 'Valider la sélection',
                                              icon: Icons.check,
                                              variant:
                                                  GlassButtonVariant.primary,
                                              fullWidth: true,
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                      child: Text('Sélectionner les articles'),
                    ),
                  ],
                ),
                if (_selectedArticles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: _selectedArticles
                          .map((a) => Chip(
                                label: Text(a.name),
                                onDeleted: () {
                                  setState(() {
                                    _selectedArticles
                                        .removeWhere((art) => art.id == a.id);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _discountValueController,
                  decoration:
                      const InputDecoration(labelText: 'Valeur de la remise'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: discountType,
                        items: const [
                          DropdownMenuItem(
                              value: 'PERCENTAGE', child: Text('Pourcentage')),
                          DropdownMenuItem(
                              value: 'FIXED_AMOUNT',
                              child: Text('Montant fixe')),
                          DropdownMenuItem(
                              value: 'POINTS_EXCHANGE',
                              child: Text('Échange de points')),
                        ],
                        onChanged: (v) =>
                            setState(() => discountType = v ?? 'PERCENTAGE'),
                        decoration:
                            const InputDecoration(labelText: 'Type de remise'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minPurchaseController,
                        decoration: const InputDecoration(
                            labelText: "Montant minimum d'achat"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _maxDiscountController,
                        decoration: const InputDecoration(
                            labelText: 'Montant max de remise'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pointsController,
                        decoration:
                            const InputDecoration(labelText: 'Points requis'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Cumulable'),
                        value: _isCumulative,
                        onChanged: (v) => setState(() => _isCumulative = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label:
                            widget.initialData == null ? 'Créer' : 'Modifier',
                        icon:
                            widget.initialData == null ? Icons.add : Icons.edit,
                        variant: GlassButtonVariant.primary,
                        fullWidth: true,
                        onPressed: _submit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassButton(
                        label: 'Annuler',
                        icon: Icons.close,
                        variant: GlassButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

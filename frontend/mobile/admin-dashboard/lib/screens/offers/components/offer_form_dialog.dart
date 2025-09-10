import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../services/article_service.dart' as article_service;
import '../../../models/article.dart';

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
  List<Article> _selectedArticles = [];
  List<Article> _allArticles = [];
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
        if (widget.initialData?['articles'] != null) {
          final initialIds = widget.initialData!['articles']
              .map((a) => a is String ? a : a['id'])
              .toSet();
          _selectedArticles =
              articles.where((a) => initialIds.contains(a.id)).toList();
        }
      });
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => _articlesLoading = false);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final submitData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'discountType': discountType,
        'discountValue': double.tryParse(_discountValueController.text) ?? 0.0,
        'isCumulative': _isCumulative,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'isActive': _isActive,
        'articles': _selectedArticles.map((a) => a.id).toList(),
      };

      final minPurchase = double.tryParse(_minPurchaseController.text);
      if (minPurchase != null) submitData['minPurchaseAmount'] = minPurchase;

      final maxDiscount = double.tryParse(_maxDiscountController.text);
      if (maxDiscount != null) submitData['maxDiscountAmount'] = maxDiscount;

      final points = int.tryParse(_pointsController.text);
      if (points != null) submitData['pointsRequired'] = points;

      Navigator.of(context).pop();
      widget.onSubmit(submitData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
      content: GlassContainer(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                  style: AppTextStyles.h3,
                ),
                SizedBox(height: AppSpacing.lg),
                _buildTextField(_nameController, 'Nom de l\'offre', isDark),
                SizedBox(height: AppSpacing.md),
                _buildTextField(_descriptionController, 'Description', isDark,
                    maxLines: 3),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                        child: _buildDatePicker(context, _startDateController,
                            'Date de début', isDark)),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _buildDatePicker(context, _endDateController,
                            'Date de fin', isDark)),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                _buildDropdown(isDark),
                SizedBox(height: AppSpacing.md),
                _buildConditionalFields(isDark),
                SizedBox(height: AppSpacing.md),
                _buildArticleSelector(context, isDark),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _buildToggle('Cumulative', _isCumulative,
                        (v) => setState(() => _isCumulative = v)),
                    SizedBox(width: AppSpacing.lg),
                    _buildToggle('Active', _isActive,
                        (v) => setState(() => _isActive = v)),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isDark,
      {int maxLines = 1,
      TextInputType? keyboardType,
      bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, isDark: isDark),
      validator: (v) {
        if (!isOptional && (v == null || v.isEmpty)) {
          return 'Champ requis';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context,
      TextEditingController controller, String label, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: _inputDecoration(label,
              isDark: isDark, suffixIcon: Icons.calendar_today_outlined),
          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: discountType,
      items: [
        DropdownMenuItem(value: 'PERCENTAGE', child: Text('Pourcentage')),
        DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Montant Fixe')),
        DropdownMenuItem(
            value: 'POINTS_EXCHANGE', child: Text('Échange de Points')),
      ],
      onChanged: (v) => setState(() => discountType = v ?? 'PERCENTAGE'),
      decoration: _inputDecoration('Type de remise', isDark: isDark),
    );
  }

  Widget _buildConditionalFields(bool isDark) {
    if (discountType == 'POINTS_EXCHANGE') {
      return _buildTextField(_pointsController, 'Points requis', isDark,
          keyboardType: TextInputType.number);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: _buildTextField(
                _discountValueController, 'Valeur de la remise', isDark,
                keyboardType: TextInputType.number)),
        SizedBox(width: AppSpacing.md),
        Expanded(
            child: _buildTextField(
                _minPurchaseController, 'Achat minimum', isDark,
                keyboardType: TextInputType.number, isOptional: true)),
        SizedBox(width: AppSpacing.md),
        Expanded(
            child: _buildTextField(_maxDiscountController, 'Remise max', isDark,
                keyboardType: TextInputType.number, isOptional: true)),
      ],
    );
  }

  Widget _buildArticleSelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassButton(
          label: 'Sélectionner des articles',
          icon: Icons.add_shopping_cart,
          variant: GlassButtonVariant.secondary,
          onPressed: () => _showArticleSelectionDialog(context, isDark),
        ),
        if (_selectedArticles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _selectedArticles
                  .map((article) => Chip(
                        label: Text(article.name),
                        onDeleted: () => setState(() => _selectedArticles
                            .removeWhere((a) => a.id == article.id)),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _showArticleSelectionDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
          title: Text('Sélectionner des articles'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: double.maxFinite,
                child: _articlesLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _allArticles.length,
                        itemBuilder: (context, index) {
                          final article = _allArticles[index];
                          final isSelected =
                              _selectedArticles.any((a) => a.id == article.id);
                          return CheckboxListTile(
                            title: Text(article.name),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedArticles.add(article);
                                } else {
                                  _selectedArticles
                                      .removeWhere((a) => a.id == article.id);
                                }
                                // Met à jour l'UI du formulaire principal
                                this.setState(() {});
                              });
                            },
                          );
                        },
                      ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Switch(
            value: value, onChanged: onChanged, activeColor: AppColors.primary),
        SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Annuler',
          variant: GlassButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SizedBox(width: AppSpacing.md),
        GlassButton(
          label: widget.initialData == null ? 'Créer' : 'Modifier',
          variant: GlassButtonVariant.primary,
          onPressed: _submit,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label,
      {bool isDark = false, IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      labelStyle:
          TextStyle(color: isDark ? AppColors.gray300 : AppColors.gray700),
      filled: true,
      fillColor: isDark
          ? AppColors.gray800.withOpacity(0.5)
          : AppColors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }
}

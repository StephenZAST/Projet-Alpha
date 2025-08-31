import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_button.dart';

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
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;
  String discountType = 'PERCENTAGE';

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialData?['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialData?['description'] ?? '');
    _discountController = TextEditingController(
        text: widget.initialData?['discount']?.toString() ?? '');
    final rawType = widget.initialData?['discountType'] ?? 'PERCENTAGE';
    if (rawType == 'PERCENTAGE' || rawType == 'percent') {
      discountType = 'PERCENTAGE';
    } else if (rawType == 'FIXED_AMOUNT' || rawType == 'fixed') {
      discountType = 'FIXED_AMOUNT';
    } else {
      discountType = 'PERCENTAGE';
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'discountType': discountType,
      });
      Navigator.of(context).pop();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.initialData == null
                      ? 'Créer une offre'
                      : 'Modifier l\'offre',
                  style: AppTextStyles.bodyBold),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _discountController,
                decoration: InputDecoration(labelText: 'Remise'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: discountType,
                items: [
                  DropdownMenuItem(
                      value: 'PERCENTAGE', child: Text('Pourcentage')),
                  DropdownMenuItem(
                      value: 'FIXED_AMOUNT', child: Text('Montant fixe')),
                ],
                onChanged: (v) =>
                    setState(() => discountType = v ?? 'PERCENTAGE'),
                decoration: InputDecoration(labelText: 'Type de remise'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: widget.initialData == null ? 'Créer' : 'Modifier',
                      icon: widget.initialData == null ? Icons.add : Icons.edit,
                      variant: GlassButtonVariant.primary,
                      fullWidth: true,
                      onPressed: _submit,
                    ),
                  ),
                  SizedBox(width: 8),
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
    );
  }
}

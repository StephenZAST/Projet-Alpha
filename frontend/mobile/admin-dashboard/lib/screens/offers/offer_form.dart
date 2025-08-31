import 'package:admin/widgets/shared/glass_button.dart';
import 'package:flutter/material.dart';

class OfferForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic>) onSubmit;

  const OfferForm({
    Key? key,
    this.initialData,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<OfferForm> createState() => _OfferFormState();
}

class _OfferFormState extends State<OfferForm> {
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
    // Correction : mappe les valeurs backend vers frontend
    final rawType = widget.initialData?['discountType'] ?? 'PERCENTAGE';
    if (rawType == 'PERCENTAGE' || rawType == 'percent') {
      discountType = 'PERCENTAGE';
    } else if (rawType == 'FIXED_AMOUNT' || rawType == 'fixed') {
      discountType = 'FIXED_AMOUNT';
    } else {
      discountType = 'PERCENTAGE';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'discountType': discountType,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Titre'),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _discountController,
            decoration: InputDecoration(labelText: 'Remise'),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: discountType,
            items: [
              DropdownMenuItem(value: 'PERCENTAGE', child: Text('Pourcentage')),
              DropdownMenuItem(
                  value: 'FIXED_AMOUNT', child: Text('Montant fixe')),
            ],
            onChanged: (v) => setState(() => discountType = v ?? 'PERCENTAGE'),
            decoration: InputDecoration(labelText: 'Type de remise'),
          ),
          SizedBox(height: 16),
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
                  onPressed: () {
                    // Ferme le formulaire via callback parent
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      if (mounted) {
                        setState(() {
                          // On suppose que le parent gère showForm
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

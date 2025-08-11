import 'package:flutter/material.dart';
import '../../../models/service_type.dart';
import '../../../widgets/shared/glass_button.dart';

class ServiceTypeDialog extends StatefulWidget {
  final ServiceType? editType;
  const ServiceTypeDialog({Key? key, this.editType}) : super(key: key);

  @override
  State<ServiceTypeDialog> createState() => _ServiceTypeDialogState();
}

class _ServiceTypeDialogState extends State<ServiceTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _description;
  bool _requiresWeight = false;
  bool _supportsPremium = false;
  bool _isDefault = false;
  bool _isActive = true;
  String? _pricingType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editType != null) {
      _name = widget.editType!.name;
      _description = widget.editType!.description;
      _requiresWeight = widget.editType!.requiresWeight ?? false;
      _supportsPremium = widget.editType!.supportsPremium ?? false;
      _isDefault = widget.editType!.isDefault ?? false;
      _isActive = widget.editType!.isActive ?? true;
      _pricingType = widget.editType!.pricingType;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    final data = {
      'name': _name,
      'description': _description,
      'requires_weight': _requiresWeight,
      'supports_premium': _supportsPremium,
      'is_default': _isDefault,
      'is_active': _isActive,
      'pricing_type': _pricingType,
    };
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editType == null
          ? 'Ajouter un type de service'
          : 'Modifier le type de service'),
      content: _isLoading
          ? SizedBox(
              height: 120, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(labelText: 'Nom'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nom obligatoire'
                            : null,
                        onSaved: (v) => _name = v?.trim(),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(labelText: 'Description'),
                        onSaved: (v) => _description = v?.trim(),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _pricingType,
                        items: [
                          DropdownMenuItem(value: 'FIXED', child: Text('Fixe')),
                          DropdownMenuItem(
                              value: 'WEIGHT_BASED', child: Text('Au poids')),
                          DropdownMenuItem(
                              value: 'SUBSCRIPTION', child: Text('Abonnement')),
                          DropdownMenuItem(
                              value: 'CUSTOM', child: Text('Personnalisé')),
                        ],
                        onChanged: (v) => setState(() => _pricingType = v),
                        decoration:
                            InputDecoration(labelText: 'Type de tarification'),
                        validator: (v) => v == null
                            ? 'Type de tarification obligatoire'
                            : null,
                      ),
                      SizedBox(height: 12),
                      SwitchListTile(
                        title: Text('Nécessite le poids'),
                        value: _requiresWeight,
                        onChanged: (v) => setState(() => _requiresWeight = v),
                      ),
                      SwitchListTile(
                        title: Text('Supporte le premium'),
                        value: _supportsPremium,
                        onChanged: (v) => setState(() => _supportsPremium = v),
                      ),
                      SwitchListTile(
                        title: Text('Type par défaut'),
                        value: _isDefault,
                        onChanged: (v) => setState(() => _isDefault = v),
                      ),
                      SwitchListTile(
                        title: Text('Actif'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        GlassButton(
          label: widget.editType == null ? 'Ajouter' : 'Enregistrer',
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}

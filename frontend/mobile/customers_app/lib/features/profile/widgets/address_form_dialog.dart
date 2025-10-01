import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/address.dart';

/// 📝 Dialog de Formulaire d'Adresse - Alpha Client App
///
/// Dialog premium pour créer ou modifier une adresse
/// avec validation en temps réel et design glassmorphism.
class AddressFormDialog extends StatefulWidget {
  final String title;
  final Address? initialAddress;
  final Future<bool> Function(CreateAddressRequest) onSave;

  const AddressFormDialog({
    Key? key,
    required this.title,
    this.initialAddress,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  bool _isDefault = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialAddress != null) {
      final address = widget.initialAddress!;
      _nameController.text = address.name;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _postalCodeController.text = address.postalCode;
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 En-tête du dialog
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.initialAddress != null ? Icons.edit_location : Icons.add_location,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.initialAddress != null 
                    ? 'Modifiez les informations de votre adresse'
                    : 'Ajoutez une nouvelle adresse',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// 📝 Formulaire
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nom de l'adresse
          _buildTextField(
            controller: _nameController,
            label: 'Nom de l\'adresse',
            hint: 'Ex: Maison, Bureau, Chez mes parents...',
            icon: Icons.label_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom de l\'adresse est requis';
              }
              if (value.trim().length < 2) {
                return 'Le nom doit contenir au moins 2 caractères';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Rue
          _buildTextField(
            controller: _streetController,
            label: 'Adresse',
            hint: 'Numéro et nom de rue',
            icon: Icons.home_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'adresse est requise';
              }
              if (value.trim().length < 5) {
                return 'L\'adresse doit contenir au moins 5 caractères';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Ville et Code postal
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'Ville',
                  hint: 'Nom de la ville',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La ville est requise';
                    }
                    if (value.trim().length < 2) {
                      return 'Nom de ville invalide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Code postal',
                  hint: '75001',
                  icon: Icons.markunread_mailbox_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Code postal requis';
                    }
                    if (value.trim().length != 5) {
                      return 'Code postal invalide';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Option par défaut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.home,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse par défaut',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Utilisée automatiquement pour vos commandes',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Champ de texte personnalisé
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.surfaceVariant(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.surfaceVariant(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// 🎯 Actions du dialog
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: widget.initialAddress != null ? 'Modifier' : 'Ajouter',
            onPressed: _isLoading ? null : _handleSave,
            isLoading: _isLoading,
            icon: widget.initialAddress != null ? Icons.edit : Icons.add,
          ),
        ),
      ],
    );
  }

  /// 💾 Gestionnaire de sauvegarde
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateAddressRequest(
        name: _nameController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        isDefault: _isDefault,
      );

      final success = await widget.onSave(request);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // L'erreur est gérée par le parent
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// 🎯 Dialog de Sélection d'Adresse
class AddressSelectionDialog extends StatefulWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final String title;
  final Function(Address) onAddressSelected;

  const AddressSelectionDialog({
    Key? key,
    required this.addresses,
    this.selectedAddress,
    this.title = 'Choisir une adresse',
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  State<AddressSelectionDialog> createState() => _AddressSelectionDialogState();
}

class _AddressSelectionDialogState extends State<AddressSelectionDialog> {
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.selectedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Liste des adresses
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.addresses.map((address) {
                      final isSelected = _selectedAddress?.id == address.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAddress = address;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.surfaceVariant(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  address.isDefault ? Icons.home : Icons.location_on,
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : AppColors.textSecondary(context),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              address.name,
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: AppColors.textPrimary(context),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (address.isDefault) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'DÉFAUT',
                                                style: AppTextStyles.labelSmall.copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        address.formattedAddress,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Annuler',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PremiumButton(
                      text: 'Sélectionner',
                      onPressed: _selectedAddress != null 
                          ? () {
                              widget.onAddressSelected(_selectedAddress!);
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: Icons.check,
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
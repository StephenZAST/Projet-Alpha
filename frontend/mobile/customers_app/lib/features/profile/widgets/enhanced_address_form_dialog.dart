import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../core/models/address.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/gps_converter.dart';
import 'location_picker_widget.dart';
import 'address_parser_helper.dart';

/// 📝 Dialog de Formulaire d'Adresse Amélioré - Alpha Client App
///
/// Dialog premium pour créer ou modifier une adresse avec sélection de localisation
/// sur carte OpenStreetMap et géolocalisation automatique.
class EnhancedAddressFormDialog extends StatefulWidget {
  final String title;
  final Address? initialAddress;
  final Future<bool> Function(CreateAddressRequest) onSave;

  const EnhancedAddressFormDialog({
    Key? key,
    required this.title,
    this.initialAddress,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EnhancedAddressFormDialog> createState() =>
      _EnhancedAddressFormDialogState();
}

class _EnhancedAddressFormDialogState extends State<EnhancedAddressFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _searchController = TextEditingController();

  late TabController _tabController;

  bool _isDefault = false;
  bool _isLoading = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedLocationAddress = '';

  List<LocationSuggestion> _searchSuggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeForm();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeForm() {
    if (widget.initialAddress != null) {
      final address = widget.initialAddress!;
      _nameController.text = address.name;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _postalCodeController.text = address.postalCode;
      _isDefault = address.isDefault;
      _selectedLatitude = address.gpsLatitude;
      _selectedLongitude = address.gpsLongitude;

      if (address.hasGpsCoordinates) {
        _selectedLocationAddress = address.formattedAddress;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    print('[EnhancedAddressFormDialog] 🔍 _onSearchChanged: "$query"');

    // ✅ ÉTAPE 1: Query vide
    if (query.isEmpty) {
      print('[EnhancedAddressFormDialog] ⚪ Query vide → nettoyage');
      setState(() {
        _searchSuggestions.clear();
        _showSuggestions = false;
        _isSearching = false;
      });
      return; // 🛑 SORTIE 1
    }

    // ✅ ÉTAPE 2: Vérifier GPS AVANT toute chose
    final isGps = GpsConverter.isGpsCoordinate(query);
    if (isGps) {
      print('[EnhancedAddressFormDialog] 🟢 ✅ GPS DÉTECTÉ: $query');

      // Convertir en format décimal normalisé
      final decimalFormat = GpsConverter.toDecimalFormat(query);
      if (decimalFormat != null) {
        print('[EnhancedAddressFormDialog] ✅ Converti en: $decimalFormat');
        // Vider les suggestions et utiliser le format converti
        setState(() {
          _searchSuggestions.clear();
          _showSuggestions = false;
          _isSearching = false;
        });
        // Mettre à jour le champ avec le format décimal normalisé
        _searchController.text = decimalFormat;
      }
      return; // IMPORTANT: SORTIE - pas d'appel API Nominatim
    }

    // ✅ ÉTAPE 3: Si pas GPS et query >= 3 caractères → Recherche Nominatim
    if (query.length >= 3) {
      print(
          '[EnhancedAddressFormDialog] 🔵 Query texte valide ($query.length chars) → Appel API Nominatim');
      _searchAddresses(query);
    } else {
      // Query trop courte
      print(
          '[EnhancedAddressFormDialog] ⚪ Query trop courte (${query.length} chars) → nettoyage');
      setState(() {
        _searchSuggestions.clear();
        _showSuggestions = false;
        _isSearching = false;
      });
    }
  }

  /// 🔍 Rechercher des adresses via Nominatim (OpenStreetMap)
  /// ⚠️ N'est appelé QUE pour les recherches texte, pas pour les coordonnées GPS
  Future<void> _searchAddresses(String query) async {
    print('[EnhancedAddressFormDialog] Recherche d\'adresse: $query');

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      final suggestions = await LocationService.searchAddresses(query);
      if (mounted) {
        setState(() {
          _searchSuggestions = suggestions;
          _isSearching = false;
        });

        // Afficher un message si aucun résultat
        if (suggestions.isEmpty) {
          print(
              '[EnhancedAddressFormDialog] Aucun résultat trouvé pour: $query');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aucune adresse trouvée. Essayez les coordonnées GPS.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMD,
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('[EnhancedAddressFormDialog] ❌ Erreur recherche adresse: $e');
      if (mounted) {
        setState(() {
          _searchSuggestions.clear();
          _isSearching = false;
          _showSuggestions = false;
        });

        // Afficher l'erreur à l'utilisateur
        _showErrorSnackBar(
            'Erreur de recherche: ${e.toString().contains('CORS') ? 'Erreur serveur - Essayez les coordonnées GPS' : e.toString()}');
      }
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    setState(() {
      _selectedLatitude = suggestion.latitude;
      _selectedLongitude = suggestion.longitude;
      _selectedLocationAddress = suggestion.formattedAddress;
      _showSuggestions = false;

      // Pré-remplir les champs du formulaire
      if (suggestion.fullStreet.isNotEmpty) {
        _streetController.text = suggestion.fullStreet;
      }
      if (suggestion.city != null) {
        _cityController.text = suggestion.city!;
      }
      if (suggestion.postalCode != null) {
        _postalCodeController.text = suggestion.postalCode!;
      }

      _searchController.text = suggestion.formattedAddress;
    });
  }

  void _onLocationSelected(double latitude, double longitude, String address) {
    setState(() {
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
      _selectedLocationAddress = address;

      // 🎯 Pré-remplir intelligemment les champs du formulaire avec l'adresse de la carte
      AddressParserHelper.parseAndFillAddressFields(
        fullAddress: address,
        streetController: _streetController,
        cityController: _cityController,
        postalCodeController: _postalCodeController,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📱 Obtenir les dimensions de l'écran et du clavier
    final screenSize = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardVisible = viewInsets.bottom > 0;

    // 🎯 Calculer la hauteur disponible intelligemment
    // Laisser de l'espace pour le clavier et la barre système
    final availableHeight = screenSize.height - viewInsets.bottom - 32;
    final dialogHeight = isKeyboardVisible
        ? availableHeight * 0.85 // Réduire quand le clavier est visible
        : min(availableHeight * 0.9, 800.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      // 🔑 Empêcher le redimensionnement automatique du dialog
      insetAnimationDuration: const Duration(milliseconds: 200),
      insetAnimationCurve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: dialogHeight,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTabBar(),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildManualForm(),
                    _buildLocationPicker(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
            widget.initialAddress != null
                ? Icons.edit_location
                : Icons.add_location,
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
                    ? 'Modifiez votre adresse avec précision'
                    : 'Ajoutez une nouvelle adresse avec localisation',
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

  /// 📑 Barre d'onglets
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary(context),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tabs: const [
          Tab(
            icon: Icon(Icons.edit_outlined, size: 18),
            text: 'Saisie manuelle',
            height: 60,
          ),
          Tab(
            icon: Icon(Icons.map_outlined, size: 18),
            text: 'Carte & GPS',
            height: 60,
          ),
        ],
      ),
    );
  }

  /// 📝 Formulaire manuel
  Widget _buildManualForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Recherche d'adresse
            _buildAddressSearchField(),

            const SizedBox(height: 16),

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

            // Informations GPS
            if (_selectedLatitude != null && _selectedLongitude != null)
              _buildGpsInfoCard(),

            const SizedBox(height: 16),

            // Option par défaut
            _buildDefaultAddressOption(),
          ],
        ),
      ),
    );
  }

  /// 🔍 Champ de recherche d'adresse avec support GPS
  Widget _buildAddressSearchField() {
    final query = _searchController.text.trim();
    final looksLikeGps = GpsConverter.isGpsCoordinate(query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recherche d\'adresse',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: looksLikeGps
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.surfaceVariant(context),
              width: looksLikeGps ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Adresse, coordonnées GPS ou Plus Code...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary(context),
                  ),
                  prefixIcon: Icon(
                    looksLikeGps ? Icons.gps_fixed : Icons.search,
                    color: looksLikeGps
                        ? AppColors.success
                        : AppColors.textSecondary(context),
                    size: 20,
                  ),
                  suffixIcon: _isSearching
                      ? Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textSecondary(context),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _showSuggestions = false;
                                });
                              },
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onTap: () {
                  if (_searchSuggestions.isNotEmpty) {
                    setState(() {
                      _showSuggestions = true;
                    });
                  }
                },
              ),

              // Suggestions de recherche ou résultat GPS
              if (_showSuggestions)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.surfaceVariant(context),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Afficher un message si GPS détecté
                      if (looksLikeGps)
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.gps_fixed,
                            color: AppColors.success,
                            size: 20,
                          ),
                          title: Text(
                            'Coordonnées GPS détectées',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            query,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      // Sinon afficher les suggestions d'adresse
                      else if (_searchSuggestions.isNotEmpty)
                        ..._searchSuggestions.take(5).map((suggestion) {
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            title: Text(
                              suggestion.formattedAddress,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        }).toList(),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Aide sur les formats GPS
        if (query.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Formats acceptés: adresse, coordonnées GPS (12.359364, -1.473508) ou Plus Code (9GJP+MWJ)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 🗺️ Sélecteur de localisation
  Widget _buildLocationPicker() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Sélectionnez votre adresse sur la carte',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Carte de localisation
          Container(
            height: 300,
            child: LocationPickerWidget(
              initialLatitude: _selectedLatitude,
              initialLongitude: _selectedLongitude,
              initialAddress: _selectedLocationAddress,
              onLocationSelected: _onLocationSelected,
            ),
          ),

          const SizedBox(height: 20),

          // Informations GPS
          if (_selectedLatitude != null && _selectedLongitude != null)
            _buildGpsInfoCard(),

          const SizedBox(height: 16),

          // Nom de l'adresse
          _buildTextField(
            controller: _nameController,
            label: 'Nom de cette adresse',
            hint: 'Ex: Maison, Bureau...',
            icon: Icons.label_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom de l\'adresse est requis';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Champs d'adresse manuels
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border(context),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Informations d\'adresse',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Complétez les informations de votre adresse',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 16),

                // Rue
                _buildTextField(
                  controller: _streetController,
                  label: 'Adresse / Rue',
                  hint: 'Ex: Kalgodin, Ouaga 2000...',
                  icon: Icons.home_outlined,
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
                        hint: 'Ex: Ouagadougou, Bobo-Dioulasso...',
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Code postal',
                        hint: '01000',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Option par défaut
          _buildDefaultAddressOption(),
        ],
      ),
    );
  }

  /// 📍 Carte d'informations GPS
  Widget _buildGpsInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.gps_fixed,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Localisation GPS enregistrée',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Lat: ${_selectedLatitude!.toStringAsFixed(6)}, '
                  'Lng: ${_selectedLongitude!.toStringAsFixed(6)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.clear,
              color: AppColors.error,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _selectedLatitude = null;
                _selectedLongitude = null;
                _selectedLocationAddress = '';
              });
            },
          ),
        ],
      ),
    );
  }

  /// 🏠 Option adresse par défaut
  Widget _buildDefaultAddressOption() {
    return Container(
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
    print('[EnhancedAddressFormDialog] _handleSave called');
    print(
        '[EnhancedAddressFormDialog] Current tab index: ${_tabController.index}');
    print(
        '[EnhancedAddressFormDialog] Selected coordinates: lat=$_selectedLatitude, lng=$_selectedLongitude');
    print('[EnhancedAddressFormDialog] Name: ${_nameController.text}');
    print('[EnhancedAddressFormDialog] Street: ${_streetController.text}');
    print('[EnhancedAddressFormDialog] City: ${_cityController.text}');
    print(
        '[EnhancedAddressFormDialog] PostalCode: ${_postalCodeController.text}');

    // Valider selon l'onglet actuel
    if (_tabController.index == 0) {
      // Onglet manuel - valider le formulaire complet
      if (!_formKey.currentState!.validate()) {
        print('[EnhancedAddressFormDialog] Form validation failed');
        return;
      }
    } else {
      // Onglet carte - vérifier les champs requis
      if (_nameController.text.trim().isEmpty) {
        _showErrorSnackBar('Le nom de l\'adresse est requis');
        return;
      }

      if (_selectedLatitude == null || _selectedLongitude == null) {
        _showErrorSnackBar(
            'Veuillez sélectionner une localisation sur la carte');
        return;
      }

      // Pour l'onglet carte, vérifier que les champs essentiels sont remplis
      // Si c'est une modification d'adresse existante, garder les valeurs existantes
      // Si c'est une nouvelle adresse, demander les champs manquants
      if (widget.initialAddress == null) {
        // Nouvelle adresse - vérifier les champs requis
        if (_streetController.text.trim().isEmpty) {
          _showErrorSnackBar(
              'L\'adresse (rue) est requise. Veuillez la saisir dans l\'onglet "Saisie manuelle"');
          return;
        }
        if (_cityController.text.trim().isEmpty) {
          _showErrorSnackBar(
              'La ville est requise. Veuillez la saisir dans l\'onglet "Saisie manuelle"');
          return;
        }
        if (_postalCodeController.text.trim().isEmpty) {
          _showErrorSnackBar(
              'Le code postal est requis. Veuillez le saisir dans l\'onglet "Saisie manuelle"');
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Construire la requête intelligemment
      final CreateAddressRequest request;

      if (_tabController.index == 0) {
        // Onglet manuel - utiliser tous les champs du formulaire
        request = CreateAddressRequest(
          name: _nameController.text.trim(),
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          gpsLatitude: _selectedLatitude,
          gpsLongitude: _selectedLongitude,
          isDefault: _isDefault,
        );
      } else {
        // Onglet carte - logique intelligente
        String name = _nameController.text.trim();
        String street = _streetController.text.trim();
        String city = _cityController.text.trim();
        String postalCode = _postalCodeController.text.trim();

        // Si c'est une modification et que les champs sont déjà remplis, les garder
        if (widget.initialAddress != null) {
          // Modification d'adresse existante - garder les valeurs existantes si pas modifiées
          // IMPORTANT: Ne jamais remplacer les champs par des coordonnées GPS
          street = street.isNotEmpty ? street : widget.initialAddress!.street;
          city = city.isNotEmpty ? city : widget.initialAddress!.city;
          postalCode = postalCode.isNotEmpty
              ? postalCode
              : widget.initialAddress!.postalCode;
        } else {
          // Nouvelle adresse - les champs ont déjà été validés ci-dessus
          // Les coordonnées GPS ne doivent PAS remplacer les champs texte
        }

        request = CreateAddressRequest(
          name: name,
          street: street,
          city: city,
          postalCode: postalCode,
          gpsLatitude: _selectedLatitude,
          gpsLongitude: _selectedLongitude,
          isDefault: _isDefault,
        );
      }

      print(
          '[EnhancedAddressFormDialog] Final request data: ${request.toJson()}');

      final success = await widget.onSave(request);
      print('[EnhancedAddressFormDialog] Save result: $success');

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('[EnhancedAddressFormDialog] Save error: $e');
      // L'erreur est gérée par le parent
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

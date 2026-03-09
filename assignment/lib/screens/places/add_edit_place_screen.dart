import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../services/location_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';

class AddEditPlaceScreen extends StatefulWidget {
  final Place? place;
  const AddEditPlaceScreen({super.key, this.place});

  @override
  State<AddEditPlaceScreen> createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lonCtrl;

  String _selectedCategory = AppConstants.categories.first.id;
  String _selectedDistrict = AppConstants.districts.first;
  bool _fetchingLocation = false;
  bool _saving = false;

  bool get _isEditing => widget.place != null;

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _websiteCtrl = TextEditingController(text: p?.website ?? '');
    _hoursCtrl = TextEditingController(text: p?.openingHours ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _latCtrl = TextEditingController(
      text: p?.latitude != null ? p!.latitude.toString() : '',
    );
    _lonCtrl = TextEditingController(
      text: p?.longitude != null ? p!.longitude.toString() : '',
    );

    if (p != null) {
      _selectedCategory = p.category;
      _selectedDistrict = AppConstants.districts.contains(p.district)
          ? p.district
          : AppConstants.districts.first;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _descCtrl,
      _addressCtrl,
      _phoneCtrl,
      _websiteCtrl,
      _hoursCtrl,
      _imageCtrl,
      _latCtrl,
      _lonCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    final pos = await LocationService.getCurrentPosition();
    setState(() => _fetchingLocation = false);

    if (pos != null) {
      _latCtrl.text = pos.latitude.toStringAsFixed(6);
      _lonCtrl.text = pos.longitude.toStringAsFixed(6);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get location. Please check permissions.'),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final auth = context.read<AuthProvider>();
    final now = DateTime.now();
    final lat = double.tryParse(_latCtrl.text);
    final lon = double.tryParse(_lonCtrl.text);

    final Place place;
    if (_isEditing) {
      place = widget.place!.copyWith(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory,
        description: _descCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        district: _selectedDistrict,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty
            ? null
            : _websiteCtrl.text.trim(),
        openingHours: _hoursCtrl.text.trim().isEmpty
            ? null
            : _hoursCtrl.text.trim(),
        imageUrl: _imageCtrl.text.trim().isEmpty
            ? null
            : _imageCtrl.text.trim(),
        latitude: lat,
        longitude: lon,
        updatedAt: now,
      );
    } else {
      place = Place(
        id: '',
        name: _nameCtrl.text.trim(),
        category: _selectedCategory,
        description: _descCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        district: _selectedDistrict,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty
            ? null
            : _websiteCtrl.text.trim(),
        openingHours: _hoursCtrl.text.trim().isEmpty
            ? null
            : _hoursCtrl.text.trim(),
        imageUrl: _imageCtrl.text.trim().isEmpty
            ? null
            : _imageCtrl.text.trim(),
        latitude: lat,
        longitude: lon,
        createdBy: auth.user?.uid ?? '',
        createdByName: auth.user?.displayName ?? '',
        createdAt: now,
        updatedAt: now,
      );
    }

    final prov = context.read<PlacesProvider>();
    final errorMsg = _isEditing
        ? await prov.updatePlace(place)
        : await prov.addPlace(place);

    if (!mounted) return;
    setState(() => _saving = false);

    if (errorMsg == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Place updated!' : 'Place added successfully!',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Place' : 'Add Place')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(label: 'Basic Information'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Place Name *',
                hint: 'e.g. King Faysal Hospital',
                controller: _nameCtrl,
                prefixIcon: Icons.place_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the place name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 18, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description *',
                hint: 'Brief description of the place',
                controller: _descCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Location'),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Street Address *',
                hint: 'e.g. KN 3 Ave, Kiyovu',
                controller: _addressCtrl,
                prefixIcon: Icons.home_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter the address'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'District *',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: AppConstants.districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDistrict = v!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Latitude',
                      hint: '-1.9441',
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      prefixIcon: Icons.swap_vert_circle_outlined,
                      validator: _validateCoord,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Longitude',
                      hint: '30.0619',
                      controller: _lonCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      prefixIcon: Icons.swap_horiz_outlined,
                      validator: _validateCoord,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _fetchingLocation ? null : _useCurrentLocation,
                icon: _fetchingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  _fetchingLocation
                      ? 'Getting location…'
                      : 'Use Current Location',
                ),
              ),

              // ── Contact ────────────────────────────────────────────────────
              const SizedBox(height: 24),
              _SectionHeader(label: 'Contact Details (optional)'),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Phone Number',
                hint: '+250 788 000 000',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Website',
                hint: 'www.example.rw',
                controller: _websiteCtrl,
                keyboardType: TextInputType.url,
                prefixIcon: Icons.language,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Opening Hours',
                hint: 'Mon–Fri: 8 am – 5 pm',
                controller: _hoursCtrl,
                prefixIcon: Icons.access_time_outlined,
              ),

              // ── Media ──────────────────────────────────────────────────────
              const SizedBox(height: 24),
              _SectionHeader(label: 'Photo (optional)'),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Image URL',
                hint: 'https://example.com/photo.jpg',
                controller: _imageCtrl,
                keyboardType: TextInputType.url,
                prefixIcon: Icons.image_outlined,
              ),

              // Preview
              if (_imageCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imageCtrl.text.trim(),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text(
                          'Invalid image URL',
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Save ───────────────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isEditing ? 'Update Place' : 'Add Place'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateCoord(String? v) {
    if (v == null || v.isEmpty) return null; // optional
    if (double.tryParse(v) == null) return 'Enter a valid number';
    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}

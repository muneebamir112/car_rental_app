import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../models/vehicle.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit;
  const AddEditVehicleScreen({super.key, this.vehicleToEdit});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _regController;
  late TextEditingController _colorController;
  late TextEditingController _dailyPriceController;
  late TextEditingController _hourlyPriceController;
  late TextEditingController _depositController;
  late TextEditingController _transmissionController;
  late TextEditingController _fuelController;
  final TextEditingController _customUrlController = TextEditingController();

  List<String> _currentImagePaths = [];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;
    _nameController = TextEditingController(text: v?.name ?? '');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _regController = TextEditingController(text: v?.registrationNumber ?? '');
    _colorController = TextEditingController(text: v?.color ?? 'Super White');
    _dailyPriceController = TextEditingController(text: v?.dailyPrice.toString() ?? '15000.0');
    _hourlyPriceController = TextEditingController(text: v?.hourlyPrice.toString() ?? '1500.0');
    _depositController = TextEditingController(text: v?.securityDeposit.toString() ?? '50000.0');
    _transmissionController = TextEditingController(text: v?.transmission ?? 'Automatic');
    _fuelController = TextEditingController(text: v?.fuelType ?? 'Petrol');

    if (v != null) {
      _currentImagePaths = List<String>.from(v.imageUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _regController.dispose();
    _colorController.dispose();
    _dailyPriceController.dispose();
    _hourlyPriceController.dispose();
    _depositController.dispose();
    _transmissionController.dispose();
    _fuelController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickCarPhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (!mounted) return;
      if (photo != null) {
        setState(() {
          _currentImagePaths.add(photo.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access camera/gallery: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _saveVehicle() {
    if (_nameController.text.isEmpty || _dailyPriceController.text.isEmpty || _regController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill mandatory fields (*).')));
      return;
    }

    if (_currentImagePaths.isEmpty) {
      _currentImagePaths.add('https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&q=80&w=800');
    }

    final provider = Provider.of<AppProvider>(context, listen: false);

    if (widget.vehicleToEdit == null) {
      final newV = Vehicle(
        id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        brand: _brandController.text.isEmpty ? 'Generic' : _brandController.text,
        model: _modelController.text.isEmpty ? '2024' : _modelController.text,
        manufacturingYear: int.tryParse(_modelController.text) ?? 2024,
        registrationNumber: _regController.text,
        color: _colorController.text,
        transmission: _transmissionController.text,
        fuelType: _fuelController.text,
        seatingCapacity: 5,
        description: 'Car added by owner.',
        dailyPrice: double.tryParse(_dailyPriceController.text) ?? 15000.0,
        hourlyPrice: double.tryParse(_hourlyPriceController.text) ?? 1500.0,
        securityDeposit: double.tryParse(_depositController.text) ?? 50000.0,
        imageUrls: _currentImagePaths,
      );
      provider.addVehicle(newV);
    } else {
      final updatedV = Vehicle(
        id: widget.vehicleToEdit!.id,
        name: _nameController.text,
        brand: _brandController.text,
        model: _modelController.text,
        manufacturingYear: int.tryParse(_modelController.text) ?? widget.vehicleToEdit!.manufacturingYear,
        registrationNumber: _regController.text,
        color: _colorController.text,
        transmission: _transmissionController.text,
        fuelType: _fuelController.text,
        seatingCapacity: widget.vehicleToEdit!.seatingCapacity,
        description: widget.vehicleToEdit!.description,
        dailyPrice: double.tryParse(_dailyPriceController.text) ?? widget.vehicleToEdit!.dailyPrice,
        hourlyPrice: double.tryParse(_hourlyPriceController.text) ?? widget.vehicleToEdit!.hourlyPrice,
        securityDeposit: double.tryParse(_depositController.text) ?? widget.vehicleToEdit!.securityDeposit,
        imageUrls: _currentImagePaths,
        status: widget.vehicleToEdit!.status,
      );
      provider.updateVehicle(updatedV);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Car inventory updated successfully!')));
  }

  Widget _buildPreviewImage(String path) {
    bool isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      } else {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.directions_car, color: Colors.grey),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.vehicleToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Car Details & Photos' : 'Add New Car to Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Car',
            onPressed: _saveVehicle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Car Fields
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Car Name *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model Year *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _regController, decoration: const InputDecoration(labelText: 'Registration Number *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _colorController, decoration: const InputDecoration(labelText: 'Color', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _dailyPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Price (PKR / Rs.) *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _hourlyPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hourly Price (PKR / Rs.)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _depositController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Security Deposit (PKR / Rs.)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _transmissionController, decoration: const InputDecoration(labelText: 'Transmission (Automatic / Manual)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _fuelController, decoration: const InputDecoration(labelText: 'Fuel Type (Petrol / Diesel / Hybrid)', border: OutlineInputBorder())),
            const SizedBox(height: 20),

            // Car Photos Section
            const Text('Car Images & Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Camera Photo'),
                  onPressed: () => _pickCarPhoto(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Gallery'),
                  onPressed: () => _pickCarPhoto(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Or Paste Web Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final url = _customUrlController.text.trim();
                    if (url.isNotEmpty) {
                      setState(() {
                        _currentImagePaths.add(url);
                        _customUrlController.clear();
                      });
                    }
                  },
                  child: const Text('Add URL'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image Previews Grid
            _currentImagePaths.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Text('No images added yet. Click Camera, Gallery, or Paste URL to attach car photos.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(_currentImagePaths.length, (idx) {
                      final path = _currentImagePaths[idx];
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildPreviewImage(path),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _currentImagePaths.removeAt(idx);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Save Vehicle Changes' : 'Add Vehicle to Inventory', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: _saveVehicle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

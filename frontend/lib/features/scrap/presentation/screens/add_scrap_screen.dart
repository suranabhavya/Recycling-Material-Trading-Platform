import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/scrap/data/models/material_model.dart';
import 'package:recycling_platform/features/scrap/presentation/providers/material_provider.dart';
import 'package:recycling_platform/features/scrap/presentation/providers/upload_provider.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class AddScrapScreen extends ConsumerStatefulWidget {
  const AddScrapScreen({super.key});

  @override
  ConsumerState<AddScrapScreen> createState() => _AddScrapScreenState();
}

class _AddScrapScreenState extends ConsumerState<AddScrapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedUnit = 'KG';
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Photos',
              style: GoogleFonts.domine(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                'Take Photo',
                style: GoogleFonts.domine(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: Text(
                'Choose from Gallery',
                style: GoogleFonts.domine(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
              title: Text(
                'Choose Multiple',
                style: GoogleFonts.domine(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload images first
      final uploadRepository = ref.read(uploadRepositoryProvider);
      final imageUrls = await uploadRepository.uploadMultipleImages(_selectedImages);

      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images');
      }

      // Create material with image URLs
      final material = MaterialModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _selectedUnit,
        price: _priceController.text.trim().isEmpty
            ? null
            : double.parse(_priceController.text.trim()),
        images: imageUrls,
      );

      final materialRepository = ref.read(materialRepositoryProvider);
      await materialRepository.createMaterial(material);

      // Refresh materials list
      ref.invalidate(materialsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Clear form
        _nameController.clear();
        _descriptionController.clear();
        _quantityController.clear();
        _priceController.clear();
        setState(() {
          _selectedImages.clear();
          _selectedUnit = 'KG';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final requiresApproval = user?.roleTemplate?.requiresApproval ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Scrap Material',
            style: GoogleFonts.domine(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'List your recyclable materials',
            style: GoogleFonts.domine(
              fontSize: 16,
              color: Colors.white.withOpacityValue(0.8),
            ),
          ),

          // Approval Notice
          if (requiresApproval) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacityValue(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This material will require approval from higher levels before being added to inventory.',
                      style: GoogleFonts.domine(
                        fontSize: 12,
                        color: Colors.white.withOpacityValue(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 30),
          
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacityValue(0.2),
                  Colors.white.withOpacityValue(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacityValue(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Material Name',
                        labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                        prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.white.withOpacityValue(0.8)),
                        filled: true,
                        fillColor: Colors.white.withOpacityValue(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                        prefixIcon: Icon(Icons.description_outlined, color: Colors.white.withOpacityValue(0.8)),
                        filled: true,
                        fillColor: Colors.white.withOpacityValue(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              prefixIcon: Icon(Icons.scale_outlined, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            dropdownColor: AppColors.primaryDark,
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'KG', child: Text('KG')),
                              DropdownMenuItem(value: 'TON', child: Text('TON')),
                              DropdownMenuItem(value: 'UNIT', child: Text('UNIT')),
                            ],
                            onChanged: (value) => setState(() => _selectedUnit = value!),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expected Price (Optional)',
                        labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                        prefixIcon: Icon(Icons.currency_rupee, color: Colors.white.withOpacityValue(0.8)),
                        filled: true,
                        fillColor: Colors.white.withOpacityValue(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Image Upload Section
                    Text(
                      'Photos',
                      style: GoogleFonts.domine(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Selected Images Grid
                    if (_selectedImages.isNotEmpty)
                      Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Add Photo Button
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacityValue(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.white.withOpacityValue(0.8),
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Photos',
                              style: GoogleFonts.domine(
                                fontSize: 14,
                                color: Colors.white.withOpacityValue(0.8),
                              ),
                            ),
                            Text(
                              '${_selectedImages.length} photo(s) selected',
                              style: GoogleFonts.domine(
                                fontSize: 12,
                                color: Colors.white.withOpacityValue(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isSubmitting ? null : AppColors.primary,
                        gradient: _isSubmitting
                            ? LinearGradient(
                                colors: [
                                  Colors.grey.withOpacityValue(0.5),
                                  Colors.grey.withOpacityValue(0.3),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isSubmitting
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withOpacityValue(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                requiresApproval ? 'Submit for Approval' : 'Submit Material',
                                style: GoogleFonts.domine(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


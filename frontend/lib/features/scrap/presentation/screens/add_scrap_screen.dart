import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Scrap Material',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'List your recyclable materials',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacityValue(0.8),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
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
                            dropdownColor: AppColors.darkGreen,
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
                    
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacityValue(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature coming soon!'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Submit for Approval',
                          style: GoogleFonts.poppins(
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
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}


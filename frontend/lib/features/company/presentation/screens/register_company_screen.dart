import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';

class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  ConsumerState<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends ConsumerState<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'AUTOMOBILE';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Register Company',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms),
                
                const SizedBox(height: 10),
                
                Text(
                  'Fill in your company details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacityValue(0.8),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                
                const SizedBox(height: 40),
                
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
                              labelText: 'Company Name',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              prefixIcon: Icon(Icons.business, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Company Email',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              if (!value!.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _phoneController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone (Optional)',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _addressController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Address (Optional)',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              prefixIcon: Icon(Icons.location_on, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Company Type',
                              labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                              prefixIcon: Icon(Icons.category, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                            ),
                            dropdownColor: AppColors.darkGreen,
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'AUTOMOBILE', child: Text('Automobile')),
                              DropdownMenuItem(value: 'RECYCLING', child: Text('Recycling')),
                              DropdownMenuItem(value: 'MANUFACTURING', child: Text('Manufacturing')),
                              DropdownMenuItem(value: 'OTHERS', child: Text('Others')),
                            ],
                            onChanged: (value) => setState(() => _selectedType = value!),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              onPressed: companyState.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        ref.read(companyProvider.notifier).createCompany(
                                          context,
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                                          address: _addressController.text.isEmpty ? null : _addressController.text,
                                          type: _selectedType,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: companyState.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text('Register Company', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


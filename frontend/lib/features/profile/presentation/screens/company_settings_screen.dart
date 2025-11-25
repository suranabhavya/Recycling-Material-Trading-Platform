import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _gstNumberController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final company = ref.read(authProvider).user?.company;
    _companyNameController = TextEditingController(text: company?.name ?? '');
    _addressController = TextEditingController(text: ''); // TODO: Add to CompanyModel
    _phoneController = TextEditingController(text: ''); // TODO: Add to CompanyModel
    _gstNumberController = TextEditingController(text: ''); // TODO: Add to CompanyModel
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _gstNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.roleTemplate?.name.toUpperCase() == 'ADMIN';
    
    // Redirect if not admin
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin privileges required.'),
            backgroundColor: AppColors.error,
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company Settings',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Admin Only',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Information Section
                      Text(
                        'Company Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      
                      const SizedBox(height: 16),
                      
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
                          borderRadius: BorderRadius.circular(20),
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
                                  controller: _companyNameController,
                                  enabled: _isEditing,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Company Name',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.business, color: Colors.white.withOpacityValue(0.8)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(_isEditing ? 0.1 : 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true ? 'Company name is required' : null,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _addressController,
                                  enabled: _isEditing,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.white.withOpacityValue(0.8)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(_isEditing ? 0.1 : 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _phoneController,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.phone_outlined, color: Colors.white.withOpacityValue(0.8)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(_isEditing ? 0.1 : 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true ? 'Phone number is required' : null,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _gstNumberController,
                                  enabled: _isEditing,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'GST Number',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.receipt_long_outlined, color: Colors.white.withOpacityValue(0.8)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(_isEditing ? 0.1 : 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true ? 'GST number is required' : null,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                if (_isEditing)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isEditing = false;
                                              final company = ref.read(authProvider).user?.company;
                                              _companyNameController.text = company?.name ?? '';
                                              _addressController.text = ''; // TODO: Add to CompanyModel
                                              _phoneController.text = ''; // TODO: Add to CompanyModel
                                              _gstNumberController.text = ''; // TODO: Add to CompanyModel
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            side: BorderSide(color: Colors.white.withOpacityValue(0.5)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState?.validate() ?? false) {
                                              // TODO: Implement save company settings
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Company update coming soon!'),
                                                  backgroundColor: AppColors.warning,
                                                ),
                                              );
                                              setState(() => _isEditing = false);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Save Changes',
                                            style: GoogleFonts.poppins(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => setState(() => _isEditing = true),
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      label: Text(
                                        'Edit Company Information',
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Company Status Section
                      Text(
                        'Company Status',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacityValue(0.2),
                              Colors.white.withOpacityValue(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 48,
                              color: user?.companyApprovalStatus?.toUpperCase() == 'APPROVED' 
                                  ? AppColors.success 
                                  : AppColors.warning,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.companyApprovalStatus?.toUpperCase() ?? 'UNKNOWN',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.companyApprovalStatus?.toUpperCase() == 'APPROVED'
                                  ? 'Your company is verified and active'
                                  : user?.companyApprovalStatus?.toUpperCase() == 'PENDING'
                                      ? 'Your company registration is under review'
                                      : 'Contact support for assistance',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacityValue(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


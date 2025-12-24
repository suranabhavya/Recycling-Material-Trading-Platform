import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';
<<<<<<< Updated upstream
=======
import 'package:recycling_platform/features/hierarchy/data/models/role_template_model.dart';
import 'package:recycling_platform/features/hierarchy/data/models/org_unit_model.dart';
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
=======
  
  // Step 2: Hierarchy Mode
  String _hierarchyMode = 'SIMPLE';
  
  // Step 3a: Roles (for both SIMPLE and ADVANCED)
  final List<RoleTemplateModel> _roleTemplates = [];
  int _currentLevel = 1;
  
  // Step 3b: Org Units (for ADVANCED mode only)
  final List<OrgUnitModel> _orgUnits = [];
  
  // Total steps calculation
  int get _totalSteps {
    // Step 1: Company Info
    // Step 2: Hierarchy Mode
    // Step 3a: Roles
    // Step 3b: Org Units (ADVANCED only)
    // Step 4: Preview (ADVANCED only)
    if (_hierarchyMode == 'SIMPLE') {
      return 3; // Company Info, Hierarchy, Roles
    } else {
      return 5; // Company Info, Hierarchy, Roles, Org Units, Preview
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with default admin role
    _roleTemplates.add(RoleTemplateModel(
      name: 'Admin',
      level: 1,
      permissions: {'all': true},
      requiresApproval: false,
      description: 'Top-level administrator with full permissions',
    ));
    _currentLevel = 2;
  }
>>>>>>> Stashed changes

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

<<<<<<< Updated upstream
=======
  void _nextStep() {
    if (_currentStep == 0) {
      // Validate step 1 - Company Info
      if (_formKey.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      // Step 2 - Hierarchy Mode selected, move to roles
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      // Step 3a - Roles defined
      if (_hierarchyMode == 'SIMPLE') {
        // For SIMPLE mode, we're done - submit
        return;
      } else {
        // For ADVANCED mode, move to org units
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      // Step 3b - Org Units defined (ADVANCED only), move to preview
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 4);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = _currentStep - 1);
    }
  }

  void _submit() {
    // Validate required fields manually since form is on a different page
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company name is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company email is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_roleTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one role is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // All validations passed, submit the form
    // Flatten org units for backend if ADVANCED mode
    final orgUnitsFlattened = _hierarchyMode == 'ADVANCED' && _orgUnits.isNotEmpty
        ? OrgUnitModel.flattenForBackend(_orgUnits)
        : null;
    
    ref.read(companyProvider.notifier).createCompany(
      context,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      type: _selectedType,
      hierarchyMode: _hierarchyMode,
      roleTemplates: _roleTemplates,
      orgUnits: orgUnitsFlattened,
    );
  }

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
<<<<<<< Updated upstream
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
=======
          child: Column(
            children: [
              // Header
              Padding(
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
                    const SizedBox(height: 10),
                    Text(
                      'Register Company',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Step ${_currentStep + 1} of $_totalSteps',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacityValue(0.8),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                    const SizedBox(height: 24),
                    // Stepper Indicator
                    _buildStepper(),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(), // Company Info
                    _buildStep2(), // Hierarchy Mode
                    _buildStep3(), // Roles
                    if (_hierarchyMode == 'ADVANCED') _buildStep4(), // Org Units
                    if (_hierarchyMode == 'ADVANCED') _buildStep5(), // Preview
                  ],
                ),
              ),
              
              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: companyState.isLoading
                              ? null
                              : (_currentStep == 2 && _hierarchyMode == 'SIMPLE') || _currentStep == 4
                                  ? _submit
                                  : _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: companyState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  (_currentStep == 2 && _hierarchyMode == 'SIMPLE') || _currentStep == 4
                                      ? 'Register Company'
                                      : 'Next',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    // Build stepper based on mode - always use constraints to prevent overflow
    final stepperContent = _hierarchyMode == 'SIMPLE'
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepIndicator(0, 'Company Info', _currentStep >= 0),
              _buildStepConnector(_currentStep > 0),
              _buildStepIndicator(1, 'Hierarchy', _currentStep >= 1),
              _buildStepConnector(_currentStep > 1),
              _buildStepIndicator(2, 'Roles', _currentStep >= 2),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepIndicator(0, 'Company', _currentStep >= 0),
              _buildStepConnector(_currentStep > 0),
              _buildStepIndicator(1, 'Hierarchy', _currentStep >= 1),
              _buildStepConnector(_currentStep > 1),
              _buildStepIndicator(2, 'Roles', _currentStep >= 2),
              _buildStepConnector(_currentStep > 2),
              _buildStepIndicator(3, 'Org Units', _currentStep >= 3),
              _buildStepConnector(_currentStep > 3),
              _buildStepIndicator(4, 'Preview', _currentStep >= 4),
            ],
          );

    // Wrap in SingleChildScrollView for horizontal scrolling if needed
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: stepperContent,
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return SizedBox(
      width: 80, // Fixed width for horizontal scrolling
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacityValue(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? Icon(Icons.check, color: AppColors.darkGreen, size: 20)
                  : Text(
                      '${step + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.darkGreen : Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isActive ? Colors.white : Colors.white.withOpacityValue(0.6),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40, // Fixed width for horizontal scrolling
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacityValue(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.white.withOpacityValue(0.8),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(Icons.category, color: Colors.white.withOpacityValue(0.8)),
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacityValue(0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            dropdownColor: AppColors.darkGreen,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white.withOpacityValue(0.8),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'AUTOMOBILE',
                                child: Text(
                                  'Automobile',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'RECYCLING',
                                child: Text(
                                  'Recycling',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'MANUFACTURING',
                                child: Text(
                                  'Manufacturing',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'OTHERS',
                                child: Text(
                                  'Others',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
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
                                  : Text(
                                      'Register Company',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              ],
            ),
=======
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Company Type',
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacityValue(0.8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.category, color: Colors.white.withOpacityValue(0.8)),
                    filled: true,
                    fillColor: Colors.white.withOpacityValue(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                  dropdownColor: AppColors.darkGreen,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacityValue(0.8)),
                  items: [
                    DropdownMenuItem(value: 'AUTOMOBILE', child: Text('Automobile', style: GoogleFonts.poppins(color: Colors.white))),
                    DropdownMenuItem(value: 'RECYCLING', child: Text('Recycling', style: GoogleFonts.poppins(color: Colors.white))),
                    DropdownMenuItem(value: 'MANUFACTURING', child: Text('Manufacturing', style: GoogleFonts.poppins(color: Colors.white))),
                    DropdownMenuItem(value: 'OTHERS', child: Text('Others', style: GoogleFonts.poppins(color: Colors.white))),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hierarchy Configuration',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how your company hierarchy will be structured',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacityValue(0.8),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use column layout for smaller screens
                  if (constraints.maxWidth < 400) {
                    return Column(
                      children: [
                        _buildModeOption('SIMPLE', 'Simple', 'Role-based hierarchy with manager relationships'),
                        const SizedBox(height: 12),
                        _buildModeOption('ADVANCED', 'Advanced', 'Full organizational tree with units'),
                      ],
                    );
                  }
                  // Use row layout for larger screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildModeOption('SIMPLE', 'Simple', 'Role-based hierarchy with manager relationships'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModeOption('ADVANCED', 'Advanced', 'Full organizational tree with units'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacityValue(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacityValue(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white.withOpacityValue(0.8), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _hierarchyMode == 'SIMPLE'
                            ? 'Simple mode uses role levels and direct manager relationships. Perfect for smaller organizations.'
                            : 'Advanced mode includes organizational units for geographic or departmental structure. Best for larger companies.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacityValue(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(String value, String title, String subtitle) {
    final isSelected = _hierarchyMode == value;
    return GestureDetector(
      onTap: () => setState(() => _hierarchyMode = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacityValue(0.2)
              : Colors.white.withOpacityValue(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacityValue(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withOpacityValue(0.5),
                      width: 2,
                    ),
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: AppColors.darkGreen)
                      : null,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacityValue(0.7),
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Define Roles & Approval Flow',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level 1 is the highest authority. Lower levels may require approval from higher levels.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacityValue(0.8),
                ),
              ),
              const SizedBox(height: 24),
              ..._roleTemplates.asMap().entries.map((entry) {
                final index = entry.key;
                final role = entry.value;
                return _RoleCard(
                  role: role,
                  isAdmin: index == 0,
                  onUpdate: (updated) {
                    setState(() {
                      _roleTemplates[index] = updated;
                    });
                  },
                  onRemove: () {
                    if (index != 0) {
                      setState(() {
                        _roleTemplates.removeAt(index);
                        _reorderLevels();
                      });
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _roleTemplates.add(RoleTemplateModel(
                      name: 'Role $_currentLevel',
                      level: _currentLevel,
                      permissions: {},
                      requiresApproval: true,
                    ));
                    _currentLevel++;
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Role Level',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
>>>>>>> Stashed changes
          ),
        ),
      ),
    );
  }
<<<<<<< Updated upstream
=======

  void _reorderLevels() {
    for (int i = 0; i < _roleTemplates.length; i++) {
      _roleTemplates[i] = _roleTemplates[i].copyWith(level: i + 1);
    }
    _currentLevel = _roleTemplates.length + 1;
  }

  // Step 4: Build Organizational Structure (ADVANCED mode only)
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organizational Structure',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your organizational units like regions, branches, or departments',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacityValue(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacityValue(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacityValue(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Organizational units help you structure your company by location or department. Users will be assigned to these units later.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacityValue(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Root unit (Company HQ)
              if (_orgUnits.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacityValue(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacityValue(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.business, color: Colors.white.withOpacityValue(0.6), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No organizational units yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacityValue(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by adding your first unit below',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacityValue(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Display org units
                ..._orgUnits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final unit = entry.value;
                  return _OrgUnitCard(
                    unit: unit,
                    depth: 0,
                    onUpdate: (updated) {
                      setState(() {
                        _orgUnits[index] = updated;
                      });
                    },
                    onRemove: () {
                      setState(() {
                        _orgUnits.removeAt(index);
                      });
                    },
                    onAddChild: (child) {
                      setState(() {
                        _orgUnits[index] = _orgUnits[index].copyWith(
                          children: [..._orgUnits[index].children, child],
                        );
                      });
                    },
                  );
                }),
              ],
              
              const SizedBox(height: 16),
              
              // Add root level unit
              OutlinedButton.icon(
                onPressed: () {
                  _showAddUnitDialog(null);
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  _orgUnits.isEmpty ? 'Add First Unit' : 'Add Another Top-Level Unit',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Skip option
              TextButton.icon(
                onPressed: () {
                  // Skip to preview
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep = 4);
                },
                icon: Icon(Icons.skip_next, color: Colors.white.withOpacityValue(0.8)),
                label: Text(
                  'Skip for now - Add org units later',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacityValue(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUnitDialog(String? parentTempId) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          parentTempId == null ? 'Add Organizational Unit' : 'Add Sub-Unit',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Unit Name',
                hintText: 'e.g., North Region, Delhi Branch',
                hintStyle: TextStyle(color: Colors.white.withOpacityValue(0.5)),
                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                prefixIcon: Icon(Icons.location_city, color: Colors.white.withOpacityValue(0.8)),
                filled: true,
                fillColor: Colors.white.withOpacityValue(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g., New Delhi, Mumbai',
                hintStyle: TextStyle(color: Colors.white.withOpacityValue(0.5)),
                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                prefixIcon: Icon(Icons.location_on, color: Colors.white.withOpacityValue(0.8)),
                filled: true,
                fillColor: Colors.white.withOpacityValue(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacityValue(0.8))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a unit name')),
                );
                return;
              }
              
              final newUnit = OrgUnitModel(
                name: nameController.text.trim(),
                parentId: parentTempId,
                metadata: locationController.text.trim().isNotEmpty
                    ? {'location': locationController.text.trim()}
                    : null,
              );
              
              setState(() {
                if (parentTempId == null) {
                  _orgUnits.add(newUnit);
                } else {
                  // Add as child to parent - handled by _OrgUnitCard
                }
              });
              
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkGreen,
            ),
            child: Text('Add Unit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Step 5: Preview & Confirm (ADVANCED mode only)
  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review & Confirm',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review your company setup before registering',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacityValue(0.8),
                ),
              ),
              const SizedBox(height: 32),
              
              // Company Info Section
              _PreviewSection(
                icon: Icons.business,
                title: 'Company Information',
                children: [
                  _PreviewItem(label: 'Name', value: _nameController.text),
                  _PreviewItem(label: 'Email', value: _emailController.text),
                  if (_phoneController.text.isNotEmpty)
                    _PreviewItem(label: 'Phone', value: _phoneController.text),
                  if (_addressController.text.isNotEmpty)
                    _PreviewItem(label: 'Address', value: _addressController.text),
                  _PreviewItem(label: 'Type', value: _selectedType),
                  _PreviewItem(label: 'Hierarchy Mode', value: _hierarchyMode),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Roles Section
              _PreviewSection(
                icon: Icons.badge,
                title: 'Roles Defined',
                children: [
                  ..._roleTemplates.map((role) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacityValue(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: role.level == 1 
                                  ? Colors.amber.withOpacityValue(0.3)
                                  : Colors.blue.withOpacityValue(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${role.level}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (role.description != null)
                                  Text(
                                    role.description!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white.withOpacityValue(0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (role.requiresApproval)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacityValue(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Needs Approval',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Org Structure Section
              if (_orgUnits.isNotEmpty)
                _PreviewSection(
                  icon: Icons.account_tree,
                  title: 'Organization Structure',
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacityValue(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._orgUnits.map((unit) => _buildPreviewOrgUnit(unit, 0)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacityValue(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacityValue(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade300),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No organizational units created. You can add them later from settings.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacityValue(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Your assignment
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacityValue(0.3),
                      Colors.green.withOpacityValue(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacityValue(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will be assigned as ${_roleTemplates.isNotEmpty ? _roleTemplates.first.name : "Admin"} of ${_nameController.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewOrgUnit(OrgUnitModel unit, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                depth == 0 ? '🏢' : (depth == 1 ? '📍' : '🏭'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  unit.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: depth == 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (unit.metadata?['location'] != null)
                Text(
                  unit.metadata!['location'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacityValue(0.6),
                  ),
                ),
            ],
          ),
          ...unit.children.map((child) => _buildPreviewOrgUnit(child, depth + 1)),
        ],
      ),
    );
  }
}

// Helper widgets for preview
class _PreviewSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _PreviewSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacityValue(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Org Unit Card Widget
class _OrgUnitCard extends StatefulWidget {
  final OrgUnitModel unit;
  final int depth;
  final Function(OrgUnitModel) onUpdate;
  final VoidCallback onRemove;
  final Function(OrgUnitModel) onAddChild;

  const _OrgUnitCard({
    required this.unit,
    required this.depth,
    required this.onUpdate,
    required this.onRemove,
    required this.onAddChild,
  });

  @override
  State<_OrgUnitCard> createState() => _OrgUnitCardState();
}

class _OrgUnitCardState extends State<_OrgUnitCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.unit.isExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onUpdate(widget.unit.copyWith(isExpanded: _isExpanded));
  }

  void _showAddChildDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Sub-Unit under ${widget.unit.name}',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Unit Name',
                hintText: 'e.g., Delhi Branch',
                hintStyle: TextStyle(color: Colors.white.withOpacityValue(0.5)),
                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                filled: true,
                fillColor: Colors.white.withOpacityValue(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g., New Delhi',
                hintStyle: TextStyle(color: Colors.white.withOpacityValue(0.5)),
                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                filled: true,
                fillColor: Colors.white.withOpacityValue(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacityValue(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacityValue(0.8))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a unit name')),
                );
                return;
              }
              
              final newUnit = OrgUnitModel(
                name: nameController.text.trim(),
                parentId: widget.unit.tempId,
                metadata: locationController.text.trim().isNotEmpty
                    ? {'location': locationController.text.trim()}
                    : null,
              );
              
              widget.onAddChild(newUnit);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkGreen,
            ),
            child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _updateChildAt(int index, OrgUnitModel updatedChild) {
    final updatedChildren = List<OrgUnitModel>.from(widget.unit.children);
    updatedChildren[index] = updatedChild;
    widget.onUpdate(widget.unit.copyWith(children: updatedChildren));
  }

  void _removeChildAt(int index) {
    final updatedChildren = List<OrgUnitModel>.from(widget.unit.children);
    updatedChildren.removeAt(index);
    widget.onUpdate(widget.unit.copyWith(children: updatedChildren));
  }

  void _addChildToChild(int childIndex, OrgUnitModel newGrandchild) {
    final updatedChildren = List<OrgUnitModel>.from(widget.unit.children);
    updatedChildren[childIndex] = updatedChildren[childIndex].copyWith(
      children: [...updatedChildren[childIndex].children, newGrandchild],
    );
    widget.onUpdate(widget.unit.copyWith(children: updatedChildren));
  }

  @override
  Widget build(BuildContext context) {
    final indent = widget.depth * 16.0;
    
    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacityValue(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacityValue(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit header
            InkWell(
              onTap: widget.unit.hasChildren ? _toggleExpanded : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      widget.depth == 0 ? '🏢' : (widget.depth == 1 ? '📍' : '🏭'),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.unit.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.unit.metadata?['location'] != null)
                            Text(
                              widget.unit.metadata!['location'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacityValue(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.unit.hasChildren)
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                        onPressed: _toggleExpanded,
                      ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      onPressed: _showAddChildDialog,
                      tooltip: 'Add sub-unit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: widget.onRemove,
                      tooltip: 'Remove unit',
                    ),
                  ],
                ),
              ),
            ),
            
            // Children (when expanded)
            if (_isExpanded && widget.unit.hasChildren)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: widget.unit.children.asMap().entries.map((entry) {
                    final index = entry.key;
                    final child = entry.value;
                    return _OrgUnitCard(
                      unit: child,
                      depth: widget.depth + 1,
                      onUpdate: (updated) => _updateChildAt(index, updated),
                      onRemove: () => _removeChildAt(index),
                      onAddChild: (newChild) => _addChildToChild(index, newChild),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
>>>>>>> Stashed changes
}


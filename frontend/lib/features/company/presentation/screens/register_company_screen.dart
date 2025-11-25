import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';
import 'package:recycling_platform/features/hierarchy/data/models/role_template_model.dart';

class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  ConsumerState<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends ConsumerState<RegisterCompanyScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1: Company Basic Info
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'AUTOMOBILE';
  
  // Step 2: Hierarchy Mode
  String _hierarchyMode = 'SIMPLE';
  
  // Step 3: Roles
  final List<RoleTemplateModel> _roleTemplates = [];
  int _currentLevel = 1;

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

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate step 1
      if (_formKey.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      // Move to step 3
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 2);
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
    ref.read(companyProvider.notifier).createCompany(
      context,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      type: _selectedType,
      hierarchyMode: _hierarchyMode,
      roleTemplates: _roleTemplates,
    );
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
                      'Step ${_currentStep + 1} of 3',
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
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
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
                              : _currentStep == 2
                                  ? _submit
                                  : _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: companyState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _currentStep == 2 ? 'Register Company' : 'Next',
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
    return Row(
      children: [
        _buildStepIndicator(0, 'Company Info', _currentStep >= 0),
        _buildStepConnector(_currentStep > 0),
        _buildStepIndicator(1, 'Hierarchy', _currentStep >= 1),
        _buildStepConnector(_currentStep > 1),
        _buildStepIndicator(2, 'Roles', _currentStep >= 2),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Information',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your company\'s basic details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacityValue(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                    prefixIcon: Icon(Icons.business, color: Colors.white.withOpacityValue(0.8)),
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildModeOption('SIMPLE', 'Simple', 'Role-based hierarchy with manager relationships'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModeOption('ADVANCED', 'Advanced', 'Full organizational tree with units'),
                  ),
                ],
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
        padding: const EdgeInsets.all(20),
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
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withOpacityValue(0.5),
                      width: 2,
                    ),
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: AppColors.darkGreen)
                      : null,
                ),
                const SizedBox(width: 12),
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
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacityValue(0.7),
              ),
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
          ),
        ),
      ),
    );
  }

  void _reorderLevels() {
    for (int i = 0; i < _roleTemplates.length; i++) {
      _roleTemplates[i] = _roleTemplates[i].copyWith(level: i + 1);
    }
    _currentLevel = _roleTemplates.length + 1;
  }
}

class _RoleCard extends StatefulWidget {
  final RoleTemplateModel role;
  final bool isAdmin;
  final Function(RoleTemplateModel) onUpdate;
  final VoidCallback onRemove;

  const _RoleCard({
    required this.role,
    required this.isAdmin,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _requiresApproval;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role.name);
    _descriptionController = TextEditingController(text: widget.role.description ?? '');
    _requiresApproval = widget.role.requiresApproval;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateRole() {
    widget.onUpdate(widget.role.copyWith(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      requiresApproval: _requiresApproval,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacityValue(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacityValue(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isAdmin
                      ? Colors.amber.withOpacityValue(0.3)
                      : Colors.blue.withOpacityValue(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level ${widget.role.level}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (!widget.isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            enabled: !widget.isAdmin,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Role Name',
              labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacityValue(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacityValue(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacityValue(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacityValue(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (_) => _updateRole(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            style: GoogleFonts.poppins(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacityValue(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacityValue(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacityValue(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacityValue(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (_) => _updateRole(),
          ),
          if (!widget.isAdmin) ...[
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(
                'Requires Approval',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Materials created by this role need approval from higher levels',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacityValue(0.7),
                ),
              ),
              value: _requiresApproval,
              onChanged: (value) {
                setState(() {
                  _requiresApproval = value ?? false;
                });
                _updateRole();
              },
              activeColor: Colors.green,
              checkColor: Colors.white,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

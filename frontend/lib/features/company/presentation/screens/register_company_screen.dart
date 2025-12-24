import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/router/app_router.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  ConsumerState<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends ConsumerState<RegisterCompanyScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: User Information
  final _step1FormKey = GlobalKey<FormState>();
  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userPasswordController = TextEditingController();
  bool _obscurePassword = true;

  // Step 2: Company Information
  final _step2FormKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyAddressController = TextEditingController();

  // Step 3: Business Industry
  String? _selectedIndustry;
  String? _selectedSubtype;

  final Map<String, List<String>> industries = {
    'Construction': ['General Contractor', 'Electrical', 'Plumbing', 'HVAC', 'Carpentry'],
    'Healthcare': ['Hospital', 'Clinic', 'Dental', 'Home Care', 'Medical Services'],
    'Food & Beverage': ['Restaurant', 'Catering', 'Food Truck', 'Bakery', 'Bar'],
    'Retail': ['Clothing Store', 'Electronics', 'Grocery', 'Furniture', 'General'],
    'Cleaning': ['Commercial', 'Residential', 'Janitorial', 'Specialized'],
    'Manufacturing': ['Production', 'Assembly', 'Processing', 'Packaging'],
    'Recycling': ['Metal Recycling', 'Plastic Recycling', 'E-Waste', 'Paper Recycling', 'General Recycling'],
    'Security': ['Private Security', 'Event Security', 'Corporate Security'],
    'Accommodation': ['Hotel', 'Motel', 'B&B', 'Hostel'],
    'Transportation': ['Logistics', 'Delivery', 'Moving', 'Taxi/Ride Share'],
    'Other': ['Specify in address'],
  };

  @override
  void dispose() {
    _pageController.dispose();
    _userFirstNameController.dispose();
    _userLastNameController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _companyNameController.dispose();
    _companyEmailController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_step2FormKey.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 2);
      }
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

  Future<void> _submit() async {
    if (_selectedIndustry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a business industry'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Call the registerCompany API
    await ref.read(authProvider.notifier).registerCompany(
      firstName: _userFirstNameController.text,
      lastName: _userLastNameController.text,
      email: _userEmailController.text,
      password: _userPasswordController.text,
      companyName: _companyNameController.text,
      companyEmail: _companyEmailController.text.isEmpty ? null : _companyEmailController.text,
      companyPhone: _companyPhoneController.text.isEmpty ? null : _companyPhoneController.text,
      companyAddress: _companyAddressController.text.isEmpty ? null : _companyAddressController.text,
      industry: _selectedIndustry!,
      subtype: _selectedSubtype,
    );

    // Check for errors
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Navigate to OTP verification with the user's email
    if (mounted) {
      context.go('${AppRouter.verifyOtp}?email=${Uri.encodeComponent(_userEmailController.text)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                      onPressed: _previousStep,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () => context.go(AppRouter.welcome),
                    ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
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

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentStep == 2 ? _submit : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _currentStep == 2 ? "Let's go!" : 'Next step',
                    style: GoogleFonts.domine(
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
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'A small step for you.\nA giant step for your\nbusiness.',
              style: GoogleFonts.domine(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // First Name & Last Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _userFirstNameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                      filled: false,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _userLastNameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                      filled: false,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Business Email
            TextFormField(
              controller: _userEmailController,
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Business email',
                hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Password
            TextFormField(
              controller: _userPasswordController,
              style: const TextStyle(color: AppColors.textPrimary),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Create a password',
                hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (value!.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),

            const SizedBox(height: 8),
            Text(
              'Choose wisely',
              style: GoogleFonts.domine(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: 60),

            // Login link
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.domine(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRouter.login),
                    child: Text(
                      'Log in',
                      style: GoogleFonts.domine(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '${_userFirstNameController.text.isNotEmpty ? _userFirstNameController.text : 'Hi'}, what\'s your\ncompany name?',
              style: GoogleFonts.domine(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // Company Name
            TextFormField(
              controller: _companyNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter company name',
                hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 24),

            // Company Email (Optional)
            TextFormField(
              controller: _companyEmailController,
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Company contact email (Optional)',
                hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Company Phone (Optional)
            TextFormField(
              controller: _companyPhoneController,
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Company phone (Optional)',
                hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Company Address (Optional)
            TextFormField(
              controller: _companyAddressController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Company address (Optional)',
                hintStyle: GoogleFonts.domine(color: AppColors.textTertiary),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What is your business\nindustry?',
            style: GoogleFonts.domine(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 30),

          // Industry list
          ...industries.keys.map((industry) {
            final icon = _getIndustryIcon(industry);
            final isSelected = _selectedIndustry == industry;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndustry = industry;
                  _selectedSubtype = null; // Reset subtype when industry changes
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      industry,
                      style: GoogleFonts.domine(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getIndustryIcon(String industry) {
    switch (industry) {
      case 'Construction':
        return '🛠️';
      case 'Healthcare':
        return '❤️';
      case 'Food & Beverage':
        return '🍴';
      case 'Retail':
        return '🛍️';
      case 'Cleaning':
        return '🧹';
      case 'Manufacturing':
        return '🏭';
      case 'Recycling':
        return '♻️';
      case 'Security':
        return '🛡️';
      case 'Accommodation':
        return '🏨';
      case 'Transportation':
        return '🚛';
      default:
        return '📋';
    }
  }
}

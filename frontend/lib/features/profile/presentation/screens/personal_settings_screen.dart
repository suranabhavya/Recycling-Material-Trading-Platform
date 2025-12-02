import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class PersonalSettingsScreen extends ConsumerStatefulWidget {
  const PersonalSettingsScreen({super.key});

  @override
  ConsumerState<PersonalSettingsScreen> createState() => _PersonalSettingsScreenState();
}

class _PersonalSettingsScreenState extends ConsumerState<PersonalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
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
                    Text(
                      'Personal Settings',
                      style: GoogleFonts.domine(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                      // Profile Information Section
                      _buildSectionTitle('Profile Information')
                          ,
                      
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
                                  controller: _nameController,
                                  enabled: _isEditingProfile,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacityValue(0.8)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(_isEditingProfile ? 0.1 : 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _emailController,
                                  enabled: _isEditingProfile,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacityValue(0.8)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(_isEditingProfile ? 0.1 : 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Email is required';
                                    if (!value!.contains('@')) return 'Invalid email';
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 20),
                                
                                if (_isEditingProfile)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isEditingProfile = false;
                                              final user = ref.read(authProvider).user;
                                              _nameController.text = user?.name ?? '';
                                              _emailController.text = user?.email ?? '';
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
                                            style: GoogleFonts.domine(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState?.validate() ?? false) {
                                              // TODO: Implement save profile
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Profile update coming soon!'),
                                                  backgroundColor: AppColors.warning,
                                                ),
                                              );
                                              setState(() => _isEditingProfile = false);
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
                                            style: GoogleFonts.domine(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => setState(() => _isEditingProfile = true),
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      label: Text(
                                        'Edit Profile',
                                        style: GoogleFonts.domine(color: Colors.white),
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
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Change Password Section
                      _buildSectionTitle('Change Password')
                          ,
                      
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
                          child: Column(
                            children: [
                              if (_isChangingPassword) ...[
                                TextFormField(
                                  controller: _currentPasswordController,
                                  obscureText: _obscureCurrentPassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Current Password',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacityValue(0.8)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.white.withOpacityValue(0.8),
                                      ),
                                      onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacityValue(0.8)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.white.withOpacityValue(0.8),
                                      ),
                                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Confirm New Password',
                                    labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacityValue(0.8)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.white.withOpacityValue(0.8),
                                      ),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacityValue(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isChangingPassword = false;
                                            _currentPasswordController.clear();
                                            _newPasswordController.clear();
                                            _confirmPasswordController.clear();
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
                                          style: GoogleFonts.domine(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_newPasswordController.text != _confirmPasswordController.text) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Passwords do not match'),
                                                backgroundColor: AppColors.error,
                                              ),
                                            );
                                            return;
                                          }
                                          // TODO: Implement change password
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Change password coming soon!'),
                                              backgroundColor: AppColors.warning,
                                            ),
                                          );
                                          setState(() => _isChangingPassword = false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Change Password',
                                          style: GoogleFonts.domine(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => setState(() => _isChangingPassword = true),
                                    icon: const Icon(Icons.vpn_key, color: Colors.white),
                                    label: Text(
                                      'Change Password',
                                      style: GoogleFonts.domine(color: Colors.white),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.domine(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}


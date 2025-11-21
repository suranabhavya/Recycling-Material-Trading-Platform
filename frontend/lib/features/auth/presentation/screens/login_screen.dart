import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/router/app_router.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
      if (next.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome ${next.user!.name}!'), backgroundColor: AppColors.success),
        );
        context.go(AppRouter.home);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacityValue(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacityValue(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.recycling, size: 80, color: Colors.white),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 400.ms),
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    'Sign in to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacityValue(0.8),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms),
                  
                  const SizedBox(height: 50),
                  
                  GlassmorphicContainer(
                    width: double.infinity,
                    height: 350,
                    borderRadius: 24,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacityValue(0.2),
                        Colors.white.withOpacityValue(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacityValue(0.5),
                        Colors.white.withOpacityValue(0.2),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacityValue(0.8)),
                                filled: true,
                                fillColor: Colors.white.withOpacityValue(0.1),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Email required';
                                if (!value!.contains('@')) return 'Invalid email';
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 400.ms)
                                .slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 20),
                            
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.white.withOpacityValue(0.8)),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacityValue(0.8)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.white.withOpacityValue(0.8),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacityValue(0.1),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Password required';
                                if (value!.length < 6) return 'Min 6 characters';
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 500.ms)
                                .slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 12),
                            
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.go(AppRouter.forgotPassword),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 600.ms),
                            
                            const SizedBox(height: 20),
                            
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
                                onPressed: authState.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 700.ms)
                                .slideY(begin: 0.3, end: 0)
                                .shimmer(duration: 2000.ms, delay: 1000.ms),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(color: Colors.white.withOpacityValue(0.8)),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRouter.register),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

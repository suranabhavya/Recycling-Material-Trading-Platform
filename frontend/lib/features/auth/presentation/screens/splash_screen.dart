import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/router/app_router.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go(AppRouter.login);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacityValue(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacityValue(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling,
                  size: 100,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
                  .then()
                  .shimmer(duration: 1500.ms, color: Colors.white.withOpacityValue(0.5)),
              
              const SizedBox(height: 40),
              
              Text(
                'Gravita',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 300.ms)
                  .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 10),
              
              Text(
                'Recycling Platform',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacityValue(0.9),
                  letterSpacing: 3,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 500.ms)
                  .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 60),
              
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacityValue(0.8)),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 600.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

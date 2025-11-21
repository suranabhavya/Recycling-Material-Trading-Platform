import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/company/data/models/company_model.dart';
import 'package:recycling_platform/features/company/presentation/providers/company_provider.dart';

class CompanySelectionScreen extends ConsumerStatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  ConsumerState<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends ConsumerState<CompanySelectionScreen> {
  CompanyModel? selectedCompany;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(companyProvider.notifier).loadCompanies());
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
                const SizedBox(height: 20),
                Text(
                  'Join a Company',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 10),
                
                Text(
                  'Select your company from the list',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Company',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (companyState.isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        else if (companyState.error != null)
                          Text(
                            companyState.error!,
                            style: GoogleFonts.poppins(color: Colors.red),
                          )
                        else
                          DropdownButtonFormField<CompanyModel>(
                            value: selectedCompany,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacityValue(0.1),
                              hintText: 'Choose a company',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white.withOpacityValue(0.6),
                                fontSize: 14,
                              ),
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
                            items: companyState.companies.map((company) {
                              return DropdownMenuItem(
                                value: company,
                                child: Text(
                                  '${company.name} (${company.type})',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCompany = value;
                              });
                            },
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
                            onPressed: selectedCompany == null || companyState.isLoading
                                ? null
                                : () => ref.read(companyProvider.notifier).joinCompany(context, selectedCompany!.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Join Company',
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
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 60),
                
                Column(
                  children: [
                    Text(
                      "Can't find your company?",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Center(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacityValue(0.3),
                              Colors.white.withOpacityValue(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacityValue(0.5),
                            width: 2,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.go('/register-company'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_business_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Register Company",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


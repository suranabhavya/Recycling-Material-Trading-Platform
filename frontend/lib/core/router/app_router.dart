import 'package:go_router/go_router.dart';
import 'package:recycling_platform/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:recycling_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:recycling_platform/features/auth/presentation/screens/register_screen.dart';
import 'package:recycling_platform/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:recycling_platform/features/auth/presentation/screens/splash_screen.dart';
import 'package:recycling_platform/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/company_selection_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/company_empty_state_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/request_access_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/company_success_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/manage_approvals_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/pending_approval_screen.dart';
import 'package:recycling_platform/features/company/presentation/screens/register_company_screen.dart';
import 'package:recycling_platform/features/home/presentation/screens/home_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/company_settings_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/help_support_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/notification_settings_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/personal_settings_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/privacy_settings_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/team_management_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/team_member_detail_screen.dart';
import 'package:recycling_platform/features/profile/presentation/screens/hierarchy_management_screen.dart';
import 'package:recycling_platform/features/lead/presentation/screens/lead_dashboard_screen.dart';
import 'package:recycling_platform/features/batch/presentation/screens/create_batch_screen.dart';
import 'package:recycling_platform/features/batch/presentation/screens/admin_batch_approval_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String companySelection = '/company-selection';
  static const String companyEmptyState = '/company-empty-state';
  static const String requestAccess = '/request-access';
  static const String companySuccess = '/company-success';
  static const String registerCompany = '/register-company';
  static const String pendingApproval = '/pending-approval';
  static const String manageApprovals = '/manage-approvals';
  static const String home = '/home';
  static const String personalSettings = '/personal-settings';
  static const String companySettings = '/company-settings';
  static const String teamManagement = '/team-management';
  static const String hierarchyManagement = '/hierarchy-management';
  static const String leadDashboard = '/lead-dashboard';
  static const String createBatch = '/create-batch';
  static const String adminBatchApproval = '/admin-batch-approval';
  static const String teamMemberDetail = '/team-member-detail';
  static const String notificationSettings = '/notification-settings';
  static const String privacySettings = '/privacy-settings';
  static const String helpSupport = '/help-support';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: verifyOtp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: companySelection,
        builder: (context, state) => const CompanySelectionScreen(),
      ),
      GoRoute(
        path: companyEmptyState,
        builder: (context, state) => const CompanyEmptyStateScreen(),
      ),
      GoRoute(
        path: requestAccess,
        builder: (context, state) => const RequestAccessScreen(),
      ),
      GoRoute(
        path: companySuccess,
        builder: (context, state) {
          final companyName = state.uri.queryParameters['name'] ?? 'Your Company';
          return CompanySuccessScreen(companyName: companyName);
        },
      ),
      GoRoute(
        path: registerCompany,
        builder: (context, state) => const RegisterCompanyScreen(),
      ),
      GoRoute(
        path: pendingApproval,
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: manageApprovals,
        builder: (context, state) => const ManageApprovalsScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: personalSettings,
        builder: (context, state) => const PersonalSettingsScreen(),
      ),
      GoRoute(
        path: companySettings,
        builder: (context, state) => const CompanySettingsScreen(),
      ),
      GoRoute(
        path: teamManagement,
        builder: (context, state) => const TeamManagementScreen(),
      ),
      GoRoute(
        path: hierarchyManagement,
        builder: (context, state) => const HierarchyManagementScreen(),
      ),
      GoRoute(
        path: leadDashboard,
        builder: (context, state) => const LeadDashboardScreen(),
      ),
      GoRoute(
        path: createBatch,
        builder: (context, state) => const CreateBatchScreen(),
      ),
      GoRoute(
        path: adminBatchApproval,
        builder: (context, state) => const AdminBatchApprovalScreen(),
      ),
      GoRoute(
        path: teamMemberDetail,
        builder: (context, state) {
          final member = state.extra as Map<String, dynamic>;
          return TeamMemberDetailScreen(
            memberId: member['id'] as String,
            memberName: member['name'] as String,
            memberEmail: member['email'] as String,
            memberRole: member['role'] as String? ?? 'MEMBER',
            createdAt: member['createdAt'] as String?,
          );
        },
      ),
      GoRoute(
        path: notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: privacySettings,
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
    ],
  );
}

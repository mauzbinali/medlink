import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_management_screen.dart';
import '../../features/appointments/presentation/screens/appointment_booking_screen.dart';
import '../../features/appointments/presentation/screens/appointment_chat_screen.dart';
import '../../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../../features/appointments/presentation/screens/my_appointments_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/doctor/presentation/screens/doctor_availability_screen.dart';
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/doctor_earnings_screen.dart';
import '../../features/doctor/presentation/screens/doctor_patient_detail_screen.dart';
import '../../features/doctor/presentation/screens/doctor_profile_screen.dart';
import '../../features/doctor/presentation/screens/prescription_editor_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/patient/presentation/screens/doctor_detail_screen.dart';
import '../../features/patient/presentation/screens/doctor_list_screen.dart';
import '../../features/patient/presentation/screens/emergency_help_screen.dart';
import '../../features/patient/presentation/screens/favorite_doctors_screen.dart';
import '../../features/patient/presentation/screens/health_tips_screen.dart';
import '../../features/patient/presentation/screens/health_tip_detail_screen.dart';
import '../../features/medical_records/presentation/screens/medical_records_screen.dart';
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/patient_profile_screen.dart';
import '../../features/patient/presentation/screens/specialties_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/prescriptions/presentation/screens/prescriptions_screen.dart';
import '../../features/telemedicine/presentation/screens/video_call_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientHome,
        builder: (context, state) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.specialties,
        builder: (context, state) => const SpecialtiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctors,
        builder: (context, state) => const DoctorListScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorDetails,
        builder: (context, state) {
          return DoctorDetailScreen(
            doctorId: state.pathParameters['doctorId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookAppointment,
        builder: (context, state) {
          return AppointmentBookingScreen(
            doctorId: state.pathParameters['doctorId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.appointments,
        builder: (context, state) => const MyAppointmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.appointmentDetails,
        builder: (context, state) {
          return AppointmentDetailScreen(
            appointmentId: state.pathParameters['appointmentId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.appointmentChat,
        builder: (context, state) {
          return AppointmentChatScreen(
            appointmentId: state.pathParameters['appointmentId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.favoriteDoctors,
        builder: (context, state) => const FavoriteDoctorsScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientProfile,
        builder: (context, state) => const PatientProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientPayments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.prescriptions,
        builder: (context, state) => const PrescriptionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.medicalRecords,
        builder: (context, state) => const MedicalRecordsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyHelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthTips,
        builder: (context, state) => const HealthTipsScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthTipDetails,
        builder: (context, state) {
          return HealthTipDetailScreen(tipId: state.pathParameters['tipId']!);
        },
      ),
      GoRoute(
        path: AppRoutes.videoCall,
        builder: (context, state) {
          return VideoCallScreen(
            appointmentId: state.pathParameters['appointmentId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.doctorDashboard,
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorPatientDetails,
        builder: (context, state) {
          return DoctorPatientDetailScreen(
            appointmentId: state.pathParameters['appointmentId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.doctorAvailability,
        builder: (context, state) => const DoctorAvailabilityScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorEarnings,
        builder: (context, state) => const DoctorEarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorProfile,
        builder: (context, state) => const DoctorProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.prescriptionEditor,
        builder: (context, state) {
          return PrescriptionEditorScreen(
            appointmentId: state.pathParameters['appointmentId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminManagementScreen(type: 'users'),
      ),
      GoRoute(
        path: AppRoutes.adminDoctors,
        builder: (context, state) =>
            const AdminManagementScreen(type: 'doctors'),
      ),
      GoRoute(
        path: AppRoutes.adminAppointments,
        builder: (context, state) =>
            const AdminManagementScreen(type: 'appointments'),
      ),
      GoRoute(
        path: AppRoutes.adminPayments,
        builder: (context, state) =>
            const AdminManagementScreen(type: 'payments'),
      ),
      GoRoute(
        path: AppRoutes.adminHealthTips,
        builder: (context, state) =>
            const AdminManagementScreen(type: 'health_tips'),
      ),
    ],
  );
});

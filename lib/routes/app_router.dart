// lib/routes/app_router.dart
import 'package:go_router/go_router.dart';
import '../widgets/main_layout.dart';
import '../screens/home_screen.dart';
import '../screens/event_screen.dart';
import '../screens/about_screen.dart';
import '../screens/members_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/code_of_conduct_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen()),
        GoRoute(
            path: '/gallery',
            builder: (context, state) => const GalleryScreen()),
        GoRoute(
            path: '/members',
            builder: (context, state) => const MembersScreen()),
        GoRoute(
            path: '/about', builder: (context, state) => const AboutScreen()),
        GoRoute(
            path: '/contact',
            builder: (context, state) => const ContactScreen()),
        GoRoute(
            path: '/code-of-conduct',
            builder: (context, state) => const CodeOfConductScreen()),
        GoRoute(
            path: '/admin/login',
            builder: (context, state) => const AdminLoginScreen()),
      ],
    ),
    GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen()),
  ],
  redirect: (context, state) {
    if (state.location == '/home') {
      return '/';
    }
    return null;
  },
);

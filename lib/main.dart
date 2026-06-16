import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import './Screens/auth/empty_screen.dart';
import './providers/auth.dart';
import './providers/tesing/products.dart';
import './services/push_notifications_service.dart';
import './services/supabase_service.dart';
import './theme/app_theme.dart';
import './Screens/app_sections.dart';
import './Screens/auth/login_screen.dart';
import './Screens/auth/password_reset_screen.dart';
import './Screens/auth/registration_screen.dart';
import './Screens/intro/splash/splash.dart';
import './Screens/home_screen.dart';
import './Screens/role_apps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();
  await PushNotificationsService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Products())
      ],
      child: MaterialApp(
        title: 'شور',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        theme: AppTheme.build(AppTheme.brandBlue, Brightness.light),
        darkTheme: AppTheme.build(AppTheme.brandBlue, Brightness.dark),
        themeMode: ThemeMode.system,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const Splash(),
        routes: {
          '/register': (context) => const RegistrationScreen(),
          '/login': (context) => const LoginScreen(),
          '/reset-password': (context) => const PasswordResetScreen(),
          '/admin': (context) => const AdminAppScreen(),
          '/consultant-app': (context) => const ConsultantAppScreen(),
          '/empty': (context) => const EmptyScreen(),
          '/home': (context) => const _AuthRequired(child: HomeScreen()),
          '/animals': (context) => const _AuthRequired(
                child: AnimalsScreen(showBottomNav: true),
              ),
          '/cars': (context) => const _AuthRequired(
                child: CarsScreen(showBottomNav: true),
              ),
          '/cars-booking': (context) =>
              const _AuthRequired(child: CarsBookingScreen()),
          '/consultants': (context) => const _AuthRequired(
                child: ConsultantsScreen(showBottomNav: true),
              ),
          '/orders': (context) => const _AuthRequired(
                child: OrdersScreen(showBottomNav: true),
              ),
          '/new-order': (context) =>
              const _AuthRequired(child: NewOrderScreen()),
          '/record-detail': (context) =>
              const _AuthRequired(child: RecordDetailScreen()),
          '/profile': (context) => const _AuthRequired(
                child: UserProfileScreen(
                  showSettings: true,
                  showBottomNav: true,
                ),
              ),
          '/settings': (context) =>
              const _AuthRequired(child: SettingsScreen()),
        },
      ),
    );
  }
}

class _AuthRequired extends StatelessWidget {
  const _AuthRequired({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<Auth>();
    if (auth.login_status) return child;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

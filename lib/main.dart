import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Import core services
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'core/services/biometric_service.dart';
import 'core/services/device_service.dart';
import 'core/utils/date_formatter.dart';

// Import data sources
import 'data/data_sources/remote/auth_remote_datasource.dart';
import 'data/data_sources/local/auth_local_datasource.dart';

// Import repositories
import 'data/repositories/auth_repository.dart';

// Import view models
import 'presentation/view_models/auth_view_model.dart';

// Import screens
import 'presentation/views/auth/login_screen.dart';
import 'presentation/views/auth/register_screen.dart';
import 'presentation/views/home/home_screen.dart';

/// Main Entry Point
/// Setup semua services dan initialize app
void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatter dengan locale Indonesia
  await DateFormatter.initialize();

  // Initialize SharedPreferences untuk StorageService
  final prefs = await SharedPreferences.getInstance();

  // Initialize StorageService
  final storageService = StorageService(prefs: prefs);

  // Initialize ApiService dengan StorageService
  final apiService = ApiService(storageService: storageService);

  // Initialize BiometricService
  final biometricService = BiometricService();

  // Initialize DeviceService
  final deviceService = DeviceService(storageService: storageService);

  // Setup Data Sources
  final authRemoteDataSource = AuthRemoteDataSource(
    apiService: apiService,
    deviceService: deviceService,
  );
  final authLocalDataSource = AuthLocalDataSource(
    storageService: storageService,
  );

  // Setup Repositories
  final authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  // Run app dengan Provider
  runApp(
    MultiProvider(
      providers: [
        // ViewModels
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            repository: authRepository,
            biometricService: biometricService,
          )..initialize(), // Initialize saat app start
        ),
        // Add more ViewModels here
      ],
      child: const MyApp(),
    ),
  );
}

/// Root Widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tax Retribution App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Initial route
      initialRoute: '/',
      // Routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

/// Splash Screen
/// Check authentication status dan navigate ke screen yang sesuai
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check auth status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      
      // Delay untuk show splash
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          if (authViewModel.isAuthenticated) {
            // Sudah login, ke home
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // Belum login, ke login screen
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Tax Retribution',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Welcome Screen (Alternative - jika mau pakai welcome screen)
/// Tidak dipakai karena kita pakai SplashScreen
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau Icon
            Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 32),
            
            // App Name
            Text(
              'Tax Retribution',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            const Text(
              'Kelola laporan pajak Anda dengan mudah',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 64),
            
            // Login Button
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Login Screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login screen belum diimplementasi'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // Register Button
            TextButton(
              onPressed: () {
                // TODO: Navigate to Register Screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Register screen belum diimplementasi'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Daftar Akun Baru',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

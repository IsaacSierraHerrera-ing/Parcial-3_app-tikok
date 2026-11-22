import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_screens.dart';
import 'feed_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthRefreshNotifier _authNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authNotifier = AuthRefreshNotifier();
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _authNotifier,
      redirect: (context, state) {
        final loggedIn = FirebaseAuth.instance.currentUser != null;
        final loggingIn = state.matchedLocation == '/login';
        final registering = state.matchedLocation == '/registro';

        if (!loggedIn && !loggingIn && !registering) return '/login';
        if (loggedIn && (loggingIn || registering)) return '/feed';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(
            onRegister: () => context.go('/registro'),
            onLoggedIn: () => context.go('/feed'),
          ),
        ),
        GoRoute(
          path: '/registro',
          builder: (context, state) => RegisterScreen(
            onLogin: () => context.go('/login'),
            onRegistered: () => context.go('/feed'),
          ),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) =>
              FeedScreen(onLogout: () => context.go('/login')),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'app_parcial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF17152B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4D67),
          secondary: Color(0xFF35C4F0),
          surface: Color(0xFF211E38),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x26FFFFFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      routerConfig: _router,
    );
  }
}

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

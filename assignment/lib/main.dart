import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/places_provider.dart';
import 'utils/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/places/place_list_screen.dart';
import 'screens/places/place_detail_screen.dart';
import 'screens/places/add_edit_place_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'models/place.dart';

void main() async {
  //firebase initialisation
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KigaliDirectoryApp());
}

class KigaliDirectoryApp extends StatelessWidget {
  const KigaliDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali Directory',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    final args = settings.arguments is Map
        ? settings.arguments as Map
        : <String, dynamic>{};

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/place-list':
        return MaterialPageRoute(
          builder: (_) =>
              PlaceListScreen(categoryId: args['categoryId'] as String?),
        );

      case '/place-detail':
        return MaterialPageRoute(
          builder: (_) => PlaceDetailScreen(placeId: args['placeId'] as String),
        );

      case '/add-place':
        return MaterialPageRoute(
          builder: (_) => AddEditPlaceScreen(place: args['place'] as Place?),
        );

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}

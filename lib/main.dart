import 'package:flutter/material.dart';
import 'package:flutter_reusalo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_reusalo/screens/login/login_screen_uno.dart';
import 'package:flutter_reusalo/screens/tabs/tabs_screen.dart';
import 'package:flutter_reusalo/screens/shopping_cart/cart_screen.dart'; // Importa tu pantalla del carrito

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Define las rutas de tu aplicación
      routes: {
        '/carrito': (context) => const CartScreen(), // Ruta para el carrito
        'TabsScreen': (context) => const TabsScreen(), // Ruta para TabsScreen
      },
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(), // Verifica el estado de sesión
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!) {
            return const TabsScreen(); // Si la autenticación biométrica es exitosa
          } else {
            return const LoginScreen(); // Si falla la autenticación o no hay sesión activa
          }
        },
      ),
    );
  }

  // Verifica si el usuario tiene sesión iniciada usando SharedPreferences
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    return isLoggedIn;
  }
}

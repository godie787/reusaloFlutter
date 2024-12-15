import 'package:flutter/material.dart';
import 'package:flutter_reusalo/screens/register/register_screen.dart';
import '../../services/auth_google.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  ElevatedButton(
                    onPressed: () {
                      // Navega a otra pantalla si lo necesitas
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF638B2E).withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 62),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontFamily: 'FredokaOne',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final user = await AuthUser.loginGoogle();
                        if (user == null) {
                          print('Inicio de sesión cancelado por el usuario.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Inicio de sesión cancelado.')),
                          );
                          return;
                        }
                        print('Inicio de sesión exitoso: ${user.email}');
                        Navigator.pushReplacementNamed(context, 'TabsScreen');
                      } catch (error) {
                        print('Error desconocido: ${error.toString()}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                error.toString() ?? 'Ups... algo salió mal'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2F3725).withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 62),
                    ),
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    ),
                    label: const Text(
                      'Iniciar con Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontFamily: 'FredokaOne',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No tienes una cuenta? ',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'FiraCode',
                          fontSize: 11,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                          print('Ir a Registro');
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FiraCode',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

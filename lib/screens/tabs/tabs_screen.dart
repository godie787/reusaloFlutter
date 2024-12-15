import 'package:flutter/material.dart';
import 'package:flutter_reusalo/screens/login/login_screen_uno.dart';
import 'package:flutter_reusalo/screens/shopping_cart/cart_screen.dart';
import 'package:flutter_reusalo/screens/tabs/eventos/tab_eventos_screen.dart';
import 'package:flutter_reusalo/screens/tabs/productos/tab_productos_screen.dart';
import 'package:flutter_reusalo/screens/tabs/home/tab_home_screen.dart';
import 'package:flutter_reusalo/screens/tabs/compras/tab_compras_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _Login1State();
}

class _Login1State extends State<TabsScreen> {
  int _currenIndex = 0;
  String _nombreUsuario = 'Usuario';

  final List<Map<String, dynamic>> _paginas = [
    {'pagina': TabHomeScreen(), 'texto': 'Home', 'icono': Icons.home},
    {
      'pagina': TabProductosScreen(),
      'texto': 'Productos',
      'icono': Icons.local_offer
    },
    {
      'pagina': TabEventosScreen(),
      'texto': 'Mis eventos',
      'icono': MdiIcons.calendar
    },
    {
      'pagina': TabComprasScreen(),
      'texto': 'Mis compras',
      'icono': MdiIcons.basket
    }
  ];

  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario();
  }

  void _obtenerNombreUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _nombreUsuario = user.email!.split('@')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await _mostrarDialogoConfirmacion(context);
        return shouldLogout ?? false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Ajusta la vista cuando aparece el teclado
        appBar: AppBar(
          actions: [
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              icon: Badge.count(
                count: 0,
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
                print("Carrito");
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/perfil.png'),
                        ),
                        border: Border.all(
                            width: 2.0, color: const Color(0xff638B2E)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        _nombreUsuario,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Mi Perfil'),
                leading: const Icon(Icons.person, color: Color(0xff638B2E)),
                onTap: () {
                  print("Mi Perfil");
                },
              ),
              ListTile(
                title: const Text('Salir'),
                leading:
                    const Icon(Icons.exit_to_app, color: Color(0xff638B2E)),
                onTap: () {
                  _mostrarDialogoConfirmacion(context);
                },
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: _paginas[_currenIndex]['pagina'],
              ),
            );
          },
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            selectedItemColor: const Color(0xff4C6231),
            unselectedItemColor: const Color(0xff638B2E),
            items: [
              BottomNavigationBarItem(
                icon: Icon(_paginas[0]['icono']),
                label: _paginas[0]['texto'],
                backgroundColor: const Color(0xffD9D9D9),
              ),
              BottomNavigationBarItem(
                icon: Icon(_paginas[1]['icono']),
                label: _paginas[1]['texto'],
                backgroundColor: const Color(0xffD9D9D9),
              ),
              BottomNavigationBarItem(
                icon: Icon(_paginas[2]['icono']),
                label: _paginas[2]['texto'],
                backgroundColor: const Color(0xffD9D9D9),
              ),
              BottomNavigationBarItem(
                icon: Badge.count(
                  count: 5,
                  child: Icon(_paginas[3]['icono']),
                ),
                label: _paginas[3]['texto'],
                backgroundColor: const Color(0xffD9D9D9),
              ),
            ],
            currentIndex: _currenIndex,
            onTap: (index) {
              setState(() {
                _currenIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmación', textAlign: TextAlign.center ,style: TextStyle(fontFamily: 'FredokaOne', fontWeight: FontWeight.normal)),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?', style: TextStyle(fontFamily: 'FiraCode')),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'FiraCode', fontSize: 12)),
            onPressed: () {
              Navigator.of(ctx).pop(false); // Cierra el popup sin cerrar sesión
            },
          ),
          ElevatedButton(
            child: const Text('Cerrar sesión', style: TextStyle(fontFamily: 'FiraCode', fontSize: 12)),
            onPressed: () async {
              Navigator.of(ctx).pop(true); // Cierra el popup

              // Cierra sesión en Firebase
              await FirebaseAuth.instance.signOut();

              // Limpia los datos de sesión en SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Navega de vuelta a la pantalla de login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

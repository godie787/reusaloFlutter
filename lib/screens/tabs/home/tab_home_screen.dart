import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';
import 'package:flutter_reusalo/screens/categorias/electronica_gadgets_cat_screen.dart';
import 'package:flutter_reusalo/screens/categorias/herramientas_equipos_cat_screen.dart';
import 'package:flutter_reusalo/screens/categorias/libros_cat_screen.dart';
import 'package:flutter_reusalo/screens/categorias/muebles_decoracion_cat_screen.dart';
import 'package:flutter_reusalo/screens/categorias/ropa_accesorios_cat_screen.dart';
import 'package:flutter_reusalo/screens/categorias/todos_los_productos_cart_screen.dart';
import 'package:flutter_reusalo/screens/proximos_eventos/proximos_eventos_screen.dart';
import 'package:flutter_reusalo/widgets_personalizados/home_productos_grid.dart';

class TabHomeScreen extends StatefulWidget {
  const TabHomeScreen({super.key});

  @override
  _TabHomeScreenState createState() => _TabHomeScreenState();
}

class _TabHomeScreenState extends State<TabHomeScreen> {
  List<dynamic>? listaProductos; // Inicializa la lista de productos
  final ProductosProvider productosProvider = ProductosProvider();

  @override
  void initState() {
    super.initState();
    _obtenerProductos();
  }

  Future<void> _obtenerProductos() async {
  try {
    final productos = await productosProvider.getProductos();
    setState(() {
      // Filtrar productos por estado "disponible"
      listaProductos = productos
          .where(
            (producto) => producto['estado']?.toLowerCase() == 'disponible',
          )
          .toList();

      // Ordenar por fecha de creación en orden descendente
      listaProductos!.sort((a, b) {
        final fechaA = DateTime.parse(a['created_at']);
        final fechaB = DateTime.parse(b['created_at']);
        return fechaB.compareTo(fechaA); // Orden descendente
      });
    });
  } catch (error) {
    print('Error al obtener productos: $error');
  }
}


  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Cierra el teclado
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador de productos
            const SizedBox(height: 10),
            _buildBannerSection(),
            const SizedBox(height: 20),
            _buildHorizontalCategories(context),
            const SizedBox(height: 20),
            _buildProductTitle(),
            const SizedBox(height: 0),
            if (listaProductos != null && listaProductos!.isNotEmpty)
              _buildProductCarousel(listaProductos!)
            else
              const Center(child: Text('No hay productos disponibles.'))
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(child: bannerInscribete()),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategories(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryItem(
            context,
            'Ropa y accesorios',
            'assets/images/ropa.png',
            RopaAccesoriosCatScreen(), // Pantalla correspondiente
          ),
          _buildCategoryItem(
            context,
            'Muebles y decoración',
            'assets/images/muebles.png',
            MueblesDecoracionCatScreen(),
          ),
          _buildCategoryItem(
            context,
            'Libros',
            'assets/images/libros.png',
            LibrosCatScreen(),
          ),
          _buildCategoryItem(
            context,
            'Electrónica y gadgets',
            'assets/images/electronica.png',
            ElectronicaGadgetsCatScreen(),
          ),
          _buildCategoryItem(
            context,
            'Herramientas y equipos',
            'assets/images/herramientas.png',
            HerramientasEquiposCatScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCarousel(List<dynamic> listaProductos) {
    return ProductosCarousel(listaProductos: listaProductos);
  }

  Widget _buildProductTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16), // Margen izquierdo
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Alinea los elementos a la izquierda
        children: [
          InkWell(
            onTap: () {
              // Navegar a la pantalla correspondiente al tocar el texto
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodosLosProductosCartScreen(),
                ),
              );
            },
            child: const Text(
              'Todos los Productos',
              style: TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8), // Espacio entre el texto y el ícono
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              size: 17,
              color: Colors.black,
            ),
            onPressed: () {
              // Navegar a la pantalla correspondiente al presionar el ícono
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodosLosProductosCartScreen(),
                ),
              );
            },
            padding:
                EdgeInsets.zero, // Elimina el padding interno del IconButton
            constraints:
                const BoxConstraints(), // Elimina restricciones adicionales
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    String imagePath,
    Widget destinationScreen, // Pantalla de destino como parámetro
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                destinationScreen, // Navega a la pantalla correspondiente
          ),
        );
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 60,
                width: 60,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class bannerInscribete extends StatelessWidget {
  const bannerInscribete({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/eventos.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned(
            bottom: 10,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventosScreen(),
                  ),
                );
                print("Inscribirme");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2F3725),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Próximos eventos',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'FredokaOne',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

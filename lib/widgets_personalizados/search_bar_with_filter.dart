import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/regiones_comunas_provider.dart';

class SearchBarWithFilter extends StatefulWidget {
  final Function(String searchQuery, RangeValues priceRange) onFilterChanged;

  const SearchBarWithFilter({super.key, required this.onFilterChanged});

  @override
  State<SearchBarWithFilter> createState() => _SearchBarWithFilterState();
}

class _SearchBarWithFilterState extends State<SearchBarWithFilter> {
  final TextEditingController _searchController = TextEditingController();
  final RegionesComunasProvider _provider = RegionesComunasProvider();

  String? _selectedRegion;
  String? _selectedComuna;
  List<dynamic> _comunas = [];
  bool _isLoadingComunas = false;
  RangeValues _priceRange = const RangeValues(0, 1000000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Contenedor del buscador y botón de filtros
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffD9D9D9),
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.search, color: Color(0xff638B2E)),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    widget.onFilterChanged(value, _priceRange);
                  },
                ),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey,
                indent: 8,
                endIndent: 8,
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
              ),
            ],
          ),
        ),
        // Contenedor de la barra de rango de precios
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por precio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff638B2E),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000000,
                divisions: 100,
                activeColor: const Color(0xff638B2E),
                inactiveColor: const Color(0xffD9D9D9),
                labels: RangeLabels(
                  '\$${_priceRange.start.round()}',
                  '\$${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                  widget.onFilterChanged(_searchController.text, _priceRange);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${_priceRange.start.round()} pesos'),
                  Text('\$${_priceRange.end.round()} pesos'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filtrar por ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff638B2E),
                      ),
                    ),
                    const Divider(),
                    _buildRegionDropdown(setState),
                    const SizedBox(height: 10),
                    _buildComunaDropdown(setState),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        widget.onFilterChanged(
                          _searchController.text,
                          _priceRange,
                        ); // Emitimos valores
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF08854),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRegionDropdown(StateSetter setState) {
    return FutureBuilder<List<dynamic>>(
      future: _provider.getRegiones(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _loadingIndicator();
        }

        final regiones = snapshot.data!;
        return DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Selecciona una región'),
          value: _selectedRegion,
          items: regiones.map<DropdownMenuItem<String>>((region) {
            return DropdownMenuItem<String>(
              value: region['codigo'] as String,
              child: Text(region['nombre'] as String),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRegion = value;
              _selectedComuna = null;
              _comunas = [];
              _isLoadingComunas = true;
            });
            _loadComunas(value!, setState);
          },
        );
      },
    );
  }

  Widget _buildComunaDropdown(StateSetter setState) {
    if (_isLoadingComunas) {
      return _loadingIndicator();
    }

    return DropdownButton<String>(
      isExpanded: true,
      hint: const Text('Selecciona una comuna'),
      value: _selectedComuna,
      items: _comunas.map<DropdownMenuItem<String>>((comuna) {
        return DropdownMenuItem<String>(
          value: comuna['nombre'] as String,
          child: Text(comuna['nombre'] as String),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedComuna = value;
        });
      },
    );
  }

  void _loadComunas(String regionCode, StateSetter setState) async {
    try {
      final comunas = await _provider.getComunas(regionCode);
      setState(() {
        _comunas = comunas;
        _isLoadingComunas = false;
      });
    } catch (e) {
      print('Error al cargar las comunas: $e');
      setState(() {
        _isLoadingComunas = false;
      });
    }
  }

  Widget _loadingIndicator() {
    return Center(
      child: Column(
        children: const [
          Text('Cargando...'),
        ],
      ),
    );
  }
}

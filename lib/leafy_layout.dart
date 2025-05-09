import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces externos
import 'package:leafy_app_flutter/providers/General/auth_provider.dart'; // Provider para sesión del usuario
import 'package:leafy_app_flutter/providers/Search/plant_search_provider.dart'; // Provider para buscar plantas
import 'package:leafy_app_flutter/screens/SearchScreen/plantDetailScreen.dart'; // Pantalla de detalle de planta

// Componente general que envuelve todas las pantallas de la app con header, footer y buscador opcional
class LeafyLayout extends StatefulWidget {
  final Widget child; // Contenido principal de la pantalla
  final bool showSearchBar; // Indica si debe mostrarse la barra de búsqueda

  const LeafyLayout({
    super.key,
    required this.child,
    required this.showSearchBar,
  });

  @override
  State<LeafyLayout> createState() => _LeafyLayoutState();
}

class _LeafyLayoutState extends State<LeafyLayout> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false; // Controla si hay una búsqueda activa

  // Lógica cuando el texto del buscador cambia
  void _onSearchChanged(String query) {
    Provider.of<PlantSearchProvider>(
      context,
      listen: false,
    ).searchPlants(query);
  }

  // Limpia el buscador
  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() {
      _isSearching = false;
    });
  }

  // Abre una URL externa en el navegador
  Future<void> abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(
      context,
    ); // Para verificar si hay sesión
    final plantSearchProvider = Provider.of<PlantSearchProvider>(
      context,
    ); // Para mostrar resultados de búsqueda

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4DC), // Color general de fondo
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFD7EAC8), // Color verde pastel del encabezado
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila principal del header
                Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      "Leafy",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Botones de navegación solo si el usuario está autenticado
                    if (auth.session != null) ...[
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/calendar'),
                        child: const Text("Calendario"),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/profile'),
                        child: const Text("Perfil"),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/misplantas'),
                        child: const Text("Mis Plantas"),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/search'),
                        child: const Text("Buscar Plantas"),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/profile'),
                        icon: const Icon(Icons.person),
                      ),
                    ],
                  ],
                ),

                // Barra de búsqueda (solo si se ha activado por parámetro)
                if (widget.showSearchBar)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (query) {
                          setState(() {
                            _isSearching = query.isNotEmpty;
                          });
                          _onSearchChanged(query);
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearSearch,
                          ),
                          hintText: 'Buscar plantas...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: Stack(
              children: [
                widget.child, // El contenido dinámico de cada pantalla
                // Si se está buscando y hay resultados, mostramos sugerencias
                if (_isSearching && plantSearchProvider.plants.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: plantSearchProvider.plants.length,
                          itemBuilder: (context, index) {
                            final plant = plantSearchProvider.plants[index];
                            return ListTile(
                              leading: Image.network(
                                plant.imagenPrincipal,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              title: Text(plant.nombre),
                              onTap: () {
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            PlantDetailScreen(plant: plant),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // FOOTER con enlaces a info legal y redes sociales
          Container(
            width: double.infinity,
            color: const Color(0xFFD7EAC8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Enlaces distribuidos en columnas
                Wrap(
                  spacing: 40,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    // Columna "Leafy"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Leafy",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Sobre nosotros"),
                        Text("Contacto"),
                        Text("FAQ"),
                      ],
                    ),
                    // Columna "Legal"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Legal",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              () => abrirUrl(
                                'https://drive.google.com/drive/folders/1r1TO_sg0ZQcqDnfUlZTX8QJiVS4Mf53m',
                              ),
                          child: const Text("Política de privacidad"),
                        ),
                        TextButton(
                          onPressed:
                              () => abrirUrl(
                                'https://drive.google.com/drive/folders/1r1TO_sg0ZQcqDnfUlZTX8QJiVS4Mf53m',
                              ),
                          child: const Text("Términos y condiciones"),
                        ),
                        TextButton(
                          onPressed:
                              () => abrirUrl(
                                'https://drive.google.com/drive/folders/1r1TO_sg0ZQcqDnfUlZTX8QJiVS4Mf53m',
                              ),
                          child: const Text("Licencia de uso"),
                        ),
                      ],
                    ),
                    // Columna "Síguenos"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Síguenos",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              () => abrirUrl(
                                'https://www.facebook.com/Cristiano/?locale=ca_ES',
                              ),
                          child: const Text("🌿 Instagram"),
                        ),
                        TextButton(
                          onPressed:
                              () => abrirUrl(
                                'https://www.instagram.com/leomessi/',
                              ),
                          child: const Text("📘 Facebook"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "© 2025 Leafy. Todos los derechos reservados.",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

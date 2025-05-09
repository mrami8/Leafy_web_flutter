import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout general de la app
import 'package:provider/provider.dart'; // Para usar PlantSearchProvider
import 'package:leafy_app_flutter/providers/Search/plant_search_provider.dart'; // Provider de búsqueda de plantas
import 'plantDetailScreen.dart'; // Pantalla de detalle de planta

// Pantalla para buscar entre las plantas registradas
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    // Ejecutar después del primer render para evitar errores de contexto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlantSearchProvider>(context, listen: false).searchPlants('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      showSearchBar: false, // Usamos una barra de búsqueda personalizada
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda con estilo personalizado
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: TextField(
                onChanged: (query) {
                  // Al escribir, filtra las plantas
                  Provider.of<PlantSearchProvider>(
                    context,
                    listen: false,
                  ).searchPlants(query);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Limpia la búsqueda
                      Provider.of<PlantSearchProvider>(
                        context,
                        listen: false,
                      ).searchPlants('');
                    },
                  ),
                  hintText: 'Buscar plantas',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resultados de la búsqueda
            Expanded(
              child: Consumer<PlantSearchProvider>(
                builder: (context, provider, _) {
                  if (provider.plants.isEmpty) {
                    // Si no hay resultados
                    return const Center(
                      child: Text('No se encontraron plantas.'),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Calcula el número de columnas según el ancho disponible
                      int crossAxisCount = (constraints.maxWidth ~/ 160).clamp(
                        2,
                        8,
                      );

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.90,
                        ),
                        itemCount: provider.plants.length,
                        itemBuilder: (context, index) {
                          final plant = provider.plants[index];

                          return GestureDetector(
                            onTap: () {
                              // Ir al detalle de la planta seleccionada
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PlantDetailScreen(plant: plant),
                                ),
                              );
                            },
                            child: Card(
                              color: const Color.fromARGB(
                                255,
                                243,
                                247,
                                240,
                              ), // Fondo Leafy
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Imagen de la planta
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Container(
                                      height: 100,
                                      color: const Color.fromARGB(
                                        255,
                                        236,
                                        250,
                                        233,
                                      ),
                                      child: Image.network(
                                        plant.imagenPrincipal,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Nombre común y científico
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (plant.nombre.trim().isNotEmpty)
                                          Text(
                                            plant.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        if (plant.nombreCientifico
                                            .trim()
                                            .isNotEmpty)
                                          Text(
                                            plant.nombreCientifico,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        const SizedBox(height: 2),
                                      ],
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

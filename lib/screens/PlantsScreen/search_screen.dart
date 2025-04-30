import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/leafy_layout.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Plants/plant_search_provider.dart';
import 'plantDetailScreen.dart';

/// Pantalla de búsqueda de plantas
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();

    // Al iniciar, se realiza una búsqueda vacía para mostrar todas las plantas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlantSearchProvider>(context, listen: false).searchPlants('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda de texto
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: TextField(
                // Cada vez que cambia el texto, se actualiza la búsqueda
                onChanged: (query) {
                  Provider.of<PlantSearchProvider>(context, listen: false)
                      .searchPlants(query);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search), // Icono de lupa
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close), // Botón para limpiar
                    onPressed: () {
                      Provider.of<PlantSearchProvider>(context, listen: false)
                          .searchPlants('');
                    },
                  ),
                  hintText: 'Buscar plantas', // Texto de ayuda
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contenedor de resultados de búsqueda
            Expanded(
              child: Consumer<PlantSearchProvider>(
                builder: (context, provider, _) {
                  // Si no hay resultados
                  if (provider.plants.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron plantas.'),
                    );
                  }

                  // Calcula el número de columnas en base al ancho
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount =
                          (constraints.maxWidth ~/ 160).clamp(2, 8);

                      // Muestra los resultados en una cuadrícula
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

                          // Cada tarjeta representa una planta
                          return GestureDetector(
                            onTap: () {
                              // Al tocar, navega a la pantalla de detalles
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlantDetailScreen(plant: plant),
                                ),
                              );
                            },
                            child: Card(
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
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        plant.imagenPrincipal,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Nombre común y nombre científico
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

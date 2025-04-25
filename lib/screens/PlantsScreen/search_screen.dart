import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/leafy_layout.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Plants/plant_search_provider.dart';
import 'plantDetailScreen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: TextField(
                onChanged: (query) {
                  Provider.of<PlantSearchProvider>(context, listen: false)
                      .searchPlants(query);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Provider.of<PlantSearchProvider>(context, listen: false)
                          .searchPlants('');
                    },
                  ),
                  hintText: 'Buscar plantas',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resultados
            Expanded(
              child: Consumer<PlantSearchProvider>(
                builder: (context, provider, _) {
                  if (provider.plants.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron plantas.'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: provider.plants.length,
                    itemBuilder: (context, index) {
                      final plant = provider.plants[index];
                      return GestureDetector(
                        onTap: () {
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: Image.network(
                                    plant.imagenPrincipal,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

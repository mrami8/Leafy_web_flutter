import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/plant_search_provider.dart';
import 'plantDetailScreen.dart';

// Pantalla para buscar y visualizar plantas de la base de datos
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado con título de la app
            Container(
              color: const Color(0xFFD6E8C4), // Verde pastel claro
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "LEAFY",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: TextField(
                  onChanged: (query) {
                    // Realiza búsqueda a medida que se escribe
                    Provider.of<PlantSearchProvider>(
                      context,
                      listen: false,
                    ).searchPlants(query);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        // Limpia el campo y la búsqueda
                        Provider.of<PlantSearchProvider>(
                          context,
                          listen: false,
                        ).searchPlants('');
                      },
                    ),
                    hintText: 'Buscar plantas',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Resultados de búsqueda
            Expanded(
              child: Consumer<PlantSearchProvider>(
                builder: (context, provider, _) {
                  // Si no hay resultados, muestra mensaje
                  if (provider.plants.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron plantas.'),
                    );
                  }

                  // Si hay resultados, muestra en cuadrícula
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          // Al tocar una planta, navega a la vista de detalle
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PlantDetailScreen(plant: plant),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Imagen de la planta
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

                              // Nombre común y científico
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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

import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/models/plant.dart';

// Pantalla que muestra los detalles de una planta seleccionada
class PlantDetailScreen extends StatelessWidget {
  final Plant plant; // Objeto planta recibido como argumento

  PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro
      body: SafeArea(
        child: Column(
          children: [
            // Header con menú superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: const Color(0xFFD7EAC8),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    "Leafy",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),

                  // Mostrar opciones si hay sesión
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    child: const Text("Buscar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/calendar'),
                    child: const Text("Calendario"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text("Perfil"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/misplantas'),
                    child: const Text("Mis Plantas"),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    icon: const Icon(Icons.person),
                  ),
                ],
              ),
            ),

            // Contenido desplazable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado con botón de volver y nombre de la planta
                    Container(
                      color: const Color(0xFFD6E8C4), // Verde pastel del encabezado
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context), // Volver a la pantalla anterior
                            child: const Icon(Icons.arrow_back, size: 24),
                          ),
                          Text(
                            plant.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 24), // Espaciador para centrar el título
                        ],
                      ),
                    ),

                    // Imagen principal o marcador si no hay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: plant.imagenPrincipal.isNotEmpty
                          ? Image.network(
                              plant.imagenPrincipal,
                              fit: BoxFit.cover,
                              height: 200,
                            )
                          : const Placeholder(fallbackHeight: 200),
                    ),

                    const SizedBox(height: 12),

                    // Nombre científico
                    Center(
                      child: Text(
                        plant.nombreCientifico,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Secciones informativas
                    _buildSectionTitle("Descripción"),
                    Text(plant.descripcion),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Riego"),
                    Text(plant.riego),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Luz"),
                    Text(plant.luz),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Temperatura"),
                    Text(plant.temperatura),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Humedad"),
                    Text(plant.humedad),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Tipo de Sustrato"),
                    Text(plant.tipoSustrato),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Frecuencia de Abono"),
                    Text(plant.frecuenciaAbono),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Plagas Comunes"),
                    Text(plant.plagasComunes),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Cuidados Especiales"),
                    Text(plant.cuidadosEspeciales),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Toxicidad"),
                    Text(plant.toxicidad),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Floración"),
                    Text(plant.floracion),

                    const SizedBox(height: 12),
                    _buildSectionTitle("Uso Recomendado"),
                    Text(plant.usoRecomendado),

                    const SizedBox(height: 16),
                    _buildSectionTitle("Imágenes de la Planta:"),

                    const SizedBox(height: 8),

                    // Galería de imágenes adicionales
                    if (plant.imagenes.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true, // Para que no tome espacio infinito
                        physics: const NeverScrollableScrollPhysics(), // Scroll heredado del padre
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: plant.imagenes.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              plant.imagenes[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )
                    else
                      const Text("No hay imágenes adicionales."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los títulos de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

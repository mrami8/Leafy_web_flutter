import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/models/plant.dart'; // Modelo de datos de planta

// Pantalla de detalle para mostrar toda la información de una planta
class PlantDetailScreen extends StatelessWidget {
  final Plant plant; // Planta que se va a mostrar

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Color de fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado superior con nombre y botón de volver
            Container(
              color: const Color(0xFFD6E8C4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Botón de retroceso
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Nombre común de la planta
                  Expanded(
                    child: Text(
                      plant.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sección principal: imagen + datos breves
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen principal de la planta (grande)
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            plant.imagenPrincipal.isNotEmpty
                                ? Image.network(
                                  plant.imagenPrincipal,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                )
                                : const Placeholder(), // Imagen por defecto si no hay
                      ),
                    ),
                  ),

                  // Fichas pequeñas con datos clave (riego, luz, etc.)
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 16, // Espacio entre columnas
                        runSpacing: 16, // Espacio entre filas
                        children: [
                          _buildSmallCard("💧 Riego", plant.riego),
                          _buildSmallCard("🌞 Luz", plant.luz),
                          _buildSmallCard("🌡️ Temperatura", plant.temperatura),
                          _buildSmallCard("💦 Humedad", plant.humedad),
                          _buildSmallCard(
                            "🌱 Tipo de Sustrato",
                            plant.tipoSustrato,
                          ),
                          _buildSmallCard(
                            "🌿 Frecuencia de Abono",
                            plant.frecuenciaAbono,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sección inferior: datos detallados y descripción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFD0E4C3),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ), // Borde redondeado superior
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre científico centrado
                    Center(
                      child: Text(
                        plant.nombreCientifico,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Secciones descriptivas
                    _buildSection("📝 Descripción", plant.descripcion),
                    _buildSection("🐛 Plagas Comunes", plant.plagasComunes),
                    _buildSection(
                      "🩺 Cuidados Especiales",
                      plant.cuidadosEspeciales,
                    ),
                    _buildSection("☠️ Toxicidad", plant.toxicidad),
                    _buildSection("🌸 Floración", plant.floracion),
                    _buildSection("🏡 Uso Recomendado", plant.usoRecomendado),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para cada tarjeta de datos clave
  Widget _buildSmallCard(String title, String content) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E8C4), // Verde pastel
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF2D5B2F), // Verde más oscuro
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para secciones largas con título y texto
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D5B2F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4, // Espaciado entre líneas
            ),
          ),
        ],
      ),
    );
  }
}

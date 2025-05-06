import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/models/plant.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Container(
              color: const Color(0xFFD6E8C4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 12),
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

            // Imagen grande + tarjetas pequeñas
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen grande
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: plant.imagenPrincipal.isNotEmpty
                            ? Image.network(
                                plant.imagenPrincipal,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              )
                            : const Placeholder(),
                      ),
                    ),
                  ),

                  // Tarjetas pequeñas
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildSmallCard("💧 Riego", plant.riego),
                          _buildSmallCard("🌞 Luz", plant.luz),
                          _buildSmallCard("🌡️ Temperatura", plant.temperatura),
                          _buildSmallCard("💦 Humedad", plant.humedad),
                          _buildSmallCard("🌱 Tipo de Sustrato", plant.tipoSustrato),
                          _buildSmallCard("🌿 Frecuencia de Abono", plant.frecuenciaAbono),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Descripción y otras secciones en scroll inferior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFD0E4C3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _buildSection("📝 Descripción", plant.descripcion),
                    _buildSection("🐛 Plagas Comunes", plant.plagasComunes),
                    _buildSection("🩺 Cuidados Especiales", plant.cuidadosEspeciales),
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

  Widget _buildSmallCard(String title, String content) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E8C4),
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
              color: Color(0xFF2D5B2F),
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
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/Garden/progress_provider.dart';

// Pantalla que muestra el progreso de crecimiento de una planta mediante fotos
class PlantGrowthPage extends StatefulWidget {
  final String jardinId; // ID del jardín al que pertenece la planta

  const PlantGrowthPage({super.key, required this.jardinId});

  @override
  State<PlantGrowthPage> createState() => _PlantGrowthPageState();
}

class _PlantGrowthPageState extends State<PlantGrowthPage> {
  @override
  void initState() {
    super.initState();

    // Al iniciar la pantalla, se cargan las fotos correspondientes al jardín
    final provider = Provider.of<ProgressProvider>(context, listen: false);
    provider.cargarFotos(widget.jardinId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProgressProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro
      // Botón flotante para subir fotos
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_a_photo),
        onPressed: () {
          // Muestra una hoja modal inferior para elegir cámara o galería
          showModalBottomSheet(
            context: context,
            builder:
                (context) => Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text('Cámara'),
                      onTap: () {
                        Navigator.pop(context);
                        provider.subirFoto(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo),
                      title: const Text('Galería'),
                      onTap: () {
                        Navigator.pop(context);
                        provider.subirFoto(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
          );
        },
      ),

      // Contenido principal
      body: Column(
        children: [
          // Barra superior con título y botón de retroceso
          Container(
            height: 50,
            width: double.infinity,
            color: const Color(0xFFD7EAC8), // Verde pastel oscuro
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                BackButton(color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Progreso de la planta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Contenedor para las fotos o mensaje si no hay ninguna
          Expanded(
            child:
                provider.fotos.isEmpty
                    ? const Center(child: Text('No hay fotos aún.'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // 2 columnas
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: provider.fotos.length,
                      itemBuilder: (context, index) {
                        final foto = provider.fotos[index];

                        return Stack(
                          children: [
                            // Imagen de la planta
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                foto['imagen_url'], // URL firmada
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                              ),
                            ),

                            // Botón para eliminar la imagen, en la esquina superior derecha
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    // Cuadro de confirmación antes de eliminar
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text(
                                              '¿Eliminar imagen?',
                                            ),
                                            content: const Text(
                                              'Esta acción no se puede deshacer.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                    );

                                    // Si el usuario confirma, se elimina la imagen
                                    if (confirm == true) {
                                      final success = await provider
                                          .eliminarFoto(foto['path']);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Imagen eliminada con éxito.'
                                                  : 'No se pudo eliminar la imagen.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

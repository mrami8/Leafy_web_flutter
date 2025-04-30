import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/Garden/progress_provider.dart';

class PlantGrowthPage extends StatefulWidget {
  final String jardinId;

  const PlantGrowthPage({super.key, required this.jardinId});

  @override
  State<PlantGrowthPage> createState() => _PlantGrowthPageState();
}

class _PlantGrowthPageState extends State<PlantGrowthPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProgressProvider>(context, listen: false);
    provider.cargarFotos(widget.jardinId);
  }

  // Método para seleccionar la imagen desde la galería o la cámara
  Future<void> _seleccionarImagen() async {
    try {
      final pickedFile = await showDialog<XFile?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Selecciona una fuente de imagen"),
            actions: [
              TextButton(
                onPressed: () async {
                  final image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  Navigator.pop(context, image);
                },
                child: const Text("Cámara"),
              ),
              TextButton(
                onPressed: () async {
                  final image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  Navigator.pop(context, image);
                },
                child: const Text("Galería"),
              ),
            ],
          );
        },
      );

      if (pickedFile == null) {
        debugPrint("No se seleccionó ninguna imagen.");
        return;
      }

      debugPrint("Ruta de la imagen seleccionada: ${pickedFile.path}");

      final provider = Provider.of<ProgressProvider>(context, listen: false);
      final bool success = await provider.agregarFoto(pickedFile.path);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Imagen añadida con éxito.'
                : 'No se pudo añadir la imagen.',
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error al seleccionar la imagen: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hubo un error al seleccionar la imagen.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProgressProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4),
      body: Column(
        children: [
          // Barra superior con logo y enlaces
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
                // Links de navegación
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

          // Contenedor para el progreso de la planta
          Expanded(
            child:
                provider.fotos.isEmpty
                    ? const Center(child: Text('No hay fotos aún.'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: provider.fotos.length,
                      itemBuilder: (context, index) {
                        final foto = provider.fotos[index];

                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                foto['imagen_url'],
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

      // Botones flotantes
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 80,
        ), // Ajusta el padding para el espacio inferior
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón "Añadir Planta"
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ), // Separación entre botones
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed:
                    _seleccionarImagen, // Llamamos al método para seleccionar imagen
                child: const Text(
                  'Añadir Planta',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            // Botón "Volver"
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ), // Separación entre botones
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Acción para volver a la pantalla anterior
                  Navigator.pop(context);
                },
                child: const Text(
                  'Volver',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

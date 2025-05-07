import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes del dispositivo
import 'package:path/path.dart' as p; // Para trabajar con nombres de archivo
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase para base de datos y almacenamiento
import 'package:leafy_app_flutter/screens/GardenScreen/planta_crecimiento_screen.dart'; // Pantalla para ver progreso de una planta
import 'package:leafy_app_flutter/leafy_layout.dart'; // Diseño general de la app

// Pantalla donde se muestran las plantas del jardín del usuario
class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<Map<String, dynamic>> plantas =
      []; // Lista de plantas cargadas del backend
  bool isLoading = true; // Indicador de carga para mostrar spinner

  @override
  void initState() {
    super.initState();
    cargarPlantas(); // Cargar plantas cuando se inicia la pantalla
  }

  // Consulta a la base de datos para traer las plantas del usuario
  Future<void> cargarPlantas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final result = await Supabase.instance.client
        .from('jardin')
        .select(
          'id, nombre_personalizado, imagen_personalizada, plantas (nombre, imagen_principal)',
        )
        .eq('id_usuario', user.id);

    // Guardamos las plantas y actualizamos el estado
    setState(() {
      plantas = (result as List).cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  // Muestra un formulario emergente para añadir una nueva planta
  void mostrarFormularioNuevaPlanta() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Añadir nueva planta'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nombre personalizado',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nombre = controller.text.trim();
                  if (nombre.isNotEmpty) {
                    Navigator.pop(context);
                    await anadirPlantaDummy(nombre);
                  }
                },
                child: const Text('Añadir'),
              ),
            ],
          ),
    );
  }

  // Inserta una nueva planta dummy en la tabla 'jardin'
  Future<void> anadirPlantaDummy(String nombrePersonalizado) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('❌ Usuario no logueado');
      return;
    }

    const dummyPlantaId = 'fdd93415-6e05-412d-b32c-cd778d990896';

    final nuevaPlanta = {
      'id_usuario': user.id,
      'id_planta': dummyPlantaId,
      'nombre_personalizado': nombrePersonalizado,
      'fecha_adquisicion': DateTime.now().toIso8601String(),
    };

    try {
      final response =
          await Supabase.instance.client
              .from('jardin')
              .insert(nuevaPlanta)
              .select();

      print('✅ Planta insertada: $response');
      await cargarPlantas(); // Recargamos plantas tras inserción
    } catch (e) {
      print('❌ Error al insertar planta: $e');
    }
  }

  // Elimina una planta del jardín por ID
  Future<void> eliminarJardin(String jardinId) async {
    await Supabase.instance.client.from('jardin').delete().eq('id', jardinId);
    await cargarPlantas(); // Recarga la lista tras eliminar
  }

  // Actualiza la imagen personalizada de una planta seleccionada
  Future<void> actualizarImagenPlanta(String jardinId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final bytes = await picked.readAsBytes();
      final fileName =
          p.basename(picked.name).replaceAll(' ', '_').toLowerCase();
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final storagePath =
          'plantastest/$userId/$fileName'; // Ruta de almacenamiento

      print('📦 PATH A SUBIR: $storagePath');
      print('👤 UID: $userId');

      // Subimos la imagen al bucket de Supabase Storage
      await Supabase.instance.client.storage
          .from('plantastest')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: 'image/png'),
          );

      // Obtenemos la URL pública de la imagen
      final publicUrl = Supabase.instance.client.storage
          .from('plantastest')
          .getPublicUrl(storagePath);
      print('🟢 Imagen subida correctamente: $publicUrl');

      // Actualizamos el registro de la planta en la tabla 'jardin'
      await Supabase.instance.client
          .from('jardin')
          .update({'imagen_personalizada': publicUrl})
          .eq('id', jardinId);

      await cargarPlantas(); // Recargamos plantas para reflejar el cambio
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      showSearchBar: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                backgroundColor: const Color(0xFF4CAF50), // Verde oscuro
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: mostrarFormularioNuevaPlanta,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Añadir Planta',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Spinner mientras carga
                  : plantas.isEmpty
                  ? const Center(
                    child: Text('Aún no tienes plantas en tu jardín 🌿'),
                  ) // Texto si no hay plantas
                  : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Seis columnas
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: plantas.length,
                    itemBuilder: (context, index) {
                      final jardinItem = plantas[index];
                      final info = jardinItem['plantas'];
                      final nombre =
                          jardinItem['nombre_personalizado'] ?? info['nombre'];
                      final imagen =
                          jardinItem['imagen_personalizada'] ??
                          info['imagen_principal'];

                      return Stack(
                        children: [
                          // Al pulsar, vamos a la pantalla de progreso
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PlantGrowthPage(
                                        jardinId: jardinItem['id'],
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        imagen != null &&
                                                imagen.toString().isNotEmpty
                                            ? Image.network(
                                              '$imagen?${DateTime.now().millisecondsSinceEpoch}', // Cache-busting
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                            : Container(
                                              color: Colors.green[100],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.local_florist,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // Botón de eliminar planta (arriba a la derecha)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black45,
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
                                            '¿Eliminar planta?',
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
                                    await eliminarJardin(jardinItem['id']);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Planta eliminada del jardín.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          // Botón para cambiar la imagen (arriba a la izquierda)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await actualizarImagenPlanta(
                                    jardinItem['id'],
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Imagen actualizada'),
                                      ),
                                    );
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
      ),
    );
  }
}

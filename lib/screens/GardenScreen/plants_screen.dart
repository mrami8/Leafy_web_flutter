import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leafy_app_flutter/screens/GardenScreen/planta_crecimiento_screen.dart';
import 'package:leafy_app_flutter/leafy_layout.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<Map<String, dynamic>> plantas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarPlantas();
  }

  Future<void> cargarPlantas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final result = await Supabase.instance.client
        .from('jardin')
        .select('id, nombre_personalizado, imagen_personalizada, plantas (nombre, imagen_principal)')
        .eq('id_usuario', user.id);

    setState(() {
      plantas = (result as List).cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  void mostrarFormularioNuevaPlanta() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Añadir nueva planta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre personalizado'),
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
      final response = await Supabase.instance.client
          .from('jardin')
          .insert(nuevaPlanta)
          .select();

      print('✅ Planta insertada: $response');
      await cargarPlantas();
    } catch (e) {
      print('❌ Error al insertar planta: $e');
    }
  }

  Future<void> eliminarJardin(String jardinId) async {
    await Supabase.instance.client.from('jardin').delete().eq('id', jardinId);
    await cargarPlantas();
  }

  Future<void> actualizarImagenPlanta(String jardinId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    try {
      final bytes = await picked.readAsBytes();
      final fileName = p.basename(picked.name).replaceAll(' ', '_').toLowerCase();
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final storagePath = 'plantastest/$userId/$fileName';  // Cambio aquí: nuevo nombre del bucket

      print('📦 PATH A SUBIR: $storagePath');
      print('👤 UID: $userId');

      await Supabase.instance.client.storage.from('plantastest').uploadBinary(  // Cambio aquí: nuevo nombre del bucket
        storagePath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: 'image/png',
        ),
      );

      final publicUrl = Supabase.instance.client.storage.from('plantastest').getPublicUrl(storagePath);  // Cambio aquí: nuevo nombre del bucket
      print('🟢 Imagen subida correctamente: $publicUrl');

      await Supabase.instance.client
          .from('jardin')
          .update({'imagen_personalizada': publicUrl})
          .eq('id', jardinId);

      await cargarPlantas();
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      showSearchBar: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF4E4),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                backgroundColor: const Color(0xFF4CAF50),
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : plantas.isEmpty
                  ? const Center(child: Text('Aún no tienes plantas en tu jardín 🌿'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: plantas.length,
                      itemBuilder: (context, index) {
                        final jardinItem = plantas[index];
                        final info = jardinItem['plantas'];
                        final nombre = jardinItem['nombre_personalizado'] ?? info['nombre'];
                        final imagen = jardinItem['imagen_personalizada'] ?? info['imagen_principal'];

                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlantGrowthPage(
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
                                      child: imagen != null && imagen.toString().isNotEmpty
                                          ? Image.network(
                                              '$imagen?${DateTime.now().millisecondsSinceEpoch}',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              color: Colors.green[100],
                                              child: const Center(
                                                child: Icon(Icons.local_florist, size: 40),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('¿Eliminar planta?'),
                                        content: const Text('Esta acción no se puede deshacer.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await eliminarJardin(jardinItem['id']);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Planta eliminada del jardín.')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                  onPressed: () async {
                                    await actualizarImagenPlanta(jardinItem['id']);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Imagen actualizada')),
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

import 'package:flutter/material.dart';
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
        .select('id, nombre_personalizado, plantas (nombre)')
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

  Future<void> anadirPlantaDummy(String nombrePersonalizado) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    const dummyPlantaId = 'fdd93415-6e05-412d-b32c-cd778d990896';

    final nuevaPlanta = {
      'id_usuario': user.id,
      'id_planta': dummyPlantaId,
      'nombre_personalizado': nombrePersonalizado,
      'fecha_adquisicion': DateTime.now().toIso8601String(),
    };

    try {
      await Supabase.instance.client.from('jardin').insert(nuevaPlanta);
      await cargarPlantas();
    } catch (e) {
      print('❌ Error al insertar planta: $e');
    }
  }

  Future<void> eliminarJardin(String jardinId) async {
    await Supabase.instance.client.from('jardin').delete().eq('id', jardinId);
    await cargarPlantas();
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      showSearchBar: true,
      child: Stack(
        children: [
          // Imagen de fondo opaca
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset('assets/FondoPantalla.jpg', fit: BoxFit.cover),
                Container(
                  color: Colors.black.withOpacity(
                    0.3,
                  ), // Oscurece la imagen sin ocultarla
                ),
              ],
            ),
          ),
          // Contenido principal
          Scaffold(
            backgroundColor: Colors.transparent,
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
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : plantas.isEmpty
                      ? const Center(
                        child: Text('Aún no tienes plantas en tu jardín 🌿'),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: plantas.length,
                        itemBuilder: (context, index) {
                          final jardinItem = plantas[index];
                          final info = jardinItem['plantas'];
                          final nombre =
                              jardinItem['nombre_personalizado'] ??
                              info['nombre'];

                          return Stack(
                            children: [
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
                                child: SizedBox(
                                  height: 139,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.asset(
                                            'assets/platapredeterminada.png',
                                            fit: BoxFit.cover,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
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
                            ],
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

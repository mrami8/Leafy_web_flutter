import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leafy_app_flutter/screens/GardenScreen/planta_crecimiento_screen.dart';

// Pantalla que muestra las plantas añadidas por el usuario en su jardín
class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<Map<String, dynamic>> plantas =
      []; // Lista de jardines/planta del usuario
  bool isLoading = true; // Controla si aún se están cargando los datos

  @override
  void initState() {
    super.initState();
    cargarPlantas(); // Cargar plantas al iniciar
  }

  // Cargar las plantas del usuario desde la tabla 'jardin'
  Future<void> cargarPlantas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final result = await Supabase.instance.client
        .from('jardin')
        .select('id, nombre_personalizado, plantas (nombre, imagen_principal)')
        .eq('id_usuario', user.id); // Solo las del usuario actual

    setState(() {
      plantas = (result as List).cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  // Mostrar formulario para añadir una nueva planta personalizada
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
                    await anadirPlantaDummy(nombre); // Añadir planta ficticia
                  }
                },
                child: const Text('Añadir'),
              ),
            ],
          ),
    );
  }

  // Añadir una nueva planta dummy al jardín del usuario
  Future<void> anadirPlantaDummy(String nombrePersonalizado) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    const dummyPlantaId = 'fdd93415-6e05-412d-b32c-cd778d990896';

    await Supabase.instance.client.from('jardin').insert({
      'id_usuario': user.id,
      'id_planta': dummyPlantaId,
      'nombre_personalizado': nombrePersonalizado,
      'fecha_adquisicion': DateTime.now().toIso8601String(),
    });

    await cargarPlantas(); // Recargar tras añadir
  }

  // Eliminar un jardín/planta del usuario
  Future<void> eliminarJardin(String jardinId) async {
    await Supabase.instance.client.from('jardin').delete().eq('id', jardinId);
    await cargarPlantas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro
      // Botón para añadir nueva planta
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: mostrarFormularioNuevaPlanta,
      ),

      body: Column(
        children: [
          // Barra superior con título
          Container(
            height: 60,
            width: double.infinity,
            color: const Color(0xFFD7EAC8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Row(
              children: [
                Spacer(),
                Text(
                  "LEAFY",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Contenido de la pantalla
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Indicador de carga
                    : plantas.isEmpty
                    ? const Center(
                      child: Text('Aún no tienes plantas en tu jardín 🌿'),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: plantas.length,
                      itemBuilder: (context, index) {
                        final jardinItem = plantas[index];
                        final info = jardinItem['plantas'];
                        final nombre =
                            jardinItem['nombre_personalizado'] ??
                            info['nombre'];
                        final imagen = info['imagen_principal'];

                        return Stack(
                          children: [
                            // Tarjeta de planta
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
                                                imagen,
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

                            // Botón de eliminar
                            Positioned(
                              top: 6,
                              right: 6,
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
        ],
      ),
    );
  }
}

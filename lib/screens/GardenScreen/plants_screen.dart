import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leafy_app_flutter/screens/GardenScreen/planta_crecimiento_screen.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Asegúrate que esta ruta es la correcta

// Pantalla principal de plantas del jardín
class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  // Lista que almacenará los datos de las plantas del jardín
  List<Map<String, dynamic>> plantas = [];
  // Variable para mostrar un indicador de carga mientras se obtienen los datos
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarPlantas(); // Se cargan las plantas al iniciar la pantalla
  }

  // Función que obtiene las plantas del jardín desde Supabase
  Future<void> cargarPlantas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final result = await Supabase.instance.client
        .from('jardin')
        .select('id, nombre_personalizado, plantas (nombre, imagen_principal)')
        .eq('id_usuario', user.id); // Se filtran las plantas por el usuario actual

    setState(() {
      plantas = (result as List).cast<Map<String, dynamic>>();
      isLoading = false; // Se desactiva el indicador de carga
    });
  }

  // Muestra un diálogo para ingresar una nueva planta
  void mostrarFormularioNuevaPlanta() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
                await anadirPlantaDummy(nombre); // Se añade la planta
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  // Inserta una planta dummy (plantilla) en la base de datos para pruebas
  Future<void> anadirPlantaDummy(String nombrePersonalizado) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // ID de una planta dummy preexistente
    const dummyPlantaId = 'fdd93415-6e05-412d-b32c-cd778d990896';

    await Supabase.instance.client.from('jardin').insert({
      'id_usuario': user.id,
      'id_planta': dummyPlantaId,
      'nombre_personalizado': nombrePersonalizado,
      'fecha_adquisicion': DateTime.now().toIso8601String(),
    });

    await cargarPlantas(); // Refresca la lista tras añadir
  }

  // Elimina una planta del jardín por ID
  Future<void> eliminarJardin(String jardinId) async {
    await Supabase.instance.client.from('jardin').delete().eq('id', jardinId);
    await cargarPlantas(); // Refresca la lista tras eliminar
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      showSearchBar: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF4E4),
        // Botón flotante centrado en la parte inferior para añadir una planta
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
          child: isLoading
              // Muestra indicador de carga mientras se obtienen los datos
              ? const Center(child: CircularProgressIndicator())
              // Si no hay plantas, muestra un mensaje
              : plantas.isEmpty
                  ? const Center(
                      child: Text('Aún no tienes plantas en tu jardín 🌿'),
                    )
                  // Muestra las plantas en una cuadrícula de 6 columnas
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
                        final imagen = info['imagen_principal'];

                        return Stack(
                          children: [
                            // Widget principal de cada planta (clicable)
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
                                          // Muestra imagen si está disponible
                                          ? Image.network(
                                              imagen,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          // Si no hay imagen, muestra un ícono decorativo
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
                                  // Muestra el nombre de la planta
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
                            // Botón de eliminar en la esquina superior derecha
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                      // Confirmación antes de eliminar
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('¿Eliminar planta?'),
                                          content: const Text(
                                            'Esta acción no se puede deshacer.',
                                          ),
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

                                      // Si el usuario confirma, se elimina la planta
                                      if (confirm == true) {
                                        await eliminarJardin(jardinItem['id']);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Planta eliminada del jardín.'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
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

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leafy_app_flutter/models/plant.dart'; // Importa el modelo Plant desde la carpeta models

// Provider que gestiona la búsqueda de plantas en Supabase
class PlantSearchProvider with ChangeNotifier {
  final SupabaseClient supabaseClient; // Cliente de Supabase que se usará para las peticiones
  List<Plant> plants = []; // Lista que almacena los resultados de la búsqueda

  // Constructor que recibe el SupabaseClient
  PlantSearchProvider(this.supabaseClient);

  // Método para buscar plantas por nombre o nombre científico
  Future<void> searchPlants(String query) async {
    try {
      final response = query.isEmpty
          ? await supabaseClient.from('plantas').select('*')
          : await supabaseClient
              .from('plantas')
              .select('*')
              .or('nombre.ilike.%$query%,nombre_cientifico.ilike.%$query%');

      print('Respuesta de la consulta: $response');

      // Convierte los resultados en objetos Plant usando el método fromSearchMap
      plants = response.map((e) => Plant.fromSearchMap(e)).toList();
      notifyListeners();
    } catch (e) {
      print('Error al buscar plantas: $e');
      plants = [];
      notifyListeners();
    }
  }
}

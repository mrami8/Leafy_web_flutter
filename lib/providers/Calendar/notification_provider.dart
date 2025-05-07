import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Proveedor de notificaciones que gestiona la obtención, adición y eliminación
/// de notificaciones para una fecha específica, usando Supabase.
class NotificationProvider extends ChangeNotifier {
  // Lista que contiene las notificaciones recuperadas de la base de datos
  List<Map<String, dynamic>> notifications = [];

  // Fecha seleccionada por el usuario para ver/gestionar notificaciones
  DateTime? selectedDate;

  /// Obtiene las notificaciones almacenadas en Supabase para una fecha específica.
  Future<void> getNotificationsForDate(DateTime date) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return; // Si el usuario no ha iniciado sesión, salimos

    // Definimos el rango de búsqueda: desde la medianoche del día seleccionado hasta el día siguiente
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    // Guardamos la fecha seleccionada y limpiamos la lista actual
    selectedDate = date;
    notifications = [];
    notifyListeners(); // Notificamos a los listeners que hubo un cambio

    try {
      // Realizamos la consulta en Supabase al registro 'calendario' filtrando:
      // - id_usuario = usuario actual
      // - fecha >= inicio del día
      // - fecha < día siguiente
      final result = await Supabase.instance.client
          .from('calendario')
          .select()
          .eq('id_usuario', user.id)
          .gte('fecha', start.toIso8601String())
          .lt('fecha', end.toIso8601String())
          .order('fecha', ascending: true); // Ordenamos por hora ascendente

      // Convertimos los resultados a una lista de mapas
      notifications = (result as List).cast<Map<String, dynamic>>();
      notifyListeners(); // Volvemos a notificar cambios
    } catch (e) {
      // Si ocurre un error, lo imprimimos en consola
      print('Error al obtener notificaciones: $e');
    }
  }

  /// Agrega una nueva notificación a la base de datos para la fecha seleccionada.
  Future<void> addNotification(Map<String, dynamic> data) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedDate == null) return;

    // ID de planta temporal hasta que se implemente la selección de planta
    const dummyPlantId = 'fdd93415-6e05-412d-b32c-cd778d990896';

    // Se extraen los datos del formulario
    final tipoCuidado = data['tipo_cuidado'];
    final hora = data['hora'] ?? '00:00';

    // Se construye el DateTime combinando la fecha seleccionada con la hora introducida
    final fechaFinal = DateTime.parse(
      '${selectedDate!.toIso8601String().split("T")[0]} $hora',
    );

    // Se crea un nuevo mapa con los datos a insertar
    final newRecord = {
      'id_usuario': user.id,
      'id_planta': dummyPlantId,
      'tipo_cuidado': tipoCuidado,
      'fecha': fechaFinal.toIso8601String(),
      'estado': false, // Estado por defecto: no realizado
    };

    try {
      // Insertamos el nuevo registro en Supabase
      await Supabase.instance.client
          .from('calendario')
          .insert(newRecord)
          .select(); // select() devuelve el objeto insertado

      // Recargamos las notificaciones para mostrar el cambio
      await getNotificationsForDate(selectedDate!);
    } catch (e) {
      print('Error al guardar notificación: $e');
    }
  }

  /// Elimina una notificación según su tipo de cuidado para la fecha seleccionada.
  Future<void> deleteNotification(String tipoCuidado) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedDate == null) return;

    // Definimos nuevamente el rango de la fecha seleccionada
    final start = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );
    final end = start.add(const Duration(days: 1));

    try {
      // Eliminamos la notificación filtrando por:
      // - usuario
      // - tipo de cuidado
      // - fecha dentro del rango del día
      await Supabase.instance.client
          .from('calendario')
          .delete()
          .eq('id_usuario', user.id)
          .eq('tipo_cuidado', tipoCuidado)
          .gte('fecha', start.toIso8601String())
          .lt('fecha', end.toIso8601String());

      // Recargamos las notificaciones para actualizar la vista
      await getNotificationsForDate(selectedDate!);
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }
}

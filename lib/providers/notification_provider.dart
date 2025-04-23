import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider para manejar las notificaciones del calendario
class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> notifications =
      []; // Lista de notificaciones cargadas
  DateTime? selectedDate; // Fecha actualmente seleccionada por el usuario

  // Cargar notificaciones desde Supabase para una fecha concreta
  Future<void> getNotificationsForDate(DateTime date) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('Usuario no logueado');
      return;
    }

    // Definir el rango de la fecha: desde la medianoche hasta la medianoche del día siguiente
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    selectedDate = date;
    notifications = []; // Limpiar la lista actual
    notifyListeners(); // Notificar a los widgets que escuchan

    try {
      final result = await Supabase.instance.client
          .from('calendario')
          .select()
          .eq('id_usuario', user.id)
          .gte('fecha', start.toIso8601String())
          .lt('fecha', end.toIso8601String());

      notifications = (result as List).cast<Map<String, dynamic>>();
      print('Notificaciones cargadas: $notifications');
      notifyListeners();
    } catch (e) {
      print('Error al obtener notificaciones: $e');
    }
  }

  // Añadir una nueva notificación para la fecha seleccionada
  Future<void> addNotification(String message) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedDate == null) {
      print('Usuario no logueado o fecha no seleccionada');
      return;
    }

    // ID de planta por defecto
    const dummyPlantId = 'fdd93415-6e05-412d-b32c-cd778d990896';

    final newRecord = {
      'id_usuario': user.id,
      'id_planta': dummyPlantId,
      'tipo_cuidado': message,
      'fecha': selectedDate!.toIso8601String(),
      'estado': false,
    };

    print('Registro a insertar: $newRecord');

    try {
      final response =
          await Supabase.instance.client
              .from('calendario')
              .insert(newRecord)
              .select(); // Insertar y devolver el registro

      print('Notificación guardada en Supabase: $response');
      await getNotificationsForDate(selectedDate!); // Recargar la lista
    } catch (e) {
      print('Error al guardar en Supabase: $e');
    }
  }

  // Eliminar una notificación por tipo de cuidado en la fecha seleccionada
  Future<void> deleteNotification(String tipoCuidado) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedDate == null) return;

    final start = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );
    final end = start.add(const Duration(days: 1));

    try {
      await Supabase.instance.client
          .from('calendario')
          .delete()
          .eq('id_usuario', user.id)
          .eq('tipo_cuidado', tipoCuidado)
          .gte('fecha', start.toIso8601String())
          .lt('fecha', end.toIso8601String());

      print('Notificación eliminada correctamente');
      await getNotificationsForDate(selectedDate!);
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }

  // Obtener todas las notificaciones del usuario, ordenadas por fecha descendente
  Future<void> getAllNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final result = await Supabase.instance.client
          .from('calendario')
          .select()
          .eq('id_usuario', user.id)
          .order('fecha', ascending: false);

      notifications = (result as List).cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (e) {
      print('Error al obtener todas las notificaciones: $e');
    }
  }
}

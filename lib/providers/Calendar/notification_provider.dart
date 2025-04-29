import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider para manejar las notificaciones del calendario
class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> notifications = [];
  DateTime? selectedDate;

  // Cargar notificaciones desde Supabase para una fecha concreta
  Future<void> getNotificationsForDate(DateTime date) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('Usuario no logueado');
      return;
    }

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    selectedDate = date;
    notifications = [];
    notifyListeners();

    try {
      final result = await Supabase.instance.client
          .from('calendario')
          .select()
          .eq('id_usuario', user.id)
          .gte('fecha', start.toIso8601String())
          .lt('fecha', end.toIso8601String())
          .order('fecha', ascending: true);

      notifications = (result as List).cast<Map<String, dynamic>>();
      print('Notificaciones cargadas: $notifications');
      notifyListeners();
    } catch (e) {
      print('Error al obtener notificaciones: $e');
    }
  }

  // NUEVO: Añadir una notificación con hora
  Future<void> addNotification(Map<String, dynamic> data) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedDate == null) {
      print('Usuario no logueado o fecha no seleccionada');
      return;
    }

    const dummyPlantId = 'fdd93415-6e05-412d-b32c-cd778d990896';
    final tipoCuidado = data['tipo_cuidado'];
    final hora = data['hora'] ?? '00:00';
    final fechaFinal = DateTime.parse(
      '${selectedDate!.toIso8601String().split("T")[0]} $hora',
    );

    final newRecord = {
      'id_usuario': user.id,
      'id_planta': dummyPlantId,
      'tipo_cuidado': tipoCuidado,
      'fecha': fechaFinal.toIso8601String(),
      'estado': false,
    };

    try {
      final response = await Supabase.instance.client
          .from('calendario')
          .insert(newRecord)
          .select();

      print('Notificación guardada en Supabase: $response');
      await getNotificationsForDate(selectedDate!);
    } catch (e) {
      print('Error al guardar en Supabase: $e');
    }
    print('Hora seleccionada: $hora');
    print('Fecha completa guardada: $fechaFinal');

  }

  // Eliminar por tipo_cuidado (puedes adaptarlo a un ID si lo necesitas)
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

      await getNotificationsForDate(selectedDate!);
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }

  // Obtener todas las notificaciones
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

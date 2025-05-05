import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> notifications = [];
  DateTime? selectedDate;

  Future<void> getNotificationsForDate(DateTime date) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

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
      notifyListeners();
    } catch (e) {
      print('Error al obtener notificaciones: $e');
    }
  }

  Future<void> addNotification(Map<String, dynamic> data) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedDate == null) return;

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
      await Supabase.instance.client
          .from('calendario')
          .insert(newRecord)
          .select();

      await getNotificationsForDate(selectedDate!);
    } catch (e) {
      print('Error al guardar notificación: $e');
    }
  }

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
}

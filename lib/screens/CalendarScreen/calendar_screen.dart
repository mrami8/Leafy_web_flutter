import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Para usar el NotificationProvider
import 'package:table_calendar/table_calendar.dart'; // Calendario interactivo
import 'package:leafy_app_flutter/providers/Calendar/notification_provider.dart'; // Provider de notificaciones
import 'package:leafy_app_flutter/widget/add_notification_form.dart'; // Formulario para añadir nuevas notificaciones
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout general de la app

// Pantalla principal del calendario
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Día enfocado por el calendario
  DateTime _focusedDay = DateTime.now();

  // Día seleccionado por el usuario (puede ser diferente al enfocado)
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    // Esperamos a que el widget se haya renderizado antes de hacer la llamada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).getNotificationsForDate(
        DateTime.now(),
      ); // Carga notificaciones del día actual al iniciar
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider para acceder a las notificaciones y estado
    final provider = Provider.of<NotificationProvider>(context);
    final notifications =
        provider.notifications; // Lista de notificaciones del día seleccionado

    return LeafyLayout(
      showSearchBar: true, // Muestra la barra de búsqueda en el layout general
      child: Padding(
        padding: const EdgeInsets.all(16), // Espaciado interno
        child: Column(
          children: [
            // Calendario mensual
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1), // Fecha mínima permitida
              lastDay: DateTime.utc(2030, 12, 31), // Fecha máxima permitida
              focusedDay: _focusedDay, // Día actual que está en vista
              selectedDayPredicate:
                  (day) => isSameDay(
                    _selectedDay,
                    day,
                  ), // Comprueba si el día está seleccionado
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                // Al seleccionar un día, cargamos las notificaciones de ese día
                Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                ).getNotificationsForDate(selectedDay);
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.green, // Color para el día seleccionado
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.lightGreen, // Color para el día actual
                  shape: BoxShape.circle,
                ),
              ),
              calendarFormat:
                  CalendarFormat.month, // Muestra el calendario por mes
            ),

            const SizedBox(height: 16), // Espacio vertical
            // Formulario para añadir una nueva notificación de cuidado
            const AddNotificationForm(),

            const SizedBox(height: 16),

            // Muestra la lista de notificaciones o un mensaje si no hay ninguna
            Expanded(
              child:
                  notifications.isEmpty
                      ? const Center(
                        child: Text('No hay notificaciones para esta fecha.'),
                      )
                      : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];

                          // Tipo de cuidado (ej: "Riego", "Abono", etc.)
                          final tipoCuidado =
                              notif['tipo_cuidado'] ?? 'Sin tipo';

                          // Convertimos el string de fecha a objeto DateTime
                          final fecha = DateTime.parse(notif['fecha']);

                          // Formateamos la hora en formato HH:MM
                          final horaFormateada =
                              '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

                          // Cada notificación se muestra como un ListTile
                          return ListTile(
                            title: Text(
                              '$horaFormateada - $tipoCuidado',
                            ), // Ej: 09:00 - Riego
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Al presionar eliminar, llamamos al método del provider
                                Provider.of<NotificationProvider>(
                                  context,
                                  listen: false,
                                ).deleteNotification(tipoCuidado);
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

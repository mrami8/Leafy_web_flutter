import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:leafy_app_flutter/providers/Calendar/notification_provider.dart';
import 'package:leafy_app_flutter/widget/add_notification_form.dart';
import 'package:leafy_app_flutter/leafy_layout.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarView _calendarView = CalendarView.day;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now();
      Provider.of<NotificationProvider>(context, listen: false)
          .getNotificationsForDate(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Renderizando pantalla de calendario');
    final provider = Provider.of<NotificationProvider>(context);
    final notifications = provider.notifications;

    return LeafyLayout(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calendario por horas',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<CalendarView>(
                      value: _calendarView,
                      onChanged: (view) {
                        if (view != null) {
                          setState(() {
                            _calendarView = view;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: CalendarView.day,
                          child: Text('Día'),
                        ),
                        DropdownMenuItem(
                          value: CalendarView.week,
                          child: Text('Semana'),
                        ),
                        DropdownMenuItem(
                          value: CalendarView.workWeek,
                          child: Text('Semana laboral'),
                        ),
                        DropdownMenuItem(
                          value: CalendarView.schedule,
                          child: Text('Agenda'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      print('🧱 Construyendo SfCalendar');
                      return SfCalendar(
                        view: _calendarView,
                        dataSource: NotificacionDataSource(
                          _convertirNotificaciones(notifications),
                        ),
                        initialDisplayDate:
                            provider.selectedDate ?? DateTime.now(),
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          timeInterval: Duration(minutes: 30),
                          startHour: 6,
                          endHour: 22,
                        ),
                        onTap: (CalendarTapDetails details) {
                          if (details.date != null) {
                            Provider.of<NotificationProvider>(context,
                                    listen: false)
                                .getNotificationsForDate(details.date!);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const AddNotificationForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Appointment> _convertirNotificaciones(
      List<Map<String, dynamic>> notifications) {
    print('Notificaciones en calendario: $notifications');

    return notifications.map((notif) {
      try {
        final fechaStr = notif['fecha'];
        final tipoCuidado = notif['tipo_cuidado'] ?? 'Sin tipo';

        final fecha = DateTime.parse(fechaStr);
        print('→ $tipoCuidado a las ${fecha.hour}:${fecha.minute}');

        return Appointment(
          startTime: fecha,
          endTime: fecha.add(const Duration(minutes: 30)),
          subject: tipoCuidado,
          color: _colorPorTipo(tipoCuidado),
        );
      } catch (e) {
        print('Error al convertir notificación: $e');
        return null;
      }
    }).whereType<Appointment>().toList();
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'riego':
        return Colors.blue;
      case 'poda':
        return Colors.orange;
      case 'fertilización':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}

class NotificacionDataSource extends CalendarDataSource {
  NotificacionDataSource(List<Appointment> source) {
    appointments = source;
  }
}

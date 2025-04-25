import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Calendar/notification_provider.dart';

// Widget que muestra un formulario para añadir notificaciones de tipo de cuidado
class AddNotificationForm extends StatelessWidget {
  const AddNotificationForm({super.key});

  // Función auxiliar para añadir una notificación llamando al provider
  void _addNotification(BuildContext context, String tipo) async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.addNotification(tipo); // Añade la notificación

    // Muestra mensaje de confirmación en pantalla
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Notificación de $tipo añadida')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título del formulario
        const Text(
          'Añadir tipo de cuidado:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // Botones agrupados para añadir distintos tipos de notificación
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,

          children: [
            // Botón para añadir tipo "Riego"
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _addNotification(context, 'Riego'),
              icon: const Icon(Icons.water_drop),
              label: const Text('Riego'),
            ),

            // Botón para añadir tipo "Poda"
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _addNotification(context, 'Poda'),
              icon: const Icon(Icons.content_cut),
              label: const Text('Poda'),
            ),

            // Botón para añadir tipo "Fertilización"
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _addNotification(context, 'Fertilización'),
              icon: const Icon(Icons.local_florist),
              label: const Text('Fertilización'),
            ),
          ],
        ),
      ],
    );
  }
}

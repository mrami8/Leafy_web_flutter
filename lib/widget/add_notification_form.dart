import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Calendar/notification_provider.dart';

class AddNotificationForm extends StatefulWidget {
  const AddNotificationForm({super.key});

  @override
  State<AddNotificationForm> createState() => _AddNotificationFormState();
}

class _AddNotificationFormState extends State<AddNotificationForm> {
  TimeOfDay? _selectedTime;

  void _pickTimeAndAdd(BuildContext context, String tipoCuidado) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    final formattedTime =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    final provider = Provider.of<NotificationProvider>(context, listen: false);

    await provider.addNotification({
      'tipo_cuidado': tipoCuidado,
      'hora': formattedTime,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notificación de "$tipoCuidado" añadida')),
    );

    setState(() {
      _selectedTime = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Añadir notificación rápida',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickTimeAndAdd(context, 'Riego'),
              icon: const Icon(Icons.water_drop),
              label: const Text('Riego'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickTimeAndAdd(context, 'Poda'),
              icon: const Icon(Icons.cut),
              label: const Text('Poda'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickTimeAndAdd(context, 'Fertilización'),
              icon: const Icon(Icons.local_florist),
              label: const Text('Fertilización'),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Calendar/notification_provider.dart';

class AddNotificationForm extends StatefulWidget {
  const AddNotificationForm({super.key});

  @override
  State<AddNotificationForm> createState() => _AddNotificationFormState();
}

class _AddNotificationFormState extends State<AddNotificationForm> {
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;

  void _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addNotification(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final message = _controller.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un tipo de cuidado')),
      );
      return;
    }

    final formattedTime = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : '00:00';

    provider.addNotification({
      'tipo_cuidado': message,
      'hora': formattedTime,
    });

    _controller.clear();
    setState(() {
      _selectedTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificación añadida')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Añadir nueva notificación',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Tipo de cuidado (Ej: Regar planta)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickTime(context),
              child: const Text('Seleccionar hora'),
            ),
            const SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : 'No hay hora seleccionada',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _addNotification(context),
          child: const Text('Añadir notificación'),
        ),
      ],
    );
  }
}

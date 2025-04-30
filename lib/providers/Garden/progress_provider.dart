import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Provider encargado de gestionar las fotos de progreso asociadas a un jardín
class ProgressProvider extends ChangeNotifier {
  List<Map<String, dynamic>> fotos = []; // Lista de fotos con su metadata
  String? jardinId; // ID del jardín actual

  // Método para cargar las fotos desde la tabla 'imagenes_progreso' y obtener URLs firmadas
  Future<void> cargarFotos(String idJardin) async {
    try {
      jardinId = idJardin;

      // Consulta a la base de datos para obtener las fotos del jardín, ordenadas por fecha
      final result = await Supabase.instance.client
          .from('imagenes_progreso')
          .select()
          .eq('id_jardin', idJardin)
          .order('fecha_subida', ascending: false);

      final storage = Supabase.instance.client.storage.from('progresoplantas');

      // Genera una lista de mapas con URL firmada, path y fecha
      fotos =
          (await Future.wait(
            (result as List).map((item) async {
              final path = item['imagen_url'];

              try {
                final signedUrl = await storage.createSignedUrl(
                  path,
                  60 * 60,
                ); // 1 hora de validez
                return {
                  'imagen_url': signedUrl,
                  'path': path,
                  'fecha_subida': item['fecha_subida'],
                };
              } catch (e) {
                debugPrint('No se pudo generar signedUrl para $path: $e');
                return null; // Ignora si hay error con esta imagen
              }
            }),
          )).whereType<Map<String, dynamic>>().toList();

      notifyListeners(); // Notifica cambios a la UI
    } catch (e) {
      debugPrint('Error al cargar fotos: $e');
    }
  }

  // Método para subir una nueva foto al almacenamiento y registrarla en la base de datos
  Future<void> subirFoto(ImageSource source) async {
    try {
      if (jardinId == null) {
        debugPrint('Error: jardinId es null');
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile == null) {
        debugPrint('No se seleccionó ninguna imagen');
        return;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('Usuario no autenticado');
        return;
      }

      // Generar path único usando UUID
      final uuid = const Uuid().v4();
      final path = '${user.id}/$jardinId/$uuid.jpg';

      final storage = Supabase.instance.client.storage.from('progresoplantas');

      // Subir imagen en función de la plataforma (web o móvil)
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await storage.uploadBinary(path, bytes);
      } else {
        final file = File(pickedFile.path);
        await storage.upload(path, file);
      }

      // Insertar referencia a la imagen en la base de datos
      await Supabase.instance.client.from('imagenes_progreso').insert({
        'id_jardin': jardinId,
        'imagen_url': path,
        'fecha_subida': DateTime.now().toIso8601String(),
      });

      // Esperar 1 segundo antes de recargar para evitar errores de sincronización
      await Future.delayed(const Duration(seconds: 1));
      await cargarFotos(jardinId!);
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
    }
  }

  // Método para eliminar una foto del almacenamiento y de la base de datos
  Future<bool> eliminarFoto(String path) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final storage = Supabase.instance.client.storage.from('progresoplantas');

      // Elimina la imagen del bucket de Supabase Storage
      await storage.remove([path]);

      // Elimina el registro de la imagen en la base de datos
      await Supabase.instance.client
          .from('imagenes_progreso')
          .delete()
          .eq('imagen_url', path);

      await cargarFotos(jardinId!); // Recarga la lista de fotos tras eliminar
      return true;
    } catch (e) {
      debugPrint('Error al eliminar imagen: $e');
      return false;
    }
  }

  Future<bool> agregarFoto(String pathLocal) async {
    try {
      if (jardinId == null) {
        debugPrint('Error: jardinId es null');
        return false;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('Usuario no autenticado');
        return false;
      }

      final uuid = const Uuid().v4();
      final path = '${user.id}/$jardinId/$uuid.jpg';
      final storage = Supabase.instance.client.storage.from('progresoplantas');

      if (kIsWeb) {
        final bytes = await XFile(pathLocal).readAsBytes();
        await storage.uploadBinary(path, bytes);
      } else {
        final file = File(pathLocal);
        await storage.upload(path, file);
      }

      await Supabase.instance.client.from('imagenes_progreso').insert({
        'id_jardin': jardinId,
        'imagen_url': path,
        'fecha_subida': DateTime.now().toIso8601String(),
      });

      await cargarFotos(jardinId!);
      return true;
    } catch (e) {
      debugPrint('Error en agregarFoto: $e');
      return false;
    }
  }
}

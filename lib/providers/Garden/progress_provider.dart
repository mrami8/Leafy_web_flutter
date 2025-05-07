import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Provider encargado de gestionar las fotos de progreso asociadas a un jardín.
class ProgressProvider extends ChangeNotifier {
  // Lista de fotos (con su metadata: url firmada, path, fecha)
  List<Map<String, dynamic>> fotos = [];

  // ID del jardín seleccionado actualmente
  String? jardinId;

  /// Carga las fotos de progreso desde la base de datos y genera URLs firmadas para mostrarlas
  Future<void> cargarFotos(String idJardin) async {
    try {
      jardinId = idJardin;

      // Consulta las imágenes asociadas al jardín en la tabla 'imagenes_progreso'
      final result = await Supabase.instance.client
          .from('imagenes_progreso')
          .select()
          .eq('id_jardin', idJardin)
          .order(
            'fecha_subida',
            ascending: false,
          ); // Orden descendente por fecha

      final storage = Supabase.instance.client.storage.from('progresoplantas');

      // Mapeamos los resultados para generar URLs firmadas de 1 hora de validez
      fotos =
          (await Future.wait(
            (result as List).map((item) async {
              final path = item['imagen_url'];
              try {
                final signedUrl = await storage.createSignedUrl(
                  path,
                  60 * 60,
                ); // 1h
                return {
                  'imagen_url': signedUrl,
                  'path': path,
                  'fecha_subida': item['fecha_subida'],
                };
              } catch (e) {
                debugPrint('No se pudo generar signedUrl para $path: $e');
                return null; // Si falla, se ignora esa imagen
              }
            }),
          )).whereType<Map<String, dynamic>>().toList(); // Elimina los nulos

      notifyListeners(); // Notifica a la UI que se ha actualizado la lista de fotos
    } catch (e) {
      debugPrint('Error al cargar fotos: $e');
    }
  }

  /// Sube una nueva foto tomada desde cámara o galería, y la registra en la base de datos
  Future<void> subirFoto(ImageSource source) async {
    try {
      if (jardinId == null) {
        debugPrint('Error: jardinId es null');
        return;
      }

      final picker = ImagePicker();

      // Abre cámara o galería según el origen indicado
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Comprime la imagen
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

      // Se genera un path único para la imagen usando UUID
      final uuid = const Uuid().v4();
      final path = '${user.id}/$jardinId/$uuid.jpg';

      final storage = Supabase.instance.client.storage.from('progresoplantas');

      // Sube la imagen al storage (tratamiento distinto para web y móvil)
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await storage.uploadBinary(path, bytes);
      } else {
        final file = File(pickedFile.path);
        await storage.upload(path, file);
      }

      // Inserta referencia de la imagen en la tabla de base de datos
      await Supabase.instance.client.from('imagenes_progreso').insert({
        'id_jardin': jardinId,
        'imagen_url': path,
        'fecha_subida': DateTime.now().toIso8601String(),
      });

      // Espera un segundo para asegurar que la imagen esté disponible antes de recargar
      await Future.delayed(const Duration(seconds: 1));
      await cargarFotos(jardinId!); // Vuelve a cargar las fotos actualizadas
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
    }
  }

  /// Elimina una foto del bucket y también su registro en la base de datos
  Future<bool> eliminarFoto(String path) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final storage = Supabase.instance.client.storage.from('progresoplantas');

      // Elimina la imagen del almacenamiento
      await storage.remove([path]);

      // Borra también el registro en la tabla `imagenes_progreso`
      await Supabase.instance.client
          .from('imagenes_progreso')
          .delete()
          .eq('imagen_url', path);

      await cargarFotos(jardinId!); // Recarga la lista de fotos
      return true;
    } catch (e) {
      debugPrint('Error al eliminar imagen: $e');
      return false;
    }
  }

  /// Agrega una foto directamente desde una ruta local, útil para importar fotos sin usar el picker
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

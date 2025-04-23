class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String fotoPerfil;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fotoPerfil,
  });

  // Método para crear un Usuario a partir de un Map (como el que viene de la base de datos)
  factory Usuario.fromMap(Map<String, dynamic> data) {
    return Usuario(
      id: data['id'],
      nombre: data['nombre'],
      email: data['email'],
      fotoPerfil: data['foto_perfil'] ?? '',
    );
  }

  // Convertir Usuario a un Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'foto_perfil': fotoPerfil,
    };
  }
}

class Usuario {
  final int id;
  final String idAuth;
  final String nombre;
  final String email;
  final String telefono;
  final String? fotoPerfil;

  Usuario({
    required this.id,
    required this.idAuth,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.fotoPerfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      idAuth: json['id_auth'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      fotoPerfil: json['foto_perfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_auth': idAuth,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'foto_perfil': fotoPerfil,
    };
  }
}

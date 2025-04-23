class Plant {
  final String id;
  final String nombre;
  final String nombreCientifico;
  final String descripcion;
  final List<String> imagenes;
  final String imagenPrincipal;
  final String riego;
  final String luz;
  final String temperatura;
  final String humedad;
  final String tipoSustrato;
  final String frecuenciaAbono;
  final String plagasComunes;
  final String cuidadosEspeciales;
  final String toxicidad;
  final String floracion;
  final String usoRecomendado;

  Plant({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.descripcion,
    required this.imagenes,
    required this.imagenPrincipal,
    required this.riego,
    required this.luz,
    required this.temperatura,
    required this.humedad,
    required this.tipoSustrato,
    required this.frecuenciaAbono,
    required this.plagasComunes,
    required this.cuidadosEspeciales,
    required this.toxicidad,
    required this.floracion,
    required this.usoRecomendado,
  });

  // Método para mapear todos los campos
 factory Plant.fromMap(Map<String, dynamic> map) {
  return Plant(
    id: map['id'],
    nombre: map['nombre'],
    nombreCientifico: map['nombre_cientifico'],
    descripcion: map['descripcion'] ?? 'Descripción no disponible',
    imagenes: List<String>.from(map['imagenes'] ?? []),
    imagenPrincipal: map['imagen_principal'] ?? '',
    riego: map['riego'] ?? 'Riego no disponible',
    luz: map['luz'] ?? 'Luz no disponible',
    temperatura: map['temperatura'] ?? 'Temperatura no disponible',
    humedad: map['humedad'] ?? 'Humedad no disponible',
    tipoSustrato: map['tipo_sustrato'] ?? 'Tipo de sustrato no disponible',
    frecuenciaAbono: map['frecuencia_abono'] ?? 'Frecuencia de abono no disponible',
    plagasComunes: map['plagas_comunes'] ?? 'Plagas comunes no disponibles',
    cuidadosEspeciales: map['cuidados_especiales'] ?? 'Cuidados especiales no disponibles',
    toxicidad: map['toxicidad'] ?? 'Toxicidad no disponible',
    floracion: map['floracion'] ?? 'Floración no disponible',
    usoRecomendado: map['uso_recomendado'] ?? 'Uso recomendado no disponible',
  );

}

  // Para búsquedas, puedes usar esta función si no necesitas todos los campos
  factory Plant.fromSearchMap(Map<String, dynamic> map) {
  return Plant(
    id: map['id'],
    nombre: map['nombre'],
    nombreCientifico: map['nombre_cientifico'],
    descripcion: map['descripcion'] ?? 'Descripción no disponible',
    imagenes: List<String>.from(map['imagenes'] ?? []),
    imagenPrincipal: map['imagen_principal'] ?? '',
    riego: map['riego'] ?? 'Riego no disponible',
    luz: map['luz'] ?? 'Luz no disponible',
    temperatura: map['temperatura'] ?? 'Temperatura no disponible',
    humedad: map['humedad'] ?? 'Humedad no disponible',
    tipoSustrato: map['tipo_sustrato'] ?? 'Tipo de sustrato no disponible',
    frecuenciaAbono: map['frecuencia_abono'] ?? 'Frecuencia de abono no disponible',
    plagasComunes: map['plagas_comunes'] ?? 'Plagas comunes no disponibles',
    cuidadosEspeciales: map['cuidados_especiales'] ?? 'Cuidados especiales no disponibles',
    toxicidad: map['toxicidad'] ?? 'Toxicidad no disponible',
    floracion: map['floracion'] ?? 'Floración no disponible',
    usoRecomendado: map['uso_recomendado'] ?? 'Uso recomendado no disponible',
  );
}
}

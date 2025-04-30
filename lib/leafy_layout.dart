import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/General/auth_provider.dart'; // Importa el provider de autenticación

// Layout base reutilizable para toda la app web
class LeafyLayout extends StatelessWidget {
  final Widget child; // Contenido que se renderiza dentro del layout

  const LeafyLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context); // Accede a la sesión actual

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4DC), // Fondo general del layout
      body: Column(
        children: [
          // HEADER / NAVBAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFD7EAC8), // Color verde claro
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.green), // Icono de Leafy
                const SizedBox(width: 8),
                const Text(
                  "Leafy",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(), // Empuja los botones a la derecha

                // Muestra navegación solo si hay sesión iniciada
                if (auth.session != null) ...[
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/search'),
                    child: const Text("Buscar"),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/calendar'),
                    child: const Text("Calendario"),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/profile'),
                    child: const Text("Perfil"),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/misplantas'),
                    child: const Text("Mis Plantas"),
                  ),
                  const SizedBox(width: 16),
                  // Ícono de perfil
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/profile'),
                    icon: const Icon(Icons.person),
                  ),
                ],
              ],
            ),
          ),

          // CONTENIDO PRINCIPAL
          Expanded(child: child),

          // FOOTER
          Container(
            width: double.infinity,
            color: const Color(0xFFD7EAC8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Secciones agrupadas en columnas usando Wrap (responsive)
                Wrap(
                  spacing: 40,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    // Sección "Leafy"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Leafy",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Sobre nosotros"),
                        Text("Contacto"),
                        Text("FAQ"),
                      ],
                    ),
                    // Sección "Legal"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Legal",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Política de privacidad"),
                        Text("Términos y condiciones"),
                        Text("Licencia de uso"),
                      ],
                    ),
                    // Sección "Síguenos"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Síguenos",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("🌿 Instagram"),
                        Text("📘 Facebook"),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Derechos de autor
                const Text(
                  "© 2025 Leafy. Todos los derechos reservados.",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

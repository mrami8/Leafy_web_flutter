import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/General/auth_provider.dart';

class LeafyLayout extends StatelessWidget {
  final Widget child;

  const LeafyLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4DC),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Menos espacio arriba y abajo
            color: const Color(0xFFD7EAC8),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "Leafy",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
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
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/profile'),
                    icon: const Icon(Icons.person),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: child),
          Container(
            width: double.infinity,
            color: const Color(0xFFD7EAC8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Menos espacio
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 40,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
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

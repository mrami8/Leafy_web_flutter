import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Profile/user_profile_provider.dart';
import 'package:leafy_app_flutter/providers/General/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'package:leafy_app_flutter/screens/LoginScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return LeafyLayout(
      child: userProfileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "LEAFY",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userProfileProvider.fotoPerfil.isNotEmpty
                          ? NetworkImage(userProfileProvider.fotoPerfil)
                          : null,
                      backgroundColor: const Color(0xFFD6E8C4),
                      child: userProfileProvider.fotoPerfil.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfileProvider.username.isNotEmpty
                          ? userProfileProvider.username
                          : "Sin nombre",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProfileProvider.email.isNotEmpty
                          ? userProfileProvider.email
                          : "Sin email",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6E8C4),
                        foregroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    child: const Text("Buscar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/calendar'),
                    child: const Text("Calendario"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text("Perfil"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/misplantas'),
                    child: const Text("Mis Plantas"),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Wrap(
                  spacing: 40,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FooterColumn(title: "Leafy", items: ["Sobre nosotros", "Contacto", "FAQ"]),
                    _FooterColumn(title: "Legal", items: ["Política de privacidad", "Términos"]),
                    _FooterColumn(title: "Síguenos", items: ["🌿", "📸", "📘"]),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "© 2025 Leafy",
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

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => Text(item)).toList(),
      ],
    );
  }
}

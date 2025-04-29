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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: NetworkImage(
                                "https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1350&q=80",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 24),
                              CircleAvatar(
                                radius: 90,
                                backgroundImage:
                                    userProfileProvider.fotoPerfil.isNotEmpty
                                        ? NetworkImage(
                                            userProfileProvider.fotoPerfil)
                                        : null,
                                backgroundColor: const Color(0xFFD6E8C4),
                                child: userProfileProvider.fotoPerfil.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 90, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userProfileProvider.username.isNotEmpty
                                          ? userProfileProvider.username
                                          : "Sin nombre",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      userProfileProvider.email.isNotEmpty
                                          ? userProfileProvider.email
                                          : "Sin email",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Sección de información personal falsa
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F7E8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Información personal",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text("📍 Ubicación: Sevilla, España"),
                          Text("🎂 Fecha de nacimiento: 22 de octubre de 1989"),
                          Text("🧬 Intereses: Ecología urbana, botánica exótica, acuaponía doméstica"),
                          Text("📚 Profesión: Arquitecta paisajista"),
                          Text(
                              "💬 Biografía: Entusiasta de los ecosistemas urbanos. "
                              "Creo espacios verdes sostenibles que mezclan diseño moderno y naturaleza viva."),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditProfileScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6E8C4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 60,
                  runSpacing: 20,
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
                        Text("Blog"),
                        Text("Comunidad"),
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
                        Text("Cookies"),
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
                        Text("🐦 Twitter"),
                        Text("🎥 YouTube"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Extras",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Lorem ipsum dolor sit amet."),
                        Text("Consectetur adipiscing elit."),
                        Text("Integer nec odio. Praesent libero."),
                        Text("Sed cursus ante dapibus diam."),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout base con estructura y estilos de Leafy
import 'package:leafy_app_flutter/providers/General/auth_provider.dart'; // Provider de autenticación

// Pantalla de registro de usuario
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para capturar el texto de los campos
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(); // Controlador para el teléfono

    return LeafyLayout(
      showSearchBar: false, // No mostramos barra de búsqueda en esta pantalla
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            Image.asset('assets/FondoPantalla.jpg', fit: BoxFit.cover),
            // Capa de oscurecimiento semitransparente
            Container(color: Colors.black.withOpacity(0.2)),

            // Contenido centrado
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Fondo blanco semitransparente
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono superior y título
                      const Icon(
                        Icons.person_add,
                        size: 48,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5B2F),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campo de nombre completo
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre completo",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo de correo electrónico
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Correo electrónico",
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo de teléfono
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Teléfono",
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo de contraseña
                      TextField(
                        controller: passwordController,
                        obscureText: true, // Oculta el texto para seguridad
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de registro
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final phone = phoneController.text.trim(); // Obtenemos el teléfono

                            if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
                              // Validación: todos los campos son obligatorios
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Por favor, completa todos los campos.",
                                  ),
                                ),
                              );
                              return;
                            }

                            // Llamamos al provider para registrar el usuario
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final success = await authProvider.register(
                              email,
                              password,
                              name,
                              phone, // Pasamos el teléfono al registrar
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Registro exitoso")),
                              );
                              Navigator.pushReplacementNamed(context, '/'); // Redirigir al login
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error al registrarse")),
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Registrarse"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Enlace para ir a la pantalla de login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿Ya tienes cuenta? "),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/'),
                            child: const Text(
                              "Inicia sesión",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

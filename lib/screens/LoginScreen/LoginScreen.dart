import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout general con estilo de la app
import 'package:leafy_app_flutter/providers/General/auth_provider.dart'; // Provider de autenticación

// Pantalla de inicio de sesión
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores de texto para recoger email y contraseña
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return LeafyLayout(
      showSearchBar: false, // Ocultamos la barra de búsqueda en esta pantalla
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo a pantalla completa
            Image.asset('assets/FondoPantalla.jpg', fit: BoxFit.cover),
            // Capa oscura semitransparente sobre la imagen
            Container(color: Colors.black.withOpacity(0.25)),
            // Contenedor principal centrado
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ), // Ancho máximo
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.92,
                    ), // Fondo semitransparente
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado con icono y texto
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 28,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Iniciar sesión",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Campo de correo electrónico
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Correo electrónico",
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de contraseña
                      TextField(
                        controller: passwordController,
                        obscureText: true, // Oculta el texto para seguridad
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón para iniciar sesión
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.green[700], // Color de Leafy
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          // Obtención y validación de datos
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Por favor, completa todos los campos.",
                                ),
                              ),
                            );
                            return;
                          }

                          // Llamamos al provider para iniciar sesión
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final success = await authProvider.login(
                            email,
                            password,
                          );

                          if (success && authProvider.session != null) {
                            // Si el login es exitoso, redirige a la pantalla principal (ej: /search)
                            Navigator.pushNamed(context, '/search');
                          } else {
                            // Si falla, muestra error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Las credenciales son incorrectas.",
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Entrar",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Enlace para ir al registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No tienes cuenta? "),
                          GestureDetector(
                            onTap:
                                () => Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              "Regístrate",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
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

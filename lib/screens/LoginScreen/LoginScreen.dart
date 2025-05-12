import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout general con estilo de la app
import 'package:leafy_app_flutter/providers/General/auth_provider.dart'; // Provider de autenticación

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailOrPhoneController = TextEditingController();
    final passwordController = TextEditingController();

    return LeafyLayout(
      showSearchBar: false, // Ocultamos la barra de búsqueda en esta pantalla
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/FondoPantalla.jpg', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.25)),
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
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

                      TextField(
                        controller: emailOrPhoneController,
                        decoration: const InputDecoration(
                          labelText: "Correo o Teléfono",
                          prefixIcon: Icon(Icons.mail_lock_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
  final emailOrPhone = emailOrPhoneController.text.trim();
  final password = passwordController.text.trim();

  if (emailOrPhone.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Por favor, completa todos los campos."),
      ),
    );
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  bool success = false;

  // Verificar si es un correo o teléfono
  if (emailOrPhone.contains('@')) {
    // Si contiene un '@', asumimos que es un correo
    success = await authProvider.login(emailOrPhone, password);
  } else {
    // Si no contiene '@', asumimos que es un teléfono
    success = await authProvider.loginWithPhone(emailOrPhone, password);
  }

  if (success && authProvider.session != null) {
    Navigator.pushNamed(context, '/search');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Las credenciales son incorrectas."),
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No tienes cuenta? "),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
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

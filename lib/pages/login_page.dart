import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import absoluto para evitar erro de caminho
import 'package:mealprep_lite/services/prefs_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final prefs = context.read<PrefsService>();
      
      // Salva os dados iniciais
      await prefs.setUserName(_nameController.text.trim());
      await prefs.setUserEmail(_emailController.text.trim());
      
      // Marca como logado para não pedir de novo
      await prefs.setLoggedIn(true);

      if (mounted) {
        // Vai para a Home e remove o histórico de volta
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_person, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Bem-vindo!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Insira seus dados para entrar.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    
                    // Campo Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty 
                          ? 'Por favor, digite seu nome' 
                          : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || !value.contains('@') 
                          ? 'Digite um email válido' 
                          : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botão Entrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('ENTRAR'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
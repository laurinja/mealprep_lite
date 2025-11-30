import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  
  // Variável para controlar se é Login ou Cadastro
  bool _isLogin = true; 

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final prefs = context.read<PrefsService>();
      
      // Salva os dados (seja login ou cadastro, no modo local a lógica é a mesma: salvar)
      await prefs.setUserName(_nameController.text.trim());
      await prefs.setUserEmail(_emailController.text.trim());
      await prefs.setLoggedIn(true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Bem-vindo de volta!' : 'Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          )
        );
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
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
                    Icon(
                      _isLogin ? Icons.lock_open : Icons.person_add, 
                      size: 64, 
                      color: Colors.green
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Insira seus dados para entrar.' : 'Preencha os dados para começar.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    
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
                    
                    // Botão Principal (Entrar ou Cadastrar)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: Text(_isLogin ? 'ENTRAR' : 'CADASTRAR'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botão de Alternância
                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(
                        _isLogin 
                          ? 'Não tem conta? Crie uma agora' 
                          : 'Já tem conta? Faça login',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
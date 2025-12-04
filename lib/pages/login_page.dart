import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealprep_lite/services/prefs_service.dart';
import '../features/meal/presentation/controllers/meal_controller.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; 
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = context.read<PrefsService>();
    final mealController = context.read<MealController>();
    
    final inputEmail = _emailController.text.trim();
    final inputPass = _passwordController.text.trim();
    final inputName = _nameController.text.trim();

    bool success = false;
    String message = '';

    if (_isLogin) {
      // --- LOGIN ---
      try {
        final userData = await mealController.authenticate(inputEmail, inputPass);
        
        if (userData != null) {
          await prefs.setUserName(userData['name']);
          await prefs.setUserEmail(userData['email']);
          await prefs.setUserPassword(userData['password']);
          await prefs.setLoggedIn(true);
          success = true;
          message = 'Bem-vindo de volta, ${userData['name']}!';
        } else {
          message = 'Email ou senha incorretos.';
        }
      } catch (e) {
        message = 'Erro de conexão: $e';
      }
    } else {
      // --- CADASTRO ---
      try {
        final registered = await mealController.register(inputName, inputEmail, inputPass);
        if (registered) {
          await prefs.setUserName(inputName);
          await prefs.setUserEmail(inputEmail);
          await prefs.setUserPassword(inputPass);
          await prefs.setLoggedIn(true);
          success = true;
          message = 'Conta criada com sucesso!';
        } else {
          message = 'Este email já está cadastrado.';
        }
      } catch (e) {
        message = 'Erro ao criar conta.';
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: success ? Colors.green : Colors.red),
      );
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isLogin ? Icons.lock_open : Icons.person_add, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(_isLogin ? 'Login Online' : 'Criar Conta', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                      validator: (v) => !v!.contains('@') ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- CAMPO DE SENHA ATUALIZADO ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha', 
                        prefixIcon: const Icon(Icons.lock), 
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), 
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword)
                        ),
                        helperText: '6-15 caracteres (letras e números)',
                        helperMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Senha obrigatória';
                        }
                        if (value.length < 6) {
                          return 'Mínimo de 6 caracteres';
                        }
                        if (value.length > 15) {
                          return 'Máximo de 15 caracteres';
                        }
                        // Regex: Apenas letras (a-z, A-Z) e números (0-9)
                        final alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');
                        if (!alphaNumeric.hasMatch(value)) {
                          return 'Apenas letras e números (sem símbolos)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isLogin ? 'ENTRAR' : 'CADASTRAR'),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(_isLogin ? 'Criar uma conta' : 'Já tenho conta'),
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
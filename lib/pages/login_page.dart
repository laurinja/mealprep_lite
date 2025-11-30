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
  final _passwordController = TextEditingController(); // Novo Controller
  
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; 
  bool _obscurePassword = true; // Controla visibilidade da senha

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = context.read<PrefsService>();
    final inputEmail = _emailController.text.trim();
    final inputPass = _passwordController.text.trim();
    final inputName = _nameController.text.trim();

    if (_isLogin) {
      // --- MODO LOGIN (Validar) ---
      final storedEmail = prefs.userEmail;
      final storedPass = prefs.userPassword;

      // Verifica se existe conta
      if (storedEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma conta encontrada. Crie uma conta primeiro.'), backgroundColor: Colors.red),
        );
        return;
      }

      // Valida credenciais
      if (inputEmail == storedEmail && inputPass == storedPass) {
        await prefs.setLoggedIn(true);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bem-vindo de volta!'), backgroundColor: Colors.green),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha incorretos.'), backgroundColor: Colors.red),
        );
      }

    } else {
      // --- MODO CRIAR CONTA (Salvar) ---
      await prefs.setUserName(inputName);
      await prefs.setUserEmail(inputEmail);
      await prefs.setUserPassword(inputPass); // Salva a senha
      await prefs.setLoggedIn(true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset(); // Limpa erros ao trocar
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
                      _isLogin ? 'Entre com seu email e senha.' : 'Preencha os dados para começar.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    
                    // Campo Nome (Apenas no cadastro)
                    if (!_isLogin) ...[
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
                    ],
                    
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
                    const SizedBox(height: 16),

                    // Campo Senha (NOVO)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 4 
                          ? 'A senha deve ter pelo menos 4 caracteres' 
                          : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botão Principal
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
                    
                    // Alternar Login/Cadastro
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
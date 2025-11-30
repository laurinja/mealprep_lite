import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/presentation/dialogs/meal_actions_dialog.dart';
import '../services/prefs_service.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _preferenciasSelecionadas = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];
  
  // Estado local para o Perfil (Drawer)
  String? _userPhotoPath;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados salvos no SharedPreferences para exibir no Drawer
  void _loadUserData() {
    final prefs = context.read<PrefsService>();
    setState(() {
      _userPhotoPath = prefs.userPhotoPath;
      _userName = prefs.userName;
      _userEmail = prefs.userEmail;
    });
  }

  // --- Função 1: Editar Foto (Avatar) ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final dir = await getApplicationDocumentsDirectory();
      final name = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = p.join(dir.path, name);

      // Comprime a imagem para não ocupar muito espaço
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        minWidth: 512, 
        minHeight: 512, 
        quality: 80,
      );

      if (result != null) {
        await context.read<PrefsService>().setUserPhotoPath(result.path);
        _loadUserData(); // Atualiza a UI
      }
    }
  }

  // --- Função 2: Criar/Editar Conta (Nome e Email) ---
  void _editProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome', 
                hintText: 'Como quer ser chamado?'
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email', 
                hintText: 'seu@email.com'
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancelar')
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final prefs = context.read<PrefsService>();
                await prefs.setUserName(nameCtrl.text.trim());
                await prefs.setUserEmail(emailCtrl.text.trim());
                
                _loadUserData(); // Atualiza a tela
                if (mounted) Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // --- Funções de Refeição ---

  void _gerarPlano() {
    context.read<MealController>().gerarPlano(_preferenciasSelecionadas);
  }

  void _showActionsDialog(Refeicao refeicao) {
    showDialog(
      context: context,
      builder: (context) => MealActionsDialog(
        onEdit: () => _handleSwap(refeicao),
        onRemove: () => _handleRemove(refeicao),
      ),
    );
  }

  Future<void> _handleSwap(Refeicao refeicao) async {
    // Feedback imediato
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buscando substituição...'),
        duration: Duration(milliseconds: 1000),
      ),
    );

    // Chama o controller e aguarda o nome da nova refeição
    final novoNome = await context.read<MealController>().trocarRefeicao(refeicao);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    if (novoNome != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trocado por: $novoNome'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma outra opção disponível para troca.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleRemove(Refeicao refeicao) {
    context.read<MealController>().removerRefeicao(refeicao.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refeição removida.')),
    );
  }
  
  void _showIngredients(Refeicao refeicao) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(refeicao.nome, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Ingredientes:', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (refeicao.ingredienteIds.isEmpty)
              const Text('Nenhum ingrediente listado.', style: TextStyle(color: Colors.grey))
            else
              ...refeicao.ingredienteIds.map((ing) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ing)),
                  ],
                ),
              )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<MealController>(
      builder: (context, mealController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MealPrep Lite'),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
          // Drawer atualizado com as funções de perfil
          endDrawer: AppDrawer(
            userPhotoPath: _userPhotoPath,
            userName: _userName,
            userEmail: _userEmail,
            onEditAvatarPressed: _pickImage,
            onEditProfilePressed: _editProfileDialog,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Cartão de Filtros ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferências', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _todasPreferencias.map((pref) {
                          final isSelected = _preferenciasSelecionadas.contains(pref);
                          return FilterChip(
                            label: Text(pref),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _preferenciasSelecionadas.add(pref);
                                } else {
                                  _preferenciasSelecionadas.remove(pref);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // --- Botão Principal ---
              ElevatedButton.icon(
                onPressed: _gerarPlano,
                icon: const Icon(Icons.restaurant_menu),
                label: Text(
                  mealController.planoSemanal.isEmpty 
                      ? 'Gerar Cardápio' 
                      : 'Gerar Novo Cardápio'
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),

              // --- Lista de Refeições ---
              if (mealController.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (mealController.planoSemanal.isNotEmpty)
                ...mealController.planoSemanal.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _showIngredients(r),
                    onLongPress: () => _showActionsDialog(r),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          child: Text(
                            r.tipo[0], 
                            style: TextStyle(color: theme.colorScheme.primary)
                          )
                        ),
                        title: Text(
                          r.nome, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.tipo),
                            if (r.tagIds.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  r.tagIds.join(', '), 
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                ))
              else
                 const Center(
                   child: Padding(
                     padding: EdgeInsets.all(32.0),
                     child: Text(
                       'Seu plano está vazio.\nSelecione preferências e toque em Gerar.',
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.grey)
                     ),
                   )
                 ),
            ],
          ),
        );
      },
    );
  }
}
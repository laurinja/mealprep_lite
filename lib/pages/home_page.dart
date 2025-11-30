import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Import absoluto para evitar erros de caminho
import 'package:mealprep_lite/services/prefs_service.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/presentation/dialogs/meal_actions_dialog.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _preferenciasSelecionadas = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];
  
  // Estado local para exibir no Drawer
  String? _userPhotoPath;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega dados do usuário (Foto, Nome, Email)
  void _loadUserData() {
    // listen: false pois estamos fora do build
    final prefs = Provider.of<PrefsService>(context, listen: false);
    setState(() {
      _userPhotoPath = prefs.userPhotoPath;
      _userName = prefs.userName;
      _userEmail = prefs.userEmail;
    });
  }

  // --- Função 1: Alterar Foto de Perfil ---
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 600
      );
      
      if (pickedFile != null) {
        final dir = await getApplicationDocumentsDirectory();
        final name = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final targetPath = p.join(dir.path, name);

        // Comprime a imagem
        final XFile? result = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          targetPath,
          minWidth: 500, 
          minHeight: 500, 
          quality: 85,
        );

        if (result != null) {
          await Provider.of<PrefsService>(context, listen: false).setUserPhotoPath(result.path);
          _loadUserData(); // Atualiza a tela
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto de perfil atualizada!'))
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  // --- Função 2: Editar Perfil (Nome editável, Email bloqueado) ---
  void _editProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome Editável
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome', 
                hintText: 'Seu nome'
              ),
            ),
            const SizedBox(height: 16),
            
            // Email Bloqueado (Read-only)
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email', 
                filled: true, 
                fillColor: Colors.black12, // Fundo cinza
                prefixIcon: Icon(Icons.lock, size: 16, color: Colors.grey),
              ),
              readOnly: true, 
              enabled: false, 
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'O email não pode ser alterado.', 
                style: TextStyle(fontSize: 12, color: Colors.grey)
              ),
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
                // Salva apenas o nome
                await prefs.setUserName(nameCtrl.text.trim());
                
                _loadUserData(); 
                if (mounted) Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome atualizado com sucesso!'))
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // --- Funções de Gestão de Refeições ---

  void _gerarPlano() {
    context.read<MealController>().gerarPlano(_preferenciasSelecionadas);
  }

  void _showActionsDialog(Refeicao r) {
    showDialog(
      context: context, 
      builder: (_) => MealActionsDialog(
        onEdit: () => _handleSwap(r),
        onRemove: () => _handleRemove(r),
      )
    );
  }

  Future<void> _handleSwap(Refeicao r) async {
    // Feedback de carregamento
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buscando substituição...'), duration: Duration(milliseconds: 1000))
    );

    final novoNome = await context.read<MealController>().trocarRefeicao(r);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (novoNome != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trocado por: $novoNome'), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem outras opções disponíveis para troca.'), 
          backgroundColor: Colors.orange
        )
      );
    }
  }

  void _handleRemove(Refeicao r) {
    context.read<MealController>().removerRefeicao(r.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refeição removida.'))
    );
  }

  void _showIngredients(Refeicao r) {
    showModalBottomSheet(
      context: context, 
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.nome, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Ingredientes:', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (r.ingredienteIds.isEmpty) 
              const Text('Nenhum ingrediente listado.', style: TextStyle(color: Colors.grey)) 
            else 
              ...r.ingredienteIds.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.green), 
                    const SizedBox(width: 8), 
                    Expanded(child: Text(i))
                  ]
                ),
              )),
            const SizedBox(height: 20),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<MealController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MealPrep Lite'),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
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
              // --- Filtros ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preferências', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _todasPreferencias.map((pref) => FilterChip(
                          label: Text(pref),
                          selected: _preferenciasSelecionadas.contains(pref),
                          onSelected: (val) => setState(() => val ? _preferenciasSelecionadas.add(pref) : _preferenciasSelecionadas.remove(pref)),
                        )).toList(),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Botão Gerar ---
              ElevatedButton.icon(
                onPressed: _gerarPlano,
                icon: const Icon(Icons.restaurant_menu),
                label: Text(controller.planoSemanal.isEmpty ? 'Gerar Cardápio' : 'Gerar Novo Cardápio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, 
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.all(16)
                ),
              ),
              const SizedBox(height: 20),

              // --- Lista de Refeições ---
              if (controller.isLoading) 
                const Center(child: CircularProgressIndicator())
              else if (controller.planoSemanal.isNotEmpty)
                ...controller.planoSemanal.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _showIngredients(r),
                    onLongPress: () => _showActionsDialog(r),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        // FOTO DO PRATO COM FALLBACK
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: r.imageUrl != null
                                ? Image.network(
                                    r.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) {
                                      // Se falhar (sem internet), mostra a inicial
                                      return Container(
                                        color: theme.colorScheme.primary.withOpacity(0.2),
                                        alignment: Alignment.center,
                                        child: Text(
                                          r.tipo[0],
                                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                      );
                                    },
                                  )
                                : Container(
                                    // Se não tiver URL, mostra inicial
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      r.tipo[0],
                                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(r.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.tipo),
                            if (r.tagIds.isNotEmpty)
                              Text(r.tagIds.join(', '), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                    child: Text('Seu plano está vazio.\nSelecione preferências e gere um cardápio!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  )
                ),
            ],
          ),
        );
      },
    );
  }
}
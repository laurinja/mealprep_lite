import 'package:flutter/material.dart';
import '../../domain/entities/refeicao.dart';
import '../../../../core/constants/meal_types.dart';

class MealFormDialog extends StatefulWidget {
  final Refeicao? meal;
  final Function(Refeicao) onSave;

  const MealFormDialog({
    super.key,
    this.meal,
    required this.onSave,
  });

  @override
  State<MealFormDialog> createState() => _MealFormDialogState();
}

class _MealFormDialogState extends State<MealFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _imgUrlController;
  late TextEditingController _ingredientsController;
  
  String _selectedType = MealTypes.breakfast;
  final List<String> _selectedTags = [];
  
  final List<String> _availableTags = ['Rápido', 'Saudável', 'Vegetariano', 'Vegano', 'Sem Glúten', 'Low Carb'];

  @override
  void initState() {
    super.initState();
    final m = widget.meal;
    
    _nameController = TextEditingController(text: m?.nome ?? '');
    _imgUrlController = TextEditingController(text: m?.imageUrl ?? '');
    
    _ingredientsController = TextEditingController(text: m?.ingredienteIds.join('\n') ?? '');
    
    _selectedType = m?.tipo ?? MealTypes.breakfast;
    
    if (m != null) {
      _selectedTags.addAll(m.tagIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imgUrlController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final ingredientsList = _ingredientsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final newMeal = Refeicao(
      id: widget.meal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nameController.text.trim(),
      tipo: _selectedType,
      tagIds: _selectedTags,
      ingredienteIds: ingredientsList,
      imageUrl: _imgUrlController.text.trim().isEmpty ? null : _imgUrlController.text.trim(),
    );

    widget.onSave(newMeal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.meal != null ? 'Editar Refeição' : 'Nova Refeição'),
      scrollable: true,
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Prato', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                items: MealTypes.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(MealTypes.translate(t)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),

              const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes (um por linha)', 
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imgUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem (Opcional)', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
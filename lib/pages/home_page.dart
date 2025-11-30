import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mealprep_lite/services/prefs_service.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _preferencias = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];
  
  // Dados do usuário
  String? _userPhotoPath;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Segunda a Sábado
    _loadUserData();
  }

  void _loadUserData() {
    final prefs = Provider.of<PrefsService>(context, listen: false);
    setState(() {
      _userPhotoPath = prefs.userPhotoPath;
      _userName = prefs.userName;
      _userEmail = prefs.userEmail;
    });
  }

  // (Mantenha aqui as funções _pickImage e _editProfileDialog do código anterior)
  // ... [CÓDIGO DE PERFIL IDÊNTICO AO ANTERIOR] ...
  // Para economizar espaço na resposta, assuma que _pickImage e _editProfileDialog
  // estão aqui exatamente como antes.

  Future<void> _pickImage() async { /* ... Copiar do anterior ... */ }
  void _editProfileDialog() { /* ... Copiar do anterior ... */ }

  // Nova função para gerar a semana toda
  void _gerarSemana() {
    context.read<MealController>().generateFullWeek(_preferencias);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = MealController.daysOfWeek; // ['Segunda', 'Terça'...]

    return Consumer<MealController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MealPrep Semanal'),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: theme.colorScheme.primary,
              tabs: days.map((day) => Tab(text: day)).toList(),
            ),
          ),
          endDrawer: AppDrawer(
            userPhotoPath: _userPhotoPath,
            userName: _userName,
            userEmail: _userEmail,
            onEditAvatarPressed: _pickImage,
            onEditProfilePressed: _editProfileDialog,
          ),
          body: Column(
            children: [
              // Barra de Ações Rápidas (Preferências + Botão Gerar)
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _todasPreferencias.map((pref) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(pref),
                            selected: _preferencias.contains(pref),
                            onSelected: (val) => setState(() => val ? _preferencias.add(pref) : _preferencias.remove(pref)),
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _gerarSemana,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Gerar Semana Completa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Conteúdo das Abas (Dias da Semana)
              Expanded(
                child: controller.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: days.map((day) {
                        final mealsForDay = controller.weeklyPlan[day] ?? {};
                        return _buildDayView(day, mealsForDay);
                      }).toList(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayView(String day, Map<String, Refeicao> meals) {
    final types = MealController.mealTypes; // Café, Almoço, Jantar

    return ListView(
      padding: const EdgeInsets.all(16),
      children: types.map((type) {
        final meal = meals[type];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do Slot (Ex: Almoço)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              
              // Conteúdo do Slot
              if (meal != null)
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: meal.imageUrl != null 
                        ? Image.network(meal.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                        : Container(color: Colors.green, width: 50, height: 50, child: const Icon(Icons.restaurant, color: Colors.white)),
                  ),
                  title: Text(meal.nome),
                  subtitle: Text(meal.tagIds.join(', ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // Aqui você implementaria a troca individual
                      // context.read<MealController>().regenerateSlot(day, type);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use "Gerar Semana" para trocar tudo por enquanto.')));
                    },
                  ),
                )
              else
                ListTile(
                  title: const Text('Vazio', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gere a semana automaticamente acima!')));
                  },
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
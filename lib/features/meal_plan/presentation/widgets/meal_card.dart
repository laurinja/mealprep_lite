import 'package:flutter/material.dart';
import '../../domain/entities/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.tipo.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              meal.nome,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            if (meal.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: meal.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: theme.colorScheme.primary.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          side: BorderSide.none,
                        ))
                    .toList(),
              )
            ]
          ],
        ),
      ),
    );
  }
}
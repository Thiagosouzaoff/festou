import 'package:flutter/material.dart';
import 'package:festou/theme.dart';

class PartyTypeSelector extends StatelessWidget {
  final String selectedType;
  final int premiumDays;
  final bool canCreateFree;
  final Function(String) onTypeChanged;
  final Function(int) onDaysChanged;

  const PartyTypeSelector({
    super.key,
    required this.selectedType,
    required this.premiumDays,
    required this.canCreateFree,
    required this.onTypeChanged,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo de Festa', style: Theme.of(context).textTheme.titleMedium?.semiBold),
        const SizedBox(height: AppSpacing.sm),
        
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: canCreateFree ? () => onTypeChanged('free') : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedType == 'free' 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: selectedType == 'free' 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 32,
                        color: selectedType == 'free'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'FREE',
                        style: Theme.of(context).textTheme.titleMedium?.bold.copyWith(
                          color: selectedType == 'free'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '1 a cada 30 dias',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Expira em 2 dias',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      if (!canCreateFree)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            '✗ Indisponível',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => onTypeChanged('premium'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedType == 'premium' 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: selectedType == 'premium' 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 32,
                        color: selectedType == 'premium'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'PREMIUM',
                        style: Theme.of(context).textTheme.titleMedium?.bold.copyWith(
                          color: selectedType == 'premium'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'R\$ 2,06/dia',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Escolha a duração',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (selectedType == 'premium') ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Duração:', style: Theme.of(context).textTheme.titleSmall?.semiBold),
                    Text('$premiumDays dias', style: Theme.of(context).textTheme.titleSmall?.bold),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Slider(
                  value: premiumDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$premiumDays dias',
                  onChanged: (value) => onDaysChanged(value.toInt()),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      'R\$ ${(premiumDays * 2.06).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.bold.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

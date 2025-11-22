import 'package:flutter/material.dart';
import 'package:festou/theme.dart';

class FilterDialog extends StatefulWidget {
  final List<String> selectedStyles;
  final List<String> selectedCities;
  final double radiusKm;

  const FilterDialog({
    super.key,
    required this.selectedStyles,
    required this.selectedCities,
    required this.radiusKm,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<String> _selectedStyles;
  late List<String> _selectedCities;
  late double _radiusKm;

  static const List<String> _allStyles = [
    'Axé',
    'Bossa Nova',
    'Carimbó',
    'Choro',
    'Eletrônico',
    'Forró',
    'Frevo',
    'Funk Brasileiro',
    'Maracatu',
    'MPB',
    'Pagode',
    'Piseiro',
    'Samba',
    'Sertanejo',
    'Tecnobrega',
  ];

  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStyles = List.from(widget.selectedStyles);
    _selectedCities = List.from(widget.selectedCities);
    _radiusKm = widget.radiusKm;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _addCity() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty && !_selectedCities.contains(city)) {
      setState(() {
        _selectedCities.add(city);
        _cityController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune,
                      color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estilos Musicais',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.semiBold),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedStyles.length == _allStyles.length) {
                                _selectedStyles.clear();
                              } else {
                                _selectedStyles = List.from(_allStyles);
                              }
                            });
                          },
                          child: Text(
                            _selectedStyles.length == _allStyles.length
                                ? 'Desmarcar Todos'
                                : 'Selecionar Todos',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _allStyles.map((style) {
                        final isSelected = _selectedStyles.contains(style);
                        return FilterChip(
                          label: Text(style),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedStyles.add(style);
                              } else {
                                _selectedStyles.remove(style);
                              }
                            });
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Cidades',
                        style:
                            Theme.of(context).textTheme.titleMedium?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'Digite o nome da cidade',
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm)),
                              filled: false,
                            ),
                            onSubmitted: (_) => _addCity(),
                            obscureText: false,
                            onEditingComplete: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          onPressed: _addCity,
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 32,
                        ),
                      ],
                    ),
                    if (_selectedCities.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _selectedCities.map((city) {
                          return InputChip(
                            label: Text(city),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() => _selectedCities.remove(city));
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Text('Distância',
                        style:
                            Theme.of(context).textTheme.titleMedium?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _radiusKm,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            label: '${_radiusKm.toInt()} km',
                            onChanged: (value) =>
                                setState(() => _radiusKm = value),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '${_radiusKm.toInt()} km',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Festas dentro de ${_radiusKm.toInt()} km da sua localização',
                      style: Theme.of(context).textTheme.bodySmall?.withColor(
                            Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStyles.clear();
                          _selectedCities.clear();
                          _radiusKm = 25;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'styles': _selectedStyles,
                          'cities': _selectedCities,
                          'radius': _radiusKm,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

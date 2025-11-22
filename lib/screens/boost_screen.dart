import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festou/models/party_model.dart';
import 'package:festou/models/user_model.dart';
import 'package:festou/services/boost_service.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/theme.dart';

class BoostScreen extends StatefulWidget {
  final PartyModel party;

  const BoostScreen({super.key, required this.party});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();

  final List<String> _selectedGenders = [];
  int _minAge = 18;
  int _maxAge = 70;
  final List<String> _selectedCities = [];
  double _radiusKm = 25;
  final List<String> _selectedStyles = [];
  int _impressionPackages = 1;

  final List<String> _availableGenders = ['Homem', 'Mulher'];
  final List<String> _availableStyles = [
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
    'Tecnobrega'
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  double get _totalCost => _impressionPackages * 21.90;
  int get _totalImpressions => _impressionPackages * 1000;
  double get _impressionsPerDay => _totalImpressions / widget.party.premiumDays;

  void _addCity() {
    if (_cityController.text.trim().isNotEmpty &&
        !_selectedCities.contains(_cityController.text.trim())) {
      setState(() {
        _selectedCities.add(_cityController.text.trim());
        _cityController.clear();
      });
    }
  }

  Future<void> _processBoost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGenders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um gênero')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Turbinamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de impressões: $_totalImpressions'),
            Text(
                'Impressões por dia: ${_impressionsPerDay.toStringAsFixed(0)}'),
            Text('Duração: ${widget.party.premiumDays} dias'),
            const SizedBox(height: AppSpacing.md),
            Text('Valor total: R\$ ${_totalCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.bold),
            const SizedBox(height: AppSpacing.sm),
            const Text('Deseja prosseguir com o pagamento?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar Pagamento'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userService = Provider.of<UserService>(context, listen: false);
    final boostService = Provider.of<BoostService>(context, listen: false);
    final currentUser = userService.currentUser;

    if (currentUser == null) return;

    await boostService.createBoost(
      partyId: widget.party.id,
      userId: currentUser.id,
      party: widget.party,
      targetGenders: _selectedGenders,
      minAge: _minAge,
      maxAge: _maxAge,
      targetCities: _selectedCities,
      radiusKm: _radiusKm,
      targetStyles: _selectedStyles,
      totalImpressions: _totalImpressions,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Evento turbinado com sucesso! O anúncio já está ativo.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turbinar Evento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rocket_launch,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('Turbine seu evento',
                              style:
                                  Theme.of(context).textTheme.titleLarge?.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Alcance mais pessoas com anúncios direcionados! Seu evento aparecerá no feed e antes dos usuários entrarem em outras festas.',
                      style: Theme.of(context).textTheme.bodyMedium?.withColor(
                          Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Público-alvo',
                style: Theme.of(context).textTheme.titleMedium?.bold),
            const SizedBox(height: AppSpacing.md),
            Text('Gênero *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _availableGenders
                  .map((gender) => FilterChip(
                        label: Text(gender),
                        selected: _selectedGenders.contains(gender),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenders.add(gender);
                            } else {
                              _selectedGenders.remove(gender);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Faixa etária', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mínimo: $_minAge anos'),
                      Slider(
                        value: _minAge.toDouble(),
                        min: 18,
                        max: 70,
                        divisions: 52,
                        onChanged: (value) {
                          setState(() {
                            _minAge = value.toInt();
                            if (_minAge > _maxAge) _maxAge = _minAge;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Máximo: $_maxAge anos'),
                      Slider(
                        value: _maxAge.toDouble(),
                        min: 18,
                        max: 70,
                        divisions: 52,
                        onChanged: (value) {
                          setState(() {
                            _maxAge = value.toInt();
                            if (_maxAge < _minAge) _minAge = _maxAge;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Cidades', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'Digite uma cidade',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addCity(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: _addCity,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_selectedCities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: _selectedCities
                    .map((city) => Chip(
                          label: Text(city),
                          onDeleted: () =>
                              setState(() => _selectedCities.remove(city)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('Raio de distância: ${_radiusKm.toInt()} km',
                style: Theme.of(context).textTheme.labelLarge),
            Slider(
              value: _radiusKm,
              min: 5,
              max: 100,
              divisions: 19,
              label: '${_radiusKm.toInt()} km',
              onChanged: (value) => setState(() => _radiusKm = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Estilos musicais',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Deixe vazio para alcançar todos os estilos',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.withColor(Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _availableStyles
                  .map((style) => FilterChip(
                        label: Text(style),
                        selected: _selectedStyles.contains(style),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStyles.add(style);
                            } else {
                              _selectedStyles.remove(style);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text('Pacote de impressões',
                style: Theme.of(context).textTheme.titleMedium?.bold),
            const SizedBox(height: AppSpacing.sm),
            Text('R\$ 21,90 por 1.000 impressões',
                style: Theme.of(context).textTheme.bodyMedium?.withColor(
                    Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                IconButton.filled(
                  onPressed: _impressionPackages > 1
                      ? () => setState(() => _impressionPackages--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                          '$_impressionPackages ${_impressionPackages == 1 ? "pacote" : "pacotes"}',
                          style: Theme.of(context).textTheme.titleLarge?.bold),
                      Text('$_totalImpressions impressões',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () => setState(() => _impressionPackages++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Impressões por dia:',
                            style: Theme.of(context).textTheme.bodyLarge),
                        Text('${_impressionsPerDay.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyLarge?.bold),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duração:',
                            style: Theme.of(context).textTheme.bodyLarge),
                        Text('${widget.party.premiumDays} dias',
                            style: Theme.of(context).textTheme.bodyLarge?.bold),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Valor total:',
                            style:
                                Theme.of(context).textTheme.titleMedium?.bold),
                        Text('R\$ ${_totalCost.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.bold
                                .withColor(
                                    Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processBoost,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Color(0xFFF9EA73)),
                ),
                child: Text('Turbinar Agora',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: LightModeColors.lightPrimary)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

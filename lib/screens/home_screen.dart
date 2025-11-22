import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festou/services/party_service.dart';
import 'package:festou/services/boost_service.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/models/party_model.dart';
import 'package:festou/models/boost_model.dart';
import 'package:festou/widgets/party_card.dart';
import 'package:festou/widgets/filter_dialog.dart';
import 'package:festou/screens/party_details_screen.dart';
import 'package:festou/theme.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _selectedStyles = [];
  List<String> _selectedCities = [];
  double _radiusKm = 25;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  List<PartyModel> _getFilteredParties(PartyService service) {
    List<PartyModel> filtered = service.parties;

    if (_selectedStyles.isNotEmpty) {
      filtered = filtered.where((p) => _selectedStyles.contains(p.style)).toList();
    }

    if (_selectedCities.isNotEmpty) {
      filtered = filtered.where((p) => 
        _selectedCities.any((city) => 
          p.location.toLowerCase().contains(city.toLowerCase())
        )
      ).toList();
    }

    if (_currentPosition != null && _selectedCities.isEmpty) {
      filtered = filtered.where((p) {
        final distance = p.distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude);
        return distance <= _radiusKm;
      }).toList();

      filtered.sort((a, b) {
        final distA = a.distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude);
        final distB = b.distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude);
        return distA.compareTo(distB);
      });
    }

    return filtered;
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        selectedStyles: _selectedStyles,
        selectedCities: _selectedCities,
        radiusKm: _radiusKm,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedStyles = result['styles'] as List<String>;
        _selectedCities = result['cities'] as List<String>;
        _radiusKm = result['radius'] as double;
      });
    }
  }

  List<BoostModel> _getMatchingBoosts(BuildContext context, List<PartyModel> parties) {
    final boostService = Provider.of<BoostService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = userService.currentUser;
    
    if (currentUser == null) return [];
    
    final activeBoosts = boostService.getActiveBoosts();
    final partyIds = parties.map((p) => p.id).toSet();
    
    return activeBoosts.where((boost) {
      return partyIds.contains(boost.partyId) && boost.matchesUser(currentUser);
    }).toList()..sort((a, b) {
      final aPriority = (a.amountPaid / a.totalImpressions) * 1000000;
      final bPriority = (b.amountPaid / b.totalImpressions) * 1000000;
      return bPriority.compareTo(aPriority);
    });
  }

  @override
  Widget build(BuildContext context) {
    final partyService = context.watch<PartyService>();
    final filteredParties = _getFilteredParties(partyService);
    final matchingBoosts = _getMatchingBoosts(context, filteredParties);
    final boostedPartyIds = matchingBoosts.map((b) => b.partyId).toSet();
    final hasActiveFilters = _selectedStyles.isNotEmpty || _selectedCities.isNotEmpty || _radiusKm != 25;
    final filterCount = _selectedStyles.length + _selectedCities.length + (_radiusKm != 25 ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Festou', style: Theme.of(context).textTheme.headlineSmall?.bold),
        actions: [
          IconButton(
            icon: Icon(_isLoadingLocation ? Icons.location_searching : Icons.my_location, color: Theme.of(context).colorScheme.primary),
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: AppSpacing.paddingMd,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showFilterDialog,
                    icon: Icon(
                      Icons.tune,
                      color: hasActiveFilters 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      hasActiveFilters 
                        ? '$filterCount ${filterCount == 1 ? "filtro" : "filtros"} ativo${filterCount == 1 ? "" : "s"}' 
                        : 'Filtrar festas',
                      style: TextStyle(
                        color: hasActiveFilters 
                          ? Theme.of(context).colorScheme.onPrimary 
                          : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasActiveFilters 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: hasActiveFilters ? 0 : 1.5,
                      ),
                    ),
                  ),
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedStyles.clear();
                        _selectedCities.clear();
                        _radiusKm = 25;
                      });
                    },
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: partyService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredParties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.celebration_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.md),
                        Text('Nenhuma festa encontrada', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _currentPosition == null 
                            ? 'Ative sua localização para ver festas próximas' 
                            : 'Tente ajustar os filtros ou aumentar o raio de distância',
                          style: Theme.of(context).textTheme.bodyMedium?.withColor(Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedStyles.clear();
                                _selectedCities.clear();
                                _radiusKm = 25;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar filtros'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: AppSpacing.paddingMd,
                    itemCount: filteredParties.length,
                    itemBuilder: (context, index) {
                      final party = filteredParties[index];
                      final isBoosted = boostedPartyIds.contains(party.id);
                      
                      if (isBoosted) {
                        return _buildBoostedPartyCard(context, party);
                      }
                      
                      return PartyCard(
                        party: party,
                        currentPosition: _currentPosition,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostedPartyCard(BuildContext context, PartyModel party) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartyDetailsScreen(partyId: party.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(party.imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text('PATROCINADO', style: Theme.of(context).textTheme.labelSmall?.bold.withColor(Colors.black)),
                      ],
                    ),
                  ),
                ),
                if (party.type == 'premium')
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          Text('Premium', style: Theme.of(context).textTheme.labelSmall?.bold.withColor(Colors.black)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(party.name, style: Theme.of(context).textTheme.titleLarge?.bold, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.music_note, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(party.style, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.place, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${party.location}, ${party.city}', style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('R\$ ${party.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium?.bold),
                    ],
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

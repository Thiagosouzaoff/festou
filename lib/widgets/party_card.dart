import 'package:flutter/material.dart';
import 'package:festou/models/party_model.dart';
import 'package:festou/screens/party_details_screen.dart';
import 'package:festou/theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PartyCard extends StatelessWidget {
  final PartyModel party;
  final Position? currentPosition;

  const PartyCard({super.key, required this.party, this.currentPosition});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  String? _getDistance() {
    if (currentPosition == null) return null;
    final distance = party.distanceFrom(currentPosition!.latitude, currentPosition!.longitude);
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    final distance = _getDistance();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PartyDetailsScreen(partyId: party.id))),
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
                right: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(party.style, style: Theme.of(context).textTheme.labelSmall?.semiBold.withColor(Theme.of(context).colorScheme.onSecondaryContainer)),
                ),
              ),
              if (distance != null)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 12, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        const SizedBox(width: 2),
                        Text(distance, style: Theme.of(context).textTheme.labelSmall?.semiBold.withColor(Theme.of(context).colorScheme.onPrimaryContainer)),
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
                Text(party.name, style: Theme.of(context).textTheme.titleLarge?.bold, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${_formatDate(party.dateTime)} às ${_formatTime(party.dateTime)}', style: Theme.of(context).textTheme.bodySmall?.withColor(Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(child: Text(party.location, style: Theme.of(context).textTheme.bodySmall?.withColor(Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('R\$ ${party.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.bold.withColor(Theme.of(context).colorScheme.primary)),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PartyDetailsScreen(partyId: party.id))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      ),
                      child: Text('Ver Mais', style: Theme.of(context).textTheme.labelLarge?.semiBold),
                    ),
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

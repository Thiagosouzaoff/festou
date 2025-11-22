import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festou/models/boost_model.dart';
import 'package:festou/models/party_model.dart';
import 'package:festou/services/boost_service.dart';
import 'package:festou/services/party_service.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/screens/party_details_screen.dart';
import 'package:festou/theme.dart';

class BoostBannerWidget extends StatelessWidget {
  final BoostModel boost;
  final PartyModel party;
  final VoidCallback onClose;

  const BoostBannerWidget({
    super.key,
    required this.boost,
    required this.party,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7,
      color: Colors.black.withValues(alpha: 0.95),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onClose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PartyDetailsScreen(partyId: party.id),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(party.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.md,
                        left: AppSpacing.md,
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
                      Positioned(
                        bottom: AppSpacing.lg,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(party.name, style: Theme.of(context).textTheme.headlineMedium?.bold.withColor(Colors.white)),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(Icons.music_note, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text(party.style, style: Theme.of(context).textTheme.bodyLarge?.withColor(Colors.white)),
                                const SizedBox(width: AppSpacing.md),
                                const Icon(Icons.place, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(party.city, style: Theme.of(context).textTheme.bodyLarge?.withColor(Colors.white), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  onClose();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PartyDetailsScreen(partyId: party.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                ),
                                child: Text('Ver Evento', style: Theme.of(context).textTheme.titleMedium?.bold.withColor(Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showBoostBannerIfAvailable(
  BuildContext context, {
  String? excludePartyId,
}) async {
  final userService = Provider.of<UserService>(context, listen: false);
  final boostService = Provider.of<BoostService>(context, listen: false);
  final partyService = Provider.of<PartyService>(context, listen: false);

  final currentUser = userService.currentUser;
  if (currentUser == null) return;

  final matchingBoost = boostService.getMatchingBoost(currentUser, excludePartyId);
  if (matchingBoost == null) return;

  final party = partyService.getPartyById(matchingBoost.partyId);
  if (party == null) return;

  await boostService.recordImpression(matchingBoost.id, currentUser.id);

  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: BoostBannerWidget(
          boost: matchingBoost,
          party: party,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

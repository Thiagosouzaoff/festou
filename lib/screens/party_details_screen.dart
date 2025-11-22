import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festou/models/party_model.dart';
import 'package:festou/models/user_model.dart';
import 'package:festou/services/party_service.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/services/boost_service.dart';
import 'package:festou/theme.dart';
import 'package:festou/screens/public_profile_screen.dart';
import 'package:festou/screens/boost_screen.dart';
import 'package:festou/widgets/boost_banner_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PartyDetailsScreen extends StatefulWidget {
  final String partyId;

  const PartyDetailsScreen({super.key, required this.partyId});

  @override
  State<PartyDetailsScreen> createState() => _PartyDetailsScreenState();
}

class _PartyDetailsScreenState extends State<PartyDetailsScreen> {
  bool _hasConfirmed = false;
  int _currentStoryIndex = 0;
  bool _bannerShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_bannerShown && mounted) {
        _bannerShown = true;
        showBoostBannerIfAvailable(context, excludePartyId: widget.partyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final partyService = Provider.of<PartyService>(context);
    final userService = Provider.of<UserService>(context);
    final party = partyService.getPartyById(widget.partyId);
    
    if (party == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Festa não encontrada')),
        body: const Center(child: Text('Esta festa não existe mais.')),
      );
    }

    final organizer = userService.getUserById(party.organizerId);
    final currentUser = userService.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(party.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                onPressed: () => _showReportDialog(context, party),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(party.name, style: Theme.of(context).textTheme.headlineSmall?.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: party.type == 'premium' ? Colors.amber : Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  party.type == 'premium' ? Icons.star : Icons.local_activity,
                                  size: 14,
                                  color: party.type == 'premium' ? Colors.black : Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  party.type == 'premium' ? 'Premium' : 'Free',
                                  style: Theme.of(context).textTheme.labelSmall?.semiBold.withColor(
                                    party.type == 'premium' ? Colors.black : Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildOrganizerInfo(context, organizer),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoRow(context, Icons.music_note, party.style),
                      const SizedBox(height: AppSpacing.xs),
                      _buildInfoRow(context, Icons.calendar_today, DateFormat('dd/MM/yyyy').format(party.dateTime)),
                      const SizedBox(height: AppSpacing.xs),
                      _buildInfoRow(context, Icons.access_time, DateFormat('HH:mm').format(party.dateTime)),
                      const SizedBox(height: AppSpacing.xs),
                      _buildInfoRow(context, Icons.place, '${party.location}, ${party.city}'),
                      const SizedBox(height: AppSpacing.xs),
                      _buildInfoRow(context, Icons.attach_money, 'R\$ ${party.price.toStringAsFixed(2)}'),
                      const SizedBox(height: AppSpacing.lg),
                      _buildConfirmButton(context, party, currentUser),
                      if (party.type == 'premium' && currentUser != null && party.organizerId == currentUser.id) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildBoostButton(context, party),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text('Descrição', style: Theme.of(context).textTheme.titleMedium?.bold),
                      const SizedBox(height: AppSpacing.sm),
                      Text(party.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (party.storyUrls.isNotEmpty) ...[
                  const Divider(height: 32),
                  Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stories da Festa', style: Theme.of(context).textTheme.titleMedium?.bold),
                        const SizedBox(height: AppSpacing.sm),
                        _buildStoryViewer(context, party),
                      ],
                    ),
                  ),
                ],
                if (party.mediaUrls.isNotEmpty) ...[
                  const Divider(height: 32),
                  Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fotos e Vídeos', style: Theme.of(context).textTheme.titleMedium?.bold),
                        const SizedBox(height: AppSpacing.sm),
                        _buildMediaGrid(context, party.mediaUrls),
                      ],
                    ),
                  ),
                ],
                if (party.attendeeIds.isNotEmpty) ...[
                  const Divider(height: 32),
                  Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quem vai (${party.attendeeIds.length})', style: Theme.of(context).textTheme.titleMedium?.bold),
                        const SizedBox(height: AppSpacing.sm),
                        _buildAttendeesList(context, party.attendeeIds, userService),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerInfo(BuildContext context, UserModel organizer) {
    return InkWell(
      onTap: () => _navigateToProfile(context, organizer),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: organizer.photoUrl != null
                ? ClipOval(
                    child: organizer.photoUrl!.startsWith('data:image')
                        ? Image.memory(base64Decode(organizer.photoUrl!.split(',')[1]), fit: BoxFit.cover)
                        : Image.asset(organizer.photoUrl!, fit: BoxFit.cover),
                  )
                : Text(organizer.name[0].toUpperCase(), style: Theme.of(context).textTheme.titleMedium?.bold.withColor(Theme.of(context).colorScheme.onPrimaryContainer)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizador', style: Theme.of(context).textTheme.labelSmall?.withColor(Theme.of(context).colorScheme.onSurfaceVariant)),
                Text(organizer.name, style: Theme.of(context).textTheme.bodyMedium?.semiBold),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, PartyModel party, UserModel? currentUser) {
    if (currentUser == null) return const SizedBox.shrink();

    final isAttending = party.attendeeIds.contains(currentUser.id) || _hasConfirmed;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isAttending ? null : () => _confirmAttendance(context, party, currentUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: isAttending ? Colors.grey : Theme.of(context).colorScheme.primary,
          foregroundColor: isAttending ? Colors.white : Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isAttending ? Icons.check_circle : Icons.celebration),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isAttending ? 'Você confirmou presença!' : 'EU VOU',
              style: Theme.of(context).textTheme.titleMedium?.bold.withColor(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoostButton(BuildContext context, PartyModel party) {
    final boostService = Provider.of<BoostService>(context, listen: false);
    final boosts = boostService.getBoostsByParty(party.id);
    final hasActiveBoost = boosts.any((b) => b.isActive && b.remainingImpressions > 0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BoostScreen(party: party)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        icon: const Icon(Icons.rocket_launch),
        label: Text(
          hasActiveBoost ? 'Aumentar Turbinamento' : 'Turbinar Evento',
          style: Theme.of(context).textTheme.titleMedium?.bold.withColor(Colors.black),
        ),
      ),
    );
  }

  Widget _buildStoryViewer(BuildContext context, PartyModel party) {
    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    party.storyUrls[_currentStoryIndex],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const Icon(Icons.play_circle, size: 64, color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.md,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: _currentStoryIndex > 0 ? _previousStory : null,
                      ),
                      Text('${_currentStoryIndex + 1} / ${party.storyUrls.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: _currentStoryIndex < party.storyUrls.length - 1 ? _nextStory : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: party.storyUrls.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => setState(() => _currentStoryIndex = index),
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentStoryIndex == index ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.asset(party.storyUrls[index], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<String> mediaUrls) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: mediaUrls.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.asset(mediaUrls[index], fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAttendeesList(BuildContext context, List<String> attendeeIds, UserService userService) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attendeeIds.length,
        itemBuilder: (context, index) {
          final attendee = userService.getUserById(attendeeIds[index]);
          return GestureDetector(
            onTap: () => _navigateToProfile(context, attendee),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: attendee.photoUrl != null
                        ? ClipOval(
                            child: attendee.photoUrl!.startsWith('data:image')
                                ? Image.memory(base64Decode(attendee.photoUrl!.split(',')[1]), fit: BoxFit.cover)
                                : Image.asset(attendee.photoUrl!, fit: BoxFit.cover),
                          )
                        : Text(attendee.name[0].toUpperCase(), style: Theme.of(context).textTheme.titleMedium?.bold.withColor(Theme.of(context).colorScheme.onPrimaryContainer)),
                  ),
                  const SizedBox(height: 4),
                  Text(attendee.name.split(' ').first, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmAttendance(BuildContext context, PartyModel party, UserModel currentUser) {
    Provider.of<PartyService>(context, listen: false).addAttendee(party.id, currentUser.id);
    setState(() => _hasConfirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Presença confirmada! Você não pode desfazer esta ação.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _previousStory() => setState(() => _currentStoryIndex--);
  void _nextStory() => setState(() => _currentStoryIndex++);

  void _navigateToProfile(BuildContext context, UserModel user) {
    final currentUser = Provider.of<UserService>(context, listen: false).currentUser;
    if (currentUser != null && user.id == currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este é o seu próprio perfil. Acesse pela aba "Perfil".')),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: user.id)));
  }

  void _showReportDialog(BuildContext context, PartyModel party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Denunciar Festa'),
        content: const Text('Você tem certeza que deseja denunciar esta festa? Nossa equipe irá analisar o conteúdo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PartyService>(context, listen: false).reportParty(party.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Denúncia enviada. Obrigado por nos ajudar a manter a comunidade segura.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Denunciar'),
          ),
        ],
      ),
    );
  }
}

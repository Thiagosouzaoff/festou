import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festou/models/user_model.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/services/party_service.dart';
import 'package:festou/theme.dart';
import 'package:festou/widgets/party_card.dart';
import 'dart:convert';

class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final partyService = context.watch<PartyService>();
    final user = userService.getUserById(userId);
    final currentUser = userService.currentUser;
    final userParties = partyService.parties.where((p) => p.organizerId == userId).toList();
    final isLiked = currentUser != null && user.likedByUserIds.contains(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: Theme.of(context).textTheme.headlineSmall?.bold),
        actions: [
          IconButton(
            icon: Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.error),
            tooltip: 'Denunciar perfil',
            onPressed: () => _showReportDialog(context, user, userService),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingXl,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: user.photoUrl != null
                        ? ClipOval(
                            child: user.photoUrl!.startsWith('data:image')
                                ? Image.memory(base64Decode(user.photoUrl!.split(',')[1]), width: 100, height: 100, fit: BoxFit.cover)
                                : Image.asset(user.photoUrl!, width: 100, height: 100, fit: BoxFit.cover),
                          )
                        : Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: Theme.of(context).textTheme.displaySmall?.bold.withColor(Theme.of(context).colorScheme.primary)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(user.name, style: Theme.of(context).textTheme.headlineMedium?.bold.withColor(Colors.white)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(user.gender == 'Homem' ? Icons.male : user.gender == 'Mulher' ? Icons.female : Icons.person, color: Colors.white, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${user.gender} • ${user.relationshipStatus}', style: Theme.of(context).textTheme.bodyMedium?.withColor(Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                  if (user.age != null || user.city != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (user.age != null) ...[
                          Icon(Icons.cake, color: Colors.white, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text('${user.age} anos', style: Theme.of(context).textTheme.bodySmall?.withColor(Colors.white.withValues(alpha: 0.9))),
                        ],
                        if (user.age != null && user.city != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text('•', style: Theme.of(context).textTheme.bodySmall?.withColor(Colors.white.withValues(alpha: 0.9))),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        if (user.city != null) ...[
                          Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(user.city!, style: Theme.of(context).textTheme.bodySmall?.withColor(Colors.white.withValues(alpha: 0.9))),
                        ],
                      ],
                    ),
                  ],
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(user.bio!, style: Theme.of(context).textTheme.bodyMedium?.withColor(Colors.white.withValues(alpha: 0.85)), textAlign: TextAlign.center, maxLines: 5),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentUser != null ? () => userService.toggleLike(userId) : null,
                        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white),
                        label: Text('${user.likedByUserIds.length}', style: Theme.of(context).textTheme.titleMedium?.semiBold.withColor(Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      if (user.likedByUserIds.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _showLikesDialog(context, user, userService),
                          icon: const Icon(Icons.people, color: Colors.white),
                          label: Text('Ver curtidas', style: Theme.of(context).textTheme.titleMedium?.semiBold.withColor(Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.favoriteStyles.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text('Estilos Favoritos', style: Theme.of(context).textTheme.titleLarge?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: user.favoriteStyles.map((style) => Chip(
                        label: Text(style, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Festas Criadas', style: Theme.of(context).textTheme.titleLarge?.semiBold),
                      Text('${userParties.length}', style: Theme.of(context).textTheme.titleLarge?.bold.withColor(Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (userParties.isEmpty)
                    Center(
                      child: Padding(
                        padding: AppSpacing.paddingXl,
                        child: Column(
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(height: AppSpacing.md),
                            Text('Este usuário ainda não criou nenhuma festa', style: Theme.of(context).textTheme.bodyMedium?.withColor(Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  else
                    ...userParties.map((party) => PartyCard(party: party)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, UserModel user, UserService userService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Denunciar perfil', style: Theme.of(context).textTheme.titleLarge?.bold),
        content: Text('Tem certeza que deseja denunciar o perfil de ${user.name}? Nossa equipe irá analisar o caso.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () {
              userService.reportUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Denúncia enviada com sucesso. Nossa equipe irá analisar.')),
              );
            },
            child: Text('Denunciar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showLikesDialog(BuildContext context, UserModel user, UserService userService) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Curtidas (${user.likedByUserIds.length})', style: Theme.of(context).textTheme.titleLarge?.bold),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: user.likedByUserIds.length,
                itemBuilder: (context, index) {
                  final likedUser = userService.getUserById(user.likedByUserIds[index]);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: likedUser.photoUrl != null
                          ? ClipOval(
                              child: likedUser.photoUrl!.startsWith('data:image')
                                  ? Image.memory(base64Decode(likedUser.photoUrl!.split(',')[1]), width: 40, height: 40, fit: BoxFit.cover)
                                  : Image.asset(likedUser.photoUrl!, width: 40, height: 40, fit: BoxFit.cover),
                            )
                          : Text(likedUser.name.isNotEmpty ? likedUser.name[0].toUpperCase() : '?', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    ),
                    title: Text(likedUser.name, style: Theme.of(context).textTheme.titleMedium?.semiBold),
                    subtitle: Text('${likedUser.gender} • ${likedUser.relationshipStatus}', style: Theme.of(context).textTheme.bodySmall),
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: likedUser.id)));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

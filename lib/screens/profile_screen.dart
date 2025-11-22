import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/services/party_service.dart';
import 'package:festou/theme.dart';
import 'package:festou/widgets/party_card.dart';
import 'package:festou/screens/public_profile_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final partyService = context.watch<PartyService>();
    final user = userService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userParties = partyService.parties.where((p) => p.organizerId == user.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil', style: Theme.of(context).textTheme.headlineSmall?.bold),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: () => _showEditDialog(context, user, userService),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.red.shade300, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${user.likedByUserIds.length} curtidas', style: Theme.of(context).textTheme.titleMedium?.semiBold.withColor(Colors.white)),
                        if (user.likedByUserIds.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          TextButton(
                            onPressed: () => _showLikesDialog(context, user, userService),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Text('Ver', style: Theme.of(context).textTheme.bodySmall?.semiBold.withColor(Colors.white)),
                          ),
                        ],
                      ],
                    ),
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
                      Text('Minhas Festas', style: Theme.of(context).textTheme.titleLarge?.semiBold),
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
                            Text('Você ainda não criou nenhuma festa', style: Theme.of(context).textTheme.bodyMedium?.withColor(Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
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

  void _showEditDialog(BuildContext context, user, UserService userService) {
    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio ?? '');
    final ageController = TextEditingController(text: user.age?.toString() ?? '');
    final cityController = TextEditingController(text: user.city ?? '');
    List<String> selectedStyles = List.from(user.favoriteStyles);
    String selectedGender = user.gender;
    String selectedRelationship = user.relationshipStatus;
    String? selectedPhotoUrl = user.photoUrl;

    final availableStyles = ['Axé', 'Bossa Nova', 'Carimbó', 'Choro', 'Eletrônico', 'Forró', 'Frevo', 'Funk Brasileiro', 'Maracatu', 'MPB', 'Pagode', 'Piseiro', 'Samba', 'Sertanejo', 'Tecnobrega'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editar Perfil', style: Theme.of(context).textTheme.titleLarge?.bold),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: selectedPhotoUrl != null
                            ? ClipOval(
                                child: selectedPhotoUrl!.startsWith('data:image')
                                    ? Image.memory(base64Decode(selectedPhotoUrl!.split(',')[1]), width: 100, height: 100, fit: BoxFit.cover)
                                    : Image.asset(selectedPhotoUrl!, width: 100, height: 100, fit: BoxFit.cover),
                              )
                            : Text(nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : '?', style: Theme.of(context).textTheme.displaySmall?.bold.withColor(Theme.of(context).colorScheme.primary)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await _showPhotoOptions(context, (photoUrl) {
                              setState(() => selectedPhotoUrl = photoUrl);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Idade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (máximo 400 caracteres)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  maxLines: 4,
                  maxLength: 400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Gênero', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: ['Homem', 'Mulher', 'Não informado'].map((gender) => ChoiceChip(
                    label: Text(gender),
                    selected: selectedGender == gender,
                    onSelected: (selected) => setState(() => selectedGender = gender),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(color: selectedGender == gender ? Colors.white : Theme.of(context).colorScheme.onSurface),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Status de Relacionamento', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: ['Solteiro', 'Compromisso', 'Não informado'].map((status) => ChoiceChip(
                    label: Text(status),
                    selected: selectedRelationship == status,
                    onSelected: (selected) => setState(() => selectedRelationship = status),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(color: selectedRelationship == status ? Colors.white : Theme.of(context).colorScheme.onSurface),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Estilos Favoritos', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: availableStyles.map((style) {
                    final isSelected = selectedStyles.contains(style);
                    return FilterChip(
                      label: Text(style, style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                      selected: isSelected,
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          selectedStyles.add(style);
                        } else {
                          selectedStyles.remove(style);
                        }
                      }),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome é obrigatório')));
                        return;
                      }
                      final age = int.tryParse(ageController.text.trim());
                      if (age != null && (age < 18 || age > 120)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Idade deve ser entre 18 e 120 anos')));
                        return;
                      }
                      userService.updateProfile(
                        name: nameController.text.trim(),
                        bio: bioController.text.trim(),
                        photoUrl: selectedPhotoUrl,
                        favoriteStyles: selectedStyles,
                        gender: selectedGender,
                        relationshipStatus: selectedRelationship,
                        age: age,
                        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado com sucesso!')));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text('Salvar', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPhotoOptions(BuildContext context, Function(String) onPhotoSelected) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Escolher Foto de Perfil', style: Theme.of(context).textTheme.titleLarge?.bold),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
              title: Text('Galeria do Telefone', style: Theme.of(context).textTheme.titleMedium),
              onTap: () async {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                  );
                  if (!context.mounted) return;
                  
                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.first;
                    if (file.bytes != null) {
                      final base64Image = 'data:image/${file.extension};base64,${base64Encode(file.bytes!)}';
                      Navigator.pop(context, base64Image);
                    } else {
                      Navigator.pop(context);
                    }
                  } else {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  debugPrint('Error picking image: $e');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro ao selecionar foto. Tente novamente.')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.collections, color: Theme.of(context).colorScheme.secondary),
              title: Text('Fotos de Exemplo', style: Theme.of(context).textTheme.titleMedium),
              onTap: () async {
                final photoResult = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const _PhotoSelectorScreen()),
                );
                if (!context.mounted) return;
                Navigator.pop(context, photoResult);
              },
            ),
          ],
        ),
      ),
    );
    
    if (result != null) {
      onPhotoSelected(result);
    }
  }

  void _showLikesDialog(BuildContext context, user, UserService userService) {
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

class _PhotoSelectorScreen extends StatelessWidget {
  const _PhotoSelectorScreen();

  @override
  Widget build(BuildContext context) {
    final samplePhotos = [
      'assets/images/party1.jpg',
      'assets/images/party2.jpg',
      'assets/images/party3.jpg',
      'assets/images/party4.jpg',
      'assets/images/party5.jpg',
      'assets/images/party6.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Foto de Perfil', style: Theme.of(context).textTheme.headlineSmall?.bold),
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.paddingMd,
            child: Text('Escolha uma foto ou adicione uma nova nos Assets', style: Theme.of(context).textTheme.bodyMedium?.withColor(Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ),
          Expanded(
            child: GridView.builder(
              padding: AppSpacing.paddingMd,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: samplePhotos.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.pop(context, samplePhotos[index]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.asset(samplePhotos[index], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

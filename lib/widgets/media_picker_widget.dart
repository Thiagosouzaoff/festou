import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:festou/theme.dart';

class MediaPickerWidget extends StatelessWidget {
  final List<PlatformFile> mediaFiles;
  final VoidCallback onAddMedia;
  final Function(int) onRemoveMedia;

  const MediaPickerWidget({
    super.key,
    required this.mediaFiles,
    required this.onAddMedia,
    required this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fotos e Vídeos', style: Theme.of(context).textTheme.titleMedium?.semiBold),
            Text(
              '${mediaFiles.length}/10',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Máximo 10 itens. Vídeos até 10 segundos.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mediaFiles.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: mediaFiles.length < 10 ? onAddMedia : null,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: mediaFiles.length < 10
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: mediaFiles.length < 10
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Adicionar',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: mediaFiles.length < 10
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final fileIndex = index - 1;
              final file = mediaFiles[fileIndex];
              final isVideo = file.extension?.toLowerCase() != null && 
                ['mp4', 'mov', 'avi', 'mkv'].contains(file.extension!.toLowerCase());
              
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: isVideo
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: Icon(
                                      Icons.videocam,
                                      size: 32,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'VIDEO',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Image.network(
                              file.path!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => 
                                Icon(Icons.image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemoveMedia(fileIndex),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

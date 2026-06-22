import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/data_models/comment.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/time_formatter.dart';
import 'package:nearvendorapp/views/screens/common/image_viewer_screen.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;

  const CommentCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwnComment = comment.authorId == AppData().currentUser?.id;
    final isVendor = comment.authorType?.name == 'vendor';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          // Card body
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 44, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isVendor
                      ? theme.primaryColor.withValues(alpha: 0.15)
                      : theme.dividerColor.withValues(alpha: 0.12),
                  backgroundImage: comment.authorPhotoUrl != null &&
                          comment.authorPhotoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(comment.authorPhotoUrl!)
                      : null,
                  child: comment.authorPhotoUrl == null ||
                          comment.authorPhotoUrl!.isEmpty
                      ? Text(
                          (comment.authorName ?? '?')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isVendor ? theme.primaryColor : null,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + vendor badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              comment.authorName ?? 'Anonymous',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVendor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Vendor',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Timestamp
                      const SizedBox(height: 2),
                      Text(
                        comment.isEdited == true
                            ? 'Edited · ${TimeFormatter.timeAgo(comment.updatedAt)}'
                            : TimeFormatter.timeAgo(comment.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.45),
                          fontSize: 10,
                        ),
                      ),
                      // Comment text
                      const SizedBox(height: 6),
                      Text(
                        comment.text ?? '',
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                      // Images
                      if (comment.images.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              List.generate(comment.images.length, (index) {
                            final url = comment.images[index];
                            return GestureDetector(
                              onTap: () => AppNavigator.push(
                                context,
                                ImageViewerScreen(
                                  imageUrls: comment.images,
                                  initialIndex: index,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => Container(
                                    width: 64,
                                    height: 64,
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu button — pinned top-right of the card
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showMenuSheet(context, isOwnComment),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuSheet(BuildContext context, bool isOwnComment) {
    final theme = Theme.of(context);
    AppBottomSheet.showBottomSheet(
      context: context,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Builder(
        builder: (sheetCtx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (isOwnComment) ...[
              _menuTile(
                theme: theme,
                icon: Icons.edit_outlined,
                label: 'Edit Comment',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  onEdit?.call();
                },
              ),
              const SizedBox(height: 8),
              _menuTile(
                theme: theme,
                icon: Icons.delete_outline_rounded,
                label: 'Delete Comment',
                isDestructive: true,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showDeleteConfirmation(context);
                },
              ),
            ] else
              _menuTile(
                theme: theme,
                icon: Icons.flag_outlined,
                label: 'Report Comment',
                isDestructive: true,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  onReport?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.textTheme.bodyLarge?.color;
    final bgColor = isDestructive
        ? theme.colorScheme.error.withValues(alpha: 0.06)
        : theme.dividerColor.withValues(alpha: 0.06);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    AppBottomSheet.showConfirmationBottomSheet(
      context: context,
      title: 'Delete Comment',
      message: 'Are you sure you want to delete this comment?',
      confirmButtonText: 'Delete',
      confirmButtonColor: Colors.red.shade700,
      onConfirm: () {
        AppNavigator.pop(context);
        onDelete?.call();
      },
    );
  }
}

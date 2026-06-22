import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/data_models/comment.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/time_formatter.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isVendor
                ? theme.primaryColor.withValues(alpha: 0.15)
                : theme.dividerColor.withValues(alpha: 0.1),
            backgroundImage:
                comment.authorPhotoUrl != null &&
                    comment.authorPhotoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(comment.authorPhotoUrl!)
                : null,
            child:
                comment.authorPhotoUrl == null ||
                    comment.authorPhotoUrl!.isEmpty
                ? Text(
                    (comment.authorName ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      color: isVendor ? theme.primaryColor : null,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName ?? 'Anonymous',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isVendor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
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
                    const Spacer(),
                    Text(
                      comment.isEdited == true
                          ? 'Edited · ${TimeFormatter.timeAgo(comment.updatedAt)}'
                          : TimeFormatter.timeAgo(comment.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      itemBuilder: (context) => [
                        if (isOwnComment) ...[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        if (!isOwnComment)
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('Report'),
                          ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                          case 'delete':
                            _showDeleteConfirmation(context);
                          case 'report':
                            onReport?.call();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                if (comment.images.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: comment.images
                        .map(
                          (url) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                width: 60,
                                height: 60,
                                color: theme.dividerColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
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

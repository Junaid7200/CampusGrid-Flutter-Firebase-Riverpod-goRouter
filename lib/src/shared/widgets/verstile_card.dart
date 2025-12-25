import 'package:flutter/material.dart';
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:go_router/go_router.dart';

enum CardType { note, myNote, subject, degree }

class VerstileCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String cardType;
  final VoidCallback? onTap;
  final int? likesCount;
  final int? resourcesCount;
  final String? authorName;
  final String? noteId; // Required for myNote type
  final VoidCallback? onRefresh; // Called after delete/edit

  const VerstileCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardType,
    this.onTap,
    this.likesCount,
    this.resourcesCount,
    this.authorName,
    this.noteId,
    this.onRefresh,
  });

  @override
  State<VerstileCard> createState() => _VerstileCardState();
}

class _VerstileCardState extends State<VerstileCard> {
  bool _isDeleting = false;

  Future<void> _handleEdit() async {
    // Navigate to edit page with noteId
    await context.push('/new_resource?noteId=${widget.noteId}');
    widget.onRefresh?.call();
  }

  Future<void> _handleDelete() async {
    final colors = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text(
          'Are you sure you want to delete "${widget.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isDeleting = true);

      try {
        await note_service.deleteNote(widget.noteId!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note deleted successfully 🗑️')),
          );
          widget.onRefresh?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = widget.cardType == "note"
        ? Icons.description_outlined
        : widget.cardType == "myNote"
        ? Icons.note_alt_outlined
        : widget.cardType == "subject"
        ? Icons.menu_book_outlined
        : Icons.school_outlined;
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurface.withAlpha((0.7 * 255).toInt()),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.authorName != null) ...[
                      Text(
                        "By ${widget.authorName}",
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface.withAlpha(
                            (0.6 * 255).toInt(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 4),
                    if (widget.cardType == "note" ||
                        widget.cardType == "myNote") ...[
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: Color(0xFFEF5350),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.likesCount != null
                                ? widget.likesCount.toString()
                                : "0",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF5350),
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.cardType == "subject") ...[
                      Row(
                        children: [
                          Icon(Icons.folder, size: 16, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            widget.resourcesCount != null
                                ? widget.resourcesCount.toString()
                                : "0",
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.cardType == "degree") ...[
                      Row(
                        children: [
                          Icon(Icons.school, size: 16, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            "Degree Program",
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.cardType == "myNote") ...[
                _isDeleting
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _handleEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Edit",
                                style: TextStyle(color: colors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _handleDelete,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Color(0xFFD32F2F)),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

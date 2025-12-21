import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

enum CardType { note, myNote, subject, degree }

class VerstileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cardType;
  final VoidCallback? onTap;
  // final IconData? icon;
  final int? likesCount;
  final int? resourcesCount;
  final String? authorName;

  const VerstileCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardType,
    this.onTap,
    // this.icon,
    this.likesCount,
    this.resourcesCount,
    this.authorName,
  });
  @override
  Widget build(BuildContext context) {
    final IconData icon = cardType == "note"
        ? Icons.description_outlined
        : cardType == "myNote"
        ? Icons.note_alt_outlined
        : cardType == "subject"
        ? Icons.menu_book_outlined
        : Icons.school_outlined;
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: SingleChildScrollView(
          child: 
          Padding(
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface.withAlpha(
                            (0.7 * 255).toInt(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (authorName != null) ...[
                        Text(
                          "By $authorName",
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
                      if (cardType == "note" || cardType == "myNote") ...[
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: Color(0xFFEF5350),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likesCount != null
                                  ? likesCount.toString()
                                  : "0",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF5350),
                              ),
                            ),
                          ],
                        ),
                      ] else if (cardType == "subject") ...[
                        Row(
                          children: [
                            Icon(
                              Icons.folder,
                              size: 16,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              resourcesCount != null
                                  ? resourcesCount.toString()
                                  : "0",
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ] else if (cardType == "degree") ...[
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 16,
                              color: colors.primary,
                            ),
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
                if (cardType == "myNote") ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle edit action
                        },
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
                        onTap: () {
                          // Handle delete action
                        },
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
      ),
    );
  }
}

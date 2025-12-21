import "package:flutter/material.dart";
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:go_router/go_router.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:campus_grid/src/shared/widgets/outlined_button.dart';

class ViewResourcePage extends StatefulWidget {
  const ViewResourcePage({super.key, required this.resourceId});
  final String resourceId;
  State<ViewResourcePage> createState() => _ViewResourcePageState();
}

class _ViewResourcePageState extends State<ViewResourcePage> {
  Map<String, dynamic> note = {};
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isLikeLoading = false;
  bool _isSaveLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final fetchedNote = await note_service.getNoteById(widget.resourceId);
      final liked = await note_service.hasUserLikedNote(widget.resourceId);
      final saved = await note_service.hasUserSavedNote(widget.resourceId);

      setState(() {
        note = fetchedNote ?? {};
        _isLiked = liked;
        _isSaved = saved;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading resource: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLike() async {
    setState(() => _isLikeLoading = true);

    try {
      if (_isLiked) {
        await note_service.unlikeNote(widget.resourceId);
        setState(() {
          _isLiked = false;
          note['likesCount'] = (note['likesCount'] ?? 1) - 1;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Removed from likes')));
        }
      } else {
        await note_service.likeNote(widget.resourceId);
        setState(() {
          _isLiked = true;
          note['likesCount'] = (note['likesCount'] ?? 0) + 1;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Added to likes ❤️')));
        }
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
      setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaveLoading = true);

    try {
      if (_isSaved) {
        await note_service.unsaveNote(widget.resourceId);
        setState(() => _isSaved = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Removed from library')));
        }
      } else {
        await note_service.saveNote(widget.resourceId);
        setState(() => _isSaved = true);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Saved to library 📚')));
        }
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
      setState(() => _isSaveLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: colors.primary,
                      size: 32,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: colors.primary,
                      size: 32,
                    ),
                    onPressed: _isSaveLoading ? null : _handleSave,
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          note['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface.withAlpha(
                              (0.7 * 255).toInt(),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'By: ${note['uploaderName'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 18,
                              color: Color(0xFFEF5350),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${note['likesCount'] ?? 0} likes',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.insert_drive_file,
                              size: 18,
                              color: colors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              note['fileType']?.toUpperCase() ?? 'FILE',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Like/Unlike Button
                        CustomButton(
                          leadingIcon: _isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          text: _isLiked ? "Unlike" : "Like",
                          onPressed: _isLikeLoading ? null : _handleLike,
                          isLoading: _isLikeLoading,
                        ),
                        SizedBox(height: 12),

                        // Download Button
                        CustomOutlinedButton(
                          leadingIcon: Icons.download_rounded,
                          text: "Download Resource",
                          onPressed: () {
                            // TODO: Implement download
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Download coming soon!')),
                            );
                          },
                        ),
                        SizedBox(height: 12),

                        // Save to Library Button
                        CustomOutlinedButton(
                          leadingIcon: _isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          text: _isSaved
                              ? "Saved to Library"
                              : "Save to Library",
                          onPressed: _isSaveLoading ? null : _handleSave,
                          isLoading: _isSaveLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File Preview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  size: 64,
                                  color: colors.primary.withAlpha(100),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Preview not available',
                                  style: TextStyle(
                                    color: colors.onSurface.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

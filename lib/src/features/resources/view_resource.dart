import "package:flutter/material.dart";
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:go_router/go_router.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:campus_grid/src/shared/widgets/outlined_button.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ViewResourcePage extends StatefulWidget {
  const ViewResourcePage({super.key, required this.resourceId});
  final String resourceId;
  @override
  State<ViewResourcePage> createState() => _ViewResourcePageState();
}

class _ViewResourcePageState extends State<ViewResourcePage> {
  Map<String, dynamic> note = {};
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isLikeLoading = false;
  bool _isSaveLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

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
      // print('Error loading resource: $e');
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

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final savePath = '${directory!.path}/${note['fileName']}';
      // print("Saving to: $savePath"); // Debug print to see the path

      final dio = Dio();
      await dio.download(
        note['fileUrl'],
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Show the actual path so you can find it
            content: Text('Saved to Downloads: ${note['fileName']}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // content: Text('Download failed: ${e.toString()}'),
            content: Text('Download failed: This note has no attached file.'),
            backgroundColor: Colors.grey[800],
          ),
        );
      }
    } finally {
      setState(() { 
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
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
                          text: _isDownloading
                              ? 'Downloading... ${(_downloadProgress * 100).toInt()}%'
                              : 'Download Resource',
                          onPressed: _isDownloading ? null : _handleDownload,
                          isLoading: _isDownloading,
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

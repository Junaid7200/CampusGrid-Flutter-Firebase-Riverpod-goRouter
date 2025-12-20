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

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final fetchedNote = await note_service.getNoteById(widget.resourceId);
      setState(() {
        note = fetchedNote ?? {};
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading resource: $e');
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // right chevron:
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
                        context.go('/search');
                      }
                    },
                  ),
                  // bookmark icon
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: colors.primary,
                      size: 32,
                    ),
                    onPressed: () {
                      // bookmark action
                    },
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
                    padding: const EdgeInsets.all(12.0),
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
                        Text(
                          '${note['description'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface.withAlpha((0.7 * 255).toInt()),
                          ),
                        ),
                        Text(
                          'By: ${note['uploaderName'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface.withAlpha((0.7 * 255).toInt()),
                          ),
                        ),
                        SizedBox(height: 16),
                        CustomButton(
                          leadingIcon: Icons.download_rounded,
                          text: "Download Resource",
                          onPressed: () {},
                        ),
                        SizedBox(height: 16),
                        CustomOutlinedButton(
                          leadingIcon: Icons.bookmark_border_rounded,
                          text: "Save to Library",
                          onPressed: () {},
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // section here to preview the document, a thumbnail basically
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

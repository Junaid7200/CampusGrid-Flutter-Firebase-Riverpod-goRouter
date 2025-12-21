import "package:flutter/material.dart";
import 'package:campus_grid/src/shared/widgets/home_header.dart';
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';
import 'package:campus_grid/src/services/user_service.dart' as user_service;
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String? displayName = user_service
      .getCurrentUserDisplayName()
      ?.toUpperCase();
  List<Map<String, dynamic>> _mostLikedNotes = [];
  List<Map<String, dynamic>> _recentlyAddedNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final mostLiked = await note_service.getMostLikedNotes(limit: 10);
      final recentNotes = await note_service.getRecentNotes(limit: 10);
      setState(() {
        _mostLikedNotes = mostLiked;
        _recentlyAddedNotes = recentNotes;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error loading notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadNotes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back,",
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${displayName ?? 'User'}",
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Most Liked Notes Section
              HomeHeader(
                heading: "Most Liked Notes",
                onActionPressed: () async {
                  await context.push('/all_notes?filter=most_liked');
                  _loadNotes();
                },
              ),

              // Horizontal ListView for Most Liked Notes
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: _mostLikedNotes.length,
                        itemBuilder: (context, index) {
                          final note = _mostLikedNotes[index];
                          final currentUserId = user_service.getCurrentUserId();
                          final isMyNote = note['uploadedBy'] == currentUserId;
                          return SizedBox(
                            width: 320,
                            child: VerstileCard(
                              title: note['title'] ?? 'Untitled',
                              subtitle: note['description'] ?? 'No description',
                              cardType: isMyNote ? "myNote" : "note",
                              likesCount: note['likesCount'] ?? 0,
                              authorName: note['uploaderName'] ?? 'Unknown',
                              onTap: () async {
                                await context.push(
                                  '/view_resource/${note['id']}',
                                );
                                _loadNotes();
                              },
                            ),
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 8),

              // Recently Added Notes Section
              HomeHeader(
                heading: "Recently Added Notes",
                onActionPressed: () async {
                  await context.push('/all_notes?filter=recent');
                  _loadNotes();
                },
              ),
              // Vertical ListView for Recently Added Notes
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentlyAddedNotes.length,
                      itemBuilder: (context, index) {
                        final note = _recentlyAddedNotes[index];
                        final currentUserId = user_service.getCurrentUserId();
                        final isMyNote = note['uploadedBy'] == currentUserId;

                        return VerstileCard(
                          title: note['title'] ?? 'Untitled',
                          subtitle: note['description'] ?? 'No description',
                          cardType: isMyNote ? "myNote" : "note",
                          likesCount: note['likesCount'] ?? 0,
                          authorName: note['uploaderName'] ?? 'Unknown',
                          onTap: () async {
                            await context.push('/view_resource/${note['id']}');
                            _loadNotes();
                          },
                        );
                      },
                    ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

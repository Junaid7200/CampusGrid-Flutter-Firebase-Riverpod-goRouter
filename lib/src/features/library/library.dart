import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/search_bar.dart';
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, this.query, this.sort});
  final String? query;
  final String? sort;

  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> libraryItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  String searchQuery = '';
  int totalLibraryItems = 0;
  bool isLoading = false;

  void initState() {
    super.initState();
    _fetchLibraryItems();
  }

  Future<void> _fetchLibraryItems() async {
    setState(() {
      isLoading = true;
    });
    libraryItems = await note_service.getUserSavedNotes();
    filteredItems = libraryItems;
    totalLibraryItems = libraryItems.length;
    setState(() {
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = libraryItems;
      } else {
        filteredItems = libraryItems.where((item) {
          final title = (item['title'] ?? '').toLowerCase();
          final description = (item['description'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) ||
              description.contains(searchLower);
        }).toList();
      }
    });
  }

  void onTap() {
    // Handle tap event
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchLibraryItems,
        child: SafeArea(
          // ---------------------------------------------------------
          // CHANGED: Replaced SingleChildScrollView + Padding + Column
          // with a single ListView. This fills the screen height.
          // ---------------------------------------------------------
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0), // Padding moved here
            children: [
              // main heading left aligned:
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Library',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // library search bar
              CustomSearchBar(
                hintText: "Search saved resources...",
                controller: controller,
                onTap: onTap,
                onChanged: _onSearchChanged,
                onSubmit: (value) {},
              ),
              const SizedBox(height: 16),
              // saved resources count
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You have $totalLibraryItems saved resources',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface.withAlpha(60),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ---------------------------------------------------------
              // CHANGED: Logic for Empty State
              // Used Container with height instead of Center so it
              // takes up vertical space to allow scrolling/swiping.
              // ---------------------------------------------------------
              if (filteredItems.isEmpty)
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.center,
                  child: Text(
                    searchQuery.isEmpty
                        ? 'No saved resources yet.'
                        : 'No results found for "$searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.onSurface.withAlpha(50),
                    ),
                  ),
                )
              else
                // listview builder, vertical list of verstile cards
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    final isMyNote = item['uploadedBy'] == currentUserId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: VerstileCard(
                        title: item['title'] ?? 'Untitled',
                        subtitle: item['description'] ?? 'No description',
                        onTap: () async {
                          await context.push('/view_resource/${item['id']}');
                          _fetchLibraryItems();
                        },
                        cardType: isMyNote ? 'myNote' : 'note',
                        authorName: item['uploaderName'] ?? 'Unknown',
                        likesCount: item['likesCount'] ?? 0,
                        noteId: item['id'],
                        onRefresh: _fetchLibraryItems,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

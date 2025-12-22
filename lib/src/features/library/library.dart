import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/search_bar.dart';
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';
import 'package:campus_grid/src/services/note_service.dart' as note_service;




class LibraryPage extends StatefulWidget {
  const LibraryPage({
    super.key,
    this.query,
    this.sort,
    });
    final String? query;
    final String? sort;

  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> libraryItems = [];
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
    totalLibraryItems = libraryItems.length;
    setState(() {
      isLoading = false;
    });
    // Fetch library items logic here
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
      body: SafeArea(
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // main heading left aligned:
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Library',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // library search bar
                  CustomSearchBar(hintText: "Search saved resources...", controller: controller, onTap: onTap, onChanged: (value) {}, onSubmit: (value) {}),
                  const SizedBox(height: 16),
                  // saved resources count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'You have $totalLibraryItems saved resources',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.onSurface.withAlpha(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // listview builder, vertical list of verstile cards
                  if (libraryItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          'No saved resources yet.',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurface.withAlpha(50),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: libraryItems.length,
                      itemBuilder: (context, index) {
                        final item = libraryItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: VerstileCard(
                            title: item['title'] ?? 'Untitled',
                            subtitle: item['description'] ?? 'No description',
                            onTap: () {
                              // Handle card tap
                            },
                            cardType: 'myNote',
                            authorName: item['uploaderName'] ?? 'Unknown',
                            likesCount: item['likesCount'] ?? 0,
                          ),
                        );
                      },
                    ),
                ],
              ),
            )
        ),
      )
    );
  }
}
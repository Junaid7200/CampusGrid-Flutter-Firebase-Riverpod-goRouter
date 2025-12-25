import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/search_bar.dart';
import 'package:campus_grid/src/shared/widgets/search_dpt_card.dart';
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';
import 'package:campus_grid/src/services/department_service.dart'
    as department_service;
import 'package:campus_grid/src/services/search_service.dart' as search_service;
import 'package:campus_grid/src/services/user_service.dart' as user_service;
import 'package:go_router/go_router.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.query, this.type});

  final String? query;
  final String? type;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _showDegrees = true;
  bool _showSubjects = true;
  bool _showNotes = true;

  List<Map<String, dynamic>> depts = [];
  Map<String, List<Map<String, dynamic>>> searchResults = {
    'degrees': [],
    'subjects': [],
    'notes': [],
  };
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      isLoading = true;
    });
    try {
      depts = await department_service.getDepartments();
    } catch (e) {
      print('Error fetching departments: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    searchQuery = query;

    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // If search is empty, show departments
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = {'degrees': [], 'subjects': [], 'notes': []};
      });
      return;
    }

    // Start new timer (debounce)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isSearching = true;
    });

    try {
      final results = await search_service.searchAll(
        query,
        searchDegrees: _showDegrees,
        searchSubjects: _showSubjects,
        searchNotes: _showNotes,
      );

      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        isSearching = false;
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text('Degrees'),
                    value: _showDegrees,
                    onChanged: (value) {
                      setState(() {
                        _showDegrees = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Subjects'),
                    value: _showSubjects,
                    onChanged: (value) {
                      setState(() {
                        _showSubjects = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Notes'),
                    value: _showNotes,
                    onChanged: (value) {
                      setState(() {
                        _showNotes = value ?? true;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {});
                    context.pop();
                    // Re-run search with new filters
                    if (searchQuery.isNotEmpty) {
                      _performSearch(searchQuery);
                    }
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore Departments and Search',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface.withAlpha(60),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        hintText: 'Search degrees, subjects, and notes',
                        controller: _searchController,
                        onTap: () {},
                        onChanged: _onSearchChanged,
                        onSubmit: (value) {},
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showFilterDialog(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE5E7EB)),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: colors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Show loading or results
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : isSearching
                    ? Center(child: CircularProgressIndicator())
                    : searchQuery.isEmpty
                    // Show departments when not searching
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: depts.length,
                        itemBuilder: (context, index) {
                          final dept = depts[index];
                          return DptCard(
                            title: dept['id'] ?? '',
                            subtitlle: dept['name'] ?? 'Unknown',
                            onTap: () {
                              context.push('/search/dpt/${dept['id']}/degree');
                            },
                          );
                        },
                      )
                    // Show search results
                    : _buildSearchResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final colors = Theme.of(context).colorScheme;
    final currentUserId = user_service.getCurrentUserId();

    final hasResults =
        searchResults['degrees']!.isNotEmpty ||
        searchResults['subjects']!.isNotEmpty ||
        searchResults['notes']!.isNotEmpty;

    if (!hasResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              color: colors.onSurface.withAlpha((0.6 * 255).toInt()),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Degrees Section
        if (searchResults['degrees']!.isNotEmpty) ...[
          Text(
            'Degrees (${searchResults['degrees']!.length})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          ...searchResults['degrees']!.map((degree) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: VerstileCard(
                title: degree['name'] ?? 'Untitled',
                subtitle: degree['description'] ?? 'No description',
                cardType: 'degree',
                onTap: () {
                  context.push(
                    '/search/dpt/${degree['dptId']}/degree/${degree['id']}/subject',
                  );
                },
              ),
            );
          }).toList(),
          SizedBox(height: 16),
        ],

        // Subjects Section
        if (searchResults['subjects']!.isNotEmpty) ...[
          Text(
            'Subjects (${searchResults['subjects']!.length})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          ...searchResults['subjects']!.map((subject) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: VerstileCard(
                title: subject['name'] ?? 'Untitled',
                subtitle: subject['description'] ?? 'No description',
                cardType: 'subject',
                resourcesCount: subject['notesCount'] ?? 0,
                onTap: () {
                  context.push(
                    '/search/dpt/${subject['dptId']}/degree/${subject['degId']}/subject/${subject['id']}/notes',
                  );
                },
              ),
            );
          }).toList(),
          SizedBox(height: 16),
        ],

        // Notes Section
        if (searchResults['notes']!.isNotEmpty) ...[
          Text(
            'Notes (${searchResults['notes']!.length})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          ...searchResults['notes']!.map((note) {
            final isMyNote = note['uploadedBy'] == currentUserId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: VerstileCard(
                title: note['title'] ?? 'Untitled',
                subtitle: note['description'] ?? 'No description',
                cardType: isMyNote ? 'myNote' : 'note',
                authorName: note['uploaderName'] ?? 'Unknown',
                likesCount: note['likesCount'] ?? 0,
                onTap: () async {
                  await context.push('/view_resource/${note['id']}');
                },
                noteId: note['id'],
                onRefresh: () => _performSearch(searchQuery),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}

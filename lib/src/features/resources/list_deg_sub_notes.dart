import "package:flutter/material.dart";
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:campus_grid/src/services/degree_service.dart' as degree_service;
import 'package:campus_grid/src/services/subject_service.dart'
    as subject_service;
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';
import 'package:campus_grid/src/services/user_service.dart' as user_service;
import 'package:go_router/go_router.dart';

class ListDegSubNotesPage extends StatefulWidget {
  const ListDegSubNotesPage({
    super.key,
    this.dptId,
    this.degId,
    this.subId,
    this.filterType,
  });

  final String? dptId;
  final String? degId;
  final String? subId;
  final String? filterType;

  @override
  State<ListDegSubNotesPage> createState() => _ListDegSubNotesPageState();
}

class _ListDegSubNotesPageState extends State<ListDegSubNotesPage> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String pageTitle = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // CASE 1: View All from home (filterType exists)
      if (widget.filterType != null) {
        if (widget.filterType == 'most_liked') {
          items = await note_service.getMostLikedNotes(limit: 50);
          pageTitle = "Most Liked Notes";
        } else if (widget.filterType == 'recent') {
          items = await note_service.getRecentNotes(limit: 50);
          pageTitle = "Recently Added Notes";
        }
      }
      // CASE 2: Show notes of a subject
      else if (widget.subId != null) {
        print("the subId is ${widget.subId}");
        items = await note_service.getNotesBySubject(widget.subId!);
        pageTitle = "Notes";
      }
      // CASE 3: Show subjects of a degree
      else if (widget.degId != null) {
        items = await subject_service.getSubjectsByDegree(widget.degId!);
        pageTitle = "Subjects";
      }
      // CASE 4: Show degrees of a department
      else if (widget.dptId != null) {
        items = await degree_service.getDegreesByDepartment(widget.dptId!);
        pageTitle = "Degrees";
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  String _determineCardType(item) {
    // If it's from filterType (notes from home)
    if (widget.filterType != null) {
      final currentUserId = user_service.getCurrentUserId();
      return item['uploadedBy'] == currentUserId ? "myNote" : "note";
    }

    // If it's from subject navigation (notes)
    if (widget.subId != null) {
      final currentUserId = user_service.getCurrentUserId();
      return item['uploadedBy'] == currentUserId ? "myNote" : "note";
    }

    // If it's subjects
    if (widget.degId != null) return "subject";

    // If it's degrees
    return "degree";
  }

  void _handleCardTap(item) async {
    // Notes: navigate to view resource
    if (widget.filterType != null || widget.subId != null) {
      await context.push('/view_resource/${item['id']}');
      _loadData();
    }
    // Subjects: navigate to notes of subject
    else if (widget.degId != null) {
      context.push(
        '/search/dpt/${widget.dptId}/degree/${widget.degId}/subject/${item['id']}/notes',
      );
    }
    // Degrees: navigate to subjects of degree
    else if (widget.dptId != null) {
      context.push('/search/dpt/${widget.dptId}/degree/${item['id']}/subject');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, style: TextStyle(color: colors.primary)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colors.primary, size: 32),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/home');
            },
            icon: Icon(Icons.home),
            color: colors.primary,
          ),
        ],
      ),
      floatingActionButton: widget.subId != null
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/new_resource');
                _loadData();
              },
              backgroundColor: colors.primary,
              shape: const CircleBorder(), // Makes it perfectly round
              child: Icon(Icons.add, color: colors.onPrimary),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Text(
                'No items found',
                style: TextStyle(fontSize: 18, color: colors.primary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final cardType = _determineCardType(item);
                final currentUserId = user_service.getCurrentUserId();
                final isMyNote = item['uploadedBy'] == currentUserId;

                return VerstileCard(
                  title: (item['title'] ?? item['name'] ?? 'Untitled')
                      .split(' ')
                      .map(
                        (word) => word.isEmpty
                            ? word
                            : word[0].toUpperCase() +
                                  word.substring(1).toLowerCase(),
                      )
                      .join(' '),
                  subtitle:
                      item['description'] != null &&
                          item['description'].isNotEmpty
                      ? item['description']
                      : (item['id']?.toUpperCase() ?? 'No description'),
                  cardType: cardType == 'note' && isMyNote
                      ? 'myNote'
                      : cardType,
                  likesCount: item['likesCount'],
                  resourcesCount: item['notesCount'],
                  authorName: item['uploaderName'],
                  onTap: () => _handleCardTap(item),
                  noteId: item['id'],
                  onRefresh: _loadData,
                );
              },
            ),
    );
  }
}

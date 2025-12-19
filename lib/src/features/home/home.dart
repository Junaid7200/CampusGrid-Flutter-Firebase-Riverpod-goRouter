import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_grid/src/shared/widgets/home_header.dart';
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';

// Placeholder data model
class NoteData {
  final String id;
  final String title;
  final String subtitle;
  final int likesCount;
  final bool isMyNote;

  NoteData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.likesCount,
    this.isMyNote = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User _user = FirebaseAuth.instance.currentUser!;

  // Placeholder data for most liked notes (horizontal list)
  final List<NoteData> _mostLikedNotes = [
    NoteData(
      id: '1',
      title: 'Introduction to Flutter',
      subtitle:
          'Learn the basics of Flutter development and widget composition.',
      likesCount: 245,
      isMyNote: true,
    ),
    NoteData(
      id: '2',
      title: 'Advanced Dart Programming',
      subtitle:
          'Deep dive into Dart language features, async/await, and streams.',
      likesCount: 198,
    ),
    NoteData(
      id: '3',
      title: 'State Management Guide',
      subtitle: 'Complete guide to Provider, Riverpod, and BLoC patterns.',
      likesCount: 187,
    ),
    NoteData(
      id: '4',
      title: 'Firebase Integration',
      subtitle: 'Authentication, Firestore, and Cloud Storage setup.',
      likesCount: 156,
    ),
    NoteData(
      id: '5',
      title: 'Material Design 3',
      subtitle: 'Modern UI/UX principles and Material You implementation.',
      likesCount: 142,
    ),
  ];

  // Placeholder data for recently added notes (vertical list)
  final List<NoteData> _recentlyAddedNotes = [
    NoteData(
      id: '6',
      title: 'Machine Learning Basics',
      subtitle: 'Introduction to ML algorithms and neural networks.',
      likesCount: 45,
    ),
    NoteData(
      id: '7',
      title: 'Database Design Patterns',
      subtitle: 'Best practices for relational and NoSQL databases.',
      likesCount: 67,
      isMyNote: true,
    ),
    NoteData(
      id: '8',
      title: 'RESTful API Development',
      subtitle:
          'Building scalable APIs with proper HTTP methods and status codes.',
      likesCount: 89,
    ),
    NoteData(
      id: '9',
      title: 'Git Workflow Strategies',
      subtitle: 'Branching, merging, and collaboration best practices.',
      likesCount: 34,
      isMyNote: true,
    ),
    NoteData(
      id: '10',
      title: 'Responsive Design Techniques',
      subtitle: 'Creating adaptive layouts for mobile, tablet, and desktop.',
      likesCount: 52,
    ),
    NoteData(
      id: '11',
      title: 'Algorithm Optimization',
      subtitle: 'Time and space complexity analysis for common algorithms.',
      likesCount: 78,
    ),
    NoteData(
      id: '12',
      title: 'Docker & Containerization',
      subtitle: 'Complete guide to containerizing applications with Docker.',
      likesCount: 91,
    ),
    NoteData(
      id: '13',
      title: 'Testing Best Practices',
      subtitle: 'Unit tests, widget tests, and integration tests in Flutter.',
      likesCount: 63,
      isMyNote: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Header
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
                          "${_user.displayName ?? 'User'}",
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
              onActionPressed: () {
                // TODO: Navigate to all popular notes
              },
            ),

            // Horizontal ListView for Most Liked Notes
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: _mostLikedNotes.length,
                itemBuilder: (context, index) {
                  final note = _mostLikedNotes[index];
                  return SizedBox(
                    width: 320,
                    child: VerstileCard(
                      title: note.title,
                      subtitle: note.subtitle,
                      cardType: note.isMyNote ? "myNote" : "note",
                      likesCount: note.likesCount,
                      onTap: () {
                        // TODO: Navigate to note details
                        print('Tapped on note: ${note.id}');
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
              onActionPressed: () {
                // TODO: Navigate to all recent notes
              },
            ),

            // Vertical ListView for Recently Added Notes
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentlyAddedNotes.length,
              itemBuilder: (context, index) {
                final note = _recentlyAddedNotes[index];
                return VerstileCard(
                  title: note.title,
                  subtitle: note.subtitle,
                  cardType: note.isMyNote ? "myNote" : "note",
                  likesCount: note.likesCount,
                  onTap: () {
                    // TODO: Navigate to note details
                    print('Tapped on note: ${note.id}');
                  },
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

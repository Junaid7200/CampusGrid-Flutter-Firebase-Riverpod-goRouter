import 'package:flutter/material.dart';
import 'package:campus_grid/src/services/user_service.dart' as user_service;
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:campus_grid/src/services/firebase_auth.dart' as auth_service;
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_grid/src/shared/widgets/outlined_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadUserNotes();
  }

  Map<String, dynamic>? userObject = {};
  List<Map<String, dynamic>> userNotes = [];
  bool isLoading = false;
  bool isDeleting = false;
  bool isLoggingOut = false;

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      userObject = await user_service.getCurrentUserProfile();
      setState(() {});
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserNotes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userId = user_service.getCurrentUserId();
      if (userId != null) {
        userNotes = await note_service.getUserNotes(userId);
        setState(() {});
      }
    } catch (e) {
      print('Error loading user notes: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(userObject);
    final colors = Theme.of(context).colorScheme;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 60),
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFE3F2FD), width: 4),
                    ),
                    child: Icon(Icons.person, size: 60, color: colors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userObject?['displayName'] ?? 'User Name'}'
                        .toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${userObject?['email'] ?? 'unknown email'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "${userObject?['notesCount'] ?? '3'}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Uploads",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${userObject?['likesReceived'] ?? '12'}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Total Likes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${userObject?['savedNotes'] ?? '5'}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Saved",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Uploads",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to upload page
                      context.push('/new_resource');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload_rounded,
                          size: 24,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Upload New",
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            if (userNotes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "You haven't uploaded any notes yet.",
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface.withAlpha((0.7 * 255).toInt()),
                  ),
                ),
              )
            else
              ...userNotes.map((note) {
                return VerstileCard(
                  title: note['title'] ?? 'Untitled',
                  subtitle: note['description'] ?? '',
                  likesCount: note['likesCount'] ?? 0,
                  authorName: userObject?['displayName'] ?? 'User',
                  cardType: "myNote",
                  onTap: () {
                    // Navigate to note details
                    context.push('/view_resource/${note['id']}');
                  },
                );
              }).toList(),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CustomOutlinedButton(
                      text: "Logout",
                      isLoading: isLoggingOut,
                      onPressed: () async {
                        setState(() {
                          isLoggingOut = true;
                        });
                        try {
                          await auth_service.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                        setState(() {
                          isLoggingOut = false;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    CustomOutlinedButton(
                      buttonColor: colors.error,
                      text: "Delete Account",
                      isLoading: isDeleting,
                      onPressed: () async {
                        setState(() {
                          isDeleting = true;
                        });
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Delete Account"),
                            content: Text(
                              "Are you sure you want to delete your account? This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: colors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await auth_service.deleteAccount();
                            if (context.mounted) {
                              context.go('/login');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Account deleted successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                        setState(() {
                          isDeleting = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

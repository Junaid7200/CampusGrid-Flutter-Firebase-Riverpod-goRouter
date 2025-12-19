import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/search_bar.dart';
import 'package:campus_grid/src/shared/widgets/search_dpt_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  List<Map<String, dynamic>> departments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final snapshot = await FirebaseFirestore.instance.collection('department').get();
    setState(() {
      departments = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
      isLoading = false;
    });
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
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {});
                    Navigator.of(context).pop();
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
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        hintText: 'Search degrees, subjects, and notes',
                        controller: TextEditingController(text: widget.query ?? ''),
                        onTap: () {},
                        onChanged: (value) {},
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
                
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: departments.length,
                        itemBuilder: (context, index) {
                          final dept = departments[index];
                          return DptCard(
                            title: dept['id'] ?? '',
                            subtitlle: dept['name'] ?? 'Unknown',
                            onTap: () {
                              print('Tapped: ${dept['id']}');
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
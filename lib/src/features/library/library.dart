import 'package:flutter/material.dart';




class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    this.query,
    this.sort,
    });
    final String? query;
    final String? sort;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Library Page. $query and $sort"),),
    );
  }
}
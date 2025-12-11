import 'package:flutter/material.dart';


class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key, 
    this.query, 
    this.type,
  });

  final String? query;
  final String? type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Search Page. $query and $type"),),
    );
  }
}
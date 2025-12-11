import "package:flutter/material.dart";


class ListDegSubNotesPage extends StatelessWidget {
  const ListDegSubNotesPage({
    super.key,
    required this.dptId,
    this.degId,
    this.subId,
  });

  final String dptId;
  final String? degId;
  final String? subId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Department ID: $dptId\nDegree ID: ${degId ?? "N/A"}\nSubject ID: ${subId ?? "N/A"}"),
      )
    );
  }
}
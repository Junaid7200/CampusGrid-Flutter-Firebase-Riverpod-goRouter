import "package:flutter/material.dart";


class ViewResourcePage extends StatelessWidget {
  const ViewResourcePage({
    super.key,
    required this.resourceId,
  });
  final String resourceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Viewing Resource ID: $resourceId"),
    ),
    );
  }
}
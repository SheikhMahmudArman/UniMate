// documentspage.dart

import 'package:flutter/material.dart';

class DocumentsPage extends StatelessWidget {
  final String title;
  final List<String> downloadedItems; // Add this property

  const DocumentsPage({
    super.key,
    required this.title,
    this.downloadedItems = const [], // Default to an empty list
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: downloadedItems.isEmpty
          ? const Center(
        child: Text(
          'No item is downloaded',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: downloadedItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(downloadedItems[index]),
          );
        },
      ),
    );
  }
}
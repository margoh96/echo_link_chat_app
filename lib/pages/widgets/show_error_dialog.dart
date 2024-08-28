// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowErrorDialog extends StatelessWidget {
  final String errorMessage;
  const ShowErrorDialog({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // You can trigger the dialog here based on your app's state or logic
    return Container(); // Placeholder widget, replace with actual UI component
  }

  // Call this function when you need to display the dialog
  void show(BuildContext context) {
    _showErrorDialog(context);
  }
}

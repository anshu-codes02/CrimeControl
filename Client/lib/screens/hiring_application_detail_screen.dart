import 'package:flutter/material.dart';
import '../models/hiring_application.dart';
import 'hiring_chat_screen.dart';

class HiringApplicationDetailScreen extends StatelessWidget {
  final HiringApplication application;
  const HiringApplicationDetailScreen({required this.application, Key? key})
    : super(key: key);
  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => HiringChatScreen(
              applicationId: application.id!,
              senderId: application.applicantId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${application.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Applicant : ${application.applicantName}'),
            Text('Email: ${application.applicantEmail ?? 'N/A'}'),
            SizedBox(height: 16),
            Text('Cover Letter:'),
            Text(application.coverLetter),
            SizedBox(height: 24),
            Text('Status: ${application.status ?? ''}'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _openChat(context),
              child: Text('Open Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

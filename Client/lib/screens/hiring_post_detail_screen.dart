import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hiring_post.dart';
import '../models/hiring_application.dart';
import '../services/hiring_service.dart';
import 'apply_to_hiring_post_screen.dart';
import 'hiring_application_detail_screen.dart';
import '../providers/auth_provider.dart';

class HiringPostDetailScreen extends StatefulWidget {
  final HiringPost post;
  const HiringPostDetailScreen({required this.post, Key? key})
    : super(key: key);

  @override
  State<HiringPostDetailScreen> createState() => _HiringPostDetailScreenState();
}

class _HiringPostDetailScreenState extends State<HiringPostDetailScreen> {
  late Future<List<HiringApplication>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = HiringService().getApplicationsForPost(
      widget.post.id!,
    );
  }

  void _refresh() {
    setState(() {
      _applicationsFuture = HiringService().getApplicationsForPost(
        widget.post.id!,
      );
    });
  }

  void _openApply() async {
    // TODO: Replace 2 with actual applicantId from auth/user provider
    final applied = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ApplyToHiringPostScreen(
              postId: widget.post.id!,
              applicantId: 2,
            ),
      ),
    );
    if (applied == true) _refresh();
  }

  void _openApplicationDetail(HiringApplication app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HiringApplicationDetailScreen(application: app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    final isRecruiter =
        currentUser != null && currentUser.id == widget.post.recruiterId;
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.caseType)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.post.overview),
            SizedBox(height: 16),
            Text('Location: ${widget.post.location}'),
            Text('Hourly Rate: ${widget.post.hourlyRate}'),
            Text('Status: ${widget.post.status ?? ''}'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _openApply,
              child: Text('Apply to this Post'),
            ),
            SizedBox(height: 24),
            if (isRecruiter) ...[
              Text(
                'Applications:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<HiringApplication>>(
                  future: _applicationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      // Hide the section if error (e.g., 403)
                      return SizedBox.shrink();
                    }
                    final apps = snapshot.data ?? [];
                    if (apps.isEmpty) {
                      return Center(child: Text('No applications yet.'));
                    }
                    return ListView.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, i) {
                        final app = apps[i];
                        return ListTile(
                          title: Text('Applicant #${app.applicantId}'),
                          subtitle: Text(app.coverLetter),
                          onTap: () => _openApplicationDetail(app),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

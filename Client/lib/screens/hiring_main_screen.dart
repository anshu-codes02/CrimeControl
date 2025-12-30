import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hiring_post.dart';
import '../services/hiring_service.dart';
import '../providers/auth_provider.dart';
import 'create_hiring_post_screen.dart';
import 'hiring_post_detail_screen.dart';

class HiringMainScreen extends StatefulWidget {
  @override
  State<HiringMainScreen> createState() => _HiringMainScreenState();
}

class _HiringMainScreenState extends State<HiringMainScreen> {
  late Future<List<HiringPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = HiringService().getPosts();
  }

  void _refresh() {
    setState(() {
      _postsFuture = HiringService().getPosts();
    });
  }

  void _openCreatePost(int recruiterId) async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateHiringPostScreen(recruiterId: recruiterId),
      ),
    );
    if (created == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isRecruiter = user != null && user.role == 'RECRUITER';
    return Scaffold(
      appBar: AppBar(
        title: Text('Hiring'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refresh),
          if (isRecruiter)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openCreatePost(user!.id!),
            ),
        ],
      ),
      body: FutureBuilder<List<HiringPost>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(child: Text('No hiring posts yet.'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final post = posts[i];
              return ListTile(
                title: Text(post.caseType),
                subtitle: Text(post.overview),
                trailing: Text(post.status ?? ''),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HiringPostDetailScreen(post: post),
                      ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}

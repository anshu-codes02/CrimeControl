import 'package:flutter/material.dart';
import '../models/case.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/case_service.dart';
import '../widgets/case_tags_display.dart';
import '../constants/app_constants.dart';
import 'package:video_player/video_player.dart';
import '../screens/profile_screen.dart'; // Added import for ProfileScreen

class CaseDetailScreen extends StatefulWidget {
  final Case caseItem;
  const CaseDetailScreen({super.key, required this.caseItem});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  late Future<List<Comment>> _commentsFuture;
  final AuthService _authService = AuthService();
  final CaseService _caseService = CaseService();
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;
  bool _isPerformingAction = false;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  User? _currentUser;
  Map<String, dynamic>? _deletionStatus;

  @override
  void initState() {
    super.initState();
    // Print all case details when the screen is opened
    final c = widget.caseItem;
    print(
      'Case details: id= [33m${c.id} [0m, title=${c.title}, description=${c.description}, status=${c.status}, postedAt=${c.postedAt}, imageUrl=${c.imageUrl}, mediaUrl=${c.mediaUrl}',
    );
    print('darpa '+c.imageUrl.toString());
    print('DEBUG: imageUrls = ${c.imageUrls}');
    print('DEBUG: imageUrls length = ${c.imageUrls.length}');
    print('DEBUG: imageUrls isEmpty = ${c.imageUrls.isEmpty}');
    _commentsFuture = _authService.fetchCaseComments(widget.caseItem.id);

    _initVideo();
    _loadCurrentUser();
    if (widget.caseItem.isClosed) {
      _checkDeletionStatus();
    }
  }

  void _initVideo() {
    final url = widget.caseItem.mediaUrl;
    if (url != null && url.isNotEmpty) {
      // Check if it's a video by looking for video extensions in the URL
      // or if it's from Firebase Storage and contains video extensions
      final isVideo = url.contains('.mp4') ||
          url.contains('.webm') ||
          url.contains('.mov') ||
          url.contains('.avi') ||
          url.contains('.mkv') ||
          (url.contains('firebasestorage.googleapis.com') && 
           (url.contains('video') || url.contains('.mp4') || url.contains('.webm') || url.contains('.mov')));
      
      if (isVideo) {
        _videoController = VideoPlayerController.network(url)
          ..initialize().then((_) {
            setState(() {
              _videoInitialized = true;
            });
          }).catchError((error) {
            print('Video initialization error: $error');
            setState(() {
              _videoInitialized = false;
            });
          });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    setState(() {
      _isPosting = true;
    });
    try {
      await _authService.postCaseComment(widget.caseItem.id, content);
      setState(() {
        _commentsFuture = _authService.fetchCaseComments(widget.caseItem.id);
        _commentController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _checkDeletionStatus() async {
    try {
      final status = await _caseService.canDeleteCase(widget.caseItem.id);
      setState(() {
        _deletionStatus = status;
      });
    } catch (e) {
      print('Error checking deletion status: $e');
    }
  }

  Future<void> _closeCase() async {
    setState(() {
      _isPerformingAction = true;
    });

    try {
      final result = await _caseService.closeCase(widget.caseItem.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Case closed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh deletion status
      await _checkDeletionStatus();
      
      // Refresh the page or notify parent
      Navigator.of(context).pop(true); // Return true to indicate case was updated
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<void> _deleteCase() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: Text('Are you sure you want to permanently delete "${widget.caseItem.title}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isPerformingAction = true;
    });

    try {
      final result = await _caseService.deleteCase(widget.caseItem.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Case deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back since case is deleted
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  bool _canUserManageCase() {
    if (_currentUser == null) return false;
    
    // Check if current user is the poster or an admin
    final currentUserId = _currentUser!.id;
    final isAdmin = _currentUser!.role == 'ADMIN';
    final isPoster = widget.caseItem.posterId == currentUserId;
    
    return isAdmin || isPoster;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.caseItem;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Case Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.title,
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.status,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (c.postedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    c.postedAt!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Tags display
            if (c.tags.isNotEmpty) ...[
              CaseTagsDisplay(
                tags: c.tags,
                maxVisible: 5,
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            
            // Multiple Images Gallery
            if (c.imageUrls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evidence Images (${c.imageUrls.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: c.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _showImageDialog(c.imageUrls[index]),
                            child: Hero(
                              tag: 'image_${c.id}_$index',
                              child: Card(
                                margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  c.imageUrls[index],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    height: 120,
                                    width: 120,
                                    color: theme.colorScheme.surface,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 24,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            // Fallback to single image for backward compatibility
            else if (c.imageUrl != null && c.imageUrl!.isNotEmpty)
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onTap: () => _showImageDialog(c.imageUrl!),
                  child: Hero(
                    tag: 'image_${c.id}_single',
                    child: Image.network(
                      c.imageUrl!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 220,
                        color: theme.colorScheme.surface,
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (c.mediaUrl != null && c.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: _videoController != null && _videoInitialized
                    ? Column(
                        children: [
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: Stack(
                              children: [
                                VideoPlayer(_videoController!),
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_videoController!.value.isPlaying) {
                                          _videoController!.pause();
                                        } else {
                                          _videoController!.play();
                                        }
                                      });
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Center(
                                        child: Icon(
                                          _videoController!.value.isPlaying
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_filled,
                                          size: 64,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                ),
                                Expanded(
                                  child: VideoProgressIndicator(
                                    _videoController!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: theme.colorScheme.primary,
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _videoController != null
                        ? Container(
                            height: 200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Loading video...'),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.video_file,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Media File',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.mediaUrl!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              c.description,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 16),
            
            // Case management actions (only show to case poster or admin)
            if (_canUserManageCase()) ...[
              _buildCaseManagementSection(),
              const SizedBox(height: 16),
            ],
            
            const SizedBox(height: 8),
            const Divider(),
            Text('Comments', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Error loading comments: \\${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No comments yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  );
                }
                final comments = snapshot.data!;
                return Column(
                  children: comments.map((c) => _buildCommentItem(c)).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    minLines: 1,
                    maxLines: 3,
                    enabled: !_isPosting,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isPosting ? null : _postComment,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isPosting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: comment.userId),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            comment.author.isNotEmpty ? comment.author : 'Unknown',
            style: theme.textTheme.labelLarge,
          ),
          subtitle: Text(comment.content, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }

  Widget _buildCaseManagementSection() {
    final theme = Theme.of(context);
    final c = widget.caseItem;
    final isClosed = c.isClosed;
    final canDelete = _deletionStatus?['canDelete'] ?? false;
    final hoursUntilDeletable = _deletionStatus?['hoursUntilDeletable'] ?? 0;

    return Card(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Case Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (!isClosed) ...[
              // Case is open - show close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPerformingAction ? null : _closeCase,
                  icon: _isPerformingAction 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock),
                  label: const Text('Close Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Closing the case will start a 24-hour timer after which the case can be permanently deleted.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              // Case is closed - show deletion info and delete button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canDelete ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canDelete ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          canDelete ? Icons.delete_forever : Icons.timer,
                          color: canDelete ? Colors.red : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          canDelete ? 'Ready for Deletion' : 'Deletion Timer Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: canDelete ? Colors.red : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (canDelete) ...[
                      const Text(
                        'This case can now be permanently deleted.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ] else ...[
                      Text(
                        'This case can be deleted in $hoursUntilDeletable hours.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (canDelete)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPerformingAction ? null : _deleteCase,
                    icon: _isPerformingAction 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_forever),
                    label: const Text('Delete Case Permanently'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey[900],
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

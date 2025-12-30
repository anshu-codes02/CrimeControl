export 'dm_list_screen.dart' show DMInboxScreen;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import 'dm_chat_screen.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class DMInboxScreen extends StatefulWidget {
  const DMInboxScreen({Key? key}) : super(key: key);

  @override
  State<DMInboxScreen> createState() => _DMInboxScreenState();
}

class _DMInboxScreenState extends State<DMInboxScreen> {
  List<dynamic> groupedDMs = [];
  bool isLoading = true;
  Map<int, bool> expandedCases = {};

  @override
  void initState() {
    super.initState();
    fetchGroupedDMs();
  }

  Future<void> fetchGroupedDMs() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/dm/grouped'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        groupedDMs = data;
        isLoading = false;
        expandedCases = {for (var c in data) c['caseId'] as int: false};
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToChat(Map user, Map caseMap) async {
    final peerUser = User(id: user['userId'], username: user['userName']);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DMChatScreen(peerUser: peerUser)),
    );
    fetchGroupedDMs();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('DM Inbox')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : groupedDMs.isEmpty
              ? Center(
                child: Text(
                  'No conversations yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              )
              : ListView.builder(
                itemCount: groupedDMs.length,
                itemBuilder: (context, caseIdx) {
                  final caseMap = groupedDMs[caseIdx];
                  final caseId = caseMap['caseId'] as int;
                  final caseTitle = caseMap['caseTitle'] ?? 'Unknown Case';
                  final users = caseMap['users'] as List<dynamic>;
                  final isExpanded = expandedCases[caseId] ?? false;
                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            caseTitle,
                            style: theme.textTheme.titleLarge,
                          ),
                          trailing: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: theme.colorScheme.primary,
                          ),
                          onTap: () {
                            setState(() {
                              expandedCases[caseId] = !isExpanded;
                            });
                          },
                        ),
                        if (isExpanded)
                          ...users
                              .where(
                                (user) => (user['messages'] as List).isNotEmpty,
                              )
                              .map(
                                (user) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.15),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    user['userName'] ?? 'Unknown',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  subtitle: Text(
                                    '${(user['messages'] as List).length} messages',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  onTap: () => _navigateToChat(user, caseMap),
                                ),
                              ),
                        if (isExpanded &&
                            users
                                .where(
                                  (user) =>
                                      (user['messages'] as List).isNotEmpty,
                                )
                                .isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'No messages in this case',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../services/auth_service.dart';

class DMChatScreen extends StatefulWidget {
  final User peerUser;
  final int? caseId;
  final String? caseTitle;
  final VoidCallback? onMessageSent;
  const DMChatScreen({
    Key? key,
    required this.peerUser,
    this.caseId,
    this.caseTitle,
    this.onMessageSent,
  }) : super(key: key);

  @override
  State<DMChatScreen> createState() => _DMChatScreenState();
}

class _DMChatScreenState extends State<DMChatScreen> {
  List<dynamic> messages = [];
  final TextEditingController _controller = TextEditingController();
  StompClient? stompClient;
  User? currentUser;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    initChat();
  }

  Future<void> initChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    currentUser = authProvider.user;
    await fetchChatHistory();
    await connectWebSocketWithAuth();
  }

  Future<void> fetchChatHistory() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}/dm/chat/${widget.peerUser.id}?caseId=${widget.caseId ?? ''}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        messages = json.decode(response.body);
      });
    }
  }

  Future<void> connectWebSocketWithAuth() async {
    final token = await AuthService().getToken();
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: '${AppConstants.baseUrl.replaceFirst('/api', '')}/ws',
        onConnect: onConnect,
        onWebSocketError: (dynamic error) => print(error),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    stompClient!.activate();
  }

  void onConnect(StompFrame frame) {
    setState(() {
      isConnected = true;
    });
    stompClient!.subscribe(
      destination: '/topic/dm.${currentUser!.id}',
      callback: (frame) {
        if (frame.body != null) {
          final msg = json.decode(frame.body!);
          if ((msg['sender']['id'] == widget.peerUser.id &&
                  msg['receiver']['id'] == currentUser!.id) ||
              (msg['sender']['id'] == currentUser!.id &&
                  msg['receiver']['id'] == widget.peerUser.id)) {
            setState(() {
              messages.add(msg);
            });
          }
        }
      },
    );
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty || stompClient == null || !isConnected)
      return;
    final msg = {
      'senderId': currentUser!.id,
      'receiverId': widget.peerUser.id,
      'content': _controller.text.trim(),
      'caseId': widget.caseId,
    };
    stompClient!.send(destination: '/app/dm.send', body: json.encode(msg));
    setState(() {
      messages.add({
        'sender': {'id': currentUser!.id},
        'receiver': {'id': widget.peerUser.id},
        'content': _controller.text.trim(),
        'caseId': widget.caseId,
      });
    });
    _controller.clear();
    if (widget.onMessageSent != null) {
      widget.onMessageSent!();
    }
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.caseTitle != null ? '${widget.caseTitle!} - ' : '') +
              (widget.peerUser.displayName.isNotEmpty
                  ? widget.peerUser.displayName
                  : (widget.peerUser.username ?? 'User')),
        ),
      ),
      body: Column(
        children: [
          if (!isConnected)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe =
                    msg['sender'] != null &&
                    msg['sender']['id'] == currentUser?.id;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg['content'] ?? 'No content'),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    enabled: isConnected,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isConnected ? sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

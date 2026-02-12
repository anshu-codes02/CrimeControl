import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DMChatScreen extends StatefulWidget {
  final User peerUser;
  final String? caseId;
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
  User? currentUser;
  IO.Socket? socket;
bool isConnected = false;

  @override
  void initState() {
    super.initState();
    initChat();
  }

  Future<void> initChat() async {
    currentUser = await AuthService().getCurrentUser();
    await fetchChatHistory();
    await connectSocketWithAuth();
  }

  Future<void> fetchChatHistory() async {
    final token = await AuthService().getToken();
    final uri = '${AppConstants.baseUrl}/dm/chat/${widget.peerUser.id}/${widget.caseId}';
    final response = await http.get(
      Uri.parse(
        uri,
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    print("=== CHAT HISTORY DEBUG ===");
    print('Requesting chat history with peerUserId: ${widget.peerUser.id} and caseId: ${widget.caseId}');
    print("currentUserId: ${currentUser?.id}");
    print('Response status: ${response.statusCode}');
    print('Response body: ${json.decode(response.body)}');
    print("==========================");
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (!mounted) return;

  setState(() {
    messages = decoded['data'] ?? [];
  });
    }
  }

  Future<void> connectSocketWithAuth() async {
    final token = await AuthService().getToken();
    socket = IO.io(
    AppConstants.baseUrl.replaceFirst('/api', ''),
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .enableAutoConnect()
        .build(),
  );

  socket!.onConnect((_) {
     if (!mounted) return;
    setState(() {
      isConnected = true;
    });
  });

  socket!.onDisconnect((_) {
     if (!mounted) return;
    setState(() {
      isConnected = false;
    });
  });

  socket!.on('dm:new',(data){
     if (!mounted) return;
    if(data['senderId']==widget.peerUser.id && data['receiverId']==currentUser!.id ||
       data['senderId']==currentUser!.id && data['receiverId']==widget.peerUser.id){
         setState(() {
           messages.add(data);
         });
       }
  });
}


  void sendMessage() {
    if (_controller.text.trim().isEmpty || socket == null || !isConnected)
      return;
    final msg = {
      'senderId': currentUser!.id,
      'receiverId': widget.peerUser.id,
      'content': _controller.text.trim(),
      'caseId': widget.caseId,
    };
    socket!.emit('dm:send', msg);

    setState(() {
      messages.add({
        'sender':{ '_id': currentUser!.id, 'username': currentUser!.username},
        'receiverId': {'_id': widget.peerUser.id, 'username': widget.peerUser.username},
        'content': _controller.text.trim(),
        'caseId': widget.caseId,
      });
    });
    _controller.clear();
    widget.onMessageSent?.call();
  }

  @override
  void dispose() {
    socket?.off('dm:new');
  socket?.off('connect');
  socket?.off('disconnect');
  socket?.disconnect();
  socket?.dispose();
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
                    msg['sender']['_id'] == currentUser?.id;
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

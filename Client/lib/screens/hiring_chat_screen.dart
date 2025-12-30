import 'package:flutter/material.dart';
import '../models/hiring_chat_message.dart';
import '../services/hiring_service.dart';

class HiringChatScreen extends StatefulWidget {
  final int applicationId;
  final int senderId;
  const HiringChatScreen({
    required this.applicationId,
    required this.senderId,
    Key? key,
  }) : super(key: key);

  @override
  State<HiringChatScreen> createState() => _HiringChatScreenState();
}

class _HiringChatScreenState extends State<HiringChatScreen> {
  late Future<List<HiringChatMessage>> _messagesFuture;
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _messagesFuture = HiringService().getChatMessages(widget.applicationId);
    });
  }

  void _send() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      final msg = HiringChatMessage(
        applicationId: widget.applicationId,
        senderId: widget.senderId,
        message: _controller.text.trim(),
      );
      await HiringService().sendChatMessage(msg);
      _controller.clear();
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<HiringChatMessage>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    return ListTile(
                      title: Text(msg.message),
                      subtitle: Text('Sender: ${msg.senderId}'),
                      trailing:
                          msg.timestamp != null
                              ? Text(
                                msg.timestamp!.toLocal().toString().substring(
                                  0,
                                  16,
                                ),
                              )
                              : null,
                    );
                  },
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
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                _sending
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircularProgressIndicator(),
                    )
                    : IconButton(icon: Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

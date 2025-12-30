import 'package:flutter/material.dart';
import '../models/hiring_application.dart';
import '../services/hiring_service.dart';

class ApplyToHiringPostScreen extends StatefulWidget {
  final int postId;
  final int applicantId;
  const ApplyToHiringPostScreen({
    required this.postId,
    required this.applicantId,
    Key? key,
  }) : super(key: key);

  @override
  State<ApplyToHiringPostScreen> createState() =>
      _ApplyToHiringPostScreenState();
}

class _ApplyToHiringPostScreenState extends State<ApplyToHiringPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final application = HiringApplication(
        postId: widget.postId,
        applicantId: widget.applicantId,
        coverLetter: _coverLetterController.text,
      );
      await HiringService().applyToPost(application);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply to Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _coverLetterController,
                decoration: InputDecoration(labelText: 'Cover Letter'),
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 24),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, child: Text('Apply')),
            ],
          ),
        ),
      ),
    );
  }
}

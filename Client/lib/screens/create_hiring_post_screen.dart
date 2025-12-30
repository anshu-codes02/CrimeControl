import 'package:flutter/material.dart';
import '../models/hiring_post.dart';
import '../services/hiring_service.dart';

class CreateHiringPostScreen extends StatefulWidget {
  final int recruiterId;
  const CreateHiringPostScreen({required this.recruiterId, Key? key})
    : super(key: key);

  @override
  State<CreateHiringPostScreen> createState() => _CreateHiringPostScreenState();
}

class _CreateHiringPostScreenState extends State<CreateHiringPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseTypeController = TextEditingController();
  final _overviewController = TextEditingController();
  final _locationController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final post = HiringPost(
        recruiterId: widget.recruiterId,
        hourlyRate: double.parse(_hourlyRateController.text),
        caseType: _caseTypeController.text,
        overview: _overviewController.text,
        location: _locationController.text,
      );
      await HiringService().createPost(post);
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
      appBar: AppBar(title: Text('Create Hiring Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _caseTypeController,
                decoration: InputDecoration(labelText: 'Case Type'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _overviewController,
                decoration: InputDecoration(labelText: 'Overview'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _hourlyRateController,
                decoration: InputDecoration(labelText: 'Hourly Rate'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 24),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submit,
                    child: Text('Create Post'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

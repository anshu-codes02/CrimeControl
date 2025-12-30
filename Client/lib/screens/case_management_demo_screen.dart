import 'package:flutter/material.dart';
import '../services/case_service.dart';

class CaseManagementDemoScreen extends StatefulWidget {
  const CaseManagementDemoScreen({Key? key}) : super(key: key);

  @override
  State<CaseManagementDemoScreen> createState() => _CaseManagementDemoScreenState();
}

class _CaseManagementDemoScreenState extends State<CaseManagementDemoScreen> {
  final CaseService _caseService = CaseService();
  final TextEditingController _caseIdController = TextEditingController();
  Map<String, dynamic>? _caseData;
  Map<String, dynamic>? _deletionStatus;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Management Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Management Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How Case Management Works:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Only the person who posted the case can close/delete it'),
                  Text('2. Cases must be closed before they can be deleted'),
                  Text('3. After closing, wait 24 hours before deletion is allowed'),
                  Text('4. The close button appears in Case Detail Screen'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Test specific case
            const Text(
              'Test Case Management:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caseIdController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Case ID',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 1',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkCaseStatus,
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Check'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Case information
            if (_caseData != null) ...[
              _buildCaseInfo(),
              const SizedBox(height: 16),
            ],
            
            // Deletion status
            if (_deletionStatus != null) ...[
              _buildDeletionStatus(),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            if (_caseData != null) ...[
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCaseInfo() {
    final status = _caseData!['status'] ?? 'UNKNOWN';
    final title = _caseData!['title'] ?? 'Untitled';
    final isClosed = status.toUpperCase() == 'CLOSED';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Information:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Title: $title'),
            Row(
              children: [
                const Text('Status: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_caseData!['postedBy'] != null) ...[
              Text('Posted by: ${_caseData!['postedBy']['username'] ?? 'Unknown'}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionStatus() {
    final canDelete = _deletionStatus!['canDelete'] ?? false;
    final isClosed = _deletionStatus!['isClosed'] ?? false;
    final hoursUntilDeletable = _deletionStatus!['hoursUntilDeletable'] ?? 0;
    
    return Card(
      color: canDelete ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canDelete ? Icons.delete_forever : Icons.timer,
                  color: canDelete ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deletion Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canDelete ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isClosed) ...[
              const Text('⚠️ Case must be closed before it can be deleted'),
            ] else if (canDelete) ...[
              const Text('✅ Case can be deleted now!'),
            ] else ...[
              Text('⏳ Case can be deleted in $hoursUntilDeletable hours'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _caseData!['status'] ?? 'UNKNOWN';
    final isClosed = status.toUpperCase() == 'CLOSED';
    final canDelete = _deletionStatus?['canDelete'] ?? false;
    
    return Column(
      children: [
        if (!isClosed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _closeCase,
              icon: const Icon(Icons.lock),
              label: const Text('Close Case'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        if (canDelete) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteCase,
              icon: const Icon(Icons.delete_forever),
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
    );
  }

  Future<void> _checkCaseStatus() async {
    final caseIdText = _caseIdController.text.trim();
    if (caseIdText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a case ID')),
      );
      return;
    }

    final caseId = int.tryParse(caseIdText);
    if (caseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid case ID')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _caseData = null;
      _deletionStatus = null;
    });

    try {
      // Get case data
      final caseData = await _caseService.getCaseById(caseId);
      
      // Get deletion status
      final deletionStatus = await _caseService.canDeleteCase(caseId);
      
      setState(() {
        _caseData = caseData;
        _deletionStatus = deletionStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _closeCase() async {
    final caseId = int.parse(_caseIdController.text);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _caseService.closeCase(caseId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Case closed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh status
      await _checkCaseStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: const Text('Are you sure you want to permanently delete this case?\n\nThis action cannot be undone.'),
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

    final caseId = int.parse(_caseIdController.text);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _caseService.deleteCase(caseId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Case deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear data since case is deleted
      setState(() {
        _caseData = null;
        _deletionStatus = null;
        _caseIdController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _caseIdController.dispose();
    super.dispose();
  }
}

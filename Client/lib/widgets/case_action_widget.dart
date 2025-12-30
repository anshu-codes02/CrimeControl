import 'package:flutter/material.dart';
import '../services/case_service.dart';

class CaseActionWidget extends StatefulWidget {
  final int caseId;
  final String caseTitle;
  final String caseStatus;
  final VoidCallback? onCaseUpdated;

  const CaseActionWidget({
    Key? key,
    required this.caseId,
    required this.caseTitle,
    required this.caseStatus,
    this.onCaseUpdated,
  }) : super(key: key);

  @override
  State<CaseActionWidget> createState() => _CaseActionWidgetState();
}

class _CaseActionWidgetState extends State<CaseActionWidget> {
  final CaseService _caseService = CaseService();
  bool _isLoading = false;
  Map<String, dynamic>? _deletionStatus;

  @override
  void initState() {
    super.initState();
    if (widget.caseStatus.toLowerCase() == 'closed') {
      _checkDeletionStatus();
    }
  }

  Future<void> _checkDeletionStatus() async {
    try {
      final status = await _caseService.canDeleteCase(widget.caseId);
      setState(() {
        _deletionStatus = status;
      });
    } catch (e) {
      print('Error checking deletion status: $e');
    }
  }

  Future<void> _closeCase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _caseService.closeCase(widget.caseId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Case closed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh deletion status
      await _checkDeletionStatus();
      
      if (widget.onCaseUpdated != null) {
        widget.onCaseUpdated!();
      }
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
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: Text('Are you sure you want to permanently delete "${widget.caseTitle}"?'),
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
      _isLoading = true;
    });

    try {
      final result = await _caseService.deleteCase(widget.caseId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Case deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.onCaseUpdated != null) {
        widget.onCaseUpdated!();
      }
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
  Widget build(BuildContext context) {
    final isClosed = widget.caseStatus.toLowerCase() == 'closed';
    final canDelete = _deletionStatus?['canDelete'] ?? false;
    final hoursUntilDeletable = _deletionStatus?['hoursUntilDeletable'] ?? 0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isClosed ? Icons.lock : Icons.folder_open,
                  color: isClosed ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.caseTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.caseStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (!isClosed) ...[
              // Case is open - show close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _closeCase,
                  icon: _isLoading 
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
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Closing the case will start a 24-hour timer after which the case can be permanently deleted.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ] else ...[
              // Case is closed - show deletion info and delete button
              if (_deletionStatus != null) ...[
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
                      onPressed: _isLoading ? null : _deleteCase,
                      icon: _isLoading 
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
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class DeletableCasesScreen extends StatefulWidget {
  const DeletableCasesScreen({Key? key}) : super(key: key);

  @override
  State<DeletableCasesScreen> createState() => _DeletableCasesScreenState();
}

class _DeletableCasesScreenState extends State<DeletableCasesScreen> {
  final CaseService _caseService = CaseService();
  List<Map<String, dynamic>> _deletableCases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletableCases();
  }

  Future<void> _loadDeletableCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cases = await _caseService.getDeletableCases();
      setState(() {
        _deletableCases = cases;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading deletable cases: ${e.toString()}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deletable Cases'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletableCases.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_sweep,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No cases ready for deletion',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDeletableCases,
                  child: ListView.builder(
                    itemCount: _deletableCases.length,
                    itemBuilder: (context, index) {
                      final caseData = _deletableCases[index];
                      return CaseActionWidget(
                        caseId: caseData['id'],
                        caseTitle: caseData['title'] ?? 'Untitled Case',
                        caseStatus: caseData['status'] ?? 'UNKNOWN',
                        onCaseUpdated: _loadDeletableCases,
                      );
                    },
                  ),
                ),
    );
  }
}

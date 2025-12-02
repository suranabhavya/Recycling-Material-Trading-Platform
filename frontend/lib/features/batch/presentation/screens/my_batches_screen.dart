import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycling_platform/core/theme/app_colors.dart';
import 'package:recycling_platform/core/utils/color_extensions.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/batch/data/models/batch_model.dart';
import 'package:recycling_platform/features/batch/presentation/providers/batch_provider.dart';

class MyBatchesScreen extends ConsumerStatefulWidget {
  const MyBatchesScreen({super.key});

  @override
  ConsumerState<MyBatchesScreen> createState() => _MyBatchesScreenState();
}

class _MyBatchesScreenState extends ConsumerState<MyBatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BatchModel> _draftBatches = [];
  List<BatchModel> _submittedBatches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(batchRepositoryProvider);
      final allBatches = await repository.getAllBatches();

      setState(() {
        _draftBatches = allBatches.where((b) => b.isDraft).toList();
        _submittedBatches = allBatches.where((b) => b.isSubmitted || b.isApproved || b.isRejected).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isLead = user?.roleTemplate?.name.toUpperCase() == 'LEAD';

    // Redirect if not lead
    if (!isLead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Lead privileges required.'),
            backgroundColor: AppColors.error,
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Batches',
                            style: GoogleFonts.domine(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manage your batches',
                            style: GoogleFonts.domine(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box, color: Colors.white),
                      onPressed: () async {
                        final result = await context.push('/create-batch');
                        if (result == true) {
                          _loadBatches();
                        }
                      },
                      tooltip: 'Create Batch',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadBatches,
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacityValue(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacityValue(0.6),
                  labelStyle: GoogleFonts.domine(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Draft'),
                    Tab(text: 'Submitted'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              'Loading batches...',
                              style: GoogleFonts.domine(
                                color: Colors.white.withOpacityValue(0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 60,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    style: GoogleFonts.domine(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _loadBatches,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: GoogleFonts.domine(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDraftTab(),
                              _buildSubmittedTab(),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftTab() {
    if (_draftBatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.drafts_outlined,
                size: 80,
                color: Colors.white.withOpacityValue(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'No Draft Batches',
                style: GoogleFonts.domine(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new batch to get started',
                style: GoogleFonts.domine(
                  fontSize: 14,
                  color: Colors.white.withOpacityValue(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBatches,
      color: AppColors.primary,
      backgroundColor: AppColors.primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _draftBatches.length,
        itemBuilder: (context, index) {
          final batch = _draftBatches[index];
          return _buildDraftBatchCard(batch, index);
        },
      ),
    );
  }

  Widget _buildSubmittedTab() {
    if (_submittedBatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send_outlined,
                size: 80,
                color: Colors.white.withOpacityValue(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'No Submitted Batches',
                style: GoogleFonts.domine(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit draft batches to send them for admin approval',
                style: GoogleFonts.domine(
                  fontSize: 14,
                  color: Colors.white.withOpacityValue(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBatches,
      color: AppColors.primary,
      backgroundColor: AppColors.primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _submittedBatches.length,
        itemBuilder: (context, index) {
          final batch = _submittedBatches[index];
          return _buildSubmittedBatchCard(batch, index);
        },
      ),
    );
  }

  Widget _buildDraftBatchCard(BatchModel batch, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacityValue(0.2),
            Colors.blue.withOpacityValue(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacityValue(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacityValue(0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.drafts,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: GoogleFonts.domine(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${batch.materialCount} materials',
                      style: GoogleFonts.domine(
                        fontSize: 13,
                        color: Colors.white.withOpacityValue(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (batch.description != null && batch.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              batch.description!,
              style: GoogleFonts.domine(
                fontSize: 13,
                color: Colors.white.withOpacityValue(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submitBatch(batch),
              icon: const Icon(Icons.send, color: Colors.white),
              label: Text(
                'Submit for Approval',
                style: GoogleFonts.domine(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedBatchCard(BatchModel batch, int index) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (batch.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Approved';
    } else if (batch.isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacityValue(0.2),
            statusColor.withOpacityValue(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacityValue(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusColor.withOpacityValue(0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: GoogleFonts.domine(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${batch.materialCount} materials',
                      style: GoogleFonts.domine(
                        fontSize: 13,
                        color: Colors.white.withOpacityValue(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacityValue(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.domine(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (batch.description != null && batch.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              batch.description!,
              style: GoogleFonts.domine(
                fontSize: 13,
                color: Colors.white.withOpacityValue(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (batch.submittedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white.withOpacityValue(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Submitted ${_formatDate(batch.submittedAt)}',
                  style: GoogleFonts.domine(
                    fontSize: 12,
                    color: Colors.white.withOpacityValue(0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _submitBatch(BatchModel batch) async {
    if (!mounted) return;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Submit Batch',
          style: GoogleFonts.domine(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to submit "${batch.name}" for admin approval? This action cannot be undone.',
          style: GoogleFonts.domine(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.domine(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.domine(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(batchRepositoryProvider);
      await repository.submitBatch(batch.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${batch.name} submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      _loadBatches();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit batch: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}


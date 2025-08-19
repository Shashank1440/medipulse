import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/medication_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sync_status_widget.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({Key? key}) : super(key: key);

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSortOption = 'Name';
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));

  // Mock medication data
  final List<Map<String, dynamic>> _allMedications = [
    {
      "id": 1,
      "name": "Metformin",
      "dosage": "500mg",
      "form": "Tablet",
      "frequency": "Twice daily",
      "nextDose": "2:00 PM",
      "status": "Active",
      "adherencePercentage": 92,
      "category": "Diabetes",
      "hasConflict": false,
      "dateAdded": DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      "id": 2,
      "name": "Lisinopril",
      "dosage": "10mg",
      "form": "Tablet",
      "frequency": "Once daily",
      "nextDose": "8:00 AM",
      "status": "Active",
      "adherencePercentage": 88,
      "category": "Blood Pressure",
      "hasConflict": true,
      "dateAdded": DateTime.now().subtract(const Duration(days: 25)),
    },
    {
      "id": 3,
      "name": "Atorvastatin",
      "dosage": "20mg",
      "form": "Tablet",
      "frequency": "Once daily",
      "nextDose": "10:00 PM",
      "status": "Active",
      "adherencePercentage": 95,
      "category": "Heart",
      "hasConflict": false,
      "dateAdded": DateTime.now().subtract(const Duration(days: 20)),
    },
    {
      "id": 4,
      "name": "Ibuprofen",
      "dosage": "400mg",
      "form": "Tablet",
      "frequency": "As needed",
      "nextDose": "As needed",
      "status": "Paused",
      "adherencePercentage": 75,
      "category": "Pain Relief",
      "hasConflict": false,
      "dateAdded": DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      "id": 5,
      "name": "Vitamin D3",
      "dosage": "1000 IU",
      "form": "Capsule",
      "frequency": "Once daily",
      "nextDose": "9:00 AM",
      "status": "Active",
      "adherencePercentage": 85,
      "category": "Vitamin",
      "hasConflict": false,
      "dateAdded": DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      "id": 6,
      "name": "Aspirin",
      "dosage": "81mg",
      "form": "Tablet",
      "frequency": "Once daily",
      "nextDose": "Completed",
      "status": "Completed",
      "adherencePercentage": 98,
      "category": "Heart",
      "hasConflict": false,
      "dateAdded": DateTime.now().subtract(const Duration(days: 60)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _simulateNetworkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _simulateNetworkStatus() {
    // Simulate network status changes for demo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isOnline = true;
          _lastSyncTime = DateTime.now();
        });
      }
    });
  }

  List<Map<String, dynamic>> get _filteredMedications {
    List<Map<String, dynamic>> filtered = _allMedications;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((medication) {
        final name = (medication['name'] as String).toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((medication) {
        return (medication['status'] as String) == _selectedCategory;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_selectedSortOption) {
        case 'Name':
          return (a['name'] as String).compareTo(b['name'] as String);
        case 'Next Dose':
          // Simple time comparison for demo
          final aTime = a['nextDose'] as String;
          final bTime = b['nextDose'] as String;
          return aTime.compareTo(bTime);
        case 'Adherence':
          final aAdherence = a['adherencePercentage'] as num;
          final bAdherence = b['adherencePercentage'] as num;
          return bAdherence.compareTo(aAdherence);
        case 'Date Added':
          final aDate = a['dateAdded'] as DateTime;
          final bDate = b['dateAdded'] as DateTime;
          return bDate.compareTo(aDate);
        default:
          return 0;
      }
    });

    return filtered;
  }

  List<Map<String, dynamic>> get _activeMedications {
    return _filteredMedications
        .where((med) => (med['status'] as String) == 'Active')
        .toList();
  }

  List<Map<String, dynamic>> get _inactiveMedications {
    return _filteredMedications
        .where((med) => (med['status'] as String) != 'Active')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            _buildStickyHeader(),
            Expanded(
              child: _filteredMedications.isEmpty
                  ? _buildEmptyState()
                  : _buildMedicationList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'MediPulse',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, '/profile-selection-screen'),
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            child: CircleAvatar(
              radius: 5.w,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Medications'),
        ],
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: Column(
        children: [
          SyncStatusWidget(
            isOnline: _isOnline,
            lastSyncTime: _lastSyncTime,
            isSyncing: _isSyncing,
            onRetrySync: _handleRetrySync,
          ),
          SearchBarWidget(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterTap: _showFilterBottomSheet,
            onSortTap: _showFilterBottomSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return TabBarView(
      controller: _tabController,
      children: [
        ListView(
          children: [
            if (_activeMedications.isNotEmpty) ...[
              _buildSectionHeader(
                  'Active Medications', _activeMedications.length),
              ..._activeMedications
                  .map((medication) => _buildMedicationCard(medication)),
            ],
            if (_inactiveMedications.isNotEmpty) ...[
              SizedBox(height: 2.h),
              _buildSectionHeader(
                  'Other Medications', _inactiveMedications.length),
              ..._inactiveMedications
                  .map((medication) => _buildMedicationCard(medication)),
            ],
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return MedicationCardWidget(
      medication: medication,
      onTap: () => _navigateToMedicationDetail(medication),
      onEdit: () => _handleEditMedication(medication),
      onDuplicate: () => _handleDuplicateMedication(medication),
      onPause: () => _handlePauseMedication(medication),
      onDelete: () => _handleDeleteMedication(medication),
      onViewHistory: () => _handleViewHistory(medication),
      onExportData: () => _handleExportData(medication),
      onShare: () => _handleShareWithDoctor(medication),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: _searchQuery.isNotEmpty
          ? 'No medications found'
          : 'No Medications Yet',
      subtitle: _searchQuery.isNotEmpty
          ? 'Try adjusting your search or filters to find what you\'re looking for.'
          : 'Start your medication journey by adding your first medication. We\'ll help you stay on track with timely reminders.',
      buttonText: _searchQuery.isNotEmpty
          ? 'Clear Search'
          : 'Add Your First Medication',
      onButtonPressed:
          _searchQuery.isNotEmpty ? _clearSearch : _navigateToAddMedication,
      illustrationUrl:
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddMedication,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 5.w,
      ),
      label: Text(
        'Add Medication',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
      _isOnline = true;
    });
  }

  void _handleRetrySync() {
    _handleRefresh();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheetWidget(
        selectedCategory: _selectedCategory,
        selectedSortOption: _selectedSortOption,
        onCategoryChanged: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
        onSortChanged: (sortOption) {
          setState(() {
            _selectedSortOption = sortOption;
          });
        },
        onApply: () {
          // Filter and sort are applied in real-time
        },
        onReset: () {
          setState(() {
            _selectedCategory = 'All';
            _selectedSortOption = 'Name';
          });
        },
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _navigateToAddMedication() {
    Navigator.pushNamed(context, '/add-medication-screen');
  }

  void _navigateToMedicationDetail(Map<String, dynamic> medication) {
    Navigator.pushNamed(context, '/medication-detail-screen');
  }

  void _handleEditMedication(Map<String, dynamic> medication) {
    Navigator.pushNamed(context, '/add-medication-screen');
  }

  void _handleDuplicateMedication(Map<String, dynamic> medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} duplicated successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _handlePauseMedication(Map<String, dynamic> medication) {
    setState(() {
      final index =
          _allMedications.indexWhere((med) => med['id'] == medication['id']);
      if (index != -1) {
        _allMedications[index]['status'] =
            _allMedications[index]['status'] == 'Active' ? 'Paused' : 'Active';
      }
    });

    final newStatus = _allMedications
        .firstWhere((med) => med['id'] == medication['id'])['status'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} ${newStatus.toLowerCase()}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _handleDeleteMedication(Map<String, dynamic> medication) {
    setState(() {
      _allMedications.removeWhere((med) => med['id'] == medication['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} deleted'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allMedications.add(medication);
            });
          },
        ),
      ),
    );
  }

  void _handleViewHistory(Map<String, dynamic> medication) {
    Navigator.pushNamed(context, '/reports-screen');
  }

  void _handleExportData(Map<String, dynamic> medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} data exported'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _handleShareWithDoctor(Map<String, dynamic> medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} shared with doctor'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }
}

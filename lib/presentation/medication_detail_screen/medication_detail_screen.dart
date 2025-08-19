import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/medication_analytics_tab.dart';
import './widgets/medication_hero_section.dart';
import './widgets/medication_history_tab.dart';
import './widgets/medication_overview_tab.dart';

class MedicationDetailScreen extends StatefulWidget {
  const MedicationDetailScreen({Key? key}) : super(key: key);

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock medication data
  final Map<String, dynamic> medicationData = {
    "id": 1,
    "name": "Metformin HCl",
    "strength": "500mg",
    "form": "Tablet",
    "route": "Oral",
    "frequency": "Twice daily",
    "dosage": "1 tablet",
    "doctor": "Dr. Priya Sharma",
    "startDate": "15/08/2025",
    "endDate": "",
    "pharmacy": "Apollo Pharmacy",
    "instructions":
        "Take with meals to reduce stomach upset. Monitor blood glucose levels regularly. Avoid alcohol consumption while taking this medication.",
    "nextDose": "Today at 8:00 PM",
    "reminderTimes": "8:00 AM, 8:00 PM",
    "snoozeDuration": 15,
    "adherencePercentage": 87.5,
    "imageUrl":
        "https://images.pexels.com/photos/3683107/pexels-photo-3683107.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
  };

  // Mock dose history data
  final List<Map<String, dynamic>> doseHistory = [
    {
      "date": "19/08/2025",
      "time": "8:05 AM",
      "status": "taken",
      "latency": "5 minutes late",
      "reason": "",
    },
    {
      "date": "19/08/2025",
      "time": "8:00 PM",
      "status": "snoozed",
      "latency": "15 minutes late",
      "reason": "Busy with work",
    },
    {
      "date": "18/08/2025",
      "time": "8:00 AM",
      "status": "taken",
      "latency": "On time",
      "reason": "",
    },
    {
      "date": "18/08/2025",
      "time": "8:00 PM",
      "status": "taken",
      "latency": "3 minutes late",
      "reason": "",
    },
    {
      "date": "17/08/2025",
      "time": "8:00 AM",
      "status": "missed",
      "latency": "N/A",
      "reason": "Forgot to take",
    },
    {
      "date": "17/08/2025",
      "time": "8:00 PM",
      "status": "taken",
      "latency": "On time",
      "reason": "",
    },
    {
      "date": "16/08/2025",
      "time": "8:00 AM",
      "status": "taken",
      "latency": "2 minutes late",
      "reason": "",
    },
    {
      "date": "16/08/2025",
      "time": "8:00 PM",
      "status": "taken",
      "latency": "On time",
      "reason": "",
    },
  ];

  // Mock analytics data
  final Map<String, dynamic> analyticsData = {
    "currentStreak": 5,
    "longestStreak": 12,
    "averageLatency": "8 minutes",
    "totalDoses": 156,
    "adherenceTrend": [85, 92, 78, 95, 88, 90, 87],
    "latencyByTime": {
      "morning": 15,
      "afternoon": 25,
      "evening": 10,
      "night": 35,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _shareReport() {
    // Simulate sharing medication report
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Medication report exported successfully',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  void _editMedication() {
    Navigator.pushNamed(context, '/add-medication-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          medicationData['name'] as String? ?? 'Medication Details',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _editMedication,
            icon: CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _shareReport,
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Hero Section
            MedicationHeroSection(medication: medicationData),

            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.lightTheme.colorScheme.primary,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                indicatorColor: AppTheme.lightTheme.colorScheme.primary,
                indicatorWeight: 3,
                labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle:
                    AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'History'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        MedicationOverviewTab(medication: medicationData),
                        MedicationHistoryTab(doseHistory: doseHistory),
                        MedicationAnalyticsTab(analyticsData: analyticsData),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

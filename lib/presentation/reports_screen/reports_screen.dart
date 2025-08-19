import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/adherence_chart_card.dart';
import './widgets/adherence_overview_card.dart';
import './widgets/date_range_selector.dart';
import './widgets/export_options_bottom_sheet.dart';
import './widgets/latency_tracking_card.dart';
import './widgets/medication_breakdown_card.dart';
import './widgets/missed_doses_analysis_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedDateRange = '30days';
  DateTime? customStartDate;
  DateTime? customEndDate;
  bool isLoading = false;
  bool isOffline = false;

  // Mock data for reports
  final Map<String, dynamic> mockReportData = {
    'adherencePercentage': 87.5,
    'currentStreak': 12,
    'previousPeriodComparison': 5.2,
    'chartData': [
      {'label': '1/8', 'adherence': 95.0},
      {'label': '2/8', 'adherence': 88.0},
      {'label': '3/8', 'adherence': 92.0},
      {'label': '4/8', 'adherence': 85.0},
      {'label': '5/8', 'adherence': 90.0},
      {'label': '6/8', 'adherence': 87.0},
      {'label': '7/8', 'adherence': 89.0},
      {'label': '8/8', 'adherence': 91.0},
      {'label': '9/8', 'adherence': 86.0},
      {'label': '10/8', 'adherence': 88.0},
      {'label': '11/8', 'adherence': 93.0},
      {'label': '12/8', 'adherence': 87.0},
      {'label': '13/8', 'adherence': 89.0},
      {'label': '14/8', 'adherence': 85.0},
      {'label': '15/8', 'adherence': 92.0},
      {'label': '16/8', 'adherence': 88.0},
      {'label': '17/8', 'adherence': 90.0},
      {'label': '18/8', 'adherence': 87.0},
      {'label': '19/8', 'adherence': 91.0},
    ],
    'medicationBreakdown': [
      {
        'name': 'Metformin',
        'dosage': '500mg',
        'frequency': 'Twice daily',
        'adherence': 92.5,
        'takenDoses': 37,
        'totalDoses': 40,
      },
      {
        'name': 'Lisinopril',
        'dosage': '10mg',
        'frequency': 'Once daily',
        'adherence': 85.0,
        'takenDoses': 17,
        'totalDoses': 20,
      },
      {
        'name': 'Atorvastatin',
        'dosage': '20mg',
        'frequency': 'Once daily at bedtime',
        'adherence': 90.0,
        'takenDoses': 18,
        'totalDoses': 20,
      },
      {
        'name': 'Aspirin',
        'dosage': '81mg',
        'frequency': 'Once daily',
        'adherence': 95.0,
        'takenDoses': 19,
        'totalDoses': 20,
      },
      {
        'name': 'Omeprazole',
        'dosage': '20mg',
        'frequency': 'Once daily before breakfast',
        'adherence': 75.0,
        'takenDoses': 15,
        'totalDoses': 20,
      },
    ],
    'missedDoses': {
      'totalMissed': 13,
      'mostMissedTime': 'Evening',
      'mostMissedDay': 'Sunday',
      'timeOfDay': [
        {'time': 'Morning', 'count': 2},
        {'time': 'Afternoon', 'count': 3},
        {'time': 'Evening', 'count': 6},
        {'time': 'Night', 'count': 2},
      ],
      'dayOfWeek': [
        {'day': 'Monday', 'count': 1},
        {'day': 'Tuesday', 'count': 2},
        {'day': 'Wednesday', 'count': 1},
        {'day': 'Thursday', 'count': 2},
        {'day': 'Friday', 'count': 1},
        {'day': 'Saturday', 'count': 3},
        {'day': 'Sunday', 'count': 3},
      ],
    },
    'latencyData': {
      'averageLatency': 25,
      'medianLatency': 18,
      'onTimePercentage': 68.5,
      'distribution': [
        {'label': 'On Time (±15m)', 'percentage': 68.5, 'maxMinutes': 15},
        {
          'label': 'Slightly Late (16-30m)',
          'percentage': 18.2,
          'maxMinutes': 30
        },
        {'label': 'Late (31-60m)', 'percentage': 9.8, 'maxMinutes': 60},
        {'label': 'Very Late (>60m)', 'percentage': 3.5, 'maxMinutes': 120},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 5, vsync: this, initialIndex: 3); // Reports tab active
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      isLoading = false;
      // In real implementation, check network connectivity
      isOffline = false;
    });
  }

  Future<void> _refreshReports() async {
    await _loadReportData();
  }

  void _onDateRangeChanged(String range) {
    setState(() {
      selectedDateRange = range;
      if (range != 'custom') {
        customStartDate = null;
        customEndDate = null;
      }
    });
    _loadReportData();
  }

  void _onCustomRangeSelected(DateTime start, DateTime end) {
    setState(() {
      selectedDateRange = 'custom';
      customStartDate = start;
      customEndDate = end;
    });
    _loadReportData();
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportOptionsBottomSheet(
        reportData: mockReportData,
        selectedPeriod: selectedDateRange,
        customStartDate: customStartDate,
        customEndDate: customEndDate,
      ),
    );
  }

  String _getSelectedPeriodLabel() {
    switch (selectedDateRange) {
      case '7days':
        return 'Last 7 Days';
      case '30days':
        return 'Last 30 Days';
      case '3months':
        return 'Last 3 Months';
      case 'custom':
        return 'Custom Range';
      default:
        return 'Last 30 Days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Reports'),
        actions: [
          if (isOffline)
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: CustomIconWidget(
                iconName: 'cloud_off',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
            ),
          IconButton(
            onPressed: _showExportOptions,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'home',
                    color: _tabController.index == 0
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text('Today'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'medication',
                    color: _tabController.index == 1
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text('Medications'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'add_circle',
                    color: _tabController.index == 2
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text('Add'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'analytics',
                    color: _tabController.index == 3
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text('Reports'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'person',
                    color: _tabController.index == 4
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text('Profile'),
                ],
              ),
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/splash-screen');
                break;
              case 1:
                Navigator.pushNamed(context, '/medication-list-screen');
                break;
              case 2:
                Navigator.pushNamed(context, '/add-medication-screen');
                break;
              case 3:
                // Current screen - Reports
                break;
              case 4:
                Navigator.pushNamed(context, '/profile-selection-screen');
                break;
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Date Range Selector (Sticky Header)
          DateRangeSelector(
            selectedRange: selectedDateRange,
            customStartDate: customStartDate,
            customEndDate: customEndDate,
            onRangeChanged: _onDateRangeChanged,
            onCustomRangeSelected: _onCustomRangeSelected,
          ),

          // Main Content
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Loading report data...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshReports,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 1.h),

                          // Offline Indicator
                          if (isOffline)
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 1.h),
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(2.w),
                                border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.error
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'cloud_off',
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      'Showing cached reports. Pull to refresh when online.',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Overall Adherence Card
                          AdherenceOverviewCard(
                            adherencePercentage:
                                mockReportData['adherencePercentage'] as double,
                            currentStreak:
                                mockReportData['currentStreak'] as int,
                            previousPeriodComparison:
                                mockReportData['previousPeriodComparison']
                                    as double,
                            selectedPeriod: _getSelectedPeriodLabel(),
                          ),

                          // Adherence Trends Chart
                          AdherenceChartCard(
                            chartData: mockReportData['chartData']
                                as List<Map<String, dynamic>>,
                            selectedPeriod: _getSelectedPeriodLabel(),
                          ),

                          // Medication Breakdown
                          MedicationBreakdownCard(
                            medicationData:
                                mockReportData['medicationBreakdown']
                                    as List<Map<String, dynamic>>,
                          ),

                          // Missed Doses Analysis
                          MissedDosesAnalysisCard(
                            missedDosesData: mockReportData['missedDoses']
                                as Map<String, dynamic>,
                          ),

                          // Latency Tracking
                          LatencyTrackingCard(
                            latencyData: mockReportData['latencyData']
                                as Map<String, dynamic>,
                          ),

                          // Bottom spacing
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

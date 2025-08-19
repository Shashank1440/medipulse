import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicationBreakdownCard extends StatefulWidget {
  final List<Map<String, dynamic>> medicationData;

  const MedicationBreakdownCard({
    super.key,
    required this.medicationData,
  });

  @override
  State<MedicationBreakdownCard> createState() =>
      _MedicationBreakdownCardState();
}

class _MedicationBreakdownCardState extends State<MedicationBreakdownCard> {
  String sortBy = 'name';
  bool ascending = true;
  String filterBy = 'all';

  List<Map<String, dynamic>> get filteredAndSortedData {
    List<Map<String, dynamic>> data = List.from(widget.medicationData);

    // Filter
    if (filterBy != 'all') {
      data = data.where((med) {
        final adherence = med['adherence'] as double;
        switch (filterBy) {
          case 'excellent':
            return adherence >= 90;
          case 'good':
            return adherence >= 70 && adherence < 90;
          case 'poor':
            return adherence < 70;
          default:
            return true;
        }
      }).toList();
    }

    // Sort
    data.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'name':
          comparison = (a['name'] as String).compareTo(b['name'] as String);
          break;
        case 'adherence':
          comparison =
              (a['adherence'] as double).compareTo(b['adherence'] as double);
          break;
        case 'doses':
          comparison =
              (a['totalDoses'] as int).compareTo(b['totalDoses'] as int);
          break;
      }
      return ascending ? comparison : -comparison;
    });

    return data;
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 90) return AppTheme.lightTheme.colorScheme.secondary;
    if (adherence >= 70) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final sortedData = filteredAndSortedData;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'medication',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Medication Breakdown',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Filter and Sort Controls
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filterBy,
                    decoration: InputDecoration(
                      labelText: 'Filter',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Medications')),
                      DropdownMenuItem(
                          value: 'excellent', child: Text('Excellent (≥90%)')),
                      DropdownMenuItem(
                          value: 'good', child: Text('Good (70-89%)')),
                      DropdownMenuItem(
                          value: 'poor', child: Text('Poor (<70%)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          filterBy = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: InputDecoration(
                      labelText: 'Sort by',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(
                          value: 'adherence', child: Text('Adherence')),
                      DropdownMenuItem(
                          value: 'doses', child: Text('Total Doses')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          sortBy = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: ascending ? 'arrow_upward' : 'arrow_downward',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Medication List
            sortedData.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'search_off',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 12.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No medications match the selected filter',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: sortedData.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) {
                      final medication = sortedData[index];
                      final adherence = medication['adherence'] as double;
                      final takenDoses = medication['takenDoses'] as int;
                      final totalDoses = medication['totalDoses'] as int;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: _getAdherenceColor(adherence)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'medication',
                                  color: _getAdherenceColor(adherence),
                                  size: 6.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medication['name'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    '${medication['dosage']} • ${medication['frequency']}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    '$takenDoses of $totalDoses doses taken',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${adherence.toStringAsFixed(1)}%',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: _getAdherenceColor(adherence),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  width: 15.w,
                                  height: 1.h,
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(0.5.h),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: adherence / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getAdherenceColor(adherence),
                                        borderRadius:
                                            BorderRadius.circular(0.5.h),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

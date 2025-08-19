import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dosage_stepper_widget.dart';
import './widgets/frequency_pattern_widget.dart';
import './widgets/medication_form_widget.dart';
import './widgets/ocr_camera_widget.dart';
import './widgets/scheduling_widget.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _notesController = TextEditingController();

  // Medication details
  String _selectedForm = 'Pills';
  String _selectedRoute = 'Oral';
  double _dosage = 1.0;
  String _dosageUnit = 'tablets';

  // Scheduling
  bool _useExactTimes = false;
  List<TimeOfDay> _exactTimes = [];
  Map<String, bool> _timeBuckets = {
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
    'Night': false,
  };

  // Frequency pattern
  String _selectedPattern = 'daily';
  int _intervalHours = 8;
  List<String> _selectedDays = [];

  // Reminder settings
  String _notificationSound = 'Default';
  int _snoozeInterval = 5;

  // UI state
  bool _showAdvancedScheduling = false;
  bool _showOCRCamera = false;

  // Mock medication suggestions
  final List<String> _medicationSuggestions = [
    'Metformin',
    'Lisinopril',
    'Atorvastatin',
    'Amlodipine',
    'Omeprazole',
    'Levothyroxine',
    'Simvastatin',
    'Losartan',
    'Gabapentin',
    'Hydrochlorothiazide',
  ];

  @override
  void dispose() {
    _medicationNameController.dispose();
    _strengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _medicationNameController.text.isNotEmpty &&
        _strengthController.text.isNotEmpty &&
        (_useExactTimes
            ? _exactTimes.isNotEmpty
            : _timeBuckets.values.any((selected) => selected));
  }

  void _showOCRCameraBottomSheet() {
    setState(() {
      _showOCRCamera = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OCRCameraWidget(
        onTextRecognized: (text) {
          _processOCRText(text);
          Navigator.pop(context);
          setState(() {
            _showOCRCamera = false;
          });
        },
        onClose: () {
          Navigator.pop(context);
          setState(() {
            _showOCRCamera = false;
          });
        },
      ),
    );
  }

  void _processOCRText(String text) {
    // Simple text processing to extract medication info
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim();
      final parts = firstLine.split(' ');

      if (parts.isNotEmpty) {
        _medicationNameController.text = parts[0];
      }

      // Extract strength if present
      final strengthMatch = RegExp(r'(\d+)\s*(mg|ml|mcg)').firstMatch(text);
      if (strengthMatch != null) {
        _strengthController.text =
            '${strengthMatch.group(1)}${strengthMatch.group(2)}';
      }

      // Set default scheduling based on common patterns
      if (text.toLowerCase().contains('twice daily') ||
          text.toLowerCase().contains('bid')) {
        setState(() {
          _timeBuckets['Morning'] = true;
          _timeBuckets['Evening'] = true;
        });
      } else if (text.toLowerCase().contains('once daily') ||
          text.toLowerCase().contains('qd')) {
        setState(() {
          _timeBuckets['Morning'] = true;
        });
      }
    }
  }

  void _saveMedication() {
    if (!_isFormValid) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medication: ${_medicationNameController.text}'),
            Text('Strength: ${_strengthController.text}'),
            Text('Form: $_selectedForm'),
            Text('Dosage: $_dosage $_dosageUnit'),
            SizedBox(height: 1.h),
            Text('Schedule:', style: TextStyle(fontWeight: FontWeight.w600)),
            if (_useExactTimes)
              ...(_exactTimes
                  .map((time) => Text('• ${time.format(context)}'))
                  .toList())
            else
              ...(_timeBuckets.entries
                  .where((entry) => entry.value)
                  .map((entry) => Text('• ${entry.key}'))
                  .toList()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSave();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    // Here you would typically save to database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medication added successfully!'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );

    // Navigate back or to medication list
    Navigator.pushReplacementNamed(context, '/medication-list-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOCRSection(),
              SizedBox(height: 3.h),
              _buildMedicationDetailsSection(),
              SizedBox(height: 3.h),
              _buildDosageSection(),
              SizedBox(height: 3.h),
              _buildSchedulingSection(),
              SizedBox(height: 3.h),
              _buildAdvancedSchedulingSection(),
              SizedBox(height: 3.h),
              _buildReminderSettingsSection(),
              SizedBox(height: 3.h),
              _buildNotesSection(),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSaveButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Add Medication'),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isFormValid ? _saveMedication : null,
          child: Text(
            'Save',
            style: TextStyle(
              color: _isFormValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOCRSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Prescription',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Use camera to automatically fill medication details',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showOCRCameraBottomSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            child: Text('Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication Details',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildMedicationNameField(),
        SizedBox(height: 2.h),
        _buildStrengthField(),
        SizedBox(height: 2.h),
        MedicationFormWidget(
          selectedForm: _selectedForm,
          onFormChanged: (form) => setState(() => _selectedForm = form),
        ),
        SizedBox(height: 2.h),
        _buildRouteSelector(),
      ],
    );
  }

  Widget _buildMedicationNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication Name *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _medicationSuggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _medicationNameController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _medicationNameController.text = controller.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Enter medication name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'medication',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medication name';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStrengthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strength *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _strengthController,
          decoration: InputDecoration(
            hintText: 'e.g., 500mg, 10ml',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'science',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter medication strength';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRouteSelector() {
    final routes = ['Oral', 'Topical', 'Injection', 'Inhalation', 'Sublingual'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route of Administration',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _selectedRoute,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'route',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          items: routes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedRoute = newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDosageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosage',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        DosageStepperWidget(
          dosage: _dosage,
          unit: _dosageUnit,
          onDosageChanged: (dosage) => setState(() => _dosage = dosage),
          onUnitChanged: (unit) => setState(() => _dosageUnit = unit),
        ),
      ],
    );
  }

  Widget _buildSchedulingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Scheduling',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SchedulingWidget(
          useExactTimes: _useExactTimes,
          exactTimes: _exactTimes,
          timeBuckets: _timeBuckets,
          onScheduleTypeChanged: (useExact) =>
              setState(() => _useExactTimes = useExact),
          onExactTimesChanged: (times) => setState(() => _exactTimes = times),
          onTimeBucketChanged: (bucket, selected) =>
              setState(() => _timeBuckets[bucket] = selected),
        ),
      ],
    );
  }

  Widget _buildAdvancedSchedulingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(
              () => _showAdvancedScheduling = !_showAdvancedScheduling),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Scheduling',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName:
                    _showAdvancedScheduling ? 'expand_less' : 'expand_more',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ],
          ),
        ),
        if (_showAdvancedScheduling) ...[
          SizedBox(height: 2.h),
          FrequencyPatternWidget(
            selectedPattern: _selectedPattern,
            intervalHours: _intervalHours,
            selectedDays: _selectedDays,
            onPatternChanged: (pattern) =>
                setState(() => _selectedPattern = pattern),
            onIntervalChanged: (hours) =>
                setState(() => _intervalHours = hours),
            onDaysChanged: (days) => setState(() => _selectedDays = days),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Settings',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildNotificationSoundSelector(),
        SizedBox(height: 2.h),
        _buildSnoozeIntervalSelector(),
      ],
    );
  }

  Widget _buildNotificationSoundSelector() {
    final sounds = ['Default', 'Gentle Bell', 'Chime', 'Alert', 'None'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Sound',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _notificationSound,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'volume_up',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          items: sounds.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _notificationSound = newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSnoozeIntervalSelector() {
    final intervals = [1, 5, 10, 15, 30];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Snooze Interval (minutes)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<int>(
          value: _snoozeInterval,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'snooze',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          items: intervals.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value minutes'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() => _snoozeInterval = newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special instructions or notes...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'note_add',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton.extended(
      onPressed: _isFormValid ? _saveMedication : null,
      backgroundColor: _isFormValid
          ? AppTheme.lightTheme.colorScheme.primary
          : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.3),
      icon: CustomIconWidget(
        iconName: 'save',
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        'Save Medication',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

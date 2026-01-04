import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../main.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _frequency = 'daily';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<TimeOfDay> _reminderTimes = [TimeOfDay(hour: 9, minute: 0)];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _addReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTimes.add(picked);
        _reminderTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  void _removeReminderTime(int index) {
    if (_reminderTimes.length > 1) {
      setState(() => _reminderTimes.removeAt(index));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must have at least one reminder time'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      // Format reminder times as HH:mm strings
      final reminderTimeStrings = _reminderTimes
          .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList();

      print('💊 Adding medication...');

      final result = await client.v1Medication.addMedication(
        userId,
        _nameController.text.trim(),
        _dosageController.text.trim(),
        _frequency,
        reminderTimeStrings,
        _startDate,
        _endDate,
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (result == null) {
        throw Exception('Failed to add medication');
      }

      print('✅ Medication added successfully');

// Schedule notifications for each reminder time
      for (var timeString in reminderTimeStrings) {
        final timeParts = timeString.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Create unique notification ID for each medication+time combination
        final notificationId = 4000 + (result.id! * 10) + reminderTimeStrings.indexOf(timeString);

        await NotificationService().scheduleMedicationReminder(
          medicationName: result.medicationName,
          hour: hour,
          minute: minute,
          customId: notificationId,
        );

        print('🔔 Scheduled notification for ${result.medicationName} at $hour:$minute');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.medicationName} added with ${reminderTimeStrings.length} reminders'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to refresh list

    } catch (e) {
      print('❌ Error adding medication: $e');
      setState(() => _isSubmitting = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Medication'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Name
              Text(
                'Medication Name',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Prenatal Vitamins',
                  prefixIcon: Icon(Icons.medication, color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: kPrimaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              // Dosage
              Text(
                'Dosage',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  hintText: 'e.g., 1 tablet, 500mg',
                  prefixIcon: Icon(Icons.local_pharmacy, color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: kPrimaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              // Frequency
              Text(
                'Frequency',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _frequency,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                    items: [
                      DropdownMenuItem(value: 'daily', child: Text('Once daily')),
                      DropdownMenuItem(value: 'twice_daily', child: Text('Twice daily')),
                      DropdownMenuItem(value: 'three_times_daily', child: Text('Three times daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Once weekly')),
                    ],
                    onChanged: (value) {
                      setState(() => _frequency = value!);
                    },
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Reminder Times
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder Times',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addReminderTime,
                    icon: Icon(Icons.add, size: 18.sp),
                    label: Text('Add Time', style: TextStyle(fontSize: 13.sp)),
                    style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              ..._reminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.alarm, color: kPrimaryColor, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        time.format(context),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => _removeReminderTime(index),
                        icon: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
                      ),
                    ],
                  ),
                );
              }).toList(),

              SizedBox(height: 20.h),

              // Start Date
              Text(
                'Start Date',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: _selectStartDate,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: kPrimaryColor, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // End Date (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'End Date (Optional)',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                  if (_endDate != null)
                    TextButton(
                      onPressed: () => setState(() => _endDate = null),
                      child: Text('Clear', style: TextStyle(fontSize: 13.sp)),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: _selectEndDate,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: kPrimaryColor, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'No end date',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: _endDate != null ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Notes
              Text(
                'Notes (Optional)',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Take with food',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: kPrimaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 30.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Add Medication',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
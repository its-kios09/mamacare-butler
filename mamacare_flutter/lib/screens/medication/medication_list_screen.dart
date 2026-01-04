import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mamacare_client/mamacare_client.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      print('💊 Loading medications for user $userId');

      final medications = await client.v1Medication.getUserMedications(userId);

      print('✅ Loaded ${medications.length} medications');

      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading medications: $e');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading medications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleMedicationStatus(Medication medication) async {
    try {
      print('🔄 Toggling medication status: ${medication.id}');

      final success =
          await client.v1Medication.toggleMedicationStatus(medication.id!);

      if (success) {
        // Cancel or reschedule notifications based on new status
        if (medication.isActive) {
          // Was active, now paused - cancel notifications
          for (int i = 0; i < medication.reminderTimes.length; i++) {
            final notificationId = 4000 + (medication.id! * 10) + i;
            await NotificationService()
                .cancelMedicationReminder(notificationId);
          }
          print('🔕 Cancelled notifications for ${medication.medicationName}');
        } else {
          // Was paused, now active - reschedule notifications
          for (var timeString in medication.reminderTimes) {
            final timeParts = timeString.split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final notificationId = 4000 +
                (medication.id! * 10) +
                medication.reminderTimes.indexOf(timeString);

            await NotificationService().scheduleMedicationReminder(
              medicationName: medication.medicationName,
              hour: hour,
              minute: minute,
              customId: notificationId,
            );
          }
          print(
              '🔔 Rescheduled notifications for ${medication.medicationName}');
        }

        await _loadMedications(); // Reload list

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medication.isActive
                  ? '✅ Medication paused - reminders cancelled'
                  : '✅ Medication activated - reminders set',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error toggling medication: $e');
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete Medication?'),
        content: Text(
          'Are you sure you want to delete ${medication.medicationName}?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      print('🗑️ Deleting medication: ${medication.id}');

      final success =
          await client.v1Medication.deleteMedication(medication.id!);

      if (success) {
        for (int i = 0; i < medication.reminderTimes.length; i++) {
          final notificationId = 4000 + (medication.id! * 10) + i;
          await NotificationService().cancelMedicationReminder(notificationId);
        }
        print('🔕 Cancelled all notifications for ${medication.medicationName}');

        await _loadMedications();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${medication.medicationName} deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting medication: $e');
    }
  }

  String _getFrequencyText(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Once daily';
      case 'twice_daily':
        return 'Twice daily';
      case 'three_times_daily':
        return '3 times daily';
      case 'weekly':
        return 'Once weekly';
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Medications'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicationScreen(),
            ),
          );

          if (result == true) {
            _loadMedications();
          }
        },
        backgroundColor: kPrimaryColor,
        icon: Icon(Icons.add, size: 24.sp),
        label: Text('Add Medication', style: TextStyle(fontSize: 14.sp)),
      ),

      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: kPrimaryColor, strokeWidth: 3),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading medications...',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _medications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMedications,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final medication = _medications[index];
                      return _buildMedicationCard(medication);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            Icons.medication_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'No Medications Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your medications to get\nreminders and track adherence',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddMedicationScreen(),
                ),
              );

              if (result == true) {
                _loadMedications();
              }
            },
            icon: Icon(Icons.add, size: 20.sp),
            label: const Text('Add Medication'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    final isActive = medication.isActive;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive ? kPrimaryColor.withOpacity(0.3) : Colors.grey[300]!,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isActive
                        ? kPrimaryColor.withOpacity(0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: isActive ? kPrimaryColor : Colors.grey[500],
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.medicationName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        medication.dosage,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Active/Inactive badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Paused',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 16.h),

            // Frequency
            Row(
              children: [
                Icon(Icons.schedule, color: kPrimaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  _getFrequencyText(medication.frequency),
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Reminder times
            Row(
              children: [
                Icon(Icons.alarm, color: kPrimaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Reminders: ${medication.reminderTimes.join(", ")}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Start/End date
            Row(
              children: [
                Icon(Icons.calendar_today, color: kPrimaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Started: ${DateFormat('MMM dd, yyyy').format(medication.startDate)}',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
                if (medication.endDate != null) ...[
                  SizedBox(width: 12.w),
                  Text(
                    'Ends: ${DateFormat('MMM dd').format(medication.endDate!)}',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                  ),
                ],
              ],
            ),

            if (medication.notes != null && medication.notes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, color: Colors.grey[600], size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        medication.notes!,
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleMedicationStatus(medication),
                    icon: Icon(
                      isActive ? Icons.pause : Icons.play_arrow,
                      size: 18.sp,
                    ),
                    label: Text(
                      isActive ? 'Pause' : 'Activate',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: BorderSide(color: kPrimaryColor),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteMedication(medication),
                    icon: Icon(Icons.delete_outline, size: 18.sp),
                    label: Text('Delete', style: TextStyle(fontSize: 13.sp)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

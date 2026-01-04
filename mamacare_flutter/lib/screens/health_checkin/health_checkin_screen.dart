import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import '../../constants/constant.dart';
import 'health_checkin_result_screen.dart';

class HealthCheckinScreen extends StatefulWidget {
  final int pregnancyWeek;

  const HealthCheckinScreen({
    super.key,
    required this.pregnancyWeek,
  });

  @override
  State<HealthCheckinScreen> createState() => _HealthCheckinScreenState();
}

class _HealthCheckinScreenState extends State<HealthCheckinScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Symptoms
  bool _hasSevereHeadache = false;
  bool _hasVisionChanges = false;
  bool _hasAbdominalPain = false;
  bool _hasSwelling = false;
  bool _hasReducedFetalMovement = false;
  bool _hasVaginalBleeding = false;
  bool _hasFluidLeakage = false;
  bool _hasContractions = false;

  // Measurements
  final TextEditingController _systolicBPController = TextEditingController();
  final TextEditingController _diastolicBPController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _additionalSymptomsController = TextEditingController();

  @override
  void dispose() {
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _weightController.dispose();
    _additionalSymptomsController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckin() async {
    setState(() => _isSubmitting = true);

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('User not logged in');

      // Parse measurements
      final systolicBP = int.tryParse(_systolicBPController.text.trim());
      final diastolicBP = int.tryParse(_diastolicBPController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());

      print('📋 Submitting health check-in...');

      // Submit to backend
      final result = await client.v1HealthCheckin.submitCheckin(
        userId,
        widget.pregnancyWeek,
        _hasSevereHeadache,
        _hasVisionChanges,
        _hasAbdominalPain,
        _hasSwelling,
        _hasReducedFetalMovement,
        _hasVaginalBleeding,
        _hasFluidLeakage,
        _hasContractions,
        systolicBP,
        diastolicBP,
        weight,
        _additionalSymptomsController.text.trim().isEmpty
            ? null
            : _additionalSymptomsController.text.trim(),
      );

      if (result == null) {
        throw Exception('Failed to submit check-in');
      }

      print('✅ Check-in submitted successfully');
      print('📊 Risk Level: ${result.riskLevel}');
      print('📊 AI Assessment: ${result.aiRiskAssessment}');
      print('📊 Recommendations: ${result.recommendations}');


      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HealthCheckinResultScreen(checkin: result),
        ),
      );
    } catch (e) {
      print('❌ Error submitting check-in: $e');
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

  List<Step> _buildSteps() {
    return [
      // Step 1: Warning Signs
      Step(
        title: Text('Warning Signs', style: TextStyle(fontSize: 14.sp)),
        content: _buildWarningSignsStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),

      // Step 2: Measurements
      Step(
        title: Text('Measurements', style: TextStyle(fontSize: 14.sp)),
        content: _buildMeasurementsStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),

      // Step 3: Additional Info
      Step(
        title: Text('Additional', style: TextStyle(fontSize: 14.sp)),
        content: _buildAdditionalStep(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Widget _buildWarningSignsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Please answer honestly. This helps detect complications early.',
                  style: TextStyle(fontSize: 12.sp, color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        Text(
          'In the past week, have you experienced:',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),

        _buildSymptomCheckbox(
          'Severe headache that won\'t go away',
          _hasSevereHeadache,
              (value) => setState(() => _hasSevereHeadache = value),
          Icons.psychology,
        ),

        _buildSymptomCheckbox(
          'Vision changes (blurred, spots, flashes)',
          _hasVisionChanges,
              (value) => setState(() => _hasVisionChanges = value),
          Icons.visibility,
        ),

        _buildSymptomCheckbox(
          'Upper abdominal pain (below ribs)',
          _hasAbdominalPain,
              (value) => setState(() => _hasAbdominalPain = value),
          Icons.medical_services,
        ),

        _buildSymptomCheckbox(
          'Sudden swelling (face, hands, feet)',
          _hasSwelling,
              (value) => setState(() => _hasSwelling = value),
          Icons.water_drop,
        ),

        _buildSymptomCheckbox(
          'Reduced baby movements',
          _hasReducedFetalMovement,
              (value) => setState(() => _hasReducedFetalMovement = value),
          Icons.child_care,
        ),

        _buildSymptomCheckbox(
          'Vaginal bleeding',
          _hasVaginalBleeding,
              (value) => setState(() => _hasVaginalBleeding = value),
          Icons.warning,
        ),

        _buildSymptomCheckbox(
          'Fluid leakage',
          _hasFluidLeakage,
              (value) => setState(() => _hasFluidLeakage = value),
          Icons.water,
        ),

        _buildSymptomCheckbox(
          'Regular contractions',
          _hasContractions,
              (value) => setState(() => _hasContractions = value),
          Icons.timeline,
        ),

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildMeasurementsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optional but helpful for better AI analysis:',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 20.h),

        // Blood Pressure
        Text(
          'Blood Pressure',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _systolicBPController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Systolic (top)',
                  hintText: '120',
                  suffixText: 'mmHg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: kPrimaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text('/', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _diastolicBPController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Diastolic (bottom)',
                  hintText: '80',
                  suffixText: 'mmHg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: kPrimaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Weight
        Text(
          'Current Weight',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),

        TextField(
          controller: _weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Weight',
            hintText: '65.5',
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildAdditionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Any other symptoms or concerns?',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),

        TextField(
          controller: _additionalSymptomsController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe any other symptoms, concerns, or questions you have...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),

        SizedBox(height: 20.h),

        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: kPrimaryColor, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Your health information is private and secure. AI analysis helps detect risks early.',
                  style: TextStyle(fontSize: 12.sp, color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildSymptomCheckbox(
      String label,
      bool value,
      Function(bool) onChanged,
      IconData icon,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: value ? kPrimaryColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: value ? kPrimaryColor : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (val) => onChanged(val ?? false),
        title: Row(
          children: [
            Icon(icon, color: value ? kPrimaryColor : Colors.grey[600], size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        activeColor: kPrimaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Weekly Health Check-in'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.white, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${widget.pregnancyWeek} Check-in',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'AI-powered health assessment',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stepper
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: kPrimaryColor),
              ),
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _submitCheckin();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  } else {
                    Navigator.pop(context);
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            _currentStep == 2 ? 'Get AI Analysis' : 'Continue',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        TextButton(
                          onPressed: _isSubmitting ? null : details.onStepCancel,
                          child: Text(
                            _currentStep == 0 ? 'Cancel' : 'Back',
                            style: TextStyle(fontSize: 14.sp, color: kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                steps: _buildSteps(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
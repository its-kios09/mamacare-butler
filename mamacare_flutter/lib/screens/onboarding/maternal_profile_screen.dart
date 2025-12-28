import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mamacare_flutter/main.dart';
import 'package:mamacare_flutter/screens/home/home_screen.dart';

import '../../constants/constant.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_card_widget.dart';
import '../../widgets/custom_strepper_widget.dart';
import '../../widgets/custom_button.dart';

class MaternalProfileScreen extends StatefulWidget {
  final int userId;

  const MaternalProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MaternalProfileScreen> createState() => _MaternalProfileScreenState();
}

class _MaternalProfileScreenState extends State<MaternalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _selectedEDD;
  DateTime? _selectedLMP;
  String? _selectedBloodType;
  bool _isLoading = false;
  int selectedIndex = 0;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  final List<Map<String, dynamic>> profileSteps = [
    {
      'title': 'Personal Details',
      'subtitle': 'Basic information',
    },
    {
      'title': 'Medical Information',
      'subtitle': 'Allergies & history',
    },
    {
      'title': 'Emergency Contact',
      'subtitle': 'Contact person',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _medicalHistoryController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isEDD) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText:
      isEDD ? 'Select Expected Due Date' : 'Select Last Menstrual Period',
    );

    if (picked != null) {
      setState(() {
        if (isEDD) {
          _selectedEDD = picked;
        } else {
          _selectedLMP = picked;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEDD == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your Expected Due Date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = await client.v1MaternalProfile.saveProfile(
        widget.userId,
        _nameController.text.trim(),
        _selectedEDD!,
        _selectedLMP,
        _selectedBloodType,
        _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        _medicalHistoryController.text.trim().isEmpty
            ? null
            : _medicalHistoryController.text.trim(),
        _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
      );

      if (!mounted) return;

      if (profile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profile saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Step 1: Personal Details
  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full name *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter your full name",
            labelStyle:
            TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        const Text(
          'Expected Due Date *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _selectDate(context, true),
          child: InputDecorator(
            decoration: InputDecoration(
              labelStyle:
              TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kTextGrey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kTextGrey),
              ),
            ),
            child: Text(
              _selectedEDD == null
                  ? 'MM/DD/YYYY'
                  : DateFormat('MMM dd, yyyy').format(_selectedEDD!),
              style: TextStyle(
                color: _selectedEDD == null ? kTextGrey : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Last Menstrual Period (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _selectDate(context, false),
          child: InputDecorator(
            decoration: InputDecoration(
              labelStyle:
              TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kTextGrey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kTextGrey),
              ),
            ),
            child: Text(
              _selectedLMP == null
                  ? 'MM/DD/YYYY'
                  : DateFormat('MMM dd, yyyy').format(_selectedLMP!),
              style: TextStyle(
                color: _selectedLMP == null ? kTextGrey : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Blood Group (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedBloodType,
          decoration: InputDecoration(
            hintText: 'Choose blood group',
            labelStyle:
            TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
          ),
          items: _bloodTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedBloodType = value);
          },
        ),
      ],
    );
  }

  // Step 2: Medical Information
  Widget _buildMedicalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allergies (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _allergiesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g., Penicillin, Peanuts, Latex',
            labelStyle:
            TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Medical History (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _medicalHistoryController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
            'Previous pregnancies, conditions, surgeries, medications...',
            labelStyle:
            TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Emergency Contact
  Widget _buildEmergencyContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Contact Name (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _emergencyContactController,
          decoration: InputDecoration(
            hintText: 'Enter contact name',
            labelStyle:
            TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Emergency Contact Phone (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _emergencyPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'e.g., +254712345678',
            labelStyle:
            TextStyle(color: kTextGrey, fontSize: ScreenUtil().setSp(15)),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kTextGrey),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              // Basic phone validation if provided
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  List<Widget> get steps => [
    _buildPersonalDetailsStep(),
    _buildMedicalInfoStep(),
    _buildEmergencyContactStep(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: kSystemPadding,
          shrinkWrap: true,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Tell us about your pregnancy journey',
              style: TextStyle(color: kTextGrey),
            ),
            const SizedBox(height: 20),
            CustomCard(
              title: 'Let\'s Get Started!',
              children: [
                CustomStepperWidget(
                  data: profileSteps,
                  onTap: (val) {
                    setState(() {
                      selectedIndex = val;
                    });
                  },
                  selectedIndex: selectedIndex,
                ),
                const SizedBox(height: 25),
                steps[selectedIndex],
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: selectedIndex <= 0 ? 'Cancel' : 'Previous',
                        onTap: () {
                          if (selectedIndex == 0) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              selectedIndex--;
                            });
                          }
                        },
                        color: kTextGrey,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomButton(
                        text: selectedIndex == steps.length - 1
                            ? (_isLoading ? 'Submitting...' : 'Submit')
                            : 'Next',
                        onTap: _isLoading
                            ? null
                            : () {
                          if (selectedIndex == steps.length - 1) {
                            // On last step, submit
                            _saveProfile();
                          } else {
                            // Validate current step before moving forward
                            if (selectedIndex == 0) {
                              if (_formKey.currentState!.validate() &&
                                  _selectedEDD != null) {
                                setState(() {
                                  selectedIndex++;
                                });
                              } else if (_selectedEDD == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select Expected Due Date'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                selectedIndex++;
                              });
                            }
                          };
                        },
                        color: _isLoading ? kTextGrey : kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
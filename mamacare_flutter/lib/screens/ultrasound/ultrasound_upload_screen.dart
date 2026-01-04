import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mamacare_flutter/screens/ultrasound/ultrasound_history_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../constants/constant.dart';
import '../../main.dart';
import '../../services/storage_service.dart';

class UltrasoundUploadScreen extends StatefulWidget {
  const UltrasoundUploadScreen({super.key});

  @override
  State<UltrasoundUploadScreen> createState() => _UltrasoundUploadScreenState();
}

class _UltrasoundUploadScreenState extends State<UltrasoundUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Uint8List> _imageBytesList = [];
  int _currentImageIndex = 0;
  bool _isAnalyzing = false;
  dynamic _analysisResult;
  int? _pregnancyWeek;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _loadPregnancyWeek();
  }

  Future<void> _loadPregnancyWeek() async {
    try {
      final userId = StorageService().getUserId();
      if (userId == null) return;

      final profile = await client.v1MaternalProfile.getProfile(userId);

      if (profile != null && profile.expectedDueDate != null) {
        final today = DateTime.now();
        final dueDate = profile.expectedDueDate!;
        final daysDiff = dueDate.difference(today).inDays;
        final weeksRemaining = (daysDiff / 7).floor();
        final currentWeek = 40 - weeksRemaining;

        setState(() {
          _pregnancyWeek = currentWeek.clamp(1, 42);
        });
      } else {
        setState(() => _pregnancyWeek = 28);
      }
    } catch (e) {
      print('Error loading pregnancy week: $e');
      setState(() => _pregnancyWeek = 28);
    }
  }

  Future<void> _pickSingleImage(ImageSource source) async {
    if (_pregnancyWeek == null) {
      _showSnackBar('Loading pregnancy information...', Colors.orange);
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      _showSnackBar('Processing image...', Colors.blue);

      final bytes = await image.readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
      );

      setState(() {
        _imageBytesList = [Uint8List.fromList(compressed)];
        _currentImageIndex = 0;
      });

      _analyzeImage();

    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _pickMultipleImages() async {
    if (_pregnancyWeek == null) {
      _showSnackBar('Loading pregnancy information...', Colors.orange);
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      _showSnackBar('Processing ${images.length} images...', Colors.blue);

      List<Uint8List> compressedList = [];
      for (var image in images) {
        final bytes = await image.readAsBytes();
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 800,
          minHeight: 800,
          quality: 70,
        );
        compressedList.add(Uint8List.fromList(compressed));
      }

      setState(() {
        _imageBytesList = compressedList;
        _currentImageIndex = 0;
      });

      _analyzeImage();

    } catch (e) {
      print('Error picking images: $e');
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytesList.isEmpty || _pregnancyWeek == null) return;

    setState(() {
      _isAnalyzing = true;
      _lastError = null;
    });

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      final base64Image = base64Encode(_imageBytesList[_currentImageIndex]);

      print('🔍 Analyzing image ${_currentImageIndex + 1} of ${_imageBytesList.length}');

      final result = await client.v1Ultrasound.analyzeUltrasound(
        userId,
        base64Image,
        _pregnancyWeek!,
      );

      print('✅ Analysis complete: ${result.measurements.length} measurements');

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
        _lastError = null;
      });

    } catch (e) {
      print('❌ Analysis error: $e');
      setState(() {
        _isAnalyzing = false;
        _lastError = e.toString();
      });
      _showSnackBar('Analysis failed. Please try again.', Colors.red);
    }
  }

  Future<void> _retryAnalysis() async {
    await _analyzeImage();
  }

  Future<void> _saveResult() async {
    if (_analysisResult == null || _imageBytesList.isEmpty || _pregnancyWeek == null) return;

    try {
      final userId = StorageService().getUserId();
      if (userId == null) throw Exception('Not logged in');

      final base64Image = base64Encode(_imageBytesList[_currentImageIndex]);
      final measurementsJson = json.encode(_analysisResult.measurements ?? {});
      final explanation = _analysisResult.explanation ?? '';
      final nextScanWeek = _analysisResult.nextScanWeek;
      final nextScanDate = _analysisResult.nextScanDate;

      print('💾 Saving scan...');

      await client.v1Ultrasound.saveUltrasoundScan(
        userId,
        _pregnancyWeek!,
        base64Image,
        measurementsJson,
        explanation,
        nextScanWeek,
        nextScanDate,
      );

      _showSnackBar('✅ Scan saved successfully!', Colors.green);

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        // Navigate to history screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UltrasoundHistoryScreen(),
          ),
        );
      }
    } catch (e) {
      print('❌ Save error: $e');
      _showSnackBar('Error saving: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Upload Method',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildBottomSheetOption(
              'Take Photo',
              Icons.camera_alt_rounded,
              kPrimaryColor,
                  () {
                Navigator.pop(context);
                _pickSingleImage(ImageSource.camera);
              },
            ),
            SizedBox(height: 12.h),
            _buildBottomSheetOption(
              'Choose Single Image',
              Icons.photo_rounded,
              Colors.purple,
                  () {
                Navigator.pop(context);
                _pickSingleImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 12.h),
            _buildBottomSheetOption(
              'Choose Multiple Images',
              Icons.photo_library_rounded,
              Colors.orange,
                  () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ultrasound Translator'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: 24.sp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UltrasoundHistoryScreen(),
                ),
              );
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: _pregnancyWeek == null
          ? _buildLoadingState()
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildWeekBadge(),
            SizedBox(height: 24.h),

            if (_imageBytesList.isEmpty)
              _buildUploadSection()
            else
              _buildAnalysisSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3),
          SizedBox(height: 20.h),
          Text(
            'Loading pregnancy information...',
            style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            'Week $_pregnancyWeek',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryColor.withOpacity(0.08),
                Colors.purple.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_information_rounded,
                  size: 64.sp,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Upload Your Ultrasound',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'AI will translate medical measurements\ninto simple language',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: 30.h),

        _buildUploadButton(
          'Upload Ultrasound Images',
          Icons.upload_file_rounded,
          _showImagePickerOptions,
          kPrimaryColor,
        ),

        SizedBox(height: 24.h),

        _buildTipsCard(),
      ],
    );
  }

  Widget _buildUploadButton(
      String label,
      IconData icon,
      VoidCallback onTap,
      Color color,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'For best results, ensure the ultrasound image is clear and well-lit',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Column(
      children: [
        if (_imageBytesList.length > 1) ...[
          _buildImageNavigation(),
          SizedBox(height: 16.h),
        ],

        _buildImagePreview(),
        SizedBox(height: 24.h),

        if (_isAnalyzing)
          _buildAnalyzingIndicator()
        else if (_lastError != null)
          _buildErrorState()
        else if (_analysisResult != null)
            _buildResults(),
      ],
    );
  }

  Widget _buildImageNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentImageIndex > 0
              ? () {
            setState(() {
              _currentImageIndex--;
              _analysisResult = null;
            });
            _analyzeImage();
          }
              : null,
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          color: kPrimaryColor,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'Image ${_currentImageIndex + 1} of ${_imageBytesList.length}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
        IconButton(
          onPressed: _currentImageIndex < _imageBytesList.length - 1
              ? () {
            setState(() {
              _currentImageIndex++;
              _analysisResult = null;
            });
            _analyzeImage();
          }
              : null,
          icon: Icon(Icons.arrow_forward_ios, size: 20.sp),
          color: kPrimaryColor,
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.memory(
          _imageBytesList[_currentImageIndex],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnalyzingIndicator() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80.w,
                height: 80.w,
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 4,
                ),
              ),
              Icon(
                Icons.auto_awesome,
                size: 36.sp,
                color: kPrimaryColor,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'AI is Analyzing...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Gemini 3 AI is extracting measurements\nand generating explanation',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _lastError ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.red[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: _retryAnalysis,
            icon: Icon(Icons.refresh, size: 20.sp),
            label: const Text('Retry Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final measurements = _analysisResult.measurements as Map<String, String>? ?? {};
    final explanation = _analysisResult.explanation ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (measurements.isNotEmpty) ...[
          Text(
            '📏 Measurements',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: measurements.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.straighten,
                                size: 16.sp,
                                color: kPrimaryColor,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        flex: 2,
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.h),
        ],

        Text(
          '🤖 AI Explanation',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple[50]!,
                Colors.pink[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.purple[200]!, width: 2),
          ),
          child: Text(
            explanation,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _imageBytesList = [];
                _analysisResult = null;
                _currentImageIndex = 0;
                _lastError = null;
              });
            },
            icon: Icon(Icons.refresh, size: 20.sp),
            label: Text('New Scan', style: TextStyle(fontSize: 14.sp)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: kPrimaryColor, width: 2),
              foregroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _saveResult,
            icon: Icon(Icons.save_rounded, size: 20.sp),
            label: Text('Save Scan', style: TextStyle(fontSize: 15.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
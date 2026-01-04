import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  /// Send emergency SMS to contacts
  Future<bool> sendEmergencySOS({
    required List<String> emergencyContacts,
    required String userName,
    required int pregnancyWeek,
  }) async {
    try {
      print('🚨 Initiating Emergency SOS...');

      // Get location
      String location = await _getCurrentLocation();

      // Create emergency message
      String message = _createEmergencyMessage(userName, pregnancyWeek, location);

      print('📱 Emergency message: $message');

      // Send SMS to all emergency contacts
      bool allSent = true;
      for (String contact in emergencyContacts) {
        final sent = await _sendSMS(contact, message);
        if (!sent) allSent = false;
      }

      if (allSent) {
        print('✅ Emergency SOS sent to ${emergencyContacts.length} contacts');
      } else {
        print('⚠️ Some SOS messages failed to send');
      }

      return allSent;
    } catch (e) {
      print('❌ Error sending Emergency SOS: $e');
      return false;
    }
  }

  /// Get current location
  Future<String> _getCurrentLocation() async {
    try {
      // Check location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return 'Location unavailable';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      // Format location
      return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      print('⚠️ Could not get location: $e');
      return 'Location unavailable';
    }
  }

  /// Create emergency message
  String _createEmergencyMessage(String userName, int pregnancyWeek, String location) {
    return '''
🚨 EMERGENCY ALERT 🚨

$userName needs IMMEDIATE HELP!

Pregnancy: Week $pregnancyWeek
Time: ${DateTime.now().toString().substring(0, 16)}
Location: $location

This is an automated emergency alert from MamaCare Butler.
Please check on her IMMEDIATELY or call emergency services.
''';
  }

  /// Send SMS to a contact
  Future<bool> _sendSMS(String phoneNumber, String message) async {
    try {
      // Clean phone number (remove spaces, dashes)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create SMS URI
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: {'body': message},
      );

      print('📤 Sending SMS to: $cleanNumber');

      // Launch SMS app
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      } else {
        print('❌ Cannot launch SMS for: $cleanNumber');
        return false;
      }
    } catch (e) {
      print('❌ Error sending SMS to $phoneNumber: $e');
      return false;
    }
  }

  /// Quick call emergency contact
  Future<void> callEmergencyContact(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri callUri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
        print('📞 Calling: $cleanNumber');
      } else {
        print('❌ Cannot make call to: $cleanNumber');
      }
    } catch (e) {
      print('❌ Error calling $phoneNumber: $e');
    }
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    final smsPermission = await Permission.sms.request();
    final locationPermission = await Permission.location.request();

    return smsPermission.isGranted && locationPermission.isGranted;
  }
}
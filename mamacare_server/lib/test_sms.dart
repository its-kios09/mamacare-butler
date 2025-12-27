import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  // SMS Configuration (from KenyaEMR)
  final smsUrl = 'https://sms-service.kenyahmis.org/api/sender';
  final apiToken = 'cWMu5tZWjZdIcJEPbrK5hUhcBwdWtVKDEWRER24SKM9343I';
  final senderId = 'HMIS-SMS';
  final gateway = 'Pal_KeHMIS';

  // Test phone number (use your number)
  print('Enter your phone number (e.g., +254712345678):');
  final phoneNumber = stdin.readLineSync() ?? '';

  // Test message
  final message = 'Test from MamaCare: Your OTP is 123456';

  print('\n📱 Sending test SMS to: $phoneNumber');
  print('📨 Message: $message\n');

  try {
    // Prepare request (same format as KenyaEMR)
    final response = await http.post(
      Uri.parse(smsUrl),
      headers: {
        'api-token': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'destination': phoneNumber,
        'msg': message,
        'sender_id': senderId,
        'gateway': gateway,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}\n');

    if (response.statusCode == 200) {
      print('✅ SMS sent successfully!');
    } else {
      print('❌ Failed to send SMS');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

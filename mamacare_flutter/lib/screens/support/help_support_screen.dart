import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/constant.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('❌ Could not launch $url');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      print('❌ Could not launch $phone');
    }
  }

  Future<void> _launchEmail(String email, String subject) async {
    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');
    if (!await launchUrl(uri)) {
      print('❌ Could not launch $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: Colors.white, size: 48.sp),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We\'re Here to Help',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Get support 24/7',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Emergency Contacts
            _buildSection(
              title: 'Emergency Contacts',
              icon: Icons.emergency,
              iconColor: Colors.red,
              children: [
                _buildContactCard(
                  icon: Icons.local_hospital,
                  title: 'Emergency Services',
                  subtitle: 'Call for immediate medical help',
                  action: '999',
                  onTap: () => _launchPhone('999'),
                  color: Colors.red,
                ),
                SizedBox(height: 12.h),
                _buildContactCard(
                  icon: Icons.phone,
                  title: 'Maternal Health Hotline',
                  subtitle: 'Free pregnancy advice 24/7',
                  action: '15999',
                  onTap: () => _launchPhone('15999'),
                  color: Colors.orange,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Contact Us
            _buildSection(
              title: 'Contact Us',
              icon: Icons.mail,
              iconColor: kPrimaryColor,
              children: [
                _buildContactCard(
                  icon: Icons.email,
                  title: 'Email Support',
                  subtitle: 'support@mamacare.co.ke',
                  action: 'Send Email',
                  onTap: () => _launchEmail(
                    'support@mamacare.co.ke',
                    'MamaCare Support Request',
                  ),
                  color: kPrimaryColor,
                ),
                SizedBox(height: 12.h),
                _buildContactCard(
                  icon: Icons.phone_in_talk,
                  title: 'Phone Support',
                  subtitle: '+254 700 000 000',
                  action: 'Call Now',
                  onTap: () => _launchPhone('+254700000000'),
                  color: Colors.green,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // FAQs
            _buildSection(
              title: 'Frequently Asked Questions',
              icon: Icons.question_answer,
              iconColor: Colors.blue,
              children: [
                _buildFAQItem(
                  question: 'How do I track my medications?',
                  answer: 'Go to the Medications tab from your home screen. Tap "Add Medication" and fill in the details including reminder times.',
                ),
                _buildFAQItem(
                  question: 'What is the kick counter for?',
                  answer: 'The kick counter helps you monitor your baby\'s movements. Count 10 kicks - if it takes longer than 2 hours, contact your healthcare provider.',
                ),
                _buildFAQItem(
                  question: 'How does the AI health check-in work?',
                  answer: 'Our AI analyzes your weekly symptoms and vital signs to detect potential complications like pre-eclampsia. Complete it every week for best results.',
                ),
                _buildFAQItem(
                  question: 'Is my data secure?',
                  answer: 'Yes! All your health data is encrypted and stored securely. We never share your information without your consent.',
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Resources
            _buildSection(
              title: 'Helpful Resources',
              icon: Icons.library_books,
              iconColor: Colors.purple,
              children: [
                _buildResourceCard(
                  icon: Icons.web,
                  title: 'Ministry of Health Kenya',
                  subtitle: 'Official maternal health guidelines',
                  onTap: () => _launchURL('https://www.health.go.ke'),
                ),
                SizedBox(height: 12.h),
                _buildResourceCard(
                  icon: Icons.article,
                  title: 'Pregnancy Care Guide',
                  subtitle: 'Week-by-week pregnancy information',
                  onTap: () => _launchURL('https://www.who.int/maternal-health'),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // App Info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: kPrimaryColor, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'MamaCare Butler',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Powered by Serverpod & Flutter',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        trailing: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          child: Text(action, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: Icon(icon, color: Colors.purple, size: 28.sp),
        title: Text(
          title,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
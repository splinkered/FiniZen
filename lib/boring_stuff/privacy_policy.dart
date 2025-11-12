import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Privacy Policy'),
              Text(
                'This privacy policy applies to the FiniZen app (hereby referred to as "Application") '
                'for mobile devices that was created by Pragnesh Patil (hereby referred to as "Service Provider") '
                'as an Open Source service. This service is intended for use "AS IS".',
              ),
              SizedBox(height: 16),

              SectionTitle('What information does the Application obtain and how is it used?'),
              Text(
                'The Application does not obtain any information when you download and use it. '
                'Registration is not required to use the Application.',
              ),
              SizedBox(height: 16),

              SectionTitle('Does the Application collect precise real time location information of the device?'),
              Text(
                'This Application does not collect precise information about the location of your mobile device.',
              ),
              SizedBox(height: 16),

              SectionTitle('Do third parties see and/or have access to information obtained by the Application?'),
              Text(
                'Since the Application does not collect any information, no data is shared with third parties.',
              ),
              SizedBox(height: 16),

              SectionTitle('What are my opt-out rights?'),
              Text(
                'You can stop all collection of information by the Application easily by uninstalling it. '
                'You may use the standard uninstall processes as may be available as part of your mobile device or '
                'via the mobile application marketplace or network.',
              ),
              SizedBox(height: 16),

              SectionTitle('Children'),
              Text(
                'The Application is not used to knowingly solicit data from or market to children under the age of 13.\n\n'
                'The Service Provider does not knowingly collect personally identifiable information from children. '
                'The Service Provider encourages all children to never submit any personally identifiable information through the Application and/or Services. '
                'The Service Provider encourages parents and legal guardians to monitor their children\'s Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission.\n\n'
                'If you have reason to believe that a child has provided personally identifiable information to the Service Provider through the Application and/or Services, '
                'please contact the Service Provider (splinkered@gmail.com) so that they will be able to take the necessary actions. '
                'You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country '
                '(in some countries we may allow your parent or guardian to do so on your behalf).',
              ),
              SizedBox(height: 16),

              SectionTitle('Security'),
              Text(
                'The Service Provider is concerned about safeguarding the confidentiality of your information. '
                'However, since the Application does not collect any information, there is no risk of your data being accessed by unauthorized individuals.',
              ),
              SizedBox(height: 16),

              SectionTitle('Changes'),
              Text(
                'This Privacy Policy may be updated from time to time for any reason. '
                'The Service Provider will notify you of any changes to their Privacy Policy by updating this page with the new Privacy Policy. '
                'You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.',
              ),
              SizedBox(height: 16),

              SectionTitle('Effective Date'),
              Text('This privacy policy is effective as of 2025-08-08'),
              SizedBox(height: 16),

              SectionTitle('Your Consent'),
              Text(
                'By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by the Service Provider.',
              ),
              SizedBox(height: 16),

              SectionTitle('Contact Us'),
              Text(
                'If you have any questions regarding privacy while using the Application, or have questions about the practices, '
                'please contact the Service Provider via email at splinkered@gmail.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

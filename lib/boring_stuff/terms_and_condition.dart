import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Terms & Conditions'),
              Text(
                'These terms and conditions apply to the FiniZen app (hereby referred to as "Application") '
                'for mobile devices that was created by Pragnesh Patil (hereby referred to as "Service Provider") as an Open Source service.',
              ),
              SizedBox(height: 16),

              SectionTitle('Acceptance of Terms'),
              Text(
                'Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. '
                'It is strongly advised that you thoroughly read and understand these terms prior to using the Application. '
                'Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly allowed, you\'re welcome to BALL (KOBEEEEE). '
                'Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions is very much appreciated, this is an open source application. '
                'All trademarks, copyrights, database rights, and other intellectual property rights related to the Application are something I genuinely dont care about, just dont sue me, I\'m too young for debt :?) ',
              ),
              SizedBox(height: 16),

              SectionTitle('Modifications & Charges'),
              Text(
                'The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. '
                'As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. '
                'The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you (chill out it\'s perpetually free).',
              ),
              SizedBox(height: 16),

              SectionTitle('User Responsibility & Device Security'),
              Text(
                'The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. '
                'It is your responsibility to maintain the security of your phone and access to the Application. '
                'The Service Provider strongly advises against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by your device\'s operating system. '
                'Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone\'s security features, and may result in the Application not functioning correctly or at all. '
                'That being said, the application does not use internet and does what it does so don\'t worry about your data, its all local, however do check playstore once in 5 years in case I decide to update this. ',

              ),
              SizedBox(height: 16),

              SectionTitle('Internet Connectivity & Charges'),
              Text(
                'Please be aware that the Service Provider does not assume responsibility for certain aspects. '
                'No functions of the Application require an active internet connection, which can be Wi-Fi or mobile data. '
              ),
              SizedBox(height: 16),


              SectionTitle('Device Usage Responsibility'),
              Text(
                'Similarly, the Service Provider cannot always assume responsibility for your usage of the application. '
                'It is your responsibility to ensure that your device remains charged. '
                'If your device runs out of battery and you are unable to access the Service, the Service Provider cannot be held responsible.',
              ),
              SizedBox(height: 16),

              SectionTitle('Service Accuracy & Reliance'),
              Text(
                'In terms of the Service Provider\'s responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, '
                'they do rely on third parties to provide information. '
                'The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.',
              ),
              SizedBox(height: 16),

              SectionTitle('Updates & Termination'),
              Text(
                'The Service Provider may wish to update the application at some point. '
                'The application is currently available as per the requirements of the operating system. These requirements may change, and you will need to download the updates to continue using it. '
                'The Service Provider does not guarantee that it will always update the application to be compatible with your device OS version.\n\n'
                'However, you agree to always accept updates to the application when offered. '
                'The Service Provider may also choose to stop providing the application and may terminate usage at any time without notice. '
                'Unless informed otherwise, upon termination: (a) the rights and licenses granted to you in these terms will end; '
                '(b) you must cease using the application and delete it from your device. ',
              ),
              SizedBox(height: 16),

              SectionTitle('Changes to These Terms and Conditions'),
              Text(
                'The Service Provider may periodically update their Terms and Conditions. You are advised to review this page regularly for any changes. (don\'t, I\'m too lazy for all this legal hassle) '
                'Changes will be communicated by posting the new Terms and Conditions on this page. ',
              ),
              SizedBox(height: 16),

              SectionTitle('Effective Date'),
              Text('These terms and conditions are effective as of 2025-08-08'),
              SizedBox(height: 16),

              SectionTitle('Contact Us'),
              Text(
                'If you have any questions or suggestions about the Terms and Conditions, please contact the Service Provider at splinkered@gmail.com.',
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

import 'package:flutter/material.dart';

class AppAboutPage extends StatelessWidget {
  const AppAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('What is this app?'),
              Text(
                'This is a simple money management app I\'ve developed for managing my money in college. '
                'It provides all necessary features to log transactions, bills and categorize them. '
                'I made this in 6 weeks of my vacations. Its not the best app as I\'ve programmed most of this while being stoned but it makes the cut. Its something I would use. ',

              ),
              SizedBox(height: 16),

              SectionTitle('How can I request any new features or contact regarding the application? '),
              Text(
                'Mail me at splinkered@gmail.com for any help regarding the application or feedback.',
              ),
              SizedBox(height: 16),

              SectionTitle('Will there ever by any ads or micro transactions in this application?'),
              Text(
                'Never.',
              ),
              SizedBox(height: 16),

              SectionTitle('The most random thought?'),
              Text(
                'We are all human beans.'
                '\nand one day, we all will rice.'
                '\nthe only thing that matters is keeping up the pulse'
                '\nno effort is big or lentil'
                
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('~ Joe'),
                ],
              ),
              SizedBox(height: 16),

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

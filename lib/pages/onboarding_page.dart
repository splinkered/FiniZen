import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/pages/dashboard_page.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _selectedCurrencyCode = 'INR';
  String? _selectedCurrencySymbol = '₹';

  Future<void> _onDone(BuildContext context) async {
    String username = _usernameController.text.trim();
    String goalText = _goalController.text.trim();
    String password = _passwordController.text;
     String avatarJson = await FluttermojiFunctions().encodeMySVGtoString();
    double? goal = double.tryParse(goalText);

    if (username.isEmpty || goal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid username and savings goal')),
      );
      return;
    }

    if (password.isNotEmpty && (password.length != 4 || !RegExp(r'^\d{4}$').hasMatch(password))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App lock password must be exactly 4 digits')),
      );
      return;
    }

    await SQLHelper.storeAppData(
      username,
      _selectedCurrencySymbol!,
      avatarJson,
      password.isNotEmpty ? 1 : 0,
      goal,
    );

    if (password.isNotEmpty) {
      await _secureStorage.write(key: 'applock_password', value: password);
      AppLock.of(context)?.enable();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Dashboard()),
    );
  }

  void _showCurrencyPickerDialog() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (currency) {
        setState(() {
          _selectedCurrencyCode = currency.code;
          _selectedCurrencySymbol = currency.symbol;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        key: _introKey,
        globalBackgroundColor: Colors.white,
        pages: [
          // Intro
          PageViewModel(
          title: 'Finizen - Finance made Zen',
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "This app helps you manage basic finances. Here's what you can do:",
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ListTile(
                      leading: Icon(Icons.monetization_on_outlined),
                      title: Text('Track your income and expenses', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.receipt),
                      title: Text('Manage bills and due dates', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.category),
                      title: Text('Categorize transactions', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),                  
                    ListTile(
                      leading: Icon(Icons.analytics, ),
                      title: Text('Minimal spending summaries', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.checklist_rtl, ),
                      title: Text('A ToDo List to track goals', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.savings, ),
                      title: Text('A seperate page to track and maintain a rigid savings', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.save, ),
                      title: Text('Create local backups, export to excel (very basic)', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Optional app lock for security', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                    ListTile(
                      leading: Icon(Icons.face_2_sharp),
                      title: Text('Cool avatar cause why not!', style: TextStyle(fontSize: 16)),
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: const Text(
                    "Lets get you started!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      
          // Username
          
          PageViewModel(
            title: 'Select Name and Avatar.',
            bodyWidget: Center(
              child: Column(
                children: [
                  FluttermojiCircleAvatar(radius: 60),
                SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: FluttermojiCustomizer(),
                ),
                ],
              ),
            ),
          ),
      
          
      
          // Savings Goal
          PageViewModel(
            
            title: 'Set a Savings Goal',
            image: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset(
                './assets/images/savings.png',
                //height: 160,
                fit: BoxFit.contain,
              ),
            ),
            bodyWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextField(
                controller: _goalController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Savings Amount (e.g. 5000)',
                  prefixIcon: Icon(Icons.savings),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
      
          // Currency Picker
          PageViewModel(
            title: 'Choose Your Preferred Currency',
            image: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset(
                './assets/images/currency.png',
                //height: 160,
                fit: BoxFit.contain,
              ),
            ),
            bodyWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: GestureDetector(
                onTap: _showCurrencyPickerDialog,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Preferred Currency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_exchange),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCurrencySymbol != null
                            ? '$_selectedCurrencySymbol ($_selectedCurrencyCode)'
                            : 'Tap to select currency',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
      
          // App Lock Password
          PageViewModel(
            title: 'Set an App Lock Password (Optional) ',
            image: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset(
                './assets/images/password.png',
                //height: 160,
                fit: BoxFit.contain,
              ),
            ),
            bodyWidget: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              child: Column(
                children: [
                  Text("you'll lose access to the application if you forget this app lock to make sure to note it down somewhere!"),
                  const SizedBox(height:10),
                  TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'App Lock Password',
                      hintText: '4-digit PIN (optional)',
                      counterText: '', // hides character counter
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
        onDone: () => _onDone(context),
        showSkipButton: false,
        showBackButton: true,
        back: const Icon(Icons.arrow_back),
        next: const Icon(Icons.arrow_forward),
        done: TextButton(onPressed: (){_onDone(context);}, child: Row(
          children: [
            Text('Submit',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),),
          ],
        )), // hidden, handled in button above
        dotsDecorator: const DotsDecorator(
          size: Size(6.0, 6.0),
          activeSize: Size(10.0, 10.0),
          activeColor: Colors.deepPurple,
          spacing: EdgeInsets.symmetric(horizontal: 3.0),
        ),
      ),
    );
  }
}

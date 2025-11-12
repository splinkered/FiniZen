import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
 
  
  final TextEditingController _pinController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  String _storedPassword = '';
  String _errorText = '';
  
 

  void _validatePin() {
    if (_pinController.text == _storedPassword) {
      AppLock.of(context)?.didUnlock('Unlocked');
    } else {
      setState(() {
        _errorText = 'Incorrect PIN. Try again.';
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    String? password = await _secureStorage.read(key: 'applock_password');
    setState(() {
      _storedPassword = password ?? '';
    });
  }


  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onKeyTap(String value) {
    if (_pinController.text.length < 4) {
      setState(() {
        _errorText = '';
        _pinController.text += value;
      });

      if (_pinController.text.length == 4) {
        _validatePin();
      }
    }
  }

  void _onBackspace() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _errorText = '';
        _pinController.text =
            _pinController.text.substring(0, _pinController.text.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _errorText = '';
      _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 60, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Enter PIN to open',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _pinController.text.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black87, width: 1.5),
                              color: isFilled ? Colors.black87 : Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (_errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _errorText,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(height: 20),
              // ElevatedButton.icon(
              //   key: const Key('UnlockButton'),
              //   onPressed: _validatePin,
              //   icon: const Icon(Icons.login, color: Colors.black87, size: 24,),
              //   label: Text('Unlock', style: Theme.of(context).textTheme.bodyMedium,),
              // ),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildKeypad() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['←', '0', 'C'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (key == '←') {
                    _onBackspace();
                  } else if (key == 'C') {
                    _onClear();
                  } else {
                    _onKeyTap(key);
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(70, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 24, color: (key == '←' || key == 'C') ? Colors.red : Colors.black87),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

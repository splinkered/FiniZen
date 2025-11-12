import 'dart:io';

import 'package:FiniZen/boring_stuff/about_page.dart';
import 'package:FiniZen/main.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:FiniZen/boring_stuff/privacy_policy.dart';
import 'package:FiniZen/boring_stuff/terms_and_condition.dart';
import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/global_variables.dart';
import 'package:FiniZen/pages/configure_bills.dart';
import 'package:FiniZen/pages/transaction_list_page.dart';
import 'package:FiniZen/pages/add_page.dart';
import 'package:FiniZen/pages/bills_page.dart';
import 'package:FiniZen/pages/statistics_page.dart';
import 'package:FiniZen/providers/dashboarddbprovider.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:FiniZen/widgets/dashboard_calender.dart';
import 'package:FiniZen/widgets/dashboard_main_carousel_item.dart';
import 'package:device_info_plus/device_info_plus.dart';  
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget { 
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}


class _DashboardState extends State<Dashboard> with RouteAware {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  
  Future<void> _showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'daily_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        color: Colors.amber,

      ),
    );
  }


  Future<void> _checkAndRequestPermissions() async {
    List<Permission> requiredPermissions = [];

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
        int sdkInt = androidInfo.version.sdkInt ?? 0;
        requiredPermissions.add(Permission.camera);
      if (sdkInt >= 33) {
        requiredPermissions.add(Permission.photos); 
      } else {
        requiredPermissions.add(Permission.storage);
      }
    } else if (Platform.isIOS) {
      requiredPermissions.addAll([
        Permission.camera,
        Permission.photos,
        Permission.notification
      ]);
    }

    Map<Permission, PermissionStatus> statuses = await requiredPermissions.request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Permissions Required"),
            content: const Text(
              "We need Camera and Storage permissions to store the records and reciepts, to continue, please grant the relevent permissions.\n"
              "Please allow them in the next screen."
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (statuses.values.any((status) => status.isPermanentlyDenied)) {
                    await openAppSettings();
                  } else {
                    Navigator.of(context).pop();
                    await _checkAndRequestPermissions();
                  }
                },
                child: const Text("Grant Permissions"),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleAppLock() async {
  String? currentPin = await _secureStorage.read(key: 'applock_password');

  TextEditingController currentPinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();
  TextEditingController confirmPinController = TextEditingController();


  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(currentPin != null ? 'Change App Lock PIN' : 'Set App Lock PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentPin != null)
                TextField(
                  controller: currentPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter current PIN',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 10,),
              TextField(
                controller: newPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter new 4-digit PIN',
                  counterText: '',
                ),
              ),
                const SizedBox(height: 10,),
              TextField(
                controller: confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  hintText: 'Confirm new PIN',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            if (currentPin != null)
              TextButton(
                onPressed: () async {
                  await _secureStorage.delete(key: 'applock_password');
                  await SQLHelper.updateAppLockStatus(1, 0);
                  AppLock.of(context)?.disable();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App lock disabled")));
                },
                child: const Text('Disable'),
              ),
            TextButton(
              onPressed: () async {
                String current = currentPinController.text.trim();
                String newPin = newPinController.text.trim();
                String confirm = confirmPinController.text.trim();

                if (newPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(newPin)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN must be 4 digits")));
                  return;
                }

                if (newPin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PINs do not match")));
                  return;
                }

                if (currentPin != null && current != currentPin) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect current PIN")));
                  return;
                }

                await _secureStorage.write(key: 'applock_password', value: newPin);
                await SQLHelper.updateAppLockStatus(1, 1);
                AppLock.of(context)?.enable();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App lock updated")));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}


void _handleCurrencyChange() async {
  showCurrencyPicker(
    context: context,
    showFlag: true,
    showCurrencyName: true,
    showCurrencyCode: true,
    onSelect: (Currency currency) async {
      await SQLHelper.updateAppCurrency(1,currency.symbol);
      setState(() {
        _userdata['currency'] = currency.symbol;
        currentcurrency= currency.symbol;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Currency updated to ${currency.symbol}')));
    },
  );
}

void _handleProfileUpdate() async {
  TextEditingController nameController = TextEditingController(text: _userdata['username']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FluttermojiCircleAvatar(radius: 40),
              const SizedBox(height: 10),
              FluttermojiCustomizer(),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String updatedName = nameController.text.trim();
              if (updatedName.isNotEmpty) {
                String updatedAvatar = await FluttermojiFunctions().encodeMySVGtoString();
                await SQLHelper.updateAppUsernameAvatar(1,updatedName, updatedAvatar);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('fluttermoji', updatedAvatar);
                await _loadAvatar();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username cannot be empty')));
              }
            },
            child: const Text("Save"),
          )
        ],
      );
    },
  );
}
  
   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {      
      Provider.of<RecordsProvider>(context, listen: false).freshRecords();
    });
    routeObserver.subscribe(this, ModalRoute.of(context)!);
     
  }
  
  bool _isLoading = true;
  double tempSpent = 0;
  double tempReceived = 0;
  double tempOverall = 0;

  String? _avatarSvg;

void _loadDashboardData() async {
  final totals = await SQLHelper.getDashboardTotals();

  setState(() {
    tempSpent = totals['spent']!;
    tempReceived = totals['received']!;
    tempOverall = tempReceived - tempSpent;
    _isLoading = false;
  });
}
void _setNotifications() async {
  //await scheduleDailyMorningNotification();
  await scheduleDailyBillReminders();
  await scheduleOverdueBillNotifications();
}

  @override  
  void initState() {
    
    super.initState();  
    _setNotifications();
    setState(() {
      
       _loadAvatar();
      _loadDashboardData();
    });

    _isLoading = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();         
    });
  }

  
  Future<void> _checkUpcomingBills() async {
    final dueBills = await SQLHelper.getBillsDueInNextTwoWeeks();


    for (int i = 0; i < dueBills.length; i++) {
      final bill = dueBills[i];
      final dueDate = DateTime.parse(bill['duedatetime']).toLocal().toString().split(' ').first;
      final uniqueId = 1000 + bill['id'];

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: uniqueId as int,
          channelKey: 'daily_channel',
          title: 'Upcoming Bill Due',
          body: '${bill['billname']} is due on $dueDate',
          notificationLayout: NotificationLayout.Default,
          groupKey: 'bill_${bill['id']}',
          color: Colors.amber
        ),
      );
    }
  }

  Map<String, dynamic> _userdata = {};
  Future<void> _loadAvatar() async {
    final appData = await SQLHelper.getappData();
    _userdata = Map<String, dynamic>.from(appData[0]);
    if (appData.isNotEmpty && appData[0]['profile_pic_icon'] != null) {
      final avatarJsonString = appData[0]['profile_pic_icon'];
      currentcurrency = appData[0]['currency'];
      
      // Apply avatar config to Fluttermoji state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fluttermoji', avatarJsonString);

      setState(() {
        _userdata = Map<String, dynamic>.from(appData[0]);
        _avatarSvg = avatarJsonString; // Just for safety
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
   setState(() {
     _loadDashboardData();
     Provider.of<RecordsProvider>(context, listen: false).freshRecords();
    });
  }
  

  final _advancedDrawerController = AdvancedDrawerController();
  @override
  Widget build(BuildContext context) {
    CarouselSliderController carouselController = CarouselSliderController();
    return _isLoading == true
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : AdvancedDrawer(
             backdrop: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromRGBO(137, 91, 161, 1), Color.fromRGBO(121, 50, 160, 1)],
                  ),
                ),
              ),
              controller: _advancedDrawerController,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              animateChildDecoration: true,
              rtlOpening: false,
              // openScale: 1.0,
              disabledGestures: false,
              childDecoration: const BoxDecoration(               
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 128.0,
                height: 128.0,
                margin: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 64.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),                
                child:  _avatarSvg != null
                  ?FluttermojiCircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 80,
                  )
                  : Icon(Icons.person, size: 64, color: Colors.white),// Assuming `avatarJson` is retrieved from DB:
                
              ),
              Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Hello ${_userdata['username']}", style: TextStyle(color: Colors.white),),
              ),),
              
              ListTile(
                onTap: () {_handleProfileUpdate(); },
                leading: Icon(Icons.account_circle_rounded),
                title: Text('Profile'),
              ),
              ListTile(
                onTap: () {
                  _handleAppLock();
                  
                },
                leading: Icon(Icons.lock),
                title: Text('App Lock'),
              ),
              ListTile(
                onTap: () { _handleCurrencyChange(); },
                leading: Icon(Icons.currency_exchange),
                title: Text('Set Currency'),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return AppAboutPage();
                  }));
                },
                leading: Icon(Icons.info_outline),
                title: Text('About'),
              ),
              ListTile(
                onTap: () {
                  openAppSettings();
                },
                leading: Icon(Icons.settings),
                title: Text('Open in Settings'),
              ),
              Spacer(),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return TermsAndConditionsPage();
                        })); },
                        child: Text('Terms of Service', style: TextStyle(color: Colors.white70)),
                        
                      ),
                      Text(' | '),
                      TextButton(
                        onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return PrivacyPolicyPage();
                        })); },
                        child: Text('Privacy Policy', style: TextStyle(color: Colors.white70)),
                        
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
            child: Scaffold(
              appBar: AppBar(
          title: const Text('FiniZen'),
          actions: [
            IconButton(onPressed: (){
              _checkUpcomingBills();
            }, icon: Icon(Icons.notifications_outlined))
          ],
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Semantics(
                    label: 'Menu',
                    onTapHint: 'expand drawer',
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
                  body: SingleChildScrollView(
                    child: SafeArea(
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [            
                //const FinAppTopNavigationBar(greeting: 'Welcome Back!', titleGiven: 'Username Username'),
                  
                
                DashboardCalender(),
                                        
                //Divider(indent: 10,endIndent: 10, thickness: 1,),
                  const SizedBox(height: 20,),
                  CarouselSlider(
                    carouselController: carouselController,
                    options: CarouselOptions(
                      height: 220, 
                      viewportFraction: 0.9,
                      initialPage: 1,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items: [
                      DashboardMainCarouselItem(title: "Expense", amt: tempSpent),
                      DashboardMainCarouselItem(title: "Overall Balance", amt: tempOverall),
                      DashboardMainCarouselItem(title: "Income", amt:  tempReceived),
                    ], ),    
                    
                    SizedBox(height: 20,),
                  
                    Column(
                      children: [                    
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          tileColor: Colors.amberAccent,
                          title: Text("View Statistics", style: Theme.of(context).textTheme.titleLarge,),
                          trailing: const  Icon(Icons.bar_chart, size: 32,),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return const  StatisticsPage();
                            }));
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          tileColor: Colors.lightGreen,
                          title: Text("Ledger Book", style: Theme.of(context).textTheme.titleLarge,),
                          trailing: const Icon(Icons.book, size: 32,),
                          onTap: () {
                            showModalBottomSheet(
                            context: context,
                            elevation: 5,
                            showDragHandle: true,
                            isScrollControlled: true,
                            builder: (_) => ListView(
                              shrinkWrap: true,                            
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListTile(
                                    shape: Border(
                                      bottom: BorderSide(width: 1, color: Colors.black54)
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                    //tileColor: Colors.lightGreenAccent,
                                    title: Text("All Transactions", style: Theme.of(context).textTheme.titleLarge,),
                                    trailing: const  Icon(Icons.list_alt, size: 32,),
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return const TransactionListPage();
                                      }));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListTile(
                                    shape: Border(
                                      bottom: BorderSide(width: 1, color: Colors.black54)
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                    //tileColor: Colors.lightBlueAccent,
                                    title: Text("Income", style: Theme.of(context).textTheme.titleLarge,),
                                    trailing: const  Icon(Icons.call_received, size: 32,),
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return const  TransactionListPage(isReceivedfilter: true,);
                                      }));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                    //tileColor: Colors.amberAccent,
                                    title: Text("Expense", style: Theme.of(context).textTheme.titleLarge,),
                                    trailing: const  Icon(Icons.arrow_outward, size: 32,),
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return const  TransactionListPage(isReceivedfilter: false);
                                      }));
                                    },
                                  ),
                                )
                              ],
                            ));
                          
                          },
                        ),
                        ListTile(                        
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          tileColor: Colors.lightBlue,
                          title: Text("Bill Manager", style: Theme.of(context).textTheme.titleLarge,),
                          trailing: const  Icon(Icons.receipt_long, size: 32,),
                          onTap: () {
                            showModalBottomSheet(
                            context: context,
                            elevation: 5,
                            showDragHandle: true,
                            isScrollControlled: true,
                            builder: (_) => ListView(
                              shrinkWrap: true,                            
                              children: [
                                Padding(
                                  
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListTile(
                                    shape: Border(
                                      bottom: BorderSide(width: 1, color: Colors.black54)
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                    //tileColor: Colors.lightGreenAccent,
                                    title: Text("Pay Bill", style: Theme.of(context).textTheme.titleLarge,),
                                    trailing: const  Icon(Icons.monetization_on_outlined, size: 32,),
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return const BillsPage();
                                      }));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                                    //tileColor: Colors.lightBlueAccent,
                                    title: Text("Configure Bill", style: Theme.of(context).textTheme.titleLarge,),
                                    trailing: const  Icon(Icons.handyman, size: 32,),
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return const ConfigureBills();
                                      }));
                                    },
                                  ),
                                ),
                                
                              ],
                            ));
                          },
                        ),
            
                         Container(
                          color: Colors.lightBlue.shade100,
                          height:90,
                          child: Center(
                            child: Text("By splinkered", style: Theme.of(context).textTheme.titleMedium),
                          ),
                        )
                        
                      ],
                    ),
                    
              ],        
            ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    backgroundColor:const Color.fromRGBO(121, 50, 160, 1),
            
                    onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return const AddPage();
            }));
                    },        
                    tooltip:"Add",
                    child: const Icon(Icons.add, size: 35, color: Colors.white,),
                  ),
                  //floatingActionButtonLocation: FloatingActionButtonLocation.,  
                  
                ),
                
          );
    
  }
  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
import 'package:FiniZen/database/db_manager.dart';
import 'package:FiniZen/lockscreen/lock_screen.dart';
import 'package:FiniZen/pages/dashboard_page.dart';
import 'package:FiniZen/pages/onboarding_page.dart';
import 'package:FiniZen/providers/dashboarddbprovider.dart';
import 'package:FiniZen/providers/expense_category_provider.dart';
import 'package:FiniZen/providers/income_category_provider.dart';
import 'package:FiniZen/routeobservers/route_observer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';


Future<void> scheduleOverdueBillNotifications() async {
  // Cancel any previous overdue bill notifications to avoid duplicates
  await AwesomeNotifications().cancelNotificationsByChannelKey('overdue_bill_channel');

  final overdueBills = await SQLHelper.getOverdueBills();

  for (final bill in overdueBills) {
    final dueDate = DateTime.parse(bill['duedatetime']).toLocal();
    final formattedDueDate = "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}";

    // IDs from 3000 to avoid clashing with others
    final uniqueId = 3000 + bill['id'];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: uniqueId.toInt(),
        channelKey: 'overdue_bill_channel',
        title: 'Overdue Bill ⚠️',
        body: '${bill['billname']} was due on $formattedDueDate. Please pay it or update the same in FiniZen!',
        notificationLayout: NotificationLayout.Default,
        color: Colors.redAccent,
      ),
      schedule: NotificationCalendar(
        hour: 9, 
        minute: 45,
        second: 0,
        millisecond: 0,
        repeats: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
    );
  }
}

Future<void> _requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print("Storage permission granted");
  } else if (await Permission.manageExternalStorage.request().isGranted) {
    print("Manage External Storage permission granted");
  } else {
    print("Storage permission denied");
  }
}

Future<void> scheduleDailyBillReminders() async {
  // Cancel any previous bill notifications in this ID range
  await AwesomeNotifications().cancelNotificationsByChannelKey('bill_channel');

  final dueBills = await SQLHelper.getBillsDueInNextTwoWeeks();

  for (final bill in dueBills) {
    final dueDate = DateTime.parse(bill['duedatetime']).toLocal();
    final formattedDueDate = "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}";

    // Start IDs from 2000 to avoid clashing with daily reminders
    final uniqueId = 2000 + bill['id'];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: uniqueId.toInt() ,
        channelKey: 'bill_channel',
        title: 'Upcoming Bill Due',
        body: '${bill['billname']} is due on $formattedDueDate',
        notificationLayout: NotificationLayout.Default,
        color: Colors.amber,
      ),
      schedule: NotificationCalendar(
        hour: 10,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
    );
  }
}

Future<void> scheduleDailyMorningNotification() async {
  // Cancel any previous scheduled instance of this notification to avoid duplicates
  await AwesomeNotifications().cancel(1);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1, // unique ID
      channelKey: 'daily_channel',
      title: 'Good Morning',
      body: 'Be sure to check your finances and track your spending!',
      notificationLayout: NotificationLayout.Default,
      color: Colors.amber
    ),
    schedule: NotificationCalendar(
      hour: 9, 
      minute: 31,
      second: 0,
      millisecond: 0,
      repeats: true, // This ensures it repeats daily
      timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
    ),

  );
}

void main({  
  Duration initialBackgroundLockLatency = const Duration(seconds: 15),
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestStoragePermission(); 
  try {

    tz.initializeTimeZones();

    // Database init - wrapped so it doesn't crash
    try {
      await SQLHelper.initAllDatabases();
      await SQLHelper.cleanUpUnusedImageFiles();
    } catch (e, st) {
      debugPrint("Database init error: $e\n$st");
    }

    // Get app data safely
    bool initEnabled = false;
    bool hasData = false;
    try {
      final appData = await SQLHelper.getappData();
      hasData = appData.isNotEmpty;
      if (hasData && appData[0]['isAppLockEnabled'] == 1) {
        initEnabled = true;
      }
    } catch (e, st) {
      debugPrint("App data fetch error: $e\n$st");
    }

    // Notifications setup
    try {
      AwesomeNotifications().initialize(
        'resource://drawable/ic_stat_notification',
        [
          NotificationChannel(
            channelKey: 'daily_channel',
            channelName: 'Daily Notifications',
            channelDescription: 'Daily morning reminders',
            defaultColor: Colors.amber,
            icon: 'resource://drawable/ic_stat_notification',
            importance: NotificationImportance.High,
          ),
          NotificationChannel(
            channelKey: 'bill_channel',
            channelName: 'Bill Reminders',
            channelDescription: 'Reminds you about upcoming bill payments',
            defaultColor: Colors.amber,
            importance: NotificationImportance.High,
          ),
          NotificationChannel(
            channelKey: 'overdue_bill_channel',
            channelName: 'Overdue Bill Alerts',
            channelDescription: 'Alerts for bills that are past due date',
            defaultColor: Colors.red,
            importance: NotificationImportance.High,
          )
        ],
      );

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      // await scheduleDailyMorningNotification();
      // await scheduleDailyBillReminders();
      // await scheduleOverdueBillNotifications();

    } catch (e, st) {
      debugPrint("Notifications init error: $e\n$st");
    }

    // Device orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    bool showOnboarding = true;

    try {
      final appData = await SQLHelper.getappData();
      if (appData.isNotEmpty) {
        showOnboarding = false;
      }
    } catch (e) {
      debugPrint("Error fetching onboarding status: $e");
    }

    // Finally, run the app

    runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => RecordsProvider()),
            ChangeNotifierProvider(create: (_) => ExpenseCategoryProvider()),
            ChangeNotifierProvider(create: (_) => IncomeCategoryProvider()),
          ],
          child: MyApp(
            showOnboarding: showOnboarding,
            initiallyEnabled: initEnabled,
            initialBackgroundLockLatency: initialBackgroundLockLatency,
          ),
        ),      
    );

  } catch (e, st) {
    debugPrint("Fatal startup error: $e\n$st");
  }
}

class MyApp extends StatelessWidget {

  

  final bool initiallyEnabled;
  final bool showOnboarding;

  @visibleForTesting
  final Duration initialBackgroundLockLatency;

  const MyApp({
    super.key,
    required this.showOnboarding,
    this.initiallyEnabled = false,
    required this.initialBackgroundLockLatency,
  });


  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.black54,
        width: 1,
        style: BorderStyle.solid,
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
      borderRadius: BorderRadius.circular(5),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      title: "FiniZen",
      builder: (context, child) => AppLock(
        builder: (context, arg) => child!,
        lockScreenBuilder: (context) => const LockScreen(
          key: Key('LockScreen'),
        ),
        initiallyEnabled: initiallyEnabled,
        initialBackgroundLockLatency: initialBackgroundLockLatency,
        inactiveBuilder: (context) => Scaffold(
          key: const Key('InactiveScreen'),
          body: Center(
            child: Image.asset('./assets/icon/iconTransparent.png'),
          ),
        ),
      ),
      home: showOnboarding ? OnboardPage() : const Dashboard(),
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(254, 206, 1, 1),
          primary: const Color.fromRGBO(254, 206, 1, 1),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black87,
          selectionColor: Colors.lightBlueAccent.shade100,
          selectionHandleColor: const Color.fromRGBO(254, 206, 1, 1),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: const TextStyle(color: Colors.black87),
          enabledBorder: border,
          focusedBorder: border,
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            overflow: TextOverflow.ellipsis,
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
          bodyMedium: TextStyle(fontSize: 20),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
      ),
    );
  }
}

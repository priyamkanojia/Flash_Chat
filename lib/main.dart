import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/services/local_notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


///Recieve when app in background
Future<void> backgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print(message.data.toString());
  print(message.notification!.title);
  print('app in background');
  LocalNotificationService.display(message);
}
//FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  //await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(notificationChannel);
  runApp(FlashChat());
}

class FlashChat extends StatefulWidget {
  @override
  _FlashChatState createState() => _FlashChatState();
}

class _FlashChatState extends State<FlashChat> {
  @override
  void initState(){
    super.initState();
    LocalNotificationService.initialize(context);
    //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //flutterLocalNotificationsPlugin.initialize(InitializationSettings);
    //FirebaseMessaging.onBack
    ///gives message when user taps and app is in terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message){
      if (message != null){
        print('Notification in terminated state');
        Navigator.pushNamed(context, ChatScreen.id);
      }
    });
    ///work when app in foreground
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification != null){
        print(message.notification!.body);
        print(message.notification!.title);
      }
      LocalNotificationService.display(message);
    });//stream for sending messages
    ///only work when app in background but open and user taps
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.pushNamed(context, ChatScreen.id);
      //print(message.data['route']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id:(context)=>WelcomeScreen(),
        LoginScreen.id:(context)=>LoginScreen(),
        ChatScreen.id: (context)=>ChatScreen(),
        RegistrationScreen.id:(context)=>RegistrationScreen(),
      },
    );
  }
}

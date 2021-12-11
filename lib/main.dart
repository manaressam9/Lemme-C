import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'modules/object_detection/home_screen.dart';

 late List<CameraDescription> cameras;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
    MyApp(List<CameraDescription> cameras) ;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const HomeScreen(),
      home:  ObjDet(cameras),

    );
  }
}

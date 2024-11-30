import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/profile.dart';
import 'package:untitled/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  const MyApp(this.prefs, {super.key});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(prefs: prefs),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.prefs});
  late SharedPreferences prefs;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AvatarCreated',
        onMessageReceived: (JavaScriptMessage message) async {
          await widget.prefs.setString('avatar', message.message);
          final user = userFromPrefs(widget.prefs);
          if (!mounted) return;
          if (user != null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Profile(data: user)));
          }
        },
      )
      ..loadFlutterAsset('assets/iframe.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

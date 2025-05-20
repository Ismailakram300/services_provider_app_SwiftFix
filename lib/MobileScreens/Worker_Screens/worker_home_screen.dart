import 'package:flutter/material.dart';
import 'package:serviceapp/MobileScreens/login.dart';
class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Panel"),
        centerTitle: true,

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginM()),
                );
              },
              child: Image.asset(
                "assets/user.png",
                height: 30,
                width: 50,
              ),
            ),
          ),
        ],

      ),
    );
  }
}

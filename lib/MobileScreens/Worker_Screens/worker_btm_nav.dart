import 'package:flutter/material.dart';
import 'package:serviceapp/MobileScreens/Worker_Screens/accepted_offers.dart';
import 'package:serviceapp/MobileScreens/add_request.dart';
import 'package:serviceapp/MobileScreens/extra.dart';
import 'package:serviceapp/MobileScreens/history.dart';
import 'package:serviceapp/MobileScreens/my_profile.dart';
import 'package:serviceapp/MobileScreens/my_request.dart';
import 'package:serviceapp/MobileScreens/user_home_screen.dart';

import 'Show_request.dart';


class WorkerBottomNavMobile extends StatefulWidget {
  const WorkerBottomNavMobile({super.key});

  @override
  State<WorkerBottomNavMobile> createState() => _WorkerBottomNavMobileState();
}

class _WorkerBottomNavMobileState extends State<WorkerBottomNavMobile> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ShowRequest(),
    const MyHistory(),
    const Acceptedoffer(),
    const MyProfile(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],


      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,


        unselectedItemColor: null,
        backgroundColor: Colors.white,


        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [

          BottomNavigationBarItem( icon: Icon(
            Icons.home,
            color: _selectedIndex == 0 ? Colors.black : Colors.grey,
          ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_shopping_cart,
              color: _selectedIndex == 2 ? Colors.black : Colors.grey,
            ),
            label: 'Accepted Offer',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.supervised_user_circle,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
            ),
            label: 'Profile',
          ),


        ],



      ),    );

  }
}

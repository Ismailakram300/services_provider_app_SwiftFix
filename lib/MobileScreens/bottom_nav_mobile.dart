import 'package:flutter/material.dart';
import 'package:serviceapp/MobileScreens/add_request.dart';
import 'package:serviceapp/MobileScreens/history.dart';
import 'package:serviceapp/MobileScreens/my_profile.dart';
import 'package:serviceapp/MobileScreens/my_request.dart';
import 'package:serviceapp/MobileScreens/user_home_screen.dart';

import 'offers.dart';


class BottomNavMobile extends StatefulWidget {
  const BottomNavMobile({super.key});

  @override
  State<BottomNavMobile> createState() => _BottomNavMobileState();
}

class _BottomNavMobileState extends State<BottomNavMobile> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const MyHistory(),

    const AddWorkRequest(),
    const Offers(),
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
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.request_page,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
            ),
            label: 'My Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.supervised_user_circle,
              color: _selectedIndex == 4 ? Colors.black : Colors.grey,
            ),
            label: 'Profile',
          ),


        ],



      ),    );

  }
}

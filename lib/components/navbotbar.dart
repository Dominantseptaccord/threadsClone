import 'package:flutter/material.dart';

class NavigationBottomBar extends StatefulWidget{
  @override
  State<NavigationBottomBar> createState() => _NavigationBottomBarState();
}

class _NavigationBottomBarState extends State<NavigationBottomBar> {
  int _selectedIndex = 0;
  Widget build(BuildContext context){
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (int index){
        setState(() {
          _selectedIndex = index;
        });
        if(index==0){
          Navigator.pushReplacementNamed(context, '/home');
        }
        else if(index==1){
          Navigator.pushReplacementNamed(context, '/posts');
        }
        else if(index==2){
          Navigator.pushReplacementNamed(context, '/profile');
        }


      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Wall',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_post_office_rounded),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Profile',
        )
      ],
    );
  }
}
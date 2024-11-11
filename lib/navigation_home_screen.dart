import 'package:flutter/material.dart';
import 'package:taxi_reservation/models/User.dart';
import 'package:taxi_reservation/screens/Flight/FlightAdmin/admindashboard.dart';
import 'package:taxi_reservation/screens/Vehicle/Admin/AddDriverScreen.dart';
import 'package:taxi_reservation/screens/Vehicle/Admin/AddVehicleScreen.dart';
import 'package:taxi_reservation/screens/Vehicle/Admin/AllDriversScreen.dart';
import 'package:taxi_reservation/screens/Vehicle/Admin/AllVehiculesScreen.dart';
import 'package:taxi_reservation/screens/Vehicle/OngoingReservations_Screen.dart';
import 'package:taxi_reservation/screens/Vehicle/RideHistory_Screen.dart';

import 'app_theme.dart';
import 'custom_drawer/drawer_user_controller.dart';
import 'custom_drawer/home_drawer.dart';
import 'feedback_screen.dart';
import 'help_screen.dart';
import 'home_screen.dart';
import 'invite_friend_screen.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const MyHomePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if(User.getInstance().role == "client")
      {
        switch (drawerIndex) {
          case DrawerIndex.HOME:
            setState(() {
              screenView = const MyHomePage();
            });
            break;
          case DrawerIndex.OngoingVres:
            setState(() {
              screenView = const OngoingReservationsScreen();
            });
            break;
          case DrawerIndex.RideHistory:
            setState(() {
              screenView = RideHistoryScreen();
            });
            break;
          case DrawerIndex.Help:
            setState(() {
              screenView = HelpScreen();
            });
            break;
          case DrawerIndex.FeedBack:
            setState(() {
              screenView = FeedbackScreen();
            });
            break;
          case DrawerIndex.Invite:
            setState(() {
              screenView = InviteFriend();
            });
            break;
          default:
            break;
        }
      }
      if(User.getInstance().role == "admin")
      {
        switch (drawerIndex) {
          case DrawerIndex.HOME:
            setState(() {
              screenView = const MyHomePage();
            });
            break;
          case DrawerIndex.AddDriver:
            setState(() {
              screenView = const AddDriverScreen();
            });
            break;
          case DrawerIndex.AddVehicle:
            setState(() {
              screenView = AddVehicleScreen();
            });
            break;
          case DrawerIndex.AdminDashboard:
            setState(() {
              screenView = AdminDashboard();
            });
            break;
          case DrawerIndex.AddVehicle:
            setState(() {
              screenView = AddVehicleScreen();
            });
            break;
          case DrawerIndex.AllDrivers:
            setState(() {
              screenView = AllDriversScreen();
            });
            break;
          case DrawerIndex.AllVehicles:
            setState(() {
              screenView = AllVehiculesScreen();
            });
            break;
          case DrawerIndex.FeedBack:
            setState(() {
              screenView = FeedbackScreen();
            });
            break;
          default:
            break;
        }
      }

    }
  }
}

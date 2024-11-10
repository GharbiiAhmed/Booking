import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get title {
    return Intl.message(
      'Flight App',
      name: 'title',
      desc: 'The title of the application',
    );
  }

  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: 'Home button label',
    );
  }

  String get admin {
    return Intl.message(
      'Admin Mode',
      name: 'admin',
      desc: 'Admin mode label',
    );
  }

  String get user {
    return Intl.message(
      'User Mode',
      name: 'user',
      desc: 'User mode label',
    );
  }

  String get flightDetails {
    return Intl.message(
      'Flight Details',
      name: 'flight_details',
      desc: 'Flight details label',
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations());
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

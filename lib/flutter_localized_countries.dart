import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CountryNames {
  static CountryNames? of(BuildContext context) {
    return Localizations.of<CountryNames>(context, CountryNames);
  }

  final String locale;
  final Map<String, String> data;
  CountryNames(this.locale, this.data);

  String? nameOf(String code) => data[code];

  List<MapEntry<String, String>> get sortedByCode {
    return data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  List<MapEntry<String, String>> get sortedByName {
    return data.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  }
}

class CountryNamesLocalizationsDelegate extends LocalizationsDelegate<CountryNames> {
  const CountryNamesLocalizationsDelegate({this.bundle});

  final AssetBundle? bundle;

  Future<List<String>> locales() async {
    return List<String>.from(await _loadJSON('languages.json') as List<dynamic>);
  }

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CountryNames> load(Locale locale) async {
    final name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    final locales = Set<String>.from(await this.locales());

    final availableLocale = Intl.verifiedLocale(
      localeName,
      (locale) => locales.contains(locale),
      onFailure: (_) => 'en'
    );

    if(availableLocale == null) {
      throw Exception('Country names not available for locale: $locale');
    }

    final data = Map<String, String>.from(await _loadJSON('data/$availableLocale.json') as Map<dynamic, dynamic>);
    return CountryNames(availableLocale, data);
  }

  @override
  bool shouldReload(LocalizationsDelegate<CountryNames> old) {
    return false;
  }

  Future<dynamic> _loadJSON(key) {
    Future<dynamic> parser(String data) async => jsonDecode(data);
    final AssetBundle bundle = this.bundle ?? rootBundle;
    
    return bundle.loadStructuredData('packages/flutter_localized_countries/' + key, parser);
  }
}

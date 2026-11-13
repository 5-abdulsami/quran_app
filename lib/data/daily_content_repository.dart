import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/daily/daily_content.dart';
import 'daily_catalogue_codec.dart';

/// The curated Ayah / Hadith of the Day, bundled with the app (built by
/// tool/build_daily_content.dart). Read once, then kept in memory.
class DailyContentRepository {
  DailyContentRepository(this._bundle, {this.assetPath = defaultAssetPath});

  static const defaultAssetPath = 'assets/daily/daily_content.json';

  final AssetBundle _bundle;
  final String assetPath;

  // The asset never changes while the app runs, so it is decoded once.
  late final Future<DailyCatalogue> _catalogue = _load();

  Future<DailyCatalogue> catalogue() => _catalogue;

  Future<DailyCatalogue> _load() async => DailyCatalogueCodec.decode(
    jsonDecode(await _bundle.loadString(assetPath)),
  );
}

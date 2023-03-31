import 'dart:async';

import 'package:event_hive/src/base_repository.dart';
import 'package:event_hive/src/type_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// This automatically initializes hive under Flutter. If you need to start with something else, please see [BaseHiveRepository]
class HiveRepository extends BaseHiveRepository {
  /// [typeAdapters] are the list of adapters that you want Hive to recognize.
  ///
  /// You can use [GenericTypeAdapter] to quickly create types.
  HiveRepository({required super.typeAdapters});

  @override
  Future<LazyBox> openBox(String database) async {
    await initialized;
    return Hive.openLazyBox(database);
  }

  @override
  Future<void> initializeEngine() => Hive.initFlutter();
}

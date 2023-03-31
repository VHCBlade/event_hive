import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_hive/src/type_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:event_db/event_db.dart';

class HiveRepository extends DatabaseRepository {
  late final Future initialized;
  final Iterable<GenericTypeAdapter> typeAdapters;

  /// [typeAdapters] are the list of adapters that you want Hive to recognize.
  ///
  /// You can use [GenericTypeAdapter] to quickly create types.
  HiveRepository({required this.typeAdapters});

  @override
  void initialize(BlocEventChannel channel) async {
    final completer = Completer();
    initialized = completer.future;
    super.initialize(channel);
    await Hive.initFlutter();
    typeAdapters.forEach((element) => element.register());
    completer.complete();
  }

  Future<LazyBox> openBox(String database) async {
    await initialized;
    return Hive.openLazyBox(database);
  }

  @override
  Future<T> saveModel<T extends GenericModel>(String database, T model) async {
    final box = await openBox(database);

    await box.put(model.autoGenId, model);
    return model;
  }

  @override
  Future<bool> deleteModel<T extends GenericModel>(
      String database, T model) async {
    if (model.id == null) {
      return false;
    }

    final box = await openBox(database);
    if (!box.containsKey(model.id)) {
      return false;
    }

    box.delete(model.id);

    return true;
  }

  @override
  Future<T?> findModel<T extends GenericModel>(
      String database, String key) async {
    final box = await openBox(database);
    final result = await box.get(key);
    return result as T?;
  }

  @override
  Future<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
      String database, T Function() supplier) async {
    final newModel = supplier();

    final box = await openBox(database);
    return Future.wait(box.keys
        .where((val) => '$val'.startsWith(newModel.prefixTypeForId("")))
        .map((key) async => (await box.get(key)) as T));
  }

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [];
}

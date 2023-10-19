import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_hive/src/type_adapter.dart';
import 'package:event_db/event_db.dart';
import 'package:hive/hive.dart';

/// This is the super class of [HiveRepository]. This doesn't have the implementation of initializing Hive with Flutter.
///
/// You can extend this
abstract class BaseHiveRepository extends DatabaseRepository {
  late final Future initialized;
  final Iterable<GenericTypeAdapter> typeAdapters;

  /// [typeAdapters] are the list of adapters that you want Hive to recognize.
  ///
  /// You can use [GenericTypeAdapter] to quickly create types.
  BaseHiveRepository({required this.typeAdapters});

  FutureOr<void> initializeEngine();

  @override
  void initialize(BlocEventChannel channel) async {
    final completer = Completer();
    initialized = completer.future;
    super.initialize(channel);
    await initializeEngine();
    typeAdapters.forEach((element) => element.register());
    completer.complete();
  }

  FutureOr<LazyBox> openBox(String database);

  @override
  Future<T> saveModel<T extends BaseModel>(String database, T model) async {
    final box = await openBox(database);

    await box.put(model.autoGenId, model);
    return model;
  }

  @override
  Future<void> saveModels<T extends BaseModel>(
      String database, Iterable<T> models) async {
    final box = await openBox(database);

    final map = {for (var v in models) v.autoGenId: v};
    await box.putAll(map);
  }

  @override
  Future<bool> deleteModel<T extends BaseModel>(
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
  Future<T?> findModel<T extends BaseModel>(String database, String key) async {
    final box = await openBox(database);
    final result = await box.get(key);
    return result as T?;
  }

  @override
  Future<Iterable<T>> findAllModelsOfType<T extends BaseModel>(
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

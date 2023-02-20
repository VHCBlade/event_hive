import 'dart:convert';

import 'package:event_db/event_db.dart';
import 'package:hive/hive.dart';

typedef TypeMapper = int? Function(String);

class GenericTypeAdapter<T extends GenericModel> extends TypeAdapter<T> {
  final T Function() generator;
  late final T instance = generator();
  final TypeMapper? typeMapper;

  /// This allows you to register Hive models without needing to extend
  /// each Model.
  ///
  /// [generator] is a generator of an instance of your model. This is used to
  /// to get the type of your model.
  ///
  /// [typeMapper] is an optional parameter to define how you want your type
  /// to be converted to an id. If not provided, it will use the hashcode of the type
  GenericTypeAdapter(this.generator, [this.typeMapper]);

  void register() {
    Hive.registerAdapter<T>(this);
  }

  @override
  T read(BinaryReader reader) {
    final model = generator();
    final map = reader.read();
    model.loadFromMap(json.decode(json.encode(map)));
    return model;
  }

  @override
  int get typeId {
    if (typeMapper == null) {
      return instance.type.hashCode;
    }

    final typeId = typeMapper!(instance.type);

    if (typeId == null) {
      throw ArgumentError('${instance.type} is not defined!');
    }

    return typeId;
  }

  @override
  void write(BinaryWriter writer, T obj) {
    writer.write(obj.toMap());
  }
}

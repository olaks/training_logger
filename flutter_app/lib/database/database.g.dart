// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, name, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(Insertable<Workout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final String name;
  final String notes;
  const Workout({required this.id, required this.name, required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      notes: Value(notes),
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Workout copyWith({int? id, String? name, String? notes}) => Workout(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
      );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> notes;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? notes}) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ExerciseCategoriesTable extends ExerciseCategories
    with TableInfo<$ExerciseCategoriesTable, ExerciseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageDataMeta =
      const VerificationMeta('imageData');
  @override
  late final GeneratedColumn<Uint8List> imageData = GeneratedColumn<Uint8List>(
      'image_data', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _exerciseTypeMeta =
      const VerificationMeta('exerciseType');
  @override
  late final GeneratedColumn<int> exerciseType = GeneratedColumn<int>(
      'exercise_type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, groupName, imageData, exerciseType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    }
    if (data.containsKey('image_data')) {
      context.handle(_imageDataMeta,
          imageData.isAcceptableOrUnknown(data['image_data']!, _imageDataMeta));
    }
    if (data.containsKey('exercise_type')) {
      context.handle(
          _exerciseTypeMeta,
          exerciseType.isAcceptableOrUnknown(
              data['exercise_type']!, _exerciseTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name']),
      imageData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}image_data']),
      exerciseType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exercise_type'])!,
    );
  }

  @override
  $ExerciseCategoriesTable createAlias(String alias) {
    return $ExerciseCategoriesTable(attachedDatabase, alias);
  }
}

class ExerciseCategory extends DataClass
    implements Insertable<ExerciseCategory> {
  final int id;
  final String name;
  final String? groupName;
  final Uint8List? imageData;
  final int exerciseType;
  const ExerciseCategory(
      {required this.id,
      required this.name,
      this.groupName,
      this.imageData,
      required this.exerciseType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    if (!nullToAbsent || imageData != null) {
      map['image_data'] = Variable<Uint8List>(imageData);
    }
    map['exercise_type'] = Variable<int>(exerciseType);
    return map;
  }

  ExerciseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      imageData: imageData == null && nullToAbsent
          ? const Value.absent()
          : Value(imageData),
      exerciseType: Value(exerciseType),
    );
  }

  factory ExerciseCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      imageData: serializer.fromJson<Uint8List?>(json['imageData']),
      exerciseType: serializer.fromJson<int>(json['exerciseType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'groupName': serializer.toJson<String?>(groupName),
      'imageData': serializer.toJson<Uint8List?>(imageData),
      'exerciseType': serializer.toJson<int>(exerciseType),
    };
  }

  ExerciseCategory copyWith(
          {int? id,
          String? name,
          Value<String?> groupName = const Value.absent(),
          Value<Uint8List?> imageData = const Value.absent(),
          int? exerciseType}) =>
      ExerciseCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        groupName: groupName.present ? groupName.value : this.groupName,
        imageData: imageData.present ? imageData.value : this.imageData,
        exerciseType: exerciseType ?? this.exerciseType,
      );
  ExerciseCategory copyWithCompanion(ExerciseCategoriesCompanion data) {
    return ExerciseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      imageData: data.imageData.present ? data.imageData.value : this.imageData,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('imageData: $imageData, ')
          ..write('exerciseType: $exerciseType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, groupName, $driftBlobEquality.hash(imageData), exerciseType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupName == this.groupName &&
          $driftBlobEquality.equals(other.imageData, this.imageData) &&
          other.exerciseType == this.exerciseType);
}

class ExerciseCategoriesCompanion extends UpdateCompanion<ExerciseCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> groupName;
  final Value<Uint8List?> imageData;
  final Value<int> exerciseType;
  const ExerciseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupName = const Value.absent(),
    this.imageData = const Value.absent(),
    this.exerciseType = const Value.absent(),
  });
  ExerciseCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.groupName = const Value.absent(),
    this.imageData = const Value.absent(),
    this.exerciseType = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ExerciseCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? groupName,
    Expression<Uint8List>? imageData,
    Expression<int>? exerciseType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupName != null) 'group_name': groupName,
      if (imageData != null) 'image_data': imageData,
      if (exerciseType != null) 'exercise_type': exerciseType,
    });
  }

  ExerciseCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? groupName,
      Value<Uint8List?>? imageData,
      Value<int>? exerciseType}) {
    return ExerciseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      imageData: imageData ?? this.imageData,
      exerciseType: exerciseType ?? this.exerciseType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (imageData.present) {
      map['image_data'] = Variable<Uint8List>(imageData.value);
    }
    if (exerciseType.present) {
      map['exercise_type'] = Variable<int>(exerciseType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('imageData: $imageData, ')
          ..write('exerciseType: $exerciseType')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _targetSetsMeta =
      const VerificationMeta('targetSets');
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
      'target_sets', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetRepsMeta =
      const VerificationMeta('targetReps');
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
      'target_reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workoutId, categoryId, targetSets, targetReps, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
          _targetSetsMeta,
          targetSets.isAcceptableOrUnknown(
              data['target_sets']!, _targetSetsMeta));
    }
    if (data.containsKey('target_reps')) {
      context.handle(
          _targetRepsMeta,
          targetReps.isAcceptableOrUnknown(
              data['target_reps']!, _targetRepsMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      targetSets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_sets']),
      targetReps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_reps']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExercise extends DataClass implements Insertable<WorkoutExercise> {
  final int id;
  final int workoutId;
  final int categoryId;
  final int? targetSets;
  final int? targetReps;
  final int sortOrder;
  const WorkoutExercise(
      {required this.id,
      required this.workoutId,
      required this.categoryId,
      this.targetSets,
      this.targetReps,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || targetSets != null) {
      map['target_sets'] = Variable<int>(targetSets);
    }
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      categoryId: Value(categoryId),
      targetSets: targetSets == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSets),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExercise(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      targetSets: serializer.fromJson<int?>(json['targetSets']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int>(workoutId),
      'categoryId': serializer.toJson<int>(categoryId),
      'targetSets': serializer.toJson<int?>(targetSets),
      'targetReps': serializer.toJson<int?>(targetReps),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorkoutExercise copyWith(
          {int? id,
          int? workoutId,
          int? categoryId,
          Value<int?> targetSets = const Value.absent(),
          Value<int?> targetReps = const Value.absent(),
          int? sortOrder}) =>
      WorkoutExercise(
        id: id ?? this.id,
        workoutId: workoutId ?? this.workoutId,
        categoryId: categoryId ?? this.categoryId,
        targetSets: targetSets.present ? targetSets.value : this.targetSets,
        targetReps: targetReps.present ? targetReps.value : this.targetReps,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WorkoutExercise copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExercise(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      targetSets:
          data.targetSets.present ? data.targetSets.value : this.targetSets,
      targetReps:
          data.targetReps.present ? data.targetReps.value : this.targetReps,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercise(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutId, categoryId, targetSets, targetReps, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExercise &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.categoryId == this.categoryId &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps &&
          other.sortOrder == this.sortOrder);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExercise> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<int> categoryId;
  final Value<int?> targetSets;
  final Value<int?> targetReps;
  final Value<int> sortOrder;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required int categoryId,
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : workoutId = Value(workoutId),
        categoryId = Value(categoryId);
  static Insertable<WorkoutExercise> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<int>? categoryId,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (categoryId != null) 'category_id': categoryId,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WorkoutExercisesCompanion copyWith(
      {Value<int>? id,
      Value<int>? workoutId,
      Value<int>? categoryId,
      Value<int?>? targetSets,
      Value<int?>? targetReps,
      Value<int>? sortOrder}) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      categoryId: categoryId ?? this.categoryId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(Insertable<Plan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final int id;
  final String name;
  const Plan({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Plan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Plan copyWith({int? id, String? name}) => Plan(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan && other.id == this.id && other.name == this.name);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<int> id;
  final Value<String> name;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  PlansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Plan> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  PlansCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return PlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PlanWorkoutsTable extends PlanWorkouts
    with TableInfo<$PlanWorkoutsTable, PlanWorkout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plans (id)'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weekdayMeta =
      const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
      'weekday', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, planId, workoutId, dateStr, weekday];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_workouts';
  @override
  VerificationContext validateIntegrity(Insertable<PlanWorkout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    }
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta,
          weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanWorkout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str']),
      weekday: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekday']),
    );
  }

  @override
  $PlanWorkoutsTable createAlias(String alias) {
    return $PlanWorkoutsTable(attachedDatabase, alias);
  }
}

class PlanWorkout extends DataClass implements Insertable<PlanWorkout> {
  final int id;
  final int planId;
  final int workoutId;
  final String? dateStr;
  final int? weekday;
  const PlanWorkout(
      {required this.id,
      required this.planId,
      required this.workoutId,
      this.dateStr,
      this.weekday});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['workout_id'] = Variable<int>(workoutId);
    if (!nullToAbsent || dateStr != null) {
      map['date_str'] = Variable<String>(dateStr);
    }
    if (!nullToAbsent || weekday != null) {
      map['weekday'] = Variable<int>(weekday);
    }
    return map;
  }

  PlanWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return PlanWorkoutsCompanion(
      id: Value(id),
      planId: Value(planId),
      workoutId: Value(workoutId),
      dateStr: dateStr == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStr),
      weekday: weekday == null && nullToAbsent
          ? const Value.absent()
          : Value(weekday),
    );
  }

  factory PlanWorkout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanWorkout(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      dateStr: serializer.fromJson<String?>(json['dateStr']),
      weekday: serializer.fromJson<int?>(json['weekday']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'workoutId': serializer.toJson<int>(workoutId),
      'dateStr': serializer.toJson<String?>(dateStr),
      'weekday': serializer.toJson<int?>(weekday),
    };
  }

  PlanWorkout copyWith(
          {int? id,
          int? planId,
          int? workoutId,
          Value<String?> dateStr = const Value.absent(),
          Value<int?> weekday = const Value.absent()}) =>
      PlanWorkout(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        workoutId: workoutId ?? this.workoutId,
        dateStr: dateStr.present ? dateStr.value : this.dateStr,
        weekday: weekday.present ? weekday.value : this.weekday,
      );
  PlanWorkout copyWithCompanion(PlanWorkoutsCompanion data) {
    return PlanWorkout(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanWorkout(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('workoutId: $workoutId, ')
          ..write('dateStr: $dateStr, ')
          ..write('weekday: $weekday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, workoutId, dateStr, weekday);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanWorkout &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.workoutId == this.workoutId &&
          other.dateStr == this.dateStr &&
          other.weekday == this.weekday);
}

class PlanWorkoutsCompanion extends UpdateCompanion<PlanWorkout> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> workoutId;
  final Value<String?> dateStr;
  final Value<int?> weekday;
  const PlanWorkoutsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.dateStr = const Value.absent(),
    this.weekday = const Value.absent(),
  });
  PlanWorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int workoutId,
    this.dateStr = const Value.absent(),
    this.weekday = const Value.absent(),
  })  : planId = Value(planId),
        workoutId = Value(workoutId);
  static Insertable<PlanWorkout> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? workoutId,
    Expression<String>? dateStr,
    Expression<int>? weekday,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (workoutId != null) 'workout_id': workoutId,
      if (dateStr != null) 'date_str': dateStr,
      if (weekday != null) 'weekday': weekday,
    });
  }

  PlanWorkoutsCompanion copyWith(
      {Value<int>? id,
      Value<int>? planId,
      Value<int>? workoutId,
      Value<String?>? dateStr,
      Value<int?>? weekday}) {
    return PlanWorkoutsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      workoutId: workoutId ?? this.workoutId,
      dateStr: dateStr ?? this.dateStr,
      weekday: weekday ?? this.weekday,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('workoutId: $workoutId, ')
          ..write('dateStr: $dateStr, ')
          ..write('weekday: $weekday')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timeSecsMeta =
      const VerificationMeta('timeSecs');
  @override
  late final GeneratedColumn<int> timeSecs = GeneratedColumn<int>(
      'time_secs', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
      'rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        dateStr,
        timestamp,
        weightKg,
        reps,
        timeSecs,
        rpe,
        grade
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('time_secs')) {
      context.handle(_timeSecsMeta,
          timeSecs.isAcceptableOrUnknown(data['time_secs']!, _timeSecsMeta));
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps']),
      timeSecs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_secs']),
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rpe']),
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade']),
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int categoryId;
  final String dateStr;
  final int timestamp;
  final double? weightKg;
  final int? reps;
  final int? timeSecs;
  final int? rpe;
  final String? grade;
  const WorkoutSet(
      {required this.id,
      required this.categoryId,
      required this.dateStr,
      required this.timestamp,
      this.weightKg,
      this.reps,
      this.timeSecs,
      this.rpe,
      this.grade});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['date_str'] = Variable<String>(dateStr);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || timeSecs != null) {
      map['time_secs'] = Variable<int>(timeSecs);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      dateStr: Value(dateStr),
      timestamp: Value(timestamp),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      timeSecs: timeSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSecs),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      dateStr: serializer.fromJson<String>(json['dateStr']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      timeSecs: serializer.fromJson<int?>(json['timeSecs']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      grade: serializer.fromJson<String?>(json['grade']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'dateStr': serializer.toJson<String>(dateStr),
      'timestamp': serializer.toJson<int>(timestamp),
      'weightKg': serializer.toJson<double?>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'timeSecs': serializer.toJson<int?>(timeSecs),
      'rpe': serializer.toJson<int?>(rpe),
      'grade': serializer.toJson<String?>(grade),
    };
  }

  WorkoutSet copyWith(
          {int? id,
          int? categoryId,
          String? dateStr,
          int? timestamp,
          Value<double?> weightKg = const Value.absent(),
          Value<int?> reps = const Value.absent(),
          Value<int?> timeSecs = const Value.absent(),
          Value<int?> rpe = const Value.absent(),
          Value<String?> grade = const Value.absent()}) =>
      WorkoutSet(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        dateStr: dateStr ?? this.dateStr,
        timestamp: timestamp ?? this.timestamp,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        reps: reps.present ? reps.value : this.reps,
        timeSecs: timeSecs.present ? timeSecs.value : this.timeSecs,
        rpe: rpe.present ? rpe.value : this.rpe,
        grade: grade.present ? grade.value : this.grade,
      );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      timeSecs: data.timeSecs.present ? data.timeSecs.value : this.timeSecs,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      grade: data.grade.present ? data.grade.value : this.grade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateStr: $dateStr, ')
          ..write('timestamp: $timestamp, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('timeSecs: $timeSecs, ')
          ..write('rpe: $rpe, ')
          ..write('grade: $grade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, categoryId, dateStr, timestamp, weightKg, reps, timeSecs, rpe, grade);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.dateStr == this.dateStr &&
          other.timestamp == this.timestamp &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.timeSecs == this.timeSecs &&
          other.rpe == this.rpe &&
          other.grade == this.grade);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> dateStr;
  final Value<int> timestamp;
  final Value<double?> weightKg;
  final Value<int?> reps;
  final Value<int?> timeSecs;
  final Value<int?> rpe;
  final Value<String?> grade;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dateStr = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.timeSecs = const Value.absent(),
    this.rpe = const Value.absent(),
    this.grade = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String dateStr,
    required int timestamp,
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.timeSecs = const Value.absent(),
    this.rpe = const Value.absent(),
    this.grade = const Value.absent(),
  })  : categoryId = Value(categoryId),
        dateStr = Value(dateStr),
        timestamp = Value(timestamp);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? dateStr,
    Expression<int>? timestamp,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? timeSecs,
    Expression<int>? rpe,
    Expression<String>? grade,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (dateStr != null) 'date_str': dateStr,
      if (timestamp != null) 'timestamp': timestamp,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (timeSecs != null) 'time_secs': timeSecs,
      if (rpe != null) 'rpe': rpe,
      if (grade != null) 'grade': grade,
    });
  }

  WorkoutSetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? dateStr,
      Value<int>? timestamp,
      Value<double?>? weightKg,
      Value<int?>? reps,
      Value<int?>? timeSecs,
      Value<int?>? rpe,
      Value<String?>? grade}) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      dateStr: dateStr ?? this.dateStr,
      timestamp: timestamp ?? this.timestamp,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      timeSecs: timeSecs ?? this.timeSecs,
      rpe: rpe ?? this.rpe,
      grade: grade ?? this.grade,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (timeSecs.present) {
      map['time_secs'] = Variable<int>(timeSecs.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateStr: $dateStr, ')
          ..write('timestamp: $timestamp, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('timeSecs: $timeSecs, ')
          ..write('rpe: $rpe, ')
          ..write('grade: $grade')
          ..write(')'))
        .toString();
  }
}

class $DayNotesTable extends DayNotes with TableInfo<$DayNotesTable, DayNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [dateStr, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_notes';
  @override
  VerificationContext validateIntegrity(Insertable<DayNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateStr};
  @override
  DayNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayNote(
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $DayNotesTable createAlias(String alias) {
    return $DayNotesTable(attachedDatabase, alias);
  }
}

class DayNote extends DataClass implements Insertable<DayNote> {
  final String dateStr;
  final String note;
  const DayNote({required this.dateStr, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_str'] = Variable<String>(dateStr);
    map['note'] = Variable<String>(note);
    return map;
  }

  DayNotesCompanion toCompanion(bool nullToAbsent) {
    return DayNotesCompanion(
      dateStr: Value(dateStr),
      note: Value(note),
    );
  }

  factory DayNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayNote(
      dateStr: serializer.fromJson<String>(json['dateStr']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateStr': serializer.toJson<String>(dateStr),
      'note': serializer.toJson<String>(note),
    };
  }

  DayNote copyWith({String? dateStr, String? note}) => DayNote(
        dateStr: dateStr ?? this.dateStr,
        note: note ?? this.note,
      );
  DayNote copyWithCompanion(DayNotesCompanion data) {
    return DayNote(
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayNote(')
          ..write('dateStr: $dateStr, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateStr, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayNote &&
          other.dateStr == this.dateStr &&
          other.note == this.note);
}

class DayNotesCompanion extends UpdateCompanion<DayNote> {
  final Value<String> dateStr;
  final Value<String> note;
  final Value<int> rowid;
  const DayNotesCompanion({
    this.dateStr = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayNotesCompanion.insert({
    required String dateStr,
    required String note,
    this.rowid = const Value.absent(),
  })  : dateStr = Value(dateStr),
        note = Value(note);
  static Insertable<DayNote> custom({
    Expression<String>? dateStr,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateStr != null) 'date_str': dateStr,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayNotesCompanion copyWith(
      {Value<String>? dateStr, Value<String>? note, Value<int>? rowid}) {
    return DayNotesCompanion(
      dateStr: dateStr ?? this.dateStr,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayNotesCompanion(')
          ..write('dateStr: $dateStr, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightsTable extends BodyWeights
    with TableInfo<$BodyWeightsTable, BodyWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
      'kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [dateStr, kg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weights';
  @override
  VerificationContext validateIntegrity(Insertable<BodyWeight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateStr};
  @override
  BodyWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeight(
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      kg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kg'])!,
    );
  }

  @override
  $BodyWeightsTable createAlias(String alias) {
    return $BodyWeightsTable(attachedDatabase, alias);
  }
}

class BodyWeight extends DataClass implements Insertable<BodyWeight> {
  final String dateStr;
  final double kg;
  const BodyWeight({required this.dateStr, required this.kg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_str'] = Variable<String>(dateStr);
    map['kg'] = Variable<double>(kg);
    return map;
  }

  BodyWeightsCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightsCompanion(
      dateStr: Value(dateStr),
      kg: Value(kg),
    );
  }

  factory BodyWeight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeight(
      dateStr: serializer.fromJson<String>(json['dateStr']),
      kg: serializer.fromJson<double>(json['kg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateStr': serializer.toJson<String>(dateStr),
      'kg': serializer.toJson<double>(kg),
    };
  }

  BodyWeight copyWith({String? dateStr, double? kg}) => BodyWeight(
        dateStr: dateStr ?? this.dateStr,
        kg: kg ?? this.kg,
      );
  BodyWeight copyWithCompanion(BodyWeightsCompanion data) {
    return BodyWeight(
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      kg: data.kg.present ? data.kg.value : this.kg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeight(')
          ..write('dateStr: $dateStr, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateStr, kg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeight &&
          other.dateStr == this.dateStr &&
          other.kg == this.kg);
}

class BodyWeightsCompanion extends UpdateCompanion<BodyWeight> {
  final Value<String> dateStr;
  final Value<double> kg;
  final Value<int> rowid;
  const BodyWeightsCompanion({
    this.dateStr = const Value.absent(),
    this.kg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyWeightsCompanion.insert({
    required String dateStr,
    required double kg,
    this.rowid = const Value.absent(),
  })  : dateStr = Value(dateStr),
        kg = Value(kg);
  static Insertable<BodyWeight> custom({
    Expression<String>? dateStr,
    Expression<double>? kg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateStr != null) 'date_str': dateStr,
      if (kg != null) 'kg': kg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyWeightsCompanion copyWith(
      {Value<String>? dateStr, Value<double>? kg, Value<int>? rowid}) {
    return BodyWeightsCompanion(
      dateStr: dateStr ?? this.dateStr,
      kg: kg ?? this.kg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightsCompanion(')
          ..write('dateStr: $dateStr, ')
          ..write('kg: $kg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InspirationsTable extends Inspirations
    with TableInfo<$InspirationsTable, Inspiration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InspirationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
      'added_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, url, notes, categoryId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inspirations';
  @override
  VerificationContext validateIntegrity(Insertable<Inspiration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Inspiration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inspiration(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $InspirationsTable createAlias(String alias) {
    return $InspirationsTable(attachedDatabase, alias);
  }
}

class Inspiration extends DataClass implements Insertable<Inspiration> {
  final int id;
  final String title;
  final String url;
  final String? notes;
  final int? categoryId;
  final int addedAt;
  const Inspiration(
      {required this.id,
      required this.title,
      required this.url,
      this.notes,
      this.categoryId,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  InspirationsCompanion toCompanion(bool nullToAbsent) {
    return InspirationsCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      addedAt: Value(addedAt),
    );
  }

  factory Inspiration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inspiration(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      notes: serializer.fromJson<String?>(json['notes']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'notes': serializer.toJson<String?>(notes),
      'categoryId': serializer.toJson<int?>(categoryId),
      'addedAt': serializer.toJson<int>(addedAt),
    };
  }

  Inspiration copyWith(
          {int? id,
          String? title,
          String? url,
          Value<String?> notes = const Value.absent(),
          Value<int?> categoryId = const Value.absent(),
          int? addedAt}) =>
      Inspiration(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
        notes: notes.present ? notes.value : this.notes,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        addedAt: addedAt ?? this.addedAt,
      );
  Inspiration copyWithCompanion(InspirationsCompanion data) {
    return Inspiration(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      notes: data.notes.present ? data.notes.value : this.notes,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inspiration(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('notes: $notes, ')
          ..write('categoryId: $categoryId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, url, notes, categoryId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inspiration &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.notes == this.notes &&
          other.categoryId == this.categoryId &&
          other.addedAt == this.addedAt);
}

class InspirationsCompanion extends UpdateCompanion<Inspiration> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> notes;
  final Value<int?> categoryId;
  final Value<int> addedAt;
  const InspirationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.notes = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  InspirationsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String url,
    this.notes = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int addedAt,
  })  : title = Value(title),
        url = Value(url),
        addedAt = Value(addedAt);
  static Insertable<Inspiration> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? notes,
    Expression<int>? categoryId,
    Expression<int>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (notes != null) 'notes': notes,
      if (categoryId != null) 'category_id': categoryId,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  InspirationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? url,
      Value<String?>? notes,
      Value<int?>? categoryId,
      Value<int>? addedAt}) {
    return InspirationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InspirationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('notes: $notes, ')
          ..write('categoryId: $categoryId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $ExerciseCategoriesTable exerciseCategories =
      $ExerciseCategoriesTable(this);
  late final $WorkoutExercisesTable workoutExercises =
      $WorkoutExercisesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PlanWorkoutsTable planWorkouts = $PlanWorkoutsTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $DayNotesTable dayNotes = $DayNotesTable(this);
  late final $BodyWeightsTable bodyWeights = $BodyWeightsTable(this);
  late final $InspirationsTable inspirations = $InspirationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        workouts,
        exerciseCategories,
        workoutExercises,
        plans,
        planWorkouts,
        workoutSets,
        dayNotes,
        bodyWeights,
        inspirations
      ];
}

typedef $$WorkoutsTableCreateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> notes,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> notes,
});

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
      _workoutExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutExercises,
              aliasName: $_aliasNameGenerator(
                  db.workouts.id, db.workoutExercises.workoutId));

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager =
        $$WorkoutExercisesTableTableManager($_db, $_db.workoutExercises)
            .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_workoutExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlanWorkoutsTable, List<PlanWorkout>>
      _planWorkoutsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.planWorkouts,
          aliasName:
              $_aliasNameGenerator(db.workouts.id, db.planWorkouts.workoutId));

  $$PlanWorkoutsTableProcessedTableManager get planWorkoutsRefs {
    final manager = $$PlanWorkoutsTableTableManager($_db, $_db.planWorkouts)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planWorkoutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutExercisesRefs(
      Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableFilterComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> planWorkoutsRefs(
      Expression<bool> Function($$PlanWorkoutsTableFilterComposer f) f) {
    final $$PlanWorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> workoutExercisesRefs<T extends Object>(
      Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> planWorkoutsRefs<T extends Object>(
      Expression<T> Function($$PlanWorkoutsTableAnnotationComposer a) f) {
    final $$PlanWorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function(
        {bool workoutExercisesRefs, bool planWorkoutsRefs})> {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> notes = const Value.absent(),
          }) =>
              WorkoutsCompanion(
            id: id,
            name: name,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> notes = const Value.absent(),
          }) =>
              WorkoutsCompanion.insert(
            id: id,
            name: name,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WorkoutsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workoutExercisesRefs = false, planWorkoutsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
                if (planWorkoutsRefs) db.planWorkouts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            WorkoutExercise>(
                        currentTable: table,
                        referencedTable: $$WorkoutsTableReferences
                            ._workoutExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .workoutExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items),
                  if (planWorkoutsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            PlanWorkout>(
                        currentTable: table,
                        referencedTable: $$WorkoutsTableReferences
                            ._planWorkoutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .planWorkoutsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function({bool workoutExercisesRefs, bool planWorkoutsRefs})>;
typedef $$ExerciseCategoriesTableCreateCompanionBuilder
    = ExerciseCategoriesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> groupName,
  Value<Uint8List?> imageData,
  Value<int> exerciseType,
});
typedef $$ExerciseCategoriesTableUpdateCompanionBuilder
    = ExerciseCategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> groupName,
  Value<Uint8List?> imageData,
  Value<int> exerciseType,
});

final class $$ExerciseCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $ExerciseCategoriesTable, ExerciseCategory> {
  $$ExerciseCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
      _workoutExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutExercises,
              aliasName: $_aliasNameGenerator(
                  db.exerciseCategories.id, db.workoutExercises.categoryId));

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager =
        $$WorkoutExercisesTableTableManager($_db, $_db.workoutExercises)
            .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_workoutExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
      _workoutSetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutSets,
              aliasName: $_aliasNameGenerator(
                  db.exerciseCategories.id, db.workoutSets.categoryId));

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InspirationsTable, List<Inspiration>>
      _inspirationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inspirations,
              aliasName: $_aliasNameGenerator(
                  db.exerciseCategories.id, db.inspirations.categoryId));

  $$InspirationsTableProcessedTableManager get inspirationsRefs {
    final manager = $$InspirationsTableTableManager($_db, $_db.inspirations)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_inspirationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExerciseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseCategoriesTable> {
  $$ExerciseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exerciseType => $composableBuilder(
      column: $table.exerciseType, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutExercisesRefs(
      Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableFilterComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(
      Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inspirationsRefs(
      Expression<bool> Function($$InspirationsTableFilterComposer f) f) {
    final $$InspirationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inspirations,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InspirationsTableFilterComposer(
              $db: $db,
              $table: $db.inspirations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExerciseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseCategoriesTable> {
  $$ExerciseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exerciseType => $composableBuilder(
      column: $table.exerciseType,
      builder: (column) => ColumnOrderings(column));
}

class $$ExerciseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseCategoriesTable> {
  $$ExerciseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageData =>
      $composableBuilder(column: $table.imageData, builder: (column) => column);

  GeneratedColumn<int> get exerciseType => $composableBuilder(
      column: $table.exerciseType, builder: (column) => column);

  Expression<T> workoutExercisesRefs<T extends Object>(
      Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(
      Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inspirationsRefs<T extends Object>(
      Expression<T> Function($$InspirationsTableAnnotationComposer a) f) {
    final $$InspirationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inspirations,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InspirationsTableAnnotationComposer(
              $db: $db,
              $table: $db.inspirations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExerciseCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExerciseCategoriesTable,
    ExerciseCategory,
    $$ExerciseCategoriesTableFilterComposer,
    $$ExerciseCategoriesTableOrderingComposer,
    $$ExerciseCategoriesTableAnnotationComposer,
    $$ExerciseCategoriesTableCreateCompanionBuilder,
    $$ExerciseCategoriesTableUpdateCompanionBuilder,
    (ExerciseCategory, $$ExerciseCategoriesTableReferences),
    ExerciseCategory,
    PrefetchHooks Function(
        {bool workoutExercisesRefs,
        bool workoutSetsRefs,
        bool inspirationsRefs})> {
  $$ExerciseCategoriesTableTableManager(
      _$AppDatabase db, $ExerciseCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> groupName = const Value.absent(),
            Value<Uint8List?> imageData = const Value.absent(),
            Value<int> exerciseType = const Value.absent(),
          }) =>
              ExerciseCategoriesCompanion(
            id: id,
            name: name,
            groupName: groupName,
            imageData: imageData,
            exerciseType: exerciseType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> groupName = const Value.absent(),
            Value<Uint8List?> imageData = const Value.absent(),
            Value<int> exerciseType = const Value.absent(),
          }) =>
              ExerciseCategoriesCompanion.insert(
            id: id,
            name: name,
            groupName: groupName,
            imageData: imageData,
            exerciseType: exerciseType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExerciseCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workoutExercisesRefs = false,
              workoutSetsRefs = false,
              inspirationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
                if (workoutSetsRefs) db.workoutSets,
                if (inspirationsRefs) db.inspirations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, WorkoutExercise>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._workoutExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .workoutExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, WorkoutSet>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._workoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .workoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (inspirationsRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, Inspiration>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._inspirationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .inspirationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExerciseCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExerciseCategoriesTable,
    ExerciseCategory,
    $$ExerciseCategoriesTableFilterComposer,
    $$ExerciseCategoriesTableOrderingComposer,
    $$ExerciseCategoriesTableAnnotationComposer,
    $$ExerciseCategoriesTableCreateCompanionBuilder,
    $$ExerciseCategoriesTableUpdateCompanionBuilder,
    (ExerciseCategory, $$ExerciseCategoriesTableReferences),
    ExerciseCategory,
    PrefetchHooks Function(
        {bool workoutExercisesRefs,
        bool workoutSetsRefs,
        bool inspirationsRefs})>;
typedef $$WorkoutExercisesTableCreateCompanionBuilder
    = WorkoutExercisesCompanion Function({
  Value<int> id,
  required int workoutId,
  required int categoryId,
  Value<int?> targetSets,
  Value<int?> targetReps,
  Value<int> sortOrder,
});
typedef $$WorkoutExercisesTableUpdateCompanionBuilder
    = WorkoutExercisesCompanion Function({
  Value<int> id,
  Value<int> workoutId,
  Value<int> categoryId,
  Value<int?> targetSets,
  Value<int?> targetReps,
  Value<int> sortOrder,
});

final class $$WorkoutExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $WorkoutExercisesTable, WorkoutExercise> {
  $$WorkoutExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
          $_aliasNameGenerator(db.workoutExercises.workoutId, db.workouts.id));

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories.createAlias($_aliasNameGenerator(
          db.workoutExercises.categoryId, db.exerciseCategories.id));

  $$ExerciseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$WorkoutExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutExercisesTable,
    WorkoutExercise,
    $$WorkoutExercisesTableFilterComposer,
    $$WorkoutExercisesTableOrderingComposer,
    $$WorkoutExercisesTableAnnotationComposer,
    $$WorkoutExercisesTableCreateCompanionBuilder,
    $$WorkoutExercisesTableUpdateCompanionBuilder,
    (WorkoutExercise, $$WorkoutExercisesTableReferences),
    WorkoutExercise,
    PrefetchHooks Function({bool workoutId, bool categoryId})> {
  $$WorkoutExercisesTableTableManager(
      _$AppDatabase db, $WorkoutExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int?> targetSets = const Value.absent(),
            Value<int?> targetReps = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              WorkoutExercisesCompanion(
            id: id,
            workoutId: workoutId,
            categoryId: categoryId,
            targetSets: targetSets,
            targetReps: targetReps,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workoutId,
            required int categoryId,
            Value<int?> targetSets = const Value.absent(),
            Value<int?> targetReps = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              WorkoutExercisesCompanion.insert(
            id: id,
            workoutId: workoutId,
            categoryId: categoryId,
            targetSets: targetSets,
            targetReps: targetReps,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$WorkoutExercisesTableReferences._workoutIdTable(db),
                    referencedColumn: $$WorkoutExercisesTableReferences
                        ._workoutIdTable(db)
                        .id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$WorkoutExercisesTableReferences._categoryIdTable(db),
                    referencedColumn: $$WorkoutExercisesTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkoutExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutExercisesTable,
    WorkoutExercise,
    $$WorkoutExercisesTableFilterComposer,
    $$WorkoutExercisesTableOrderingComposer,
    $$WorkoutExercisesTableAnnotationComposer,
    $$WorkoutExercisesTableCreateCompanionBuilder,
    $$WorkoutExercisesTableUpdateCompanionBuilder,
    (WorkoutExercise, $$WorkoutExercisesTableReferences),
    WorkoutExercise,
    PrefetchHooks Function({bool workoutId, bool categoryId})>;
typedef $$PlansTableCreateCompanionBuilder = PlansCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$PlansTableUpdateCompanionBuilder = PlansCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlanWorkoutsTable, List<PlanWorkout>>
      _planWorkoutsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.planWorkouts,
          aliasName: $_aliasNameGenerator(db.plans.id, db.planWorkouts.planId));

  $$PlanWorkoutsTableProcessedTableManager get planWorkoutsRefs {
    final manager = $$PlanWorkoutsTableTableManager($_db, $_db.planWorkouts)
        .filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planWorkoutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> planWorkoutsRefs(
      Expression<bool> Function($$PlanWorkoutsTableFilterComposer f) f) {
    final $$PlanWorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> planWorkoutsRefs<T extends Object>(
      Expression<T> Function($$PlanWorkoutsTableAnnotationComposer a) f) {
    final $$PlanWorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlansTable,
    Plan,
    $$PlansTableFilterComposer,
    $$PlansTableOrderingComposer,
    $$PlansTableAnnotationComposer,
    $$PlansTableCreateCompanionBuilder,
    $$PlansTableUpdateCompanionBuilder,
    (Plan, $$PlansTableReferences),
    Plan,
    PrefetchHooks Function({bool planWorkoutsRefs})> {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              PlansCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              PlansCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PlansTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({planWorkoutsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (planWorkoutsRefs) db.planWorkouts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planWorkoutsRefs)
                    await $_getPrefetchedData<Plan, $PlansTable, PlanWorkout>(
                        currentTable: table,
                        referencedTable:
                            $$PlansTableReferences._planWorkoutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlansTableReferences(db, table, p0)
                                .planWorkoutsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlansTable,
    Plan,
    $$PlansTableFilterComposer,
    $$PlansTableOrderingComposer,
    $$PlansTableAnnotationComposer,
    $$PlansTableCreateCompanionBuilder,
    $$PlansTableUpdateCompanionBuilder,
    (Plan, $$PlansTableReferences),
    Plan,
    PrefetchHooks Function({bool planWorkoutsRefs})>;
typedef $$PlanWorkoutsTableCreateCompanionBuilder = PlanWorkoutsCompanion
    Function({
  Value<int> id,
  required int planId,
  required int workoutId,
  Value<String?> dateStr,
  Value<int?> weekday,
});
typedef $$PlanWorkoutsTableUpdateCompanionBuilder = PlanWorkoutsCompanion
    Function({
  Value<int> id,
  Value<int> planId,
  Value<int> workoutId,
  Value<String?> dateStr,
  Value<int?> weekday,
});

final class $$PlanWorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanWorkoutsTable, PlanWorkout> {
  $$PlanWorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) => db.plans
      .createAlias($_aliasNameGenerator(db.planWorkouts.planId, db.plans.id));

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager($_db, $_db.plans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
          $_aliasNameGenerator(db.planWorkouts.workoutId, db.workouts.id));

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlanWorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanWorkoutsTable> {
  $$PlanWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnFilters(column));

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableFilterComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanWorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanWorkoutsTable> {
  $$PlanWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableOrderingComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanWorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanWorkoutsTable> {
  $$PlanWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableAnnotationComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanWorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanWorkoutsTable,
    PlanWorkout,
    $$PlanWorkoutsTableFilterComposer,
    $$PlanWorkoutsTableOrderingComposer,
    $$PlanWorkoutsTableAnnotationComposer,
    $$PlanWorkoutsTableCreateCompanionBuilder,
    $$PlanWorkoutsTableUpdateCompanionBuilder,
    (PlanWorkout, $$PlanWorkoutsTableReferences),
    PlanWorkout,
    PrefetchHooks Function({bool planId, bool workoutId})> {
  $$PlanWorkoutsTableTableManager(_$AppDatabase db, $PlanWorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> planId = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<String?> dateStr = const Value.absent(),
            Value<int?> weekday = const Value.absent(),
          }) =>
              PlanWorkoutsCompanion(
            id: id,
            planId: planId,
            workoutId: workoutId,
            dateStr: dateStr,
            weekday: weekday,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int planId,
            required int workoutId,
            Value<String?> dateStr = const Value.absent(),
            Value<int?> weekday = const Value.absent(),
          }) =>
              PlanWorkoutsCompanion.insert(
            id: id,
            planId: planId,
            workoutId: workoutId,
            dateStr: dateStr,
            weekday: weekday,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlanWorkoutsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({planId = false, workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable:
                        $$PlanWorkoutsTableReferences._planIdTable(db),
                    referencedColumn:
                        $$PlanWorkoutsTableReferences._planIdTable(db).id,
                  ) as T;
                }
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$PlanWorkoutsTableReferences._workoutIdTable(db),
                    referencedColumn:
                        $$PlanWorkoutsTableReferences._workoutIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlanWorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanWorkoutsTable,
    PlanWorkout,
    $$PlanWorkoutsTableFilterComposer,
    $$PlanWorkoutsTableOrderingComposer,
    $$PlanWorkoutsTableAnnotationComposer,
    $$PlanWorkoutsTableCreateCompanionBuilder,
    $$PlanWorkoutsTableUpdateCompanionBuilder,
    (PlanWorkout, $$PlanWorkoutsTableReferences),
    PlanWorkout,
    PrefetchHooks Function({bool planId, bool workoutId})>;
typedef $$WorkoutSetsTableCreateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String dateStr,
  required int timestamp,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> timeSecs,
  Value<int?> rpe,
  Value<String?> grade,
});
typedef $$WorkoutSetsTableUpdateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> dateStr,
  Value<int> timestamp,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> timeSecs,
  Value<int?> rpe,
  Value<String?> grade,
});

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories.createAlias($_aliasNameGenerator(
          db.workoutSets.categoryId, db.exerciseCategories.id));

  $$ExerciseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeSecs => $composableBuilder(
      column: $table.timeSecs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeSecs => $composableBuilder(
      column: $table.timeSecs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get timeSecs =>
      $composableBuilder(column: $table.timeSecs, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$WorkoutSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool categoryId})> {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> dateStr = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> timeSecs = const Value.absent(),
            Value<int?> rpe = const Value.absent(),
            Value<String?> grade = const Value.absent(),
          }) =>
              WorkoutSetsCompanion(
            id: id,
            categoryId: categoryId,
            dateStr: dateStr,
            timestamp: timestamp,
            weightKg: weightKg,
            reps: reps,
            timeSecs: timeSecs,
            rpe: rpe,
            grade: grade,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String dateStr,
            required int timestamp,
            Value<double?> weightKg = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> timeSecs = const Value.absent(),
            Value<int?> rpe = const Value.absent(),
            Value<String?> grade = const Value.absent(),
          }) =>
              WorkoutSetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            dateStr: dateStr,
            timestamp: timestamp,
            weightKg: weightKg,
            reps: reps,
            timeSecs: timeSecs,
            rpe: rpe,
            grade: grade,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$WorkoutSetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$WorkoutSetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkoutSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool categoryId})>;
typedef $$DayNotesTableCreateCompanionBuilder = DayNotesCompanion Function({
  required String dateStr,
  required String note,
  Value<int> rowid,
});
typedef $$DayNotesTableUpdateCompanionBuilder = DayNotesCompanion Function({
  Value<String> dateStr,
  Value<String> note,
  Value<int> rowid,
});

class $$DayNotesTableFilterComposer
    extends Composer<_$AppDatabase, $DayNotesTable> {
  $$DayNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$DayNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayNotesTable> {
  $$DayNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$DayNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayNotesTable> {
  $$DayNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DayNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DayNotesTable,
    DayNote,
    $$DayNotesTableFilterComposer,
    $$DayNotesTableOrderingComposer,
    $$DayNotesTableAnnotationComposer,
    $$DayNotesTableCreateCompanionBuilder,
    $$DayNotesTableUpdateCompanionBuilder,
    (DayNote, BaseReferences<_$AppDatabase, $DayNotesTable, DayNote>),
    DayNote,
    PrefetchHooks Function()> {
  $$DayNotesTableTableManager(_$AppDatabase db, $DayNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dateStr = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DayNotesCompanion(
            dateStr: dateStr,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dateStr,
            required String note,
            Value<int> rowid = const Value.absent(),
          }) =>
              DayNotesCompanion.insert(
            dateStr: dateStr,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DayNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DayNotesTable,
    DayNote,
    $$DayNotesTableFilterComposer,
    $$DayNotesTableOrderingComposer,
    $$DayNotesTableAnnotationComposer,
    $$DayNotesTableCreateCompanionBuilder,
    $$DayNotesTableUpdateCompanionBuilder,
    (DayNote, BaseReferences<_$AppDatabase, $DayNotesTable, DayNote>),
    DayNote,
    PrefetchHooks Function()>;
typedef $$BodyWeightsTableCreateCompanionBuilder = BodyWeightsCompanion
    Function({
  required String dateStr,
  required double kg,
  Value<int> rowid,
});
typedef $$BodyWeightsTableUpdateCompanionBuilder = BodyWeightsCompanion
    Function({
  Value<String> dateStr,
  Value<double> kg,
  Value<int> rowid,
});

class $$BodyWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kg => $composableBuilder(
      column: $table.kg, builder: (column) => ColumnFilters(column));
}

class $$BodyWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kg => $composableBuilder(
      column: $table.kg, builder: (column) => ColumnOrderings(column));
}

class $$BodyWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);
}

class $$BodyWeightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BodyWeightsTable,
    BodyWeight,
    $$BodyWeightsTableFilterComposer,
    $$BodyWeightsTableOrderingComposer,
    $$BodyWeightsTableAnnotationComposer,
    $$BodyWeightsTableCreateCompanionBuilder,
    $$BodyWeightsTableUpdateCompanionBuilder,
    (BodyWeight, BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>),
    BodyWeight,
    PrefetchHooks Function()> {
  $$BodyWeightsTableTableManager(_$AppDatabase db, $BodyWeightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dateStr = const Value.absent(),
            Value<double> kg = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyWeightsCompanion(
            dateStr: dateStr,
            kg: kg,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dateStr,
            required double kg,
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyWeightsCompanion.insert(
            dateStr: dateStr,
            kg: kg,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BodyWeightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BodyWeightsTable,
    BodyWeight,
    $$BodyWeightsTableFilterComposer,
    $$BodyWeightsTableOrderingComposer,
    $$BodyWeightsTableAnnotationComposer,
    $$BodyWeightsTableCreateCompanionBuilder,
    $$BodyWeightsTableUpdateCompanionBuilder,
    (BodyWeight, BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>),
    BodyWeight,
    PrefetchHooks Function()>;
typedef $$InspirationsTableCreateCompanionBuilder = InspirationsCompanion
    Function({
  Value<int> id,
  required String title,
  required String url,
  Value<String?> notes,
  Value<int?> categoryId,
  required int addedAt,
});
typedef $$InspirationsTableUpdateCompanionBuilder = InspirationsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> url,
  Value<String?> notes,
  Value<int?> categoryId,
  Value<int> addedAt,
});

final class $$InspirationsTableReferences
    extends BaseReferences<_$AppDatabase, $InspirationsTable, Inspiration> {
  $$InspirationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories.createAlias($_aliasNameGenerator(
          db.inspirations.categoryId, db.exerciseCategories.id));

  $$ExerciseCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InspirationsTableFilterComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InspirationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InspirationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$InspirationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InspirationsTable,
    Inspiration,
    $$InspirationsTableFilterComposer,
    $$InspirationsTableOrderingComposer,
    $$InspirationsTableAnnotationComposer,
    $$InspirationsTableCreateCompanionBuilder,
    $$InspirationsTableUpdateCompanionBuilder,
    (Inspiration, $$InspirationsTableReferences),
    Inspiration,
    PrefetchHooks Function({bool categoryId})> {
  $$InspirationsTableTableManager(_$AppDatabase db, $InspirationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InspirationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InspirationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InspirationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int> addedAt = const Value.absent(),
          }) =>
              InspirationsCompanion(
            id: id,
            title: title,
            url: url,
            notes: notes,
            categoryId: categoryId,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String url,
            Value<String?> notes = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required int addedAt,
          }) =>
              InspirationsCompanion.insert(
            id: id,
            title: title,
            url: url,
            notes: notes,
            categoryId: categoryId,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InspirationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$InspirationsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$InspirationsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InspirationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InspirationsTable,
    Inspiration,
    $$InspirationsTableFilterComposer,
    $$InspirationsTableOrderingComposer,
    $$InspirationsTableAnnotationComposer,
    $$InspirationsTableCreateCompanionBuilder,
    $$InspirationsTableUpdateCompanionBuilder,
    (Inspiration, $$InspirationsTableReferences),
    Inspiration,
    PrefetchHooks Function({bool categoryId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$ExerciseCategoriesTableTableManager get exerciseCategories =>
      $$ExerciseCategoriesTableTableManager(_db, _db.exerciseCategories);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PlanWorkoutsTableTableManager get planWorkouts =>
      $$PlanWorkoutsTableTableManager(_db, _db.planWorkouts);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$DayNotesTableTableManager get dayNotes =>
      $$DayNotesTableTableManager(_db, _db.dayNotes);
  $$BodyWeightsTableTableManager get bodyWeights =>
      $$BodyWeightsTableTableManager(_db, _db.bodyWeights);
  $$InspirationsTableTableManager get inspirations =>
      $$InspirationsTableTableManager(_db, _db.inspirations);
}

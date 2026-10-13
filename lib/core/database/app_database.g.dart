// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MotorcycleModelsTable extends MotorcycleModels
    with TableInfo<$MotorcycleModelsTable, MotorcycleModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MotorcycleModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<String> generation = GeneratedColumn<String>(
    'generation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearStartMeta = const VerificationMeta(
    'yearStart',
  );
  @override
  late final GeneratedColumn<int> yearStart = GeneratedColumn<int>(
    'year_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearEndMeta = const VerificationMeta(
    'yearEnd',
  );
  @override
  late final GeneratedColumn<int> yearEnd = GeneratedColumn<int>(
    'year_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    brand,
    model,
    variant,
    generation,
    yearStart,
    yearEnd,
    sourceUrl,
    verifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'motorcycle_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<MotorcycleModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('year_start')) {
      context.handle(
        _yearStartMeta,
        yearStart.isAcceptableOrUnknown(data['year_start']!, _yearStartMeta),
      );
    } else if (isInserting) {
      context.missing(_yearStartMeta);
    }
    if (data.containsKey('year_end')) {
      context.handle(
        _yearEndMeta,
        yearEnd.isAcceptableOrUnknown(data['year_end']!, _yearEndMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MotorcycleModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MotorcycleModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generation'],
      ),
      yearStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_start'],
      )!,
      yearEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_end'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
    );
  }

  @override
  $MotorcycleModelsTable createAlias(String alias) {
    return $MotorcycleModelsTable(attachedDatabase, alias);
  }
}

class MotorcycleModel extends DataClass implements Insertable<MotorcycleModel> {
  final int id;
  final String brand;
  final String model;
  final String? variant;
  final String? generation;
  final int yearStart;
  final int? yearEnd;
  final String? sourceUrl;
  final DateTime? verifiedAt;
  const MotorcycleModel({
    required this.id,
    required this.brand,
    required this.model,
    this.variant,
    this.generation,
    required this.yearStart,
    this.yearEnd,
    this.sourceUrl,
    this.verifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    if (!nullToAbsent || generation != null) {
      map['generation'] = Variable<String>(generation);
    }
    map['year_start'] = Variable<int>(yearStart);
    if (!nullToAbsent || yearEnd != null) {
      map['year_end'] = Variable<int>(yearEnd);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    return map;
  }

  MotorcycleModelsCompanion toCompanion(bool nullToAbsent) {
    return MotorcycleModelsCompanion(
      id: Value(id),
      brand: Value(brand),
      model: Value(model),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      generation: generation == null && nullToAbsent
          ? const Value.absent()
          : Value(generation),
      yearStart: Value(yearStart),
      yearEnd: yearEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(yearEnd),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
    );
  }

  factory MotorcycleModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MotorcycleModel(
      id: serializer.fromJson<int>(json['id']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      variant: serializer.fromJson<String?>(json['variant']),
      generation: serializer.fromJson<String?>(json['generation']),
      yearStart: serializer.fromJson<int>(json['yearStart']),
      yearEnd: serializer.fromJson<int?>(json['yearEnd']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'variant': serializer.toJson<String?>(variant),
      'generation': serializer.toJson<String?>(generation),
      'yearStart': serializer.toJson<int>(yearStart),
      'yearEnd': serializer.toJson<int?>(yearEnd),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
    };
  }

  MotorcycleModel copyWith({
    int? id,
    String? brand,
    String? model,
    Value<String?> variant = const Value.absent(),
    Value<String?> generation = const Value.absent(),
    int? yearStart,
    Value<int?> yearEnd = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<DateTime?> verifiedAt = const Value.absent(),
  }) => MotorcycleModel(
    id: id ?? this.id,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    variant: variant.present ? variant.value : this.variant,
    generation: generation.present ? generation.value : this.generation,
    yearStart: yearStart ?? this.yearStart,
    yearEnd: yearEnd.present ? yearEnd.value : this.yearEnd,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
  );
  MotorcycleModel copyWithCompanion(MotorcycleModelsCompanion data) {
    return MotorcycleModel(
      id: data.id.present ? data.id.value : this.id,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      variant: data.variant.present ? data.variant.value : this.variant,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      yearStart: data.yearStart.present ? data.yearStart.value : this.yearStart,
      yearEnd: data.yearEnd.present ? data.yearEnd.value : this.yearEnd,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MotorcycleModel(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('variant: $variant, ')
          ..write('generation: $generation, ')
          ..write('yearStart: $yearStart, ')
          ..write('yearEnd: $yearEnd, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    brand,
    model,
    variant,
    generation,
    yearStart,
    yearEnd,
    sourceUrl,
    verifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MotorcycleModel &&
          other.id == this.id &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.variant == this.variant &&
          other.generation == this.generation &&
          other.yearStart == this.yearStart &&
          other.yearEnd == this.yearEnd &&
          other.sourceUrl == this.sourceUrl &&
          other.verifiedAt == this.verifiedAt);
}

class MotorcycleModelsCompanion extends UpdateCompanion<MotorcycleModel> {
  final Value<int> id;
  final Value<String> brand;
  final Value<String> model;
  final Value<String?> variant;
  final Value<String?> generation;
  final Value<int> yearStart;
  final Value<int?> yearEnd;
  final Value<String?> sourceUrl;
  final Value<DateTime?> verifiedAt;
  const MotorcycleModelsCompanion({
    this.id = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.variant = const Value.absent(),
    this.generation = const Value.absent(),
    this.yearStart = const Value.absent(),
    this.yearEnd = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.verifiedAt = const Value.absent(),
  });
  MotorcycleModelsCompanion.insert({
    this.id = const Value.absent(),
    required String brand,
    required String model,
    this.variant = const Value.absent(),
    this.generation = const Value.absent(),
    required int yearStart,
    this.yearEnd = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.verifiedAt = const Value.absent(),
  }) : brand = Value(brand),
       model = Value(model),
       yearStart = Value(yearStart);
  static Insertable<MotorcycleModel> custom({
    Expression<int>? id,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? variant,
    Expression<String>? generation,
    Expression<int>? yearStart,
    Expression<int>? yearEnd,
    Expression<String>? sourceUrl,
    Expression<DateTime>? verifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (variant != null) 'variant': variant,
      if (generation != null) 'generation': generation,
      if (yearStart != null) 'year_start': yearStart,
      if (yearEnd != null) 'year_end': yearEnd,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (verifiedAt != null) 'verified_at': verifiedAt,
    });
  }

  MotorcycleModelsCompanion copyWith({
    Value<int>? id,
    Value<String>? brand,
    Value<String>? model,
    Value<String?>? variant,
    Value<String?>? generation,
    Value<int>? yearStart,
    Value<int?>? yearEnd,
    Value<String?>? sourceUrl,
    Value<DateTime?>? verifiedAt,
  }) {
    return MotorcycleModelsCompanion(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      generation: generation ?? this.generation,
      yearStart: yearStart ?? this.yearStart,
      yearEnd: yearEnd ?? this.yearEnd,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (generation.present) {
      map['generation'] = Variable<String>(generation.value);
    }
    if (yearStart.present) {
      map['year_start'] = Variable<int>(yearStart.value);
    }
    if (yearEnd.present) {
      map['year_end'] = Variable<int>(yearEnd.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MotorcycleModelsCompanion(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('variant: $variant, ')
          ..write('generation: $generation, ')
          ..write('yearStart: $yearStart, ')
          ..write('yearEnd: $yearEnd, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }
}

class $MotorcyclesTable extends Motorcycles
    with TableInfo<$MotorcyclesTable, Motorcycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MotorcyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycle_models (id)',
    ),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufactureYearMeta = const VerificationMeta(
    'manufactureYear',
  );
  @override
  late final GeneratedColumn<int> manufactureYear = GeneratedColumn<int>(
    'manufacture_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateNumberMeta = const VerificationMeta(
    'plateNumber',
  );
  @override
  late final GeneratedColumn<String> plateNumber = GeneratedColumn<String>(
    'plate_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🏍️'),
  );
  static const VerificationMeta _usageProfileMeta = const VerificationMeta(
    'usageProfile',
  );
  @override
  late final GeneratedColumn<String> usageProfile = GeneratedColumn<String>(
    'usage_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('campuran'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    nickname,
    manufactureYear,
    plateNumber,
    emoji,
    usageProfile,
    createdAt,
    updatedAt,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'motorcycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Motorcycle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('manufacture_year')) {
      context.handle(
        _manufactureYearMeta,
        manufactureYear.isAcceptableOrUnknown(
          data['manufacture_year']!,
          _manufactureYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufactureYearMeta);
    }
    if (data.containsKey('plate_number')) {
      context.handle(
        _plateNumberMeta,
        plateNumber.isAcceptableOrUnknown(
          data['plate_number']!,
          _plateNumberMeta,
        ),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('usage_profile')) {
      context.handle(
        _usageProfileMeta,
        usageProfile.isAcceptableOrUnknown(
          data['usage_profile']!,
          _usageProfileMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Motorcycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Motorcycle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      ),
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      manufactureYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manufacture_year'],
      )!,
      plateNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate_number'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      usageProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_profile'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $MotorcyclesTable createAlias(String alias) {
    return $MotorcyclesTable(attachedDatabase, alias);
  }
}

class Motorcycle extends DataClass implements Insertable<Motorcycle> {
  final int id;
  final int? modelId;
  final String nickname;
  final int manufactureYear;
  final String? plateNumber;
  final String emoji;
  final String usageProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPrimary;
  const Motorcycle({
    required this.id,
    this.modelId,
    required this.nickname,
    required this.manufactureYear,
    this.plateNumber,
    required this.emoji,
    required this.usageProfile,
    required this.createdAt,
    required this.updatedAt,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<int>(modelId);
    }
    map['nickname'] = Variable<String>(nickname);
    map['manufacture_year'] = Variable<int>(manufactureYear);
    if (!nullToAbsent || plateNumber != null) {
      map['plate_number'] = Variable<String>(plateNumber);
    }
    map['emoji'] = Variable<String>(emoji);
    map['usage_profile'] = Variable<String>(usageProfile);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  MotorcyclesCompanion toCompanion(bool nullToAbsent) {
    return MotorcyclesCompanion(
      id: Value(id),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      nickname: Value(nickname),
      manufactureYear: Value(manufactureYear),
      plateNumber: plateNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(plateNumber),
      emoji: Value(emoji),
      usageProfile: Value(usageProfile),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isPrimary: Value(isPrimary),
    );
  }

  factory Motorcycle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Motorcycle(
      id: serializer.fromJson<int>(json['id']),
      modelId: serializer.fromJson<int?>(json['modelId']),
      nickname: serializer.fromJson<String>(json['nickname']),
      manufactureYear: serializer.fromJson<int>(json['manufactureYear']),
      plateNumber: serializer.fromJson<String?>(json['plateNumber']),
      emoji: serializer.fromJson<String>(json['emoji']),
      usageProfile: serializer.fromJson<String>(json['usageProfile']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelId': serializer.toJson<int?>(modelId),
      'nickname': serializer.toJson<String>(nickname),
      'manufactureYear': serializer.toJson<int>(manufactureYear),
      'plateNumber': serializer.toJson<String?>(plateNumber),
      'emoji': serializer.toJson<String>(emoji),
      'usageProfile': serializer.toJson<String>(usageProfile),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  Motorcycle copyWith({
    int? id,
    Value<int?> modelId = const Value.absent(),
    String? nickname,
    int? manufactureYear,
    Value<String?> plateNumber = const Value.absent(),
    String? emoji,
    String? usageProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPrimary,
  }) => Motorcycle(
    id: id ?? this.id,
    modelId: modelId.present ? modelId.value : this.modelId,
    nickname: nickname ?? this.nickname,
    manufactureYear: manufactureYear ?? this.manufactureYear,
    plateNumber: plateNumber.present ? plateNumber.value : this.plateNumber,
    emoji: emoji ?? this.emoji,
    usageProfile: usageProfile ?? this.usageProfile,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  Motorcycle copyWithCompanion(MotorcyclesCompanion data) {
    return Motorcycle(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      manufactureYear: data.manufactureYear.present
          ? data.manufactureYear.value
          : this.manufactureYear,
      plateNumber: data.plateNumber.present
          ? data.plateNumber.value
          : this.plateNumber,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      usageProfile: data.usageProfile.present
          ? data.usageProfile.value
          : this.usageProfile,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Motorcycle(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('nickname: $nickname, ')
          ..write('manufactureYear: $manufactureYear, ')
          ..write('plateNumber: $plateNumber, ')
          ..write('emoji: $emoji, ')
          ..write('usageProfile: $usageProfile, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    nickname,
    manufactureYear,
    plateNumber,
    emoji,
    usageProfile,
    createdAt,
    updatedAt,
    isPrimary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Motorcycle &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.nickname == this.nickname &&
          other.manufactureYear == this.manufactureYear &&
          other.plateNumber == this.plateNumber &&
          other.emoji == this.emoji &&
          other.usageProfile == this.usageProfile &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isPrimary == this.isPrimary);
}

class MotorcyclesCompanion extends UpdateCompanion<Motorcycle> {
  final Value<int> id;
  final Value<int?> modelId;
  final Value<String> nickname;
  final Value<int> manufactureYear;
  final Value<String?> plateNumber;
  final Value<String> emoji;
  final Value<String> usageProfile;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isPrimary;
  const MotorcyclesCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.manufactureYear = const Value.absent(),
    this.plateNumber = const Value.absent(),
    this.emoji = const Value.absent(),
    this.usageProfile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isPrimary = const Value.absent(),
  });
  MotorcyclesCompanion.insert({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    required String nickname,
    required int manufactureYear,
    this.plateNumber = const Value.absent(),
    this.emoji = const Value.absent(),
    this.usageProfile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isPrimary = const Value.absent(),
  }) : nickname = Value(nickname),
       manufactureYear = Value(manufactureYear);
  static Insertable<Motorcycle> custom({
    Expression<int>? id,
    Expression<int>? modelId,
    Expression<String>? nickname,
    Expression<int>? manufactureYear,
    Expression<String>? plateNumber,
    Expression<String>? emoji,
    Expression<String>? usageProfile,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isPrimary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (nickname != null) 'nickname': nickname,
      if (manufactureYear != null) 'manufacture_year': manufactureYear,
      if (plateNumber != null) 'plate_number': plateNumber,
      if (emoji != null) 'emoji': emoji,
      if (usageProfile != null) 'usage_profile': usageProfile,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isPrimary != null) 'is_primary': isPrimary,
    });
  }

  MotorcyclesCompanion copyWith({
    Value<int>? id,
    Value<int?>? modelId,
    Value<String>? nickname,
    Value<int>? manufactureYear,
    Value<String?>? plateNumber,
    Value<String>? emoji,
    Value<String>? usageProfile,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isPrimary,
  }) {
    return MotorcyclesCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      nickname: nickname ?? this.nickname,
      manufactureYear: manufactureYear ?? this.manufactureYear,
      plateNumber: plateNumber ?? this.plateNumber,
      emoji: emoji ?? this.emoji,
      usageProfile: usageProfile ?? this.usageProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (manufactureYear.present) {
      map['manufacture_year'] = Variable<int>(manufactureYear.value);
    }
    if (plateNumber.present) {
      map['plate_number'] = Variable<String>(plateNumber.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (usageProfile.present) {
      map['usage_profile'] = Variable<String>(usageProfile.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MotorcyclesCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('nickname: $nickname, ')
          ..write('manufactureYear: $manufactureYear, ')
          ..write('plateNumber: $plateNumber, ')
          ..write('emoji: $emoji, ')
          ..write('usageProfile: $usageProfile, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }
}

class $OdometerLogsTable extends OdometerLogs
    with TableInfo<$OdometerLogsTable, OdometerLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OdometerLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    odometerKm,
    recordedAt,
    source,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'odometer_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<OdometerLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerKmMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OdometerLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OdometerLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $OdometerLogsTable createAlias(String alias) {
    return $OdometerLogsTable(attachedDatabase, alias);
  }
}

class OdometerLog extends DataClass implements Insertable<OdometerLog> {
  final int id;
  final int motorcycleId;
  final double odometerKm;
  final DateTime recordedAt;
  final String source;
  final String? note;
  const OdometerLog({
    required this.id,
    required this.motorcycleId,
    required this.odometerKm,
    required this.recordedAt,
    required this.source,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    map['odometer_km'] = Variable<double>(odometerKm);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  OdometerLogsCompanion toCompanion(bool nullToAbsent) {
    return OdometerLogsCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      odometerKm: Value(odometerKm),
      recordedAt: Value(recordedAt),
      source: Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory OdometerLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OdometerLog(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      odometerKm: serializer.fromJson<double>(json['odometerKm']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      source: serializer.fromJson<String>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'odometerKm': serializer.toJson<double>(odometerKm),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'source': serializer.toJson<String>(source),
      'note': serializer.toJson<String?>(note),
    };
  }

  OdometerLog copyWith({
    int? id,
    int? motorcycleId,
    double? odometerKm,
    DateTime? recordedAt,
    String? source,
    Value<String?> note = const Value.absent(),
  }) => OdometerLog(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    odometerKm: odometerKm ?? this.odometerKm,
    recordedAt: recordedAt ?? this.recordedAt,
    source: source ?? this.source,
    note: note.present ? note.value : this.note,
  );
  OdometerLog copyWithCompanion(OdometerLogsCompanion data) {
    return OdometerLog(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OdometerLog(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, motorcycleId, odometerKm, recordedAt, source, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OdometerLog &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.odometerKm == this.odometerKm &&
          other.recordedAt == this.recordedAt &&
          other.source == this.source &&
          other.note == this.note);
}

class OdometerLogsCompanion extends UpdateCompanion<OdometerLog> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<double> odometerKm;
  final Value<DateTime> recordedAt;
  final Value<String> source;
  final Value<String?> note;
  const OdometerLogsCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
  });
  OdometerLogsCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    required double odometerKm,
    required DateTime recordedAt,
    this.source = const Value.absent(),
    this.note = const Value.absent(),
  }) : motorcycleId = Value(motorcycleId),
       odometerKm = Value(odometerKm),
       recordedAt = Value(recordedAt);
  static Insertable<OdometerLog> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<double>? odometerKm,
    Expression<DateTime>? recordedAt,
    Expression<String>? source,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
    });
  }

  OdometerLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<double>? odometerKm,
    Value<DateTime>? recordedAt,
    Value<String>? source,
    Value<String?>? note,
  }) {
    return OdometerLogsCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      odometerKm: odometerKm ?? this.odometerKm,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OdometerLogsCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ComponentTypesTable extends ComponentTypes
    with TableInfo<$ComponentTypesTable, ComponentType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComponentTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _safetyCriticalMeta = const VerificationMeta(
    'safetyCritical',
  );
  @override
  late final GeneratedColumn<bool> safetyCritical = GeneratedColumn<bool>(
    'safety_critical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("safety_critical" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appliesToMeta = const VerificationMeta(
    'appliesTo',
  );
  @override
  late final GeneratedColumn<String> appliesTo = GeneratedColumn<String>(
    'applies_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    safetyCritical,
    appliesTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'component_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComponentType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('safety_critical')) {
      context.handle(
        _safetyCriticalMeta,
        safetyCritical.isAcceptableOrUnknown(
          data['safety_critical']!,
          _safetyCriticalMeta,
        ),
      );
    }
    if (data.containsKey('applies_to')) {
      context.handle(
        _appliesToMeta,
        appliesTo.isAcceptableOrUnknown(data['applies_to']!, _appliesToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComponentType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComponentType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      safetyCritical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}safety_critical'],
      )!,
      appliesTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to'],
      ),
    );
  }

  @override
  $ComponentTypesTable createAlias(String alias) {
    return $ComponentTypesTable(attachedDatabase, alias);
  }
}

class ComponentType extends DataClass implements Insertable<ComponentType> {
  final int id;
  final String name;
  final String category;
  final bool safetyCritical;
  final String? appliesTo;
  const ComponentType({
    required this.id,
    required this.name,
    required this.category,
    required this.safetyCritical,
    this.appliesTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['safety_critical'] = Variable<bool>(safetyCritical);
    if (!nullToAbsent || appliesTo != null) {
      map['applies_to'] = Variable<String>(appliesTo);
    }
    return map;
  }

  ComponentTypesCompanion toCompanion(bool nullToAbsent) {
    return ComponentTypesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      safetyCritical: Value(safetyCritical),
      appliesTo: appliesTo == null && nullToAbsent
          ? const Value.absent()
          : Value(appliesTo),
    );
  }

  factory ComponentType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComponentType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      safetyCritical: serializer.fromJson<bool>(json['safetyCritical']),
      appliesTo: serializer.fromJson<String?>(json['appliesTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'safetyCritical': serializer.toJson<bool>(safetyCritical),
      'appliesTo': serializer.toJson<String?>(appliesTo),
    };
  }

  ComponentType copyWith({
    int? id,
    String? name,
    String? category,
    bool? safetyCritical,
    Value<String?> appliesTo = const Value.absent(),
  }) => ComponentType(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    safetyCritical: safetyCritical ?? this.safetyCritical,
    appliesTo: appliesTo.present ? appliesTo.value : this.appliesTo,
  );
  ComponentType copyWithCompanion(ComponentTypesCompanion data) {
    return ComponentType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      safetyCritical: data.safetyCritical.present
          ? data.safetyCritical.value
          : this.safetyCritical,
      appliesTo: data.appliesTo.present ? data.appliesTo.value : this.appliesTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComponentType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('safetyCritical: $safetyCritical, ')
          ..write('appliesTo: $appliesTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, safetyCritical, appliesTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComponentType &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.safetyCritical == this.safetyCritical &&
          other.appliesTo == this.appliesTo);
}

class ComponentTypesCompanion extends UpdateCompanion<ComponentType> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<bool> safetyCritical;
  final Value<String?> appliesTo;
  const ComponentTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.safetyCritical = const Value.absent(),
    this.appliesTo = const Value.absent(),
  });
  ComponentTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    this.safetyCritical = const Value.absent(),
    this.appliesTo = const Value.absent(),
  }) : name = Value(name),
       category = Value(category);
  static Insertable<ComponentType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<bool>? safetyCritical,
    Expression<String>? appliesTo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (safetyCritical != null) 'safety_critical': safetyCritical,
      if (appliesTo != null) 'applies_to': appliesTo,
    });
  }

  ComponentTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<bool>? safetyCritical,
    Value<String?>? appliesTo,
  }) {
    return ComponentTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      safetyCritical: safetyCritical ?? this.safetyCritical,
      appliesTo: appliesTo ?? this.appliesTo,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (safetyCritical.present) {
      map['safety_critical'] = Variable<bool>(safetyCritical.value);
    }
    if (appliesTo.present) {
      map['applies_to'] = Variable<String>(appliesTo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComponentTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('safetyCritical: $safetyCritical, ')
          ..write('appliesTo: $appliesTo')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceRulesTable extends MaintenanceRules
    with TableInfo<$MaintenanceRulesTable, MaintenanceRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycle_models (id)',
    ),
  );
  static const VerificationMeta _componentTypeIdMeta = const VerificationMeta(
    'componentTypeId',
  );
  @override
  late final GeneratedColumn<int> componentTypeId = GeneratedColumn<int>(
    'component_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES component_types (id)',
    ),
  );
  static const VerificationMeta _intervalKmMeta = const VerificationMeta(
    'intervalKm',
  );
  @override
  late final GeneratedColumn<double> intervalKm = GeneratedColumn<double>(
    'interval_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severeUseRuleMeta = const VerificationMeta(
    'severeUseRule',
  );
  @override
  late final GeneratedColumn<String> severeUseRule = GeneratedColumn<String>(
    'severe_use_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<String> ruleVersion = GeneratedColumn<String>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('v1'),
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    componentTypeId,
    intervalKm,
    intervalDays,
    severeUseRule,
    sourceUrl,
    ruleVersion,
    verifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('component_type_id')) {
      context.handle(
        _componentTypeIdMeta,
        componentTypeId.isAcceptableOrUnknown(
          data['component_type_id']!,
          _componentTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentTypeIdMeta);
    }
    if (data.containsKey('interval_km')) {
      context.handle(
        _intervalKmMeta,
        intervalKm.isAcceptableOrUnknown(data['interval_km']!, _intervalKmMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('severe_use_rule')) {
      context.handle(
        _severeUseRuleMeta,
        severeUseRule.isAcceptableOrUnknown(
          data['severe_use_rule']!,
          _severeUseRuleMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      ),
      componentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}component_type_id'],
      )!,
      intervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interval_km'],
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      severeUseRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severe_use_rule'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_version'],
      )!,
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
    );
  }

  @override
  $MaintenanceRulesTable createAlias(String alias) {
    return $MaintenanceRulesTable(attachedDatabase, alias);
  }
}

class MaintenanceRule extends DataClass implements Insertable<MaintenanceRule> {
  final int id;
  final int? modelId;
  final int componentTypeId;
  final double? intervalKm;
  final int? intervalDays;
  final String? severeUseRule;
  final String? sourceUrl;
  final String ruleVersion;
  final DateTime? verifiedAt;
  const MaintenanceRule({
    required this.id,
    this.modelId,
    required this.componentTypeId,
    this.intervalKm,
    this.intervalDays,
    this.severeUseRule,
    this.sourceUrl,
    required this.ruleVersion,
    this.verifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<int>(modelId);
    }
    map['component_type_id'] = Variable<int>(componentTypeId);
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<double>(intervalKm);
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    if (!nullToAbsent || severeUseRule != null) {
      map['severe_use_rule'] = Variable<String>(severeUseRule);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['rule_version'] = Variable<String>(ruleVersion);
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    return map;
  }

  MaintenanceRulesCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceRulesCompanion(
      id: Value(id),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      componentTypeId: Value(componentTypeId),
      intervalKm: intervalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalKm),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      severeUseRule: severeUseRule == null && nullToAbsent
          ? const Value.absent()
          : Value(severeUseRule),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      ruleVersion: Value(ruleVersion),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
    );
  }

  factory MaintenanceRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceRule(
      id: serializer.fromJson<int>(json['id']),
      modelId: serializer.fromJson<int?>(json['modelId']),
      componentTypeId: serializer.fromJson<int>(json['componentTypeId']),
      intervalKm: serializer.fromJson<double?>(json['intervalKm']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      severeUseRule: serializer.fromJson<String?>(json['severeUseRule']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      ruleVersion: serializer.fromJson<String>(json['ruleVersion']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelId': serializer.toJson<int?>(modelId),
      'componentTypeId': serializer.toJson<int>(componentTypeId),
      'intervalKm': serializer.toJson<double?>(intervalKm),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'severeUseRule': serializer.toJson<String?>(severeUseRule),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'ruleVersion': serializer.toJson<String>(ruleVersion),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
    };
  }

  MaintenanceRule copyWith({
    int? id,
    Value<int?> modelId = const Value.absent(),
    int? componentTypeId,
    Value<double?> intervalKm = const Value.absent(),
    Value<int?> intervalDays = const Value.absent(),
    Value<String?> severeUseRule = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    String? ruleVersion,
    Value<DateTime?> verifiedAt = const Value.absent(),
  }) => MaintenanceRule(
    id: id ?? this.id,
    modelId: modelId.present ? modelId.value : this.modelId,
    componentTypeId: componentTypeId ?? this.componentTypeId,
    intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    severeUseRule: severeUseRule.present
        ? severeUseRule.value
        : this.severeUseRule,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
  );
  MaintenanceRule copyWithCompanion(MaintenanceRulesCompanion data) {
    return MaintenanceRule(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      componentTypeId: data.componentTypeId.present
          ? data.componentTypeId.value
          : this.componentTypeId,
      intervalKm: data.intervalKm.present
          ? data.intervalKm.value
          : this.intervalKm,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      severeUseRule: data.severeUseRule.present
          ? data.severeUseRule.value
          : this.severeUseRule,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRule(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('severeUseRule: $severeUseRule, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    componentTypeId,
    intervalKm,
    intervalDays,
    severeUseRule,
    sourceUrl,
    ruleVersion,
    verifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceRule &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.componentTypeId == this.componentTypeId &&
          other.intervalKm == this.intervalKm &&
          other.intervalDays == this.intervalDays &&
          other.severeUseRule == this.severeUseRule &&
          other.sourceUrl == this.sourceUrl &&
          other.ruleVersion == this.ruleVersion &&
          other.verifiedAt == this.verifiedAt);
}

class MaintenanceRulesCompanion extends UpdateCompanion<MaintenanceRule> {
  final Value<int> id;
  final Value<int?> modelId;
  final Value<int> componentTypeId;
  final Value<double?> intervalKm;
  final Value<int?> intervalDays;
  final Value<String?> severeUseRule;
  final Value<String?> sourceUrl;
  final Value<String> ruleVersion;
  final Value<DateTime?> verifiedAt;
  const MaintenanceRulesCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.componentTypeId = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.severeUseRule = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.verifiedAt = const Value.absent(),
  });
  MaintenanceRulesCompanion.insert({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    required int componentTypeId,
    this.intervalKm = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.severeUseRule = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.verifiedAt = const Value.absent(),
  }) : componentTypeId = Value(componentTypeId);
  static Insertable<MaintenanceRule> custom({
    Expression<int>? id,
    Expression<int>? modelId,
    Expression<int>? componentTypeId,
    Expression<double>? intervalKm,
    Expression<int>? intervalDays,
    Expression<String>? severeUseRule,
    Expression<String>? sourceUrl,
    Expression<String>? ruleVersion,
    Expression<DateTime>? verifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (componentTypeId != null) 'component_type_id': componentTypeId,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (severeUseRule != null) 'severe_use_rule': severeUseRule,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (verifiedAt != null) 'verified_at': verifiedAt,
    });
  }

  MaintenanceRulesCompanion copyWith({
    Value<int>? id,
    Value<int?>? modelId,
    Value<int>? componentTypeId,
    Value<double?>? intervalKm,
    Value<int?>? intervalDays,
    Value<String?>? severeUseRule,
    Value<String?>? sourceUrl,
    Value<String>? ruleVersion,
    Value<DateTime?>? verifiedAt,
  }) {
    return MaintenanceRulesCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      componentTypeId: componentTypeId ?? this.componentTypeId,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalDays: intervalDays ?? this.intervalDays,
      severeUseRule: severeUseRule ?? this.severeUseRule,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (componentTypeId.present) {
      map['component_type_id'] = Variable<int>(componentTypeId.value);
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<double>(intervalKm.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (severeUseRule.present) {
      map['severe_use_rule'] = Variable<String>(severeUseRule.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<String>(ruleVersion.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRulesCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('severeUseRule: $severeUseRule, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }
}

class $ComponentStatusesTable extends ComponentStatuses
    with TableInfo<$ComponentStatusesTable, ComponentStatus> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComponentStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _componentTypeIdMeta = const VerificationMeta(
    'componentTypeId',
  );
  @override
  late final GeneratedColumn<int> componentTypeId = GeneratedColumn<int>(
    'component_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES component_types (id)',
    ),
  );
  static const VerificationMeta _estimatedStatusMeta = const VerificationMeta(
    'estimatedStatus',
  );
  @override
  late final GeneratedColumn<String> estimatedStatus = GeneratedColumn<String>(
    'estimated_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calculatedAtMeta = const VerificationMeta(
    'calculatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
    'calculated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<String> ruleVersion = GeneratedColumn<String>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    componentTypeId,
    estimatedStatus,
    score,
    explanation,
    confidence,
    calculatedAt,
    ruleVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'component_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComponentStatus> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('component_type_id')) {
      context.handle(
        _componentTypeIdMeta,
        componentTypeId.isAcceptableOrUnknown(
          data['component_type_id']!,
          _componentTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentTypeIdMeta);
    }
    if (data.containsKey('estimated_status')) {
      context.handle(
        _estimatedStatusMeta,
        estimatedStatus.isAcceptableOrUnknown(
          data['estimated_status']!,
          _estimatedStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedStatusMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
        _calculatedAtMeta,
        calculatedAt.isAcceptableOrUnknown(
          data['calculated_at']!,
          _calculatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComponentStatus map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComponentStatus(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      componentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}component_type_id'],
      )!,
      estimatedStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estimated_status'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      calculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_at'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_version'],
      )!,
    );
  }

  @override
  $ComponentStatusesTable createAlias(String alias) {
    return $ComponentStatusesTable(attachedDatabase, alias);
  }
}

class ComponentStatus extends DataClass implements Insertable<ComponentStatus> {
  final int id;
  final int motorcycleId;
  final int componentTypeId;
  final String estimatedStatus;
  final double? score;
  final String explanation;
  final double? confidence;
  final DateTime calculatedAt;
  final String ruleVersion;
  const ComponentStatus({
    required this.id,
    required this.motorcycleId,
    required this.componentTypeId,
    required this.estimatedStatus,
    this.score,
    required this.explanation,
    this.confidence,
    required this.calculatedAt,
    required this.ruleVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    map['component_type_id'] = Variable<int>(componentTypeId);
    map['estimated_status'] = Variable<String>(estimatedStatus);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    map['explanation'] = Variable<String>(explanation);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    map['rule_version'] = Variable<String>(ruleVersion);
    return map;
  }

  ComponentStatusesCompanion toCompanion(bool nullToAbsent) {
    return ComponentStatusesCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      componentTypeId: Value(componentTypeId),
      estimatedStatus: Value(estimatedStatus),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      explanation: Value(explanation),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      calculatedAt: Value(calculatedAt),
      ruleVersion: Value(ruleVersion),
    );
  }

  factory ComponentStatus.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComponentStatus(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      componentTypeId: serializer.fromJson<int>(json['componentTypeId']),
      estimatedStatus: serializer.fromJson<String>(json['estimatedStatus']),
      score: serializer.fromJson<double?>(json['score']),
      explanation: serializer.fromJson<String>(json['explanation']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
      ruleVersion: serializer.fromJson<String>(json['ruleVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'componentTypeId': serializer.toJson<int>(componentTypeId),
      'estimatedStatus': serializer.toJson<String>(estimatedStatus),
      'score': serializer.toJson<double?>(score),
      'explanation': serializer.toJson<String>(explanation),
      'confidence': serializer.toJson<double?>(confidence),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
      'ruleVersion': serializer.toJson<String>(ruleVersion),
    };
  }

  ComponentStatus copyWith({
    int? id,
    int? motorcycleId,
    int? componentTypeId,
    String? estimatedStatus,
    Value<double?> score = const Value.absent(),
    String? explanation,
    Value<double?> confidence = const Value.absent(),
    DateTime? calculatedAt,
    String? ruleVersion,
  }) => ComponentStatus(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    componentTypeId: componentTypeId ?? this.componentTypeId,
    estimatedStatus: estimatedStatus ?? this.estimatedStatus,
    score: score.present ? score.value : this.score,
    explanation: explanation ?? this.explanation,
    confidence: confidence.present ? confidence.value : this.confidence,
    calculatedAt: calculatedAt ?? this.calculatedAt,
    ruleVersion: ruleVersion ?? this.ruleVersion,
  );
  ComponentStatus copyWithCompanion(ComponentStatusesCompanion data) {
    return ComponentStatus(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      componentTypeId: data.componentTypeId.present
          ? data.componentTypeId.value
          : this.componentTypeId,
      estimatedStatus: data.estimatedStatus.present
          ? data.estimatedStatus.value
          : this.estimatedStatus,
      score: data.score.present ? data.score.value : this.score,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComponentStatus(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('estimatedStatus: $estimatedStatus, ')
          ..write('score: $score, ')
          ..write('explanation: $explanation, ')
          ..write('confidence: $confidence, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('ruleVersion: $ruleVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    motorcycleId,
    componentTypeId,
    estimatedStatus,
    score,
    explanation,
    confidence,
    calculatedAt,
    ruleVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComponentStatus &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.componentTypeId == this.componentTypeId &&
          other.estimatedStatus == this.estimatedStatus &&
          other.score == this.score &&
          other.explanation == this.explanation &&
          other.confidence == this.confidence &&
          other.calculatedAt == this.calculatedAt &&
          other.ruleVersion == this.ruleVersion);
}

class ComponentStatusesCompanion extends UpdateCompanion<ComponentStatus> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<int> componentTypeId;
  final Value<String> estimatedStatus;
  final Value<double?> score;
  final Value<String> explanation;
  final Value<double?> confidence;
  final Value<DateTime> calculatedAt;
  final Value<String> ruleVersion;
  const ComponentStatusesCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.componentTypeId = const Value.absent(),
    this.estimatedStatus = const Value.absent(),
    this.score = const Value.absent(),
    this.explanation = const Value.absent(),
    this.confidence = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.ruleVersion = const Value.absent(),
  });
  ComponentStatusesCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    required int componentTypeId,
    required String estimatedStatus,
    this.score = const Value.absent(),
    required String explanation,
    this.confidence = const Value.absent(),
    required DateTime calculatedAt,
    required String ruleVersion,
  }) : motorcycleId = Value(motorcycleId),
       componentTypeId = Value(componentTypeId),
       estimatedStatus = Value(estimatedStatus),
       explanation = Value(explanation),
       calculatedAt = Value(calculatedAt),
       ruleVersion = Value(ruleVersion);
  static Insertable<ComponentStatus> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<int>? componentTypeId,
    Expression<String>? estimatedStatus,
    Expression<double>? score,
    Expression<String>? explanation,
    Expression<double>? confidence,
    Expression<DateTime>? calculatedAt,
    Expression<String>? ruleVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (componentTypeId != null) 'component_type_id': componentTypeId,
      if (estimatedStatus != null) 'estimated_status': estimatedStatus,
      if (score != null) 'score': score,
      if (explanation != null) 'explanation': explanation,
      if (confidence != null) 'confidence': confidence,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (ruleVersion != null) 'rule_version': ruleVersion,
    });
  }

  ComponentStatusesCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<int>? componentTypeId,
    Value<String>? estimatedStatus,
    Value<double?>? score,
    Value<String>? explanation,
    Value<double?>? confidence,
    Value<DateTime>? calculatedAt,
    Value<String>? ruleVersion,
  }) {
    return ComponentStatusesCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      componentTypeId: componentTypeId ?? this.componentTypeId,
      estimatedStatus: estimatedStatus ?? this.estimatedStatus,
      score: score ?? this.score,
      explanation: explanation ?? this.explanation,
      confidence: confidence ?? this.confidence,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      ruleVersion: ruleVersion ?? this.ruleVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (componentTypeId.present) {
      map['component_type_id'] = Variable<int>(componentTypeId.value);
    }
    if (estimatedStatus.present) {
      map['estimated_status'] = Variable<String>(estimatedStatus.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<String>(ruleVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComponentStatusesCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('estimatedStatus: $estimatedStatus, ')
          ..write('score: $score, ')
          ..write('explanation: $explanation, ')
          ..write('confidence: $confidence, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('ruleVersion: $ruleVersion')
          ..write(')'))
        .toString();
  }
}

class $ServiceRecordsTable extends ServiceRecords
    with TableInfo<$ServiceRecordsTable, ServiceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _servicedAtMeta = const VerificationMeta(
    'servicedAt',
  );
  @override
  late final GeneratedColumn<DateTime> servicedAt = GeneratedColumn<DateTime>(
    'serviced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workshopNameMeta = const VerificationMeta(
    'workshopName',
  );
  @override
  late final GeneratedColumn<String> workshopName = GeneratedColumn<String>(
    'workshop_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<int> totalCost = GeneratedColumn<int>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    servicedAt,
    odometerKm,
    workshopName,
    notes,
    totalCost,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('serviced_at')) {
      context.handle(
        _servicedAtMeta,
        servicedAt.isAcceptableOrUnknown(data['serviced_at']!, _servicedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_servicedAtMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    }
    if (data.containsKey('workshop_name')) {
      context.handle(
        _workshopNameMeta,
        workshopName.isAcceptableOrUnknown(
          data['workshop_name']!,
          _workshopNameMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      servicedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}serviced_at'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      ),
      workshopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workshop_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ServiceRecordsTable createAlias(String alias) {
    return $ServiceRecordsTable(attachedDatabase, alias);
  }
}

class ServiceRecord extends DataClass implements Insertable<ServiceRecord> {
  final int id;
  final int motorcycleId;
  final DateTime servicedAt;
  final double? odometerKm;
  final String? workshopName;
  final String? notes;
  final int totalCost;
  final DateTime createdAt;
  const ServiceRecord({
    required this.id,
    required this.motorcycleId,
    required this.servicedAt,
    this.odometerKm,
    this.workshopName,
    this.notes,
    required this.totalCost,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    map['serviced_at'] = Variable<DateTime>(servicedAt);
    if (!nullToAbsent || odometerKm != null) {
      map['odometer_km'] = Variable<double>(odometerKm);
    }
    if (!nullToAbsent || workshopName != null) {
      map['workshop_name'] = Variable<String>(workshopName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['total_cost'] = Variable<int>(totalCost);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceRecordsCompanion toCompanion(bool nullToAbsent) {
    return ServiceRecordsCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      servicedAt: Value(servicedAt),
      odometerKm: odometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerKm),
      workshopName: workshopName == null && nullToAbsent
          ? const Value.absent()
          : Value(workshopName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      totalCost: Value(totalCost),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceRecord(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      servicedAt: serializer.fromJson<DateTime>(json['servicedAt']),
      odometerKm: serializer.fromJson<double?>(json['odometerKm']),
      workshopName: serializer.fromJson<String?>(json['workshopName']),
      notes: serializer.fromJson<String?>(json['notes']),
      totalCost: serializer.fromJson<int>(json['totalCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'servicedAt': serializer.toJson<DateTime>(servicedAt),
      'odometerKm': serializer.toJson<double?>(odometerKm),
      'workshopName': serializer.toJson<String?>(workshopName),
      'notes': serializer.toJson<String?>(notes),
      'totalCost': serializer.toJson<int>(totalCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceRecord copyWith({
    int? id,
    int? motorcycleId,
    DateTime? servicedAt,
    Value<double?> odometerKm = const Value.absent(),
    Value<String?> workshopName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? totalCost,
    DateTime? createdAt,
  }) => ServiceRecord(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    servicedAt: servicedAt ?? this.servicedAt,
    odometerKm: odometerKm.present ? odometerKm.value : this.odometerKm,
    workshopName: workshopName.present ? workshopName.value : this.workshopName,
    notes: notes.present ? notes.value : this.notes,
    totalCost: totalCost ?? this.totalCost,
    createdAt: createdAt ?? this.createdAt,
  );
  ServiceRecord copyWithCompanion(ServiceRecordsCompanion data) {
    return ServiceRecord(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      servicedAt: data.servicedAt.present
          ? data.servicedAt.value
          : this.servicedAt,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      workshopName: data.workshopName.present
          ? data.workshopName.value
          : this.workshopName,
      notes: data.notes.present ? data.notes.value : this.notes,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRecord(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('servicedAt: $servicedAt, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('workshopName: $workshopName, ')
          ..write('notes: $notes, ')
          ..write('totalCost: $totalCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    motorcycleId,
    servicedAt,
    odometerKm,
    workshopName,
    notes,
    totalCost,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceRecord &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.servicedAt == this.servicedAt &&
          other.odometerKm == this.odometerKm &&
          other.workshopName == this.workshopName &&
          other.notes == this.notes &&
          other.totalCost == this.totalCost &&
          other.createdAt == this.createdAt);
}

class ServiceRecordsCompanion extends UpdateCompanion<ServiceRecord> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<DateTime> servicedAt;
  final Value<double?> odometerKm;
  final Value<String?> workshopName;
  final Value<String?> notes;
  final Value<int> totalCost;
  final Value<DateTime> createdAt;
  const ServiceRecordsCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.servicedAt = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.workshopName = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ServiceRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    required DateTime servicedAt,
    this.odometerKm = const Value.absent(),
    this.workshopName = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : motorcycleId = Value(motorcycleId),
       servicedAt = Value(servicedAt);
  static Insertable<ServiceRecord> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<DateTime>? servicedAt,
    Expression<double>? odometerKm,
    Expression<String>? workshopName,
    Expression<String>? notes,
    Expression<int>? totalCost,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (servicedAt != null) 'serviced_at': servicedAt,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (workshopName != null) 'workshop_name': workshopName,
      if (notes != null) 'notes': notes,
      if (totalCost != null) 'total_cost': totalCost,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ServiceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<DateTime>? servicedAt,
    Value<double?>? odometerKm,
    Value<String?>? workshopName,
    Value<String?>? notes,
    Value<int>? totalCost,
    Value<DateTime>? createdAt,
  }) {
    return ServiceRecordsCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      servicedAt: servicedAt ?? this.servicedAt,
      odometerKm: odometerKm ?? this.odometerKm,
      workshopName: workshopName ?? this.workshopName,
      notes: notes ?? this.notes,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (servicedAt.present) {
      map['serviced_at'] = Variable<DateTime>(servicedAt.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (workshopName.present) {
      map['workshop_name'] = Variable<String>(workshopName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<int>(totalCost.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('servicedAt: $servicedAt, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('workshopName: $workshopName, ')
          ..write('notes: $notes, ')
          ..write('totalCost: $totalCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ServiceItemsTable extends ServiceItems
    with TableInfo<$ServiceItemsTable, ServiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serviceRecordIdMeta = const VerificationMeta(
    'serviceRecordId',
  );
  @override
  late final GeneratedColumn<int> serviceRecordId = GeneratedColumn<int>(
    'service_record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_records (id)',
    ),
  );
  static const VerificationMeta _componentTypeIdMeta = const VerificationMeta(
    'componentTypeId',
  );
  @override
  late final GeneratedColumn<int> componentTypeId = GeneratedColumn<int>(
    'component_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES component_types (id)',
    ),
  );
  static const VerificationMeta _sparepartIdMeta = const VerificationMeta(
    'sparepartId',
  );
  @override
  late final GeneratedColumn<int> sparepartId = GeneratedColumn<int>(
    'sparepart_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partsCostMeta = const VerificationMeta(
    'partsCost',
  );
  @override
  late final GeneratedColumn<int> partsCost = GeneratedColumn<int>(
    'parts_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _laborCostMeta = const VerificationMeta(
    'laborCost',
  );
  @override
  late final GeneratedColumn<int> laborCost = GeneratedColumn<int>(
    'labor_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<int> totalCost = GeneratedColumn<int>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceRecordId,
    componentTypeId,
    sparepartId,
    action,
    partsCost,
    laborCost,
    totalCost,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_record_id')) {
      context.handle(
        _serviceRecordIdMeta,
        serviceRecordId.isAcceptableOrUnknown(
          data['service_record_id']!,
          _serviceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceRecordIdMeta);
    }
    if (data.containsKey('component_type_id')) {
      context.handle(
        _componentTypeIdMeta,
        componentTypeId.isAcceptableOrUnknown(
          data['component_type_id']!,
          _componentTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('sparepart_id')) {
      context.handle(
        _sparepartIdMeta,
        sparepartId.isAcceptableOrUnknown(
          data['sparepart_id']!,
          _sparepartIdMeta,
        ),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('parts_cost')) {
      context.handle(
        _partsCostMeta,
        partsCost.isAcceptableOrUnknown(data['parts_cost']!, _partsCostMeta),
      );
    }
    if (data.containsKey('labor_cost')) {
      context.handle(
        _laborCostMeta,
        laborCost.isAcceptableOrUnknown(data['labor_cost']!, _laborCostMeta),
      );
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serviceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_record_id'],
      )!,
      componentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}component_type_id'],
      ),
      sparepartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sparepart_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      partsCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parts_cost'],
      )!,
      laborCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}labor_cost'],
      )!,
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ServiceItemsTable createAlias(String alias) {
    return $ServiceItemsTable(attachedDatabase, alias);
  }
}

class ServiceItem extends DataClass implements Insertable<ServiceItem> {
  final int id;
  final int serviceRecordId;
  final int? componentTypeId;
  final int? sparepartId;
  final String action;
  final int partsCost;
  final int laborCost;
  final int totalCost;
  final String? notes;
  const ServiceItem({
    required this.id,
    required this.serviceRecordId,
    this.componentTypeId,
    this.sparepartId,
    required this.action,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_record_id'] = Variable<int>(serviceRecordId);
    if (!nullToAbsent || componentTypeId != null) {
      map['component_type_id'] = Variable<int>(componentTypeId);
    }
    if (!nullToAbsent || sparepartId != null) {
      map['sparepart_id'] = Variable<int>(sparepartId);
    }
    map['action'] = Variable<String>(action);
    map['parts_cost'] = Variable<int>(partsCost);
    map['labor_cost'] = Variable<int>(laborCost);
    map['total_cost'] = Variable<int>(totalCost);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ServiceItemsCompanion toCompanion(bool nullToAbsent) {
    return ServiceItemsCompanion(
      id: Value(id),
      serviceRecordId: Value(serviceRecordId),
      componentTypeId: componentTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(componentTypeId),
      sparepartId: sparepartId == null && nullToAbsent
          ? const Value.absent()
          : Value(sparepartId),
      action: Value(action),
      partsCost: Value(partsCost),
      laborCost: Value(laborCost),
      totalCost: Value(totalCost),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ServiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceItem(
      id: serializer.fromJson<int>(json['id']),
      serviceRecordId: serializer.fromJson<int>(json['serviceRecordId']),
      componentTypeId: serializer.fromJson<int?>(json['componentTypeId']),
      sparepartId: serializer.fromJson<int?>(json['sparepartId']),
      action: serializer.fromJson<String>(json['action']),
      partsCost: serializer.fromJson<int>(json['partsCost']),
      laborCost: serializer.fromJson<int>(json['laborCost']),
      totalCost: serializer.fromJson<int>(json['totalCost']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceRecordId': serializer.toJson<int>(serviceRecordId),
      'componentTypeId': serializer.toJson<int?>(componentTypeId),
      'sparepartId': serializer.toJson<int?>(sparepartId),
      'action': serializer.toJson<String>(action),
      'partsCost': serializer.toJson<int>(partsCost),
      'laborCost': serializer.toJson<int>(laborCost),
      'totalCost': serializer.toJson<int>(totalCost),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ServiceItem copyWith({
    int? id,
    int? serviceRecordId,
    Value<int?> componentTypeId = const Value.absent(),
    Value<int?> sparepartId = const Value.absent(),
    String? action,
    int? partsCost,
    int? laborCost,
    int? totalCost,
    Value<String?> notes = const Value.absent(),
  }) => ServiceItem(
    id: id ?? this.id,
    serviceRecordId: serviceRecordId ?? this.serviceRecordId,
    componentTypeId: componentTypeId.present
        ? componentTypeId.value
        : this.componentTypeId,
    sparepartId: sparepartId.present ? sparepartId.value : this.sparepartId,
    action: action ?? this.action,
    partsCost: partsCost ?? this.partsCost,
    laborCost: laborCost ?? this.laborCost,
    totalCost: totalCost ?? this.totalCost,
    notes: notes.present ? notes.value : this.notes,
  );
  ServiceItem copyWithCompanion(ServiceItemsCompanion data) {
    return ServiceItem(
      id: data.id.present ? data.id.value : this.id,
      serviceRecordId: data.serviceRecordId.present
          ? data.serviceRecordId.value
          : this.serviceRecordId,
      componentTypeId: data.componentTypeId.present
          ? data.componentTypeId.value
          : this.componentTypeId,
      sparepartId: data.sparepartId.present
          ? data.sparepartId.value
          : this.sparepartId,
      action: data.action.present ? data.action.value : this.action,
      partsCost: data.partsCost.present ? data.partsCost.value : this.partsCost,
      laborCost: data.laborCost.present ? data.laborCost.value : this.laborCost,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItem(')
          ..write('id: $id, ')
          ..write('serviceRecordId: $serviceRecordId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('sparepartId: $sparepartId, ')
          ..write('action: $action, ')
          ..write('partsCost: $partsCost, ')
          ..write('laborCost: $laborCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serviceRecordId,
    componentTypeId,
    sparepartId,
    action,
    partsCost,
    laborCost,
    totalCost,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceItem &&
          other.id == this.id &&
          other.serviceRecordId == this.serviceRecordId &&
          other.componentTypeId == this.componentTypeId &&
          other.sparepartId == this.sparepartId &&
          other.action == this.action &&
          other.partsCost == this.partsCost &&
          other.laborCost == this.laborCost &&
          other.totalCost == this.totalCost &&
          other.notes == this.notes);
}

class ServiceItemsCompanion extends UpdateCompanion<ServiceItem> {
  final Value<int> id;
  final Value<int> serviceRecordId;
  final Value<int?> componentTypeId;
  final Value<int?> sparepartId;
  final Value<String> action;
  final Value<int> partsCost;
  final Value<int> laborCost;
  final Value<int> totalCost;
  final Value<String?> notes;
  const ServiceItemsCompanion({
    this.id = const Value.absent(),
    this.serviceRecordId = const Value.absent(),
    this.componentTypeId = const Value.absent(),
    this.sparepartId = const Value.absent(),
    this.action = const Value.absent(),
    this.partsCost = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ServiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int serviceRecordId,
    this.componentTypeId = const Value.absent(),
    this.sparepartId = const Value.absent(),
    required String action,
    this.partsCost = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.notes = const Value.absent(),
  }) : serviceRecordId = Value(serviceRecordId),
       action = Value(action);
  static Insertable<ServiceItem> custom({
    Expression<int>? id,
    Expression<int>? serviceRecordId,
    Expression<int>? componentTypeId,
    Expression<int>? sparepartId,
    Expression<String>? action,
    Expression<int>? partsCost,
    Expression<int>? laborCost,
    Expression<int>? totalCost,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceRecordId != null) 'service_record_id': serviceRecordId,
      if (componentTypeId != null) 'component_type_id': componentTypeId,
      if (sparepartId != null) 'sparepart_id': sparepartId,
      if (action != null) 'action': action,
      if (partsCost != null) 'parts_cost': partsCost,
      if (laborCost != null) 'labor_cost': laborCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (notes != null) 'notes': notes,
    });
  }

  ServiceItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? serviceRecordId,
    Value<int?>? componentTypeId,
    Value<int?>? sparepartId,
    Value<String>? action,
    Value<int>? partsCost,
    Value<int>? laborCost,
    Value<int>? totalCost,
    Value<String?>? notes,
  }) {
    return ServiceItemsCompanion(
      id: id ?? this.id,
      serviceRecordId: serviceRecordId ?? this.serviceRecordId,
      componentTypeId: componentTypeId ?? this.componentTypeId,
      sparepartId: sparepartId ?? this.sparepartId,
      action: action ?? this.action,
      partsCost: partsCost ?? this.partsCost,
      laborCost: laborCost ?? this.laborCost,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceRecordId.present) {
      map['service_record_id'] = Variable<int>(serviceRecordId.value);
    }
    if (componentTypeId.present) {
      map['component_type_id'] = Variable<int>(componentTypeId.value);
    }
    if (sparepartId.present) {
      map['sparepart_id'] = Variable<int>(sparepartId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (partsCost.present) {
      map['parts_cost'] = Variable<int>(partsCost.value);
    }
    if (laborCost.present) {
      map['labor_cost'] = Variable<int>(laborCost.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<int>(totalCost.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('serviceRecordId: $serviceRecordId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('sparepartId: $sparepartId, ')
          ..write('action: $action, ')
          ..write('partsCost: $partsCost, ')
          ..write('laborCost: $laborCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SelfInspectionsTable extends SelfInspections
    with TableInfo<$SelfInspectionsTable, SelfInspection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelfInspectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _inspectedAtMeta = const VerificationMeta(
    'inspectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> inspectedAt = GeneratedColumn<DateTime>(
    'inspected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _riskLevelMeta = const VerificationMeta(
    'riskLevel',
  );
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
    'risk_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    inspectedAt,
    notes,
    riskLevel,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'self_inspections';
  @override
  VerificationContext validateIntegrity(
    Insertable<SelfInspection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('inspected_at')) {
      context.handle(
        _inspectedAtMeta,
        inspectedAt.isAcceptableOrUnknown(
          data['inspected_at']!,
          _inspectedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('risk_level')) {
      context.handle(
        _riskLevelMeta,
        riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SelfInspection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelfInspection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      inspectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inspected_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      riskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_level'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SelfInspectionsTable createAlias(String alias) {
    return $SelfInspectionsTable(attachedDatabase, alias);
  }
}

class SelfInspection extends DataClass implements Insertable<SelfInspection> {
  final int id;
  final int motorcycleId;
  final DateTime inspectedAt;
  final String? notes;
  final String? riskLevel;
  final String status;
  const SelfInspection({
    required this.id,
    required this.motorcycleId,
    required this.inspectedAt,
    this.notes,
    this.riskLevel,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    map['inspected_at'] = Variable<DateTime>(inspectedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || riskLevel != null) {
      map['risk_level'] = Variable<String>(riskLevel);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SelfInspectionsCompanion toCompanion(bool nullToAbsent) {
    return SelfInspectionsCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      inspectedAt: Value(inspectedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      riskLevel: riskLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(riskLevel),
      status: Value(status),
    );
  }

  factory SelfInspection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelfInspection(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      inspectedAt: serializer.fromJson<DateTime>(json['inspectedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      riskLevel: serializer.fromJson<String?>(json['riskLevel']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'inspectedAt': serializer.toJson<DateTime>(inspectedAt),
      'notes': serializer.toJson<String?>(notes),
      'riskLevel': serializer.toJson<String?>(riskLevel),
      'status': serializer.toJson<String>(status),
    };
  }

  SelfInspection copyWith({
    int? id,
    int? motorcycleId,
    DateTime? inspectedAt,
    Value<String?> notes = const Value.absent(),
    Value<String?> riskLevel = const Value.absent(),
    String? status,
  }) => SelfInspection(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    inspectedAt: inspectedAt ?? this.inspectedAt,
    notes: notes.present ? notes.value : this.notes,
    riskLevel: riskLevel.present ? riskLevel.value : this.riskLevel,
    status: status ?? this.status,
  );
  SelfInspection copyWithCompanion(SelfInspectionsCompanion data) {
    return SelfInspection(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      inspectedAt: data.inspectedAt.present
          ? data.inspectedAt.value
          : this.inspectedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelfInspection(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('inspectedAt: $inspectedAt, ')
          ..write('notes: $notes, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, motorcycleId, inspectedAt, notes, riskLevel, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelfInspection &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.inspectedAt == this.inspectedAt &&
          other.notes == this.notes &&
          other.riskLevel == this.riskLevel &&
          other.status == this.status);
}

class SelfInspectionsCompanion extends UpdateCompanion<SelfInspection> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<DateTime> inspectedAt;
  final Value<String?> notes;
  final Value<String?> riskLevel;
  final Value<String> status;
  const SelfInspectionsCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.inspectedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.status = const Value.absent(),
  });
  SelfInspectionsCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    this.inspectedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.status = const Value.absent(),
  }) : motorcycleId = Value(motorcycleId);
  static Insertable<SelfInspection> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<DateTime>? inspectedAt,
    Expression<String>? notes,
    Expression<String>? riskLevel,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (inspectedAt != null) 'inspected_at': inspectedAt,
      if (notes != null) 'notes': notes,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (status != null) 'status': status,
    });
  }

  SelfInspectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<DateTime>? inspectedAt,
    Value<String?>? notes,
    Value<String?>? riskLevel,
    Value<String>? status,
  }) {
    return SelfInspectionsCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      inspectedAt: inspectedAt ?? this.inspectedAt,
      notes: notes ?? this.notes,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (inspectedAt.present) {
      map['inspected_at'] = Variable<DateTime>(inspectedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelfInspectionsCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('inspectedAt: $inspectedAt, ')
          ..write('notes: $notes, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $InspectionAnswersTable extends InspectionAnswers
    with TableInfo<$InspectionAnswersTable, InspectionAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InspectionAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _inspectionIdMeta = const VerificationMeta(
    'inspectionId',
  );
  @override
  late final GeneratedColumn<int> inspectionId = GeneratedColumn<int>(
    'inspection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES self_inspections (id)',
    ),
  );
  static const VerificationMeta _questionCodeMeta = const VerificationMeta(
    'questionCode',
  );
  @override
  late final GeneratedColumn<String> questionCode = GeneratedColumn<String>(
    'question_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerTypeMeta = const VerificationMeta(
    'answerType',
  );
  @override
  late final GeneratedColumn<String> answerType = GeneratedColumn<String>(
    'answer_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _riskFlagMeta = const VerificationMeta(
    'riskFlag',
  );
  @override
  late final GeneratedColumn<bool> riskFlag = GeneratedColumn<bool>(
    'risk_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("risk_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inspectionId,
    questionCode,
    answer,
    answerType,
    riskFlag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inspection_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<InspectionAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('inspection_id')) {
      context.handle(
        _inspectionIdMeta,
        inspectionId.isAcceptableOrUnknown(
          data['inspection_id']!,
          _inspectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectionIdMeta);
    }
    if (data.containsKey('question_code')) {
      context.handle(
        _questionCodeMeta,
        questionCode.isAcceptableOrUnknown(
          data['question_code']!,
          _questionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionCodeMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('answer_type')) {
      context.handle(
        _answerTypeMeta,
        answerType.isAcceptableOrUnknown(data['answer_type']!, _answerTypeMeta),
      );
    }
    if (data.containsKey('risk_flag')) {
      context.handle(
        _riskFlagMeta,
        riskFlag.isAcceptableOrUnknown(data['risk_flag']!, _riskFlagMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InspectionAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InspectionAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      inspectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inspection_id'],
      )!,
      questionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_code'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      answerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_type'],
      ),
      riskFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}risk_flag'],
      )!,
    );
  }

  @override
  $InspectionAnswersTable createAlias(String alias) {
    return $InspectionAnswersTable(attachedDatabase, alias);
  }
}

class InspectionAnswer extends DataClass
    implements Insertable<InspectionAnswer> {
  final int id;
  final int inspectionId;
  final String questionCode;
  final String answer;
  final String? answerType;
  final bool riskFlag;
  const InspectionAnswer({
    required this.id,
    required this.inspectionId,
    required this.questionCode,
    required this.answer,
    this.answerType,
    required this.riskFlag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['inspection_id'] = Variable<int>(inspectionId);
    map['question_code'] = Variable<String>(questionCode);
    map['answer'] = Variable<String>(answer);
    if (!nullToAbsent || answerType != null) {
      map['answer_type'] = Variable<String>(answerType);
    }
    map['risk_flag'] = Variable<bool>(riskFlag);
    return map;
  }

  InspectionAnswersCompanion toCompanion(bool nullToAbsent) {
    return InspectionAnswersCompanion(
      id: Value(id),
      inspectionId: Value(inspectionId),
      questionCode: Value(questionCode),
      answer: Value(answer),
      answerType: answerType == null && nullToAbsent
          ? const Value.absent()
          : Value(answerType),
      riskFlag: Value(riskFlag),
    );
  }

  factory InspectionAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InspectionAnswer(
      id: serializer.fromJson<int>(json['id']),
      inspectionId: serializer.fromJson<int>(json['inspectionId']),
      questionCode: serializer.fromJson<String>(json['questionCode']),
      answer: serializer.fromJson<String>(json['answer']),
      answerType: serializer.fromJson<String?>(json['answerType']),
      riskFlag: serializer.fromJson<bool>(json['riskFlag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'inspectionId': serializer.toJson<int>(inspectionId),
      'questionCode': serializer.toJson<String>(questionCode),
      'answer': serializer.toJson<String>(answer),
      'answerType': serializer.toJson<String?>(answerType),
      'riskFlag': serializer.toJson<bool>(riskFlag),
    };
  }

  InspectionAnswer copyWith({
    int? id,
    int? inspectionId,
    String? questionCode,
    String? answer,
    Value<String?> answerType = const Value.absent(),
    bool? riskFlag,
  }) => InspectionAnswer(
    id: id ?? this.id,
    inspectionId: inspectionId ?? this.inspectionId,
    questionCode: questionCode ?? this.questionCode,
    answer: answer ?? this.answer,
    answerType: answerType.present ? answerType.value : this.answerType,
    riskFlag: riskFlag ?? this.riskFlag,
  );
  InspectionAnswer copyWithCompanion(InspectionAnswersCompanion data) {
    return InspectionAnswer(
      id: data.id.present ? data.id.value : this.id,
      inspectionId: data.inspectionId.present
          ? data.inspectionId.value
          : this.inspectionId,
      questionCode: data.questionCode.present
          ? data.questionCode.value
          : this.questionCode,
      answer: data.answer.present ? data.answer.value : this.answer,
      answerType: data.answerType.present
          ? data.answerType.value
          : this.answerType,
      riskFlag: data.riskFlag.present ? data.riskFlag.value : this.riskFlag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InspectionAnswer(')
          ..write('id: $id, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('questionCode: $questionCode, ')
          ..write('answer: $answer, ')
          ..write('answerType: $answerType, ')
          ..write('riskFlag: $riskFlag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, inspectionId, questionCode, answer, answerType, riskFlag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InspectionAnswer &&
          other.id == this.id &&
          other.inspectionId == this.inspectionId &&
          other.questionCode == this.questionCode &&
          other.answer == this.answer &&
          other.answerType == this.answerType &&
          other.riskFlag == this.riskFlag);
}

class InspectionAnswersCompanion extends UpdateCompanion<InspectionAnswer> {
  final Value<int> id;
  final Value<int> inspectionId;
  final Value<String> questionCode;
  final Value<String> answer;
  final Value<String?> answerType;
  final Value<bool> riskFlag;
  const InspectionAnswersCompanion({
    this.id = const Value.absent(),
    this.inspectionId = const Value.absent(),
    this.questionCode = const Value.absent(),
    this.answer = const Value.absent(),
    this.answerType = const Value.absent(),
    this.riskFlag = const Value.absent(),
  });
  InspectionAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int inspectionId,
    required String questionCode,
    required String answer,
    this.answerType = const Value.absent(),
    this.riskFlag = const Value.absent(),
  }) : inspectionId = Value(inspectionId),
       questionCode = Value(questionCode),
       answer = Value(answer);
  static Insertable<InspectionAnswer> custom({
    Expression<int>? id,
    Expression<int>? inspectionId,
    Expression<String>? questionCode,
    Expression<String>? answer,
    Expression<String>? answerType,
    Expression<bool>? riskFlag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inspectionId != null) 'inspection_id': inspectionId,
      if (questionCode != null) 'question_code': questionCode,
      if (answer != null) 'answer': answer,
      if (answerType != null) 'answer_type': answerType,
      if (riskFlag != null) 'risk_flag': riskFlag,
    });
  }

  InspectionAnswersCompanion copyWith({
    Value<int>? id,
    Value<int>? inspectionId,
    Value<String>? questionCode,
    Value<String>? answer,
    Value<String?>? answerType,
    Value<bool>? riskFlag,
  }) {
    return InspectionAnswersCompanion(
      id: id ?? this.id,
      inspectionId: inspectionId ?? this.inspectionId,
      questionCode: questionCode ?? this.questionCode,
      answer: answer ?? this.answer,
      answerType: answerType ?? this.answerType,
      riskFlag: riskFlag ?? this.riskFlag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (inspectionId.present) {
      map['inspection_id'] = Variable<int>(inspectionId.value);
    }
    if (questionCode.present) {
      map['question_code'] = Variable<String>(questionCode.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (answerType.present) {
      map['answer_type'] = Variable<String>(answerType.value);
    }
    if (riskFlag.present) {
      map['risk_flag'] = Variable<bool>(riskFlag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InspectionAnswersCompanion(')
          ..write('id: $id, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('questionCode: $questionCode, ')
          ..write('answer: $answer, ')
          ..write('answerType: $answerType, ')
          ..write('riskFlag: $riskFlag')
          ..write(')'))
        .toString();
  }
}

class $ComplaintsTable extends Complaints
    with TableInfo<$ComplaintsTable, Complaint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _inspectionIdMeta = const VerificationMeta(
    'inspectionId',
  );
  @override
  late final GeneratedColumn<int> inspectionId = GeneratedColumn<int>(
    'inspection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES self_inspections (id)',
    ),
  );
  static const VerificationMeta _resolvedByServiceIdMeta =
      const VerificationMeta('resolvedByServiceId');
  @override
  late final GeneratedColumn<int> resolvedByServiceId = GeneratedColumn<int>(
    'resolved_by_service_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_records (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(' baru'),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    inspectionId,
    resolvedByServiceId,
    title,
    description,
    status,
    openedAt,
    closedAt,
    odometerKm,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaints';
  @override
  VerificationContext validateIntegrity(
    Insertable<Complaint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('inspection_id')) {
      context.handle(
        _inspectionIdMeta,
        inspectionId.isAcceptableOrUnknown(
          data['inspection_id']!,
          _inspectionIdMeta,
        ),
      );
    }
    if (data.containsKey('resolved_by_service_id')) {
      context.handle(
        _resolvedByServiceIdMeta,
        resolvedByServiceId.isAcceptableOrUnknown(
          data['resolved_by_service_id']!,
          _resolvedByServiceIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Complaint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Complaint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      inspectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inspection_id'],
      ),
      resolvedByServiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_by_service_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ComplaintsTable createAlias(String alias) {
    return $ComplaintsTable(attachedDatabase, alias);
  }
}

class Complaint extends DataClass implements Insertable<Complaint> {
  final int id;
  final int motorcycleId;
  final int? inspectionId;
  final int? resolvedByServiceId;
  final String title;
  final String description;
  final String status;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double? odometerKm;
  final DateTime updatedAt;
  const Complaint({
    required this.id,
    required this.motorcycleId,
    this.inspectionId,
    this.resolvedByServiceId,
    required this.title,
    required this.description,
    required this.status,
    required this.openedAt,
    this.closedAt,
    this.odometerKm,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    if (!nullToAbsent || inspectionId != null) {
      map['inspection_id'] = Variable<int>(inspectionId);
    }
    if (!nullToAbsent || resolvedByServiceId != null) {
      map['resolved_by_service_id'] = Variable<int>(resolvedByServiceId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || odometerKm != null) {
      map['odometer_km'] = Variable<double>(odometerKm);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ComplaintsCompanion toCompanion(bool nullToAbsent) {
    return ComplaintsCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      inspectionId: inspectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(inspectionId),
      resolvedByServiceId: resolvedByServiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedByServiceId),
      title: Value(title),
      description: Value(description),
      status: Value(status),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      odometerKm: odometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerKm),
      updatedAt: Value(updatedAt),
    );
  }

  factory Complaint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Complaint(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      inspectionId: serializer.fromJson<int?>(json['inspectionId']),
      resolvedByServiceId: serializer.fromJson<int?>(
        json['resolvedByServiceId'],
      ),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      odometerKm: serializer.fromJson<double?>(json['odometerKm']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'inspectionId': serializer.toJson<int?>(inspectionId),
      'resolvedByServiceId': serializer.toJson<int?>(resolvedByServiceId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'odometerKm': serializer.toJson<double?>(odometerKm),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Complaint copyWith({
    int? id,
    int? motorcycleId,
    Value<int?> inspectionId = const Value.absent(),
    Value<int?> resolvedByServiceId = const Value.absent(),
    String? title,
    String? description,
    String? status,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    Value<double?> odometerKm = const Value.absent(),
    DateTime? updatedAt,
  }) => Complaint(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    inspectionId: inspectionId.present ? inspectionId.value : this.inspectionId,
    resolvedByServiceId: resolvedByServiceId.present
        ? resolvedByServiceId.value
        : this.resolvedByServiceId,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    odometerKm: odometerKm.present ? odometerKm.value : this.odometerKm,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Complaint copyWithCompanion(ComplaintsCompanion data) {
    return Complaint(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      inspectionId: data.inspectionId.present
          ? data.inspectionId.value
          : this.inspectionId,
      resolvedByServiceId: data.resolvedByServiceId.present
          ? data.resolvedByServiceId.value
          : this.resolvedByServiceId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Complaint(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('resolvedByServiceId: $resolvedByServiceId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    motorcycleId,
    inspectionId,
    resolvedByServiceId,
    title,
    description,
    status,
    openedAt,
    closedAt,
    odometerKm,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Complaint &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.inspectionId == this.inspectionId &&
          other.resolvedByServiceId == this.resolvedByServiceId &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.odometerKm == this.odometerKm &&
          other.updatedAt == this.updatedAt);
}

class ComplaintsCompanion extends UpdateCompanion<Complaint> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<int?> inspectionId;
  final Value<int?> resolvedByServiceId;
  final Value<String> title;
  final Value<String> description;
  final Value<String> status;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<double?> odometerKm;
  final Value<DateTime> updatedAt;
  const ComplaintsCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.inspectionId = const Value.absent(),
    this.resolvedByServiceId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ComplaintsCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    this.inspectionId = const Value.absent(),
    this.resolvedByServiceId = const Value.absent(),
    required String title,
    required String description,
    this.status = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : motorcycleId = Value(motorcycleId),
       title = Value(title),
       description = Value(description);
  static Insertable<Complaint> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<int>? inspectionId,
    Expression<int>? resolvedByServiceId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<double>? odometerKm,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (inspectionId != null) 'inspection_id': inspectionId,
      if (resolvedByServiceId != null)
        'resolved_by_service_id': resolvedByServiceId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ComplaintsCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<int?>? inspectionId,
    Value<int?>? resolvedByServiceId,
    Value<String>? title,
    Value<String>? description,
    Value<String>? status,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<double?>? odometerKm,
    Value<DateTime>? updatedAt,
  }) {
    return ComplaintsCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      inspectionId: inspectionId ?? this.inspectionId,
      resolvedByServiceId: resolvedByServiceId ?? this.resolvedByServiceId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      odometerKm: odometerKm ?? this.odometerKm,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (inspectionId.present) {
      map['inspection_id'] = Variable<int>(inspectionId.value);
    }
    if (resolvedByServiceId.present) {
      map['resolved_by_service_id'] = Variable<int>(resolvedByServiceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintsCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('resolvedByServiceId: $resolvedByServiceId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ComplaintMessagesTable extends ComplaintMessages
    with TableInfo<$ComplaintMessagesTable, ComplaintMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _complaintIdMeta = const VerificationMeta(
    'complaintId',
  );
  @override
  late final GeneratedColumn<int> complaintId = GeneratedColumn<int>(
    'complaint_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES complaints (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _analysisModeMeta = const VerificationMeta(
    'analysisMode',
  );
  @override
  late final GeneratedColumn<String> analysisMode = GeneratedColumn<String>(
    'analysis_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    complaintId,
    role,
    content,
    createdAt,
    analysisMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaint_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComplaintMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('complaint_id')) {
      context.handle(
        _complaintIdMeta,
        complaintId.isAcceptableOrUnknown(
          data['complaint_id']!,
          _complaintIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_complaintIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('analysis_mode')) {
      context.handle(
        _analysisModeMeta,
        analysisMode.isAcceptableOrUnknown(
          data['analysis_mode']!,
          _analysisModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComplaintMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComplaintMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      complaintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}complaint_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      analysisMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_mode'],
      ),
    );
  }

  @override
  $ComplaintMessagesTable createAlias(String alias) {
    return $ComplaintMessagesTable(attachedDatabase, alias);
  }
}

class ComplaintMessage extends DataClass
    implements Insertable<ComplaintMessage> {
  final int id;
  final int complaintId;
  final String role;
  final String content;
  final DateTime createdAt;
  final String? analysisMode;
  const ComplaintMessage({
    required this.id,
    required this.complaintId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.analysisMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['complaint_id'] = Variable<int>(complaintId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || analysisMode != null) {
      map['analysis_mode'] = Variable<String>(analysisMode);
    }
    return map;
  }

  ComplaintMessagesCompanion toCompanion(bool nullToAbsent) {
    return ComplaintMessagesCompanion(
      id: Value(id),
      complaintId: Value(complaintId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      analysisMode: analysisMode == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisMode),
    );
  }

  factory ComplaintMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComplaintMessage(
      id: serializer.fromJson<int>(json['id']),
      complaintId: serializer.fromJson<int>(json['complaintId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      analysisMode: serializer.fromJson<String?>(json['analysisMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'complaintId': serializer.toJson<int>(complaintId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'analysisMode': serializer.toJson<String?>(analysisMode),
    };
  }

  ComplaintMessage copyWith({
    int? id,
    int? complaintId,
    String? role,
    String? content,
    DateTime? createdAt,
    Value<String?> analysisMode = const Value.absent(),
  }) => ComplaintMessage(
    id: id ?? this.id,
    complaintId: complaintId ?? this.complaintId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    analysisMode: analysisMode.present ? analysisMode.value : this.analysisMode,
  );
  ComplaintMessage copyWithCompanion(ComplaintMessagesCompanion data) {
    return ComplaintMessage(
      id: data.id.present ? data.id.value : this.id,
      complaintId: data.complaintId.present
          ? data.complaintId.value
          : this.complaintId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      analysisMode: data.analysisMode.present
          ? data.analysisMode.value
          : this.analysisMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintMessage(')
          ..write('id: $id, ')
          ..write('complaintId: $complaintId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('analysisMode: $analysisMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, complaintId, role, content, createdAt, analysisMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComplaintMessage &&
          other.id == this.id &&
          other.complaintId == this.complaintId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.analysisMode == this.analysisMode);
}

class ComplaintMessagesCompanion extends UpdateCompanion<ComplaintMessage> {
  final Value<int> id;
  final Value<int> complaintId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<String?> analysisMode;
  const ComplaintMessagesCompanion({
    this.id = const Value.absent(),
    this.complaintId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.analysisMode = const Value.absent(),
  });
  ComplaintMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int complaintId,
    required String role,
    required String content,
    this.createdAt = const Value.absent(),
    this.analysisMode = const Value.absent(),
  }) : complaintId = Value(complaintId),
       role = Value(role),
       content = Value(content);
  static Insertable<ComplaintMessage> custom({
    Expression<int>? id,
    Expression<int>? complaintId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? analysisMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (complaintId != null) 'complaint_id': complaintId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (analysisMode != null) 'analysis_mode': analysisMode,
    });
  }

  ComplaintMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? complaintId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<String?>? analysisMode,
  }) {
    return ComplaintMessagesCompanion(
      id: id ?? this.id,
      complaintId: complaintId ?? this.complaintId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      analysisMode: analysisMode ?? this.analysisMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (complaintId.present) {
      map['complaint_id'] = Variable<int>(complaintId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (analysisMode.present) {
      map['analysis_mode'] = Variable<String>(analysisMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintMessagesCompanion(')
          ..write('id: $id, ')
          ..write('complaintId: $complaintId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('analysisMode: $analysisMode')
          ..write(')'))
        .toString();
  }
}

class $ComplaintAnalysesTable extends ComplaintAnalyses
    with TableInfo<$ComplaintAnalysesTable, ComplaintAnalysis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintAnalysesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _complaintIdMeta = const VerificationMeta(
    'complaintId',
  );
  @override
  late final GeneratedColumn<int> complaintId = GeneratedColumn<int>(
    'complaint_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES complaints (id)',
    ),
  );
  static const VerificationMeta _symptomsJsonMeta = const VerificationMeta(
    'symptomsJson',
  );
  @override
  late final GeneratedColumn<String> symptomsJson = GeneratedColumn<String>(
    'symptoms_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _componentCandidatesJsonMeta =
      const VerificationMeta('componentCandidatesJson');
  @override
  late final GeneratedColumn<String> componentCandidatesJson =
      GeneratedColumn<String>(
        'component_candidates_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _followUpJsonMeta = const VerificationMeta(
    'followUpJson',
  );
  @override
  late final GeneratedColumn<String> followUpJson = GeneratedColumn<String>(
    'follow_up_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _historicalMatchesJsonMeta =
      const VerificationMeta('historicalMatchesJson');
  @override
  late final GeneratedColumn<String> historicalMatchesJson =
      GeneratedColumn<String>(
        'historical_matches_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _riskLevelMeta = const VerificationMeta(
    'riskLevel',
  );
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
    'risk_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _analysisModeMeta = const VerificationMeta(
    'analysisMode',
  );
  @override
  late final GeneratedColumn<String> analysisMode = GeneratedColumn<String>(
    'analysis_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
    'analyzed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    complaintId,
    symptomsJson,
    componentCandidatesJson,
    followUpJson,
    historicalMatchesJson,
    riskLevel,
    summary,
    modelVersion,
    analysisMode,
    analyzedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaint_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComplaintAnalysis> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('complaint_id')) {
      context.handle(
        _complaintIdMeta,
        complaintId.isAcceptableOrUnknown(
          data['complaint_id']!,
          _complaintIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_complaintIdMeta);
    }
    if (data.containsKey('symptoms_json')) {
      context.handle(
        _symptomsJsonMeta,
        symptomsJson.isAcceptableOrUnknown(
          data['symptoms_json']!,
          _symptomsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_symptomsJsonMeta);
    }
    if (data.containsKey('component_candidates_json')) {
      context.handle(
        _componentCandidatesJsonMeta,
        componentCandidatesJson.isAcceptableOrUnknown(
          data['component_candidates_json']!,
          _componentCandidatesJsonMeta,
        ),
      );
    }
    if (data.containsKey('follow_up_json')) {
      context.handle(
        _followUpJsonMeta,
        followUpJson.isAcceptableOrUnknown(
          data['follow_up_json']!,
          _followUpJsonMeta,
        ),
      );
    }
    if (data.containsKey('historical_matches_json')) {
      context.handle(
        _historicalMatchesJsonMeta,
        historicalMatchesJson.isAcceptableOrUnknown(
          data['historical_matches_json']!,
          _historicalMatchesJsonMeta,
        ),
      );
    }
    if (data.containsKey('risk_level')) {
      context.handle(
        _riskLevelMeta,
        riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_riskLevelMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    if (data.containsKey('analysis_mode')) {
      context.handle(
        _analysisModeMeta,
        analysisMode.isAcceptableOrUnknown(
          data['analysis_mode']!,
          _analysisModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analysisModeMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComplaintAnalysis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComplaintAnalysis(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      complaintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}complaint_id'],
      )!,
      symptomsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms_json'],
      )!,
      componentCandidatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_candidates_json'],
      ),
      followUpJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}follow_up_json'],
      ),
      historicalMatchesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}historical_matches_json'],
      ),
      riskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_level'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
      analysisMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_mode'],
      )!,
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at'],
      )!,
    );
  }

  @override
  $ComplaintAnalysesTable createAlias(String alias) {
    return $ComplaintAnalysesTable(attachedDatabase, alias);
  }
}

class ComplaintAnalysis extends DataClass
    implements Insertable<ComplaintAnalysis> {
  final int id;
  final int complaintId;
  final String symptomsJson;
  final String? componentCandidatesJson;
  final String? followUpJson;
  final String? historicalMatchesJson;
  final String riskLevel;
  final String summary;
  final String? modelVersion;
  final String analysisMode;
  final DateTime analyzedAt;
  const ComplaintAnalysis({
    required this.id,
    required this.complaintId,
    required this.symptomsJson,
    this.componentCandidatesJson,
    this.followUpJson,
    this.historicalMatchesJson,
    required this.riskLevel,
    required this.summary,
    this.modelVersion,
    required this.analysisMode,
    required this.analyzedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['complaint_id'] = Variable<int>(complaintId);
    map['symptoms_json'] = Variable<String>(symptomsJson);
    if (!nullToAbsent || componentCandidatesJson != null) {
      map['component_candidates_json'] = Variable<String>(
        componentCandidatesJson,
      );
    }
    if (!nullToAbsent || followUpJson != null) {
      map['follow_up_json'] = Variable<String>(followUpJson);
    }
    if (!nullToAbsent || historicalMatchesJson != null) {
      map['historical_matches_json'] = Variable<String>(historicalMatchesJson);
    }
    map['risk_level'] = Variable<String>(riskLevel);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    map['analysis_mode'] = Variable<String>(analysisMode);
    map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    return map;
  }

  ComplaintAnalysesCompanion toCompanion(bool nullToAbsent) {
    return ComplaintAnalysesCompanion(
      id: Value(id),
      complaintId: Value(complaintId),
      symptomsJson: Value(symptomsJson),
      componentCandidatesJson: componentCandidatesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(componentCandidatesJson),
      followUpJson: followUpJson == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpJson),
      historicalMatchesJson: historicalMatchesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(historicalMatchesJson),
      riskLevel: Value(riskLevel),
      summary: Value(summary),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      analysisMode: Value(analysisMode),
      analyzedAt: Value(analyzedAt),
    );
  }

  factory ComplaintAnalysis.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComplaintAnalysis(
      id: serializer.fromJson<int>(json['id']),
      complaintId: serializer.fromJson<int>(json['complaintId']),
      symptomsJson: serializer.fromJson<String>(json['symptomsJson']),
      componentCandidatesJson: serializer.fromJson<String?>(
        json['componentCandidatesJson'],
      ),
      followUpJson: serializer.fromJson<String?>(json['followUpJson']),
      historicalMatchesJson: serializer.fromJson<String?>(
        json['historicalMatchesJson'],
      ),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      summary: serializer.fromJson<String>(json['summary']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      analysisMode: serializer.fromJson<String>(json['analysisMode']),
      analyzedAt: serializer.fromJson<DateTime>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'complaintId': serializer.toJson<int>(complaintId),
      'symptomsJson': serializer.toJson<String>(symptomsJson),
      'componentCandidatesJson': serializer.toJson<String?>(
        componentCandidatesJson,
      ),
      'followUpJson': serializer.toJson<String?>(followUpJson),
      'historicalMatchesJson': serializer.toJson<String?>(
        historicalMatchesJson,
      ),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'summary': serializer.toJson<String>(summary),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'analysisMode': serializer.toJson<String>(analysisMode),
      'analyzedAt': serializer.toJson<DateTime>(analyzedAt),
    };
  }

  ComplaintAnalysis copyWith({
    int? id,
    int? complaintId,
    String? symptomsJson,
    Value<String?> componentCandidatesJson = const Value.absent(),
    Value<String?> followUpJson = const Value.absent(),
    Value<String?> historicalMatchesJson = const Value.absent(),
    String? riskLevel,
    String? summary,
    Value<String?> modelVersion = const Value.absent(),
    String? analysisMode,
    DateTime? analyzedAt,
  }) => ComplaintAnalysis(
    id: id ?? this.id,
    complaintId: complaintId ?? this.complaintId,
    symptomsJson: symptomsJson ?? this.symptomsJson,
    componentCandidatesJson: componentCandidatesJson.present
        ? componentCandidatesJson.value
        : this.componentCandidatesJson,
    followUpJson: followUpJson.present ? followUpJson.value : this.followUpJson,
    historicalMatchesJson: historicalMatchesJson.present
        ? historicalMatchesJson.value
        : this.historicalMatchesJson,
    riskLevel: riskLevel ?? this.riskLevel,
    summary: summary ?? this.summary,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
    analysisMode: analysisMode ?? this.analysisMode,
    analyzedAt: analyzedAt ?? this.analyzedAt,
  );
  ComplaintAnalysis copyWithCompanion(ComplaintAnalysesCompanion data) {
    return ComplaintAnalysis(
      id: data.id.present ? data.id.value : this.id,
      complaintId: data.complaintId.present
          ? data.complaintId.value
          : this.complaintId,
      symptomsJson: data.symptomsJson.present
          ? data.symptomsJson.value
          : this.symptomsJson,
      componentCandidatesJson: data.componentCandidatesJson.present
          ? data.componentCandidatesJson.value
          : this.componentCandidatesJson,
      followUpJson: data.followUpJson.present
          ? data.followUpJson.value
          : this.followUpJson,
      historicalMatchesJson: data.historicalMatchesJson.present
          ? data.historicalMatchesJson.value
          : this.historicalMatchesJson,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      summary: data.summary.present ? data.summary.value : this.summary,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      analysisMode: data.analysisMode.present
          ? data.analysisMode.value
          : this.analysisMode,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintAnalysis(')
          ..write('id: $id, ')
          ..write('complaintId: $complaintId, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('componentCandidatesJson: $componentCandidatesJson, ')
          ..write('followUpJson: $followUpJson, ')
          ..write('historicalMatchesJson: $historicalMatchesJson, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('summary: $summary, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('analysisMode: $analysisMode, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    complaintId,
    symptomsJson,
    componentCandidatesJson,
    followUpJson,
    historicalMatchesJson,
    riskLevel,
    summary,
    modelVersion,
    analysisMode,
    analyzedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComplaintAnalysis &&
          other.id == this.id &&
          other.complaintId == this.complaintId &&
          other.symptomsJson == this.symptomsJson &&
          other.componentCandidatesJson == this.componentCandidatesJson &&
          other.followUpJson == this.followUpJson &&
          other.historicalMatchesJson == this.historicalMatchesJson &&
          other.riskLevel == this.riskLevel &&
          other.summary == this.summary &&
          other.modelVersion == this.modelVersion &&
          other.analysisMode == this.analysisMode &&
          other.analyzedAt == this.analyzedAt);
}

class ComplaintAnalysesCompanion extends UpdateCompanion<ComplaintAnalysis> {
  final Value<int> id;
  final Value<int> complaintId;
  final Value<String> symptomsJson;
  final Value<String?> componentCandidatesJson;
  final Value<String?> followUpJson;
  final Value<String?> historicalMatchesJson;
  final Value<String> riskLevel;
  final Value<String> summary;
  final Value<String?> modelVersion;
  final Value<String> analysisMode;
  final Value<DateTime> analyzedAt;
  const ComplaintAnalysesCompanion({
    this.id = const Value.absent(),
    this.complaintId = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.componentCandidatesJson = const Value.absent(),
    this.followUpJson = const Value.absent(),
    this.historicalMatchesJson = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.summary = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.analysisMode = const Value.absent(),
    this.analyzedAt = const Value.absent(),
  });
  ComplaintAnalysesCompanion.insert({
    this.id = const Value.absent(),
    required int complaintId,
    required String symptomsJson,
    this.componentCandidatesJson = const Value.absent(),
    this.followUpJson = const Value.absent(),
    this.historicalMatchesJson = const Value.absent(),
    required String riskLevel,
    required String summary,
    this.modelVersion = const Value.absent(),
    required String analysisMode,
    this.analyzedAt = const Value.absent(),
  }) : complaintId = Value(complaintId),
       symptomsJson = Value(symptomsJson),
       riskLevel = Value(riskLevel),
       summary = Value(summary),
       analysisMode = Value(analysisMode);
  static Insertable<ComplaintAnalysis> custom({
    Expression<int>? id,
    Expression<int>? complaintId,
    Expression<String>? symptomsJson,
    Expression<String>? componentCandidatesJson,
    Expression<String>? followUpJson,
    Expression<String>? historicalMatchesJson,
    Expression<String>? riskLevel,
    Expression<String>? summary,
    Expression<String>? modelVersion,
    Expression<String>? analysisMode,
    Expression<DateTime>? analyzedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (complaintId != null) 'complaint_id': complaintId,
      if (symptomsJson != null) 'symptoms_json': symptomsJson,
      if (componentCandidatesJson != null)
        'component_candidates_json': componentCandidatesJson,
      if (followUpJson != null) 'follow_up_json': followUpJson,
      if (historicalMatchesJson != null)
        'historical_matches_json': historicalMatchesJson,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (summary != null) 'summary': summary,
      if (modelVersion != null) 'model_version': modelVersion,
      if (analysisMode != null) 'analysis_mode': analysisMode,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
    });
  }

  ComplaintAnalysesCompanion copyWith({
    Value<int>? id,
    Value<int>? complaintId,
    Value<String>? symptomsJson,
    Value<String?>? componentCandidatesJson,
    Value<String?>? followUpJson,
    Value<String?>? historicalMatchesJson,
    Value<String>? riskLevel,
    Value<String>? summary,
    Value<String?>? modelVersion,
    Value<String>? analysisMode,
    Value<DateTime>? analyzedAt,
  }) {
    return ComplaintAnalysesCompanion(
      id: id ?? this.id,
      complaintId: complaintId ?? this.complaintId,
      symptomsJson: symptomsJson ?? this.symptomsJson,
      componentCandidatesJson:
          componentCandidatesJson ?? this.componentCandidatesJson,
      followUpJson: followUpJson ?? this.followUpJson,
      historicalMatchesJson:
          historicalMatchesJson ?? this.historicalMatchesJson,
      riskLevel: riskLevel ?? this.riskLevel,
      summary: summary ?? this.summary,
      modelVersion: modelVersion ?? this.modelVersion,
      analysisMode: analysisMode ?? this.analysisMode,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (complaintId.present) {
      map['complaint_id'] = Variable<int>(complaintId.value);
    }
    if (symptomsJson.present) {
      map['symptoms_json'] = Variable<String>(symptomsJson.value);
    }
    if (componentCandidatesJson.present) {
      map['component_candidates_json'] = Variable<String>(
        componentCandidatesJson.value,
      );
    }
    if (followUpJson.present) {
      map['follow_up_json'] = Variable<String>(followUpJson.value);
    }
    if (historicalMatchesJson.present) {
      map['historical_matches_json'] = Variable<String>(
        historicalMatchesJson.value,
      );
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (analysisMode.present) {
      map['analysis_mode'] = Variable<String>(analysisMode.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintAnalysesCompanion(')
          ..write('id: $id, ')
          ..write('complaintId: $complaintId, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('componentCandidatesJson: $componentCandidatesJson, ')
          ..write('followUpJson: $followUpJson, ')
          ..write('historicalMatchesJson: $historicalMatchesJson, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('summary: $summary, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('analysisMode: $analysisMode, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }
}

class $CatalogSourcesTable extends CatalogSources
    with TableInfo<$CatalogSourcesTable, CatalogSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _websiteUrlMeta = const VerificationMeta(
    'websiteUrl',
  );
  @override
  late final GeneratedColumn<String> websiteUrl = GeneratedColumn<String>(
    'website_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseOrPermissionMeta =
      const VerificationMeta('licenseOrPermission');
  @override
  late final GeneratedColumn<String> licenseOrPermission =
      GeneratedColumn<String>(
        'license_or_permission',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerName,
    websiteUrl,
    licenseOrPermission,
    verifiedAt,
    lastCheckedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerNameMeta);
    }
    if (data.containsKey('website_url')) {
      context.handle(
        _websiteUrlMeta,
        websiteUrl.isAcceptableOrUnknown(data['website_url']!, _websiteUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_websiteUrlMeta);
    }
    if (data.containsKey('license_or_permission')) {
      context.handle(
        _licenseOrPermissionMeta,
        licenseOrPermission.isAcceptableOrUnknown(
          data['license_or_permission']!,
          _licenseOrPermissionMeta,
        ),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      )!,
      websiteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website_url'],
      )!,
      licenseOrPermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_or_permission'],
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
    );
  }

  @override
  $CatalogSourcesTable createAlias(String alias) {
    return $CatalogSourcesTable(attachedDatabase, alias);
  }
}

class CatalogSource extends DataClass implements Insertable<CatalogSource> {
  final int id;
  final String providerName;
  final String websiteUrl;
  final String? licenseOrPermission;
  final DateTime? verifiedAt;
  final DateTime? lastCheckedAt;
  const CatalogSource({
    required this.id,
    required this.providerName,
    required this.websiteUrl,
    this.licenseOrPermission,
    this.verifiedAt,
    this.lastCheckedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_name'] = Variable<String>(providerName);
    map['website_url'] = Variable<String>(websiteUrl);
    if (!nullToAbsent || licenseOrPermission != null) {
      map['license_or_permission'] = Variable<String>(licenseOrPermission);
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    return map;
  }

  CatalogSourcesCompanion toCompanion(bool nullToAbsent) {
    return CatalogSourcesCompanion(
      id: Value(id),
      providerName: Value(providerName),
      websiteUrl: Value(websiteUrl),
      licenseOrPermission: licenseOrPermission == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseOrPermission),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
    );
  }

  factory CatalogSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogSource(
      id: serializer.fromJson<int>(json['id']),
      providerName: serializer.fromJson<String>(json['providerName']),
      websiteUrl: serializer.fromJson<String>(json['websiteUrl']),
      licenseOrPermission: serializer.fromJson<String?>(
        json['licenseOrPermission'],
      ),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerName': serializer.toJson<String>(providerName),
      'websiteUrl': serializer.toJson<String>(websiteUrl),
      'licenseOrPermission': serializer.toJson<String?>(licenseOrPermission),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
    };
  }

  CatalogSource copyWith({
    int? id,
    String? providerName,
    String? websiteUrl,
    Value<String?> licenseOrPermission = const Value.absent(),
    Value<DateTime?> verifiedAt = const Value.absent(),
    Value<DateTime?> lastCheckedAt = const Value.absent(),
  }) => CatalogSource(
    id: id ?? this.id,
    providerName: providerName ?? this.providerName,
    websiteUrl: websiteUrl ?? this.websiteUrl,
    licenseOrPermission: licenseOrPermission.present
        ? licenseOrPermission.value
        : this.licenseOrPermission,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
  );
  CatalogSource copyWithCompanion(CatalogSourcesCompanion data) {
    return CatalogSource(
      id: data.id.present ? data.id.value : this.id,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      websiteUrl: data.websiteUrl.present
          ? data.websiteUrl.value
          : this.websiteUrl,
      licenseOrPermission: data.licenseOrPermission.present
          ? data.licenseOrPermission.value
          : this.licenseOrPermission,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogSource(')
          ..write('id: $id, ')
          ..write('providerName: $providerName, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('licenseOrPermission: $licenseOrPermission, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerName,
    websiteUrl,
    licenseOrPermission,
    verifiedAt,
    lastCheckedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogSource &&
          other.id == this.id &&
          other.providerName == this.providerName &&
          other.websiteUrl == this.websiteUrl &&
          other.licenseOrPermission == this.licenseOrPermission &&
          other.verifiedAt == this.verifiedAt &&
          other.lastCheckedAt == this.lastCheckedAt);
}

class CatalogSourcesCompanion extends UpdateCompanion<CatalogSource> {
  final Value<int> id;
  final Value<String> providerName;
  final Value<String> websiteUrl;
  final Value<String?> licenseOrPermission;
  final Value<DateTime?> verifiedAt;
  final Value<DateTime?> lastCheckedAt;
  const CatalogSourcesCompanion({
    this.id = const Value.absent(),
    this.providerName = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.licenseOrPermission = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
  });
  CatalogSourcesCompanion.insert({
    this.id = const Value.absent(),
    required String providerName,
    required String websiteUrl,
    this.licenseOrPermission = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
  }) : providerName = Value(providerName),
       websiteUrl = Value(websiteUrl);
  static Insertable<CatalogSource> custom({
    Expression<int>? id,
    Expression<String>? providerName,
    Expression<String>? websiteUrl,
    Expression<String>? licenseOrPermission,
    Expression<DateTime>? verifiedAt,
    Expression<DateTime>? lastCheckedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerName != null) 'provider_name': providerName,
      if (websiteUrl != null) 'website_url': websiteUrl,
      if (licenseOrPermission != null)
        'license_or_permission': licenseOrPermission,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
    });
  }

  CatalogSourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? providerName,
    Value<String>? websiteUrl,
    Value<String?>? licenseOrPermission,
    Value<DateTime?>? verifiedAt,
    Value<DateTime?>? lastCheckedAt,
  }) {
    return CatalogSourcesCompanion(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      licenseOrPermission: licenseOrPermission ?? this.licenseOrPermission,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (websiteUrl.present) {
      map['website_url'] = Variable<String>(websiteUrl.value);
    }
    if (licenseOrPermission.present) {
      map['license_or_permission'] = Variable<String>(
        licenseOrPermission.value,
      );
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogSourcesCompanion(')
          ..write('id: $id, ')
          ..write('providerName: $providerName, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('licenseOrPermission: $licenseOrPermission, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt')
          ..write(')'))
        .toString();
  }
}

class $SparepartsTable extends Spareparts
    with TableInfo<$SparepartsTable, Sparepart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SparepartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_sources (id)',
    ),
  );
  static const VerificationMeta _partNumberMeta = const VerificationMeta(
    'partNumber',
  );
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
    'part_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referencePriceMeta = const VerificationMeta(
    'referencePrice',
  );
  @override
  late final GeneratedColumn<int> referencePrice = GeneratedColumn<int>(
    'reference_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productUrlMeta = const VerificationMeta(
    'productUrl',
  );
  @override
  late final GeneratedColumn<String> productUrl = GeneratedColumn<String>(
    'product_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceUpdatedAtMeta = const VerificationMeta(
    'priceUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> priceUpdatedAt =
      GeneratedColumn<DateTime>(
        'price_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  @override
  late final GeneratedColumn<String> catalogVersion = GeneratedColumn<String>(
    'catalog_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    partNumber,
    name,
    brand,
    category,
    referencePrice,
    productUrl,
    priceUpdatedAt,
    catalogVersion,
    isVerified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spareparts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sparepart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('part_number')) {
      context.handle(
        _partNumberMeta,
        partNumber.isAcceptableOrUnknown(data['part_number']!, _partNumberMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('reference_price')) {
      context.handle(
        _referencePriceMeta,
        referencePrice.isAcceptableOrUnknown(
          data['reference_price']!,
          _referencePriceMeta,
        ),
      );
    }
    if (data.containsKey('product_url')) {
      context.handle(
        _productUrlMeta,
        productUrl.isAcceptableOrUnknown(data['product_url']!, _productUrlMeta),
      );
    }
    if (data.containsKey('price_updated_at')) {
      context.handle(
        _priceUpdatedAtMeta,
        priceUpdatedAt.isAcceptableOrUnknown(
          data['price_updated_at']!,
          _priceUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sparepart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sparepart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      ),
      partNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_number'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      referencePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_price'],
      ),
      productUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_url'],
      ),
      priceUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}price_updated_at'],
      ),
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_version'],
      ),
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
    );
  }

  @override
  $SparepartsTable createAlias(String alias) {
    return $SparepartsTable(attachedDatabase, alias);
  }
}

class Sparepart extends DataClass implements Insertable<Sparepart> {
  final int id;
  final int? sourceId;
  final String? partNumber;
  final String name;
  final String? brand;
  final String category;
  final int? referencePrice;
  final String? productUrl;
  final DateTime? priceUpdatedAt;
  final String? catalogVersion;
  final bool isVerified;
  const Sparepart({
    required this.id,
    this.sourceId,
    this.partNumber,
    required this.name,
    this.brand,
    required this.category,
    this.referencePrice,
    this.productUrl,
    this.priceUpdatedAt,
    this.catalogVersion,
    required this.isVerified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    if (!nullToAbsent || partNumber != null) {
      map['part_number'] = Variable<String>(partNumber);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || referencePrice != null) {
      map['reference_price'] = Variable<int>(referencePrice);
    }
    if (!nullToAbsent || productUrl != null) {
      map['product_url'] = Variable<String>(productUrl);
    }
    if (!nullToAbsent || priceUpdatedAt != null) {
      map['price_updated_at'] = Variable<DateTime>(priceUpdatedAt);
    }
    if (!nullToAbsent || catalogVersion != null) {
      map['catalog_version'] = Variable<String>(catalogVersion);
    }
    map['is_verified'] = Variable<bool>(isVerified);
    return map;
  }

  SparepartsCompanion toCompanion(bool nullToAbsent) {
    return SparepartsCompanion(
      id: Value(id),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      partNumber: partNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(partNumber),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      category: Value(category),
      referencePrice: referencePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(referencePrice),
      productUrl: productUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(productUrl),
      priceUpdatedAt: priceUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(priceUpdatedAt),
      catalogVersion: catalogVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogVersion),
      isVerified: Value(isVerified),
    );
  }

  factory Sparepart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sparepart(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      partNumber: serializer.fromJson<String?>(json['partNumber']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String>(json['category']),
      referencePrice: serializer.fromJson<int?>(json['referencePrice']),
      productUrl: serializer.fromJson<String?>(json['productUrl']),
      priceUpdatedAt: serializer.fromJson<DateTime?>(json['priceUpdatedAt']),
      catalogVersion: serializer.fromJson<String?>(json['catalogVersion']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int?>(sourceId),
      'partNumber': serializer.toJson<String?>(partNumber),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String>(category),
      'referencePrice': serializer.toJson<int?>(referencePrice),
      'productUrl': serializer.toJson<String?>(productUrl),
      'priceUpdatedAt': serializer.toJson<DateTime?>(priceUpdatedAt),
      'catalogVersion': serializer.toJson<String?>(catalogVersion),
      'isVerified': serializer.toJson<bool>(isVerified),
    };
  }

  Sparepart copyWith({
    int? id,
    Value<int?> sourceId = const Value.absent(),
    Value<String?> partNumber = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    String? category,
    Value<int?> referencePrice = const Value.absent(),
    Value<String?> productUrl = const Value.absent(),
    Value<DateTime?> priceUpdatedAt = const Value.absent(),
    Value<String?> catalogVersion = const Value.absent(),
    bool? isVerified,
  }) => Sparepart(
    id: id ?? this.id,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    partNumber: partNumber.present ? partNumber.value : this.partNumber,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category ?? this.category,
    referencePrice: referencePrice.present
        ? referencePrice.value
        : this.referencePrice,
    productUrl: productUrl.present ? productUrl.value : this.productUrl,
    priceUpdatedAt: priceUpdatedAt.present
        ? priceUpdatedAt.value
        : this.priceUpdatedAt,
    catalogVersion: catalogVersion.present
        ? catalogVersion.value
        : this.catalogVersion,
    isVerified: isVerified ?? this.isVerified,
  );
  Sparepart copyWithCompanion(SparepartsCompanion data) {
    return Sparepart(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      partNumber: data.partNumber.present
          ? data.partNumber.value
          : this.partNumber,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      referencePrice: data.referencePrice.present
          ? data.referencePrice.value
          : this.referencePrice,
      productUrl: data.productUrl.present
          ? data.productUrl.value
          : this.productUrl,
      priceUpdatedAt: data.priceUpdatedAt.present
          ? data.priceUpdatedAt.value
          : this.priceUpdatedAt,
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sparepart(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('partNumber: $partNumber, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('referencePrice: $referencePrice, ')
          ..write('productUrl: $productUrl, ')
          ..write('priceUpdatedAt: $priceUpdatedAt, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('isVerified: $isVerified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    partNumber,
    name,
    brand,
    category,
    referencePrice,
    productUrl,
    priceUpdatedAt,
    catalogVersion,
    isVerified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sparepart &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.partNumber == this.partNumber &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.referencePrice == this.referencePrice &&
          other.productUrl == this.productUrl &&
          other.priceUpdatedAt == this.priceUpdatedAt &&
          other.catalogVersion == this.catalogVersion &&
          other.isVerified == this.isVerified);
}

class SparepartsCompanion extends UpdateCompanion<Sparepart> {
  final Value<int> id;
  final Value<int?> sourceId;
  final Value<String?> partNumber;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String> category;
  final Value<int?> referencePrice;
  final Value<String?> productUrl;
  final Value<DateTime?> priceUpdatedAt;
  final Value<String?> catalogVersion;
  final Value<bool> isVerified;
  const SparepartsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.referencePrice = const Value.absent(),
    this.productUrl = const Value.absent(),
    this.priceUpdatedAt = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.isVerified = const Value.absent(),
  });
  SparepartsCompanion.insert({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.partNumber = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required String category,
    this.referencePrice = const Value.absent(),
    this.productUrl = const Value.absent(),
    this.priceUpdatedAt = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.isVerified = const Value.absent(),
  }) : name = Value(name),
       category = Value(category);
  static Insertable<Sparepart> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<String>? partNumber,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<int>? referencePrice,
    Expression<String>? productUrl,
    Expression<DateTime>? priceUpdatedAt,
    Expression<String>? catalogVersion,
    Expression<bool>? isVerified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (partNumber != null) 'part_number': partNumber,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (referencePrice != null) 'reference_price': referencePrice,
      if (productUrl != null) 'product_url': productUrl,
      if (priceUpdatedAt != null) 'price_updated_at': priceUpdatedAt,
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (isVerified != null) 'is_verified': isVerified,
    });
  }

  SparepartsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceId,
    Value<String?>? partNumber,
    Value<String>? name,
    Value<String?>? brand,
    Value<String>? category,
    Value<int?>? referencePrice,
    Value<String?>? productUrl,
    Value<DateTime?>? priceUpdatedAt,
    Value<String?>? catalogVersion,
    Value<bool>? isVerified,
  }) {
    return SparepartsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      partNumber: partNumber ?? this.partNumber,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      referencePrice: referencePrice ?? this.referencePrice,
      productUrl: productUrl ?? this.productUrl,
      priceUpdatedAt: priceUpdatedAt ?? this.priceUpdatedAt,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (referencePrice.present) {
      map['reference_price'] = Variable<int>(referencePrice.value);
    }
    if (productUrl.present) {
      map['product_url'] = Variable<String>(productUrl.value);
    }
    if (priceUpdatedAt.present) {
      map['price_updated_at'] = Variable<DateTime>(priceUpdatedAt.value);
    }
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<String>(catalogVersion.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SparepartsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('partNumber: $partNumber, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('referencePrice: $referencePrice, ')
          ..write('productUrl: $productUrl, ')
          ..write('priceUpdatedAt: $priceUpdatedAt, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('isVerified: $isVerified')
          ..write(')'))
        .toString();
  }
}

class $SparepartFitmentsTable extends SparepartFitments
    with TableInfo<$SparepartFitmentsTable, SparepartFitment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SparepartFitmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sparepartIdMeta = const VerificationMeta(
    'sparepartId',
  );
  @override
  late final GeneratedColumn<int> sparepartId = GeneratedColumn<int>(
    'sparepart_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spareparts (id)',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<int> modelId = GeneratedColumn<int>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycle_models (id)',
    ),
  );
  static const VerificationMeta _yearStartMeta = const VerificationMeta(
    'yearStart',
  );
  @override
  late final GeneratedColumn<int> yearStart = GeneratedColumn<int>(
    'year_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearEndMeta = const VerificationMeta(
    'yearEnd',
  );
  @override
  late final GeneratedColumn<int> yearEnd = GeneratedColumn<int>(
    'year_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sparepartId,
    modelId,
    yearStart,
    yearEnd,
    notes,
    verifiedAt,
    sourceUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sparepart_fitments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SparepartFitment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sparepart_id')) {
      context.handle(
        _sparepartIdMeta,
        sparepartId.isAcceptableOrUnknown(
          data['sparepart_id']!,
          _sparepartIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sparepartIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('year_start')) {
      context.handle(
        _yearStartMeta,
        yearStart.isAcceptableOrUnknown(data['year_start']!, _yearStartMeta),
      );
    } else if (isInserting) {
      context.missing(_yearStartMeta);
    }
    if (data.containsKey('year_end')) {
      context.handle(
        _yearEndMeta,
        yearEnd.isAcceptableOrUnknown(data['year_end']!, _yearEndMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SparepartFitment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SparepartFitment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sparepartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sparepart_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_id'],
      ),
      yearStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_start'],
      )!,
      yearEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_end'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
    );
  }

  @override
  $SparepartFitmentsTable createAlias(String alias) {
    return $SparepartFitmentsTable(attachedDatabase, alias);
  }
}

class SparepartFitment extends DataClass
    implements Insertable<SparepartFitment> {
  final int id;
  final int sparepartId;
  final int? modelId;
  final int yearStart;
  final int? yearEnd;
  final String? notes;
  final DateTime? verifiedAt;
  final String? sourceUrl;
  const SparepartFitment({
    required this.id,
    required this.sparepartId,
    this.modelId,
    required this.yearStart,
    this.yearEnd,
    this.notes,
    this.verifiedAt,
    this.sourceUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sparepart_id'] = Variable<int>(sparepartId);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<int>(modelId);
    }
    map['year_start'] = Variable<int>(yearStart);
    if (!nullToAbsent || yearEnd != null) {
      map['year_end'] = Variable<int>(yearEnd);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    return map;
  }

  SparepartFitmentsCompanion toCompanion(bool nullToAbsent) {
    return SparepartFitmentsCompanion(
      id: Value(id),
      sparepartId: Value(sparepartId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      yearStart: Value(yearStart),
      yearEnd: yearEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(yearEnd),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
    );
  }

  factory SparepartFitment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SparepartFitment(
      id: serializer.fromJson<int>(json['id']),
      sparepartId: serializer.fromJson<int>(json['sparepartId']),
      modelId: serializer.fromJson<int?>(json['modelId']),
      yearStart: serializer.fromJson<int>(json['yearStart']),
      yearEnd: serializer.fromJson<int?>(json['yearEnd']),
      notes: serializer.fromJson<String?>(json['notes']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sparepartId': serializer.toJson<int>(sparepartId),
      'modelId': serializer.toJson<int?>(modelId),
      'yearStart': serializer.toJson<int>(yearStart),
      'yearEnd': serializer.toJson<int?>(yearEnd),
      'notes': serializer.toJson<String?>(notes),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
    };
  }

  SparepartFitment copyWith({
    int? id,
    int? sparepartId,
    Value<int?> modelId = const Value.absent(),
    int? yearStart,
    Value<int?> yearEnd = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> verifiedAt = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
  }) => SparepartFitment(
    id: id ?? this.id,
    sparepartId: sparepartId ?? this.sparepartId,
    modelId: modelId.present ? modelId.value : this.modelId,
    yearStart: yearStart ?? this.yearStart,
    yearEnd: yearEnd.present ? yearEnd.value : this.yearEnd,
    notes: notes.present ? notes.value : this.notes,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
  );
  SparepartFitment copyWithCompanion(SparepartFitmentsCompanion data) {
    return SparepartFitment(
      id: data.id.present ? data.id.value : this.id,
      sparepartId: data.sparepartId.present
          ? data.sparepartId.value
          : this.sparepartId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      yearStart: data.yearStart.present ? data.yearStart.value : this.yearStart,
      yearEnd: data.yearEnd.present ? data.yearEnd.value : this.yearEnd,
      notes: data.notes.present ? data.notes.value : this.notes,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SparepartFitment(')
          ..write('id: $id, ')
          ..write('sparepartId: $sparepartId, ')
          ..write('modelId: $modelId, ')
          ..write('yearStart: $yearStart, ')
          ..write('yearEnd: $yearEnd, ')
          ..write('notes: $notes, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('sourceUrl: $sourceUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sparepartId,
    modelId,
    yearStart,
    yearEnd,
    notes,
    verifiedAt,
    sourceUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SparepartFitment &&
          other.id == this.id &&
          other.sparepartId == this.sparepartId &&
          other.modelId == this.modelId &&
          other.yearStart == this.yearStart &&
          other.yearEnd == this.yearEnd &&
          other.notes == this.notes &&
          other.verifiedAt == this.verifiedAt &&
          other.sourceUrl == this.sourceUrl);
}

class SparepartFitmentsCompanion extends UpdateCompanion<SparepartFitment> {
  final Value<int> id;
  final Value<int> sparepartId;
  final Value<int?> modelId;
  final Value<int> yearStart;
  final Value<int?> yearEnd;
  final Value<String?> notes;
  final Value<DateTime?> verifiedAt;
  final Value<String?> sourceUrl;
  const SparepartFitmentsCompanion({
    this.id = const Value.absent(),
    this.sparepartId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.yearStart = const Value.absent(),
    this.yearEnd = const Value.absent(),
    this.notes = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.sourceUrl = const Value.absent(),
  });
  SparepartFitmentsCompanion.insert({
    this.id = const Value.absent(),
    required int sparepartId,
    this.modelId = const Value.absent(),
    required int yearStart,
    this.yearEnd = const Value.absent(),
    this.notes = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.sourceUrl = const Value.absent(),
  }) : sparepartId = Value(sparepartId),
       yearStart = Value(yearStart);
  static Insertable<SparepartFitment> custom({
    Expression<int>? id,
    Expression<int>? sparepartId,
    Expression<int>? modelId,
    Expression<int>? yearStart,
    Expression<int>? yearEnd,
    Expression<String>? notes,
    Expression<DateTime>? verifiedAt,
    Expression<String>? sourceUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sparepartId != null) 'sparepart_id': sparepartId,
      if (modelId != null) 'model_id': modelId,
      if (yearStart != null) 'year_start': yearStart,
      if (yearEnd != null) 'year_end': yearEnd,
      if (notes != null) 'notes': notes,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (sourceUrl != null) 'source_url': sourceUrl,
    });
  }

  SparepartFitmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? sparepartId,
    Value<int?>? modelId,
    Value<int>? yearStart,
    Value<int?>? yearEnd,
    Value<String?>? notes,
    Value<DateTime?>? verifiedAt,
    Value<String?>? sourceUrl,
  }) {
    return SparepartFitmentsCompanion(
      id: id ?? this.id,
      sparepartId: sparepartId ?? this.sparepartId,
      modelId: modelId ?? this.modelId,
      yearStart: yearStart ?? this.yearStart,
      yearEnd: yearEnd ?? this.yearEnd,
      notes: notes ?? this.notes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sparepartId.present) {
      map['sparepart_id'] = Variable<int>(sparepartId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<int>(modelId.value);
    }
    if (yearStart.present) {
      map['year_start'] = Variable<int>(yearStart.value);
    }
    if (yearEnd.present) {
      map['year_end'] = Variable<int>(yearEnd.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SparepartFitmentsCompanion(')
          ..write('id: $id, ')
          ..write('sparepartId: $sparepartId, ')
          ..write('modelId: $modelId, ')
          ..write('yearStart: $yearStart, ')
          ..write('yearEnd: $yearEnd, ')
          ..write('notes: $notes, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('sourceUrl: $sourceUrl')
          ..write(')'))
        .toString();
  }
}

class $BudgetPlansTable extends BudgetPlans
    with TableInfo<$BudgetPlansTable, BudgetPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _budgetAmountMeta = const VerificationMeta(
    'budgetAmount',
  );
  @override
  late final GeneratedColumn<int> budgetAmount = GeneratedColumn<int>(
    'budget_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    budgetAmount,
    period,
    createdAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('budget_amount')) {
      context.handle(
        _budgetAmountMeta,
        budgetAmount.isAcceptableOrUnknown(
          data['budget_amount']!,
          _budgetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_budgetAmountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      budgetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_amount'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BudgetPlansTable createAlias(String alias) {
    return $BudgetPlansTable(attachedDatabase, alias);
  }
}

class BudgetPlan extends DataClass implements Insertable<BudgetPlan> {
  final int id;
  final int motorcycleId;
  final int budgetAmount;
  final String? period;
  final DateTime createdAt;
  final String? notes;
  const BudgetPlan({
    required this.id,
    required this.motorcycleId,
    required this.budgetAmount,
    this.period,
    required this.createdAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    map['budget_amount'] = Variable<int>(budgetAmount);
    if (!nullToAbsent || period != null) {
      map['period'] = Variable<String>(period);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BudgetPlansCompanion toCompanion(bool nullToAbsent) {
    return BudgetPlansCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      budgetAmount: Value(budgetAmount),
      period: period == null && nullToAbsent
          ? const Value.absent()
          : Value(period),
      createdAt: Value(createdAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BudgetPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetPlan(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      budgetAmount: serializer.fromJson<int>(json['budgetAmount']),
      period: serializer.fromJson<String?>(json['period']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'budgetAmount': serializer.toJson<int>(budgetAmount),
      'period': serializer.toJson<String?>(period),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BudgetPlan copyWith({
    int? id,
    int? motorcycleId,
    int? budgetAmount,
    Value<String?> period = const Value.absent(),
    DateTime? createdAt,
    Value<String?> notes = const Value.absent(),
  }) => BudgetPlan(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    budgetAmount: budgetAmount ?? this.budgetAmount,
    period: period.present ? period.value : this.period,
    createdAt: createdAt ?? this.createdAt,
    notes: notes.present ? notes.value : this.notes,
  );
  BudgetPlan copyWithCompanion(BudgetPlansCompanion data) {
    return BudgetPlan(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      budgetAmount: data.budgetAmount.present
          ? data.budgetAmount.value
          : this.budgetAmount,
      period: data.period.present ? data.period.value : this.period,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetPlan(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('period: $period, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, motorcycleId, budgetAmount, period, createdAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetPlan &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.budgetAmount == this.budgetAmount &&
          other.period == this.period &&
          other.createdAt == this.createdAt &&
          other.notes == this.notes);
}

class BudgetPlansCompanion extends UpdateCompanion<BudgetPlan> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<int> budgetAmount;
  final Value<String?> period;
  final Value<DateTime> createdAt;
  final Value<String?> notes;
  const BudgetPlansCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.budgetAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BudgetPlansCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    required int budgetAmount,
    this.period = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : motorcycleId = Value(motorcycleId),
       budgetAmount = Value(budgetAmount);
  static Insertable<BudgetPlan> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<int>? budgetAmount,
    Expression<String>? period,
    Expression<DateTime>? createdAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (budgetAmount != null) 'budget_amount': budgetAmount,
      if (period != null) 'period': period,
      if (createdAt != null) 'created_at': createdAt,
      if (notes != null) 'notes': notes,
    });
  }

  BudgetPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<int>? budgetAmount,
    Value<String?>? period,
    Value<DateTime>? createdAt,
    Value<String?>? notes,
  }) {
    return BudgetPlansCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (budgetAmount.present) {
      map['budget_amount'] = Variable<int>(budgetAmount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetPlansCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('period: $period, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ServiceRecommendationsTable extends ServiceRecommendations
    with TableInfo<$ServiceRecommendationsTable, ServiceRecommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceRecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _budgetPlanIdMeta = const VerificationMeta(
    'budgetPlanId',
  );
  @override
  late final GeneratedColumn<int> budgetPlanId = GeneratedColumn<int>(
    'budget_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_plans (id)',
    ),
  );
  static const VerificationMeta _estimatedTotalMeta = const VerificationMeta(
    'estimatedTotal',
  );
  @override
  late final GeneratedColumn<int> estimatedTotal = GeneratedColumn<int>(
    'estimated_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<String> ruleVersion = GeneratedColumn<String>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dataFreshnessMeta = const VerificationMeta(
    'dataFreshness',
  );
  @override
  late final GeneratedColumn<String> dataFreshness = GeneratedColumn<String>(
    'data_freshness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    budgetPlanId,
    estimatedTotal,
    ruleVersion,
    generatedAt,
    dataFreshness,
    explanation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_recommendations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceRecommendation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('budget_plan_id')) {
      context.handle(
        _budgetPlanIdMeta,
        budgetPlanId.isAcceptableOrUnknown(
          data['budget_plan_id']!,
          _budgetPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_budgetPlanIdMeta);
    }
    if (data.containsKey('estimated_total')) {
      context.handle(
        _estimatedTotalMeta,
        estimatedTotal.isAcceptableOrUnknown(
          data['estimated_total']!,
          _estimatedTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedTotalMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    if (data.containsKey('data_freshness')) {
      context.handle(
        _dataFreshnessMeta,
        dataFreshness.isAcceptableOrUnknown(
          data['data_freshness']!,
          _dataFreshnessMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceRecommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceRecommendation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      budgetPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_plan_id'],
      )!,
      estimatedTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_total'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_version'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      dataFreshness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_freshness'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
    );
  }

  @override
  $ServiceRecommendationsTable createAlias(String alias) {
    return $ServiceRecommendationsTable(attachedDatabase, alias);
  }
}

class ServiceRecommendation extends DataClass
    implements Insertable<ServiceRecommendation> {
  final int id;
  final int budgetPlanId;
  final int estimatedTotal;
  final String ruleVersion;
  final DateTime generatedAt;
  final String? dataFreshness;
  final String? explanation;
  const ServiceRecommendation({
    required this.id,
    required this.budgetPlanId,
    required this.estimatedTotal,
    required this.ruleVersion,
    required this.generatedAt,
    this.dataFreshness,
    this.explanation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['budget_plan_id'] = Variable<int>(budgetPlanId);
    map['estimated_total'] = Variable<int>(estimatedTotal);
    map['rule_version'] = Variable<String>(ruleVersion);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || dataFreshness != null) {
      map['data_freshness'] = Variable<String>(dataFreshness);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    return map;
  }

  ServiceRecommendationsCompanion toCompanion(bool nullToAbsent) {
    return ServiceRecommendationsCompanion(
      id: Value(id),
      budgetPlanId: Value(budgetPlanId),
      estimatedTotal: Value(estimatedTotal),
      ruleVersion: Value(ruleVersion),
      generatedAt: Value(generatedAt),
      dataFreshness: dataFreshness == null && nullToAbsent
          ? const Value.absent()
          : Value(dataFreshness),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
    );
  }

  factory ServiceRecommendation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceRecommendation(
      id: serializer.fromJson<int>(json['id']),
      budgetPlanId: serializer.fromJson<int>(json['budgetPlanId']),
      estimatedTotal: serializer.fromJson<int>(json['estimatedTotal']),
      ruleVersion: serializer.fromJson<String>(json['ruleVersion']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      dataFreshness: serializer.fromJson<String?>(json['dataFreshness']),
      explanation: serializer.fromJson<String?>(json['explanation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'budgetPlanId': serializer.toJson<int>(budgetPlanId),
      'estimatedTotal': serializer.toJson<int>(estimatedTotal),
      'ruleVersion': serializer.toJson<String>(ruleVersion),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'dataFreshness': serializer.toJson<String?>(dataFreshness),
      'explanation': serializer.toJson<String?>(explanation),
    };
  }

  ServiceRecommendation copyWith({
    int? id,
    int? budgetPlanId,
    int? estimatedTotal,
    String? ruleVersion,
    DateTime? generatedAt,
    Value<String?> dataFreshness = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
  }) => ServiceRecommendation(
    id: id ?? this.id,
    budgetPlanId: budgetPlanId ?? this.budgetPlanId,
    estimatedTotal: estimatedTotal ?? this.estimatedTotal,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    generatedAt: generatedAt ?? this.generatedAt,
    dataFreshness: dataFreshness.present
        ? dataFreshness.value
        : this.dataFreshness,
    explanation: explanation.present ? explanation.value : this.explanation,
  );
  ServiceRecommendation copyWithCompanion(
    ServiceRecommendationsCompanion data,
  ) {
    return ServiceRecommendation(
      id: data.id.present ? data.id.value : this.id,
      budgetPlanId: data.budgetPlanId.present
          ? data.budgetPlanId.value
          : this.budgetPlanId,
      estimatedTotal: data.estimatedTotal.present
          ? data.estimatedTotal.value
          : this.estimatedTotal,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      dataFreshness: data.dataFreshness.present
          ? data.dataFreshness.value
          : this.dataFreshness,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRecommendation(')
          ..write('id: $id, ')
          ..write('budgetPlanId: $budgetPlanId, ')
          ..write('estimatedTotal: $estimatedTotal, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('dataFreshness: $dataFreshness, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    budgetPlanId,
    estimatedTotal,
    ruleVersion,
    generatedAt,
    dataFreshness,
    explanation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceRecommendation &&
          other.id == this.id &&
          other.budgetPlanId == this.budgetPlanId &&
          other.estimatedTotal == this.estimatedTotal &&
          other.ruleVersion == this.ruleVersion &&
          other.generatedAt == this.generatedAt &&
          other.dataFreshness == this.dataFreshness &&
          other.explanation == this.explanation);
}

class ServiceRecommendationsCompanion
    extends UpdateCompanion<ServiceRecommendation> {
  final Value<int> id;
  final Value<int> budgetPlanId;
  final Value<int> estimatedTotal;
  final Value<String> ruleVersion;
  final Value<DateTime> generatedAt;
  final Value<String?> dataFreshness;
  final Value<String?> explanation;
  const ServiceRecommendationsCompanion({
    this.id = const Value.absent(),
    this.budgetPlanId = const Value.absent(),
    this.estimatedTotal = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.dataFreshness = const Value.absent(),
    this.explanation = const Value.absent(),
  });
  ServiceRecommendationsCompanion.insert({
    this.id = const Value.absent(),
    required int budgetPlanId,
    required int estimatedTotal,
    required String ruleVersion,
    this.generatedAt = const Value.absent(),
    this.dataFreshness = const Value.absent(),
    this.explanation = const Value.absent(),
  }) : budgetPlanId = Value(budgetPlanId),
       estimatedTotal = Value(estimatedTotal),
       ruleVersion = Value(ruleVersion);
  static Insertable<ServiceRecommendation> custom({
    Expression<int>? id,
    Expression<int>? budgetPlanId,
    Expression<int>? estimatedTotal,
    Expression<String>? ruleVersion,
    Expression<DateTime>? generatedAt,
    Expression<String>? dataFreshness,
    Expression<String>? explanation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetPlanId != null) 'budget_plan_id': budgetPlanId,
      if (estimatedTotal != null) 'estimated_total': estimatedTotal,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (dataFreshness != null) 'data_freshness': dataFreshness,
      if (explanation != null) 'explanation': explanation,
    });
  }

  ServiceRecommendationsCompanion copyWith({
    Value<int>? id,
    Value<int>? budgetPlanId,
    Value<int>? estimatedTotal,
    Value<String>? ruleVersion,
    Value<DateTime>? generatedAt,
    Value<String?>? dataFreshness,
    Value<String?>? explanation,
  }) {
    return ServiceRecommendationsCompanion(
      id: id ?? this.id,
      budgetPlanId: budgetPlanId ?? this.budgetPlanId,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      generatedAt: generatedAt ?? this.generatedAt,
      dataFreshness: dataFreshness ?? this.dataFreshness,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (budgetPlanId.present) {
      map['budget_plan_id'] = Variable<int>(budgetPlanId.value);
    }
    if (estimatedTotal.present) {
      map['estimated_total'] = Variable<int>(estimatedTotal.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<String>(ruleVersion.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (dataFreshness.present) {
      map['data_freshness'] = Variable<String>(dataFreshness.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('budgetPlanId: $budgetPlanId, ')
          ..write('estimatedTotal: $estimatedTotal, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('dataFreshness: $dataFreshness, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }
}

class $RecommendationItemsTable extends RecommendationItems
    with TableInfo<$RecommendationItemsTable, RecommendationItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recommendationIdMeta = const VerificationMeta(
    'recommendationId',
  );
  @override
  late final GeneratedColumn<int> recommendationId = GeneratedColumn<int>(
    'recommendation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_recommendations (id)',
    ),
  );
  static const VerificationMeta _componentTypeIdMeta = const VerificationMeta(
    'componentTypeId',
  );
  @override
  late final GeneratedColumn<int> componentTypeId = GeneratedColumn<int>(
    'component_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES component_types (id)',
    ),
  );
  static const VerificationMeta _sparepartIdMeta = const VerificationMeta(
    'sparepartId',
  );
  @override
  late final GeneratedColumn<int> sparepartId = GeneratedColumn<int>(
    'sparepart_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedCostMeta = const VerificationMeta(
    'estimatedCost',
  );
  @override
  late final GeneratedColumn<int> estimatedCost = GeneratedColumn<int>(
    'estimated_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedLaborCostMeta =
      const VerificationMeta('estimatedLaborCost');
  @override
  late final GeneratedColumn<int> estimatedLaborCost = GeneratedColumn<int>(
    'estimated_labor_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consequenceIfDelayedMeta =
      const VerificationMeta('consequenceIfDelayed');
  @override
  late final GeneratedColumn<String> consequenceIfDelayed =
      GeneratedColumn<String>(
        'consequence_if_delayed',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _requiresInspectionMeta =
      const VerificationMeta('requiresInspection');
  @override
  late final GeneratedColumn<bool> requiresInspection = GeneratedColumn<bool>(
    'requires_inspection',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_inspection" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recommendationId,
    componentTypeId,
    sparepartId,
    priority,
    decision,
    estimatedCost,
    estimatedLaborCost,
    reason,
    consequenceIfDelayed,
    requiresInspection,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendation_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecommendationItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recommendation_id')) {
      context.handle(
        _recommendationIdMeta,
        recommendationId.isAcceptableOrUnknown(
          data['recommendation_id']!,
          _recommendationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendationIdMeta);
    }
    if (data.containsKey('component_type_id')) {
      context.handle(
        _componentTypeIdMeta,
        componentTypeId.isAcceptableOrUnknown(
          data['component_type_id']!,
          _componentTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentTypeIdMeta);
    }
    if (data.containsKey('sparepart_id')) {
      context.handle(
        _sparepartIdMeta,
        sparepartId.isAcceptableOrUnknown(
          data['sparepart_id']!,
          _sparepartIdMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionMeta);
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
        _estimatedCostMeta,
        estimatedCost.isAcceptableOrUnknown(
          data['estimated_cost']!,
          _estimatedCostMeta,
        ),
      );
    }
    if (data.containsKey('estimated_labor_cost')) {
      context.handle(
        _estimatedLaborCostMeta,
        estimatedLaborCost.isAcceptableOrUnknown(
          data['estimated_labor_cost']!,
          _estimatedLaborCostMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('consequence_if_delayed')) {
      context.handle(
        _consequenceIfDelayedMeta,
        consequenceIfDelayed.isAcceptableOrUnknown(
          data['consequence_if_delayed']!,
          _consequenceIfDelayedMeta,
        ),
      );
    }
    if (data.containsKey('requires_inspection')) {
      context.handle(
        _requiresInspectionMeta,
        requiresInspection.isAcceptableOrUnknown(
          data['requires_inspection']!,
          _requiresInspectionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecommendationItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecommendationItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recommendationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recommendation_id'],
      )!,
      componentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}component_type_id'],
      )!,
      sparepartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sparepart_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      )!,
      estimatedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_cost'],
      ),
      estimatedLaborCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_labor_cost'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      consequenceIfDelayed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consequence_if_delayed'],
      ),
      requiresInspection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_inspection'],
      )!,
    );
  }

  @override
  $RecommendationItemsTable createAlias(String alias) {
    return $RecommendationItemsTable(attachedDatabase, alias);
  }
}

class RecommendationItem extends DataClass
    implements Insertable<RecommendationItem> {
  final int id;
  final int recommendationId;
  final int componentTypeId;
  final int? sparepartId;
  final String priority;
  final String decision;
  final int? estimatedCost;
  final int? estimatedLaborCost;
  final String reason;
  final String? consequenceIfDelayed;
  final bool requiresInspection;
  const RecommendationItem({
    required this.id,
    required this.recommendationId,
    required this.componentTypeId,
    this.sparepartId,
    required this.priority,
    required this.decision,
    this.estimatedCost,
    this.estimatedLaborCost,
    required this.reason,
    this.consequenceIfDelayed,
    required this.requiresInspection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recommendation_id'] = Variable<int>(recommendationId);
    map['component_type_id'] = Variable<int>(componentTypeId);
    if (!nullToAbsent || sparepartId != null) {
      map['sparepart_id'] = Variable<int>(sparepartId);
    }
    map['priority'] = Variable<String>(priority);
    map['decision'] = Variable<String>(decision);
    if (!nullToAbsent || estimatedCost != null) {
      map['estimated_cost'] = Variable<int>(estimatedCost);
    }
    if (!nullToAbsent || estimatedLaborCost != null) {
      map['estimated_labor_cost'] = Variable<int>(estimatedLaborCost);
    }
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || consequenceIfDelayed != null) {
      map['consequence_if_delayed'] = Variable<String>(consequenceIfDelayed);
    }
    map['requires_inspection'] = Variable<bool>(requiresInspection);
    return map;
  }

  RecommendationItemsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationItemsCompanion(
      id: Value(id),
      recommendationId: Value(recommendationId),
      componentTypeId: Value(componentTypeId),
      sparepartId: sparepartId == null && nullToAbsent
          ? const Value.absent()
          : Value(sparepartId),
      priority: Value(priority),
      decision: Value(decision),
      estimatedCost: estimatedCost == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedCost),
      estimatedLaborCost: estimatedLaborCost == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedLaborCost),
      reason: Value(reason),
      consequenceIfDelayed: consequenceIfDelayed == null && nullToAbsent
          ? const Value.absent()
          : Value(consequenceIfDelayed),
      requiresInspection: Value(requiresInspection),
    );
  }

  factory RecommendationItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecommendationItem(
      id: serializer.fromJson<int>(json['id']),
      recommendationId: serializer.fromJson<int>(json['recommendationId']),
      componentTypeId: serializer.fromJson<int>(json['componentTypeId']),
      sparepartId: serializer.fromJson<int?>(json['sparepartId']),
      priority: serializer.fromJson<String>(json['priority']),
      decision: serializer.fromJson<String>(json['decision']),
      estimatedCost: serializer.fromJson<int?>(json['estimatedCost']),
      estimatedLaborCost: serializer.fromJson<int?>(json['estimatedLaborCost']),
      reason: serializer.fromJson<String>(json['reason']),
      consequenceIfDelayed: serializer.fromJson<String?>(
        json['consequenceIfDelayed'],
      ),
      requiresInspection: serializer.fromJson<bool>(json['requiresInspection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recommendationId': serializer.toJson<int>(recommendationId),
      'componentTypeId': serializer.toJson<int>(componentTypeId),
      'sparepartId': serializer.toJson<int?>(sparepartId),
      'priority': serializer.toJson<String>(priority),
      'decision': serializer.toJson<String>(decision),
      'estimatedCost': serializer.toJson<int?>(estimatedCost),
      'estimatedLaborCost': serializer.toJson<int?>(estimatedLaborCost),
      'reason': serializer.toJson<String>(reason),
      'consequenceIfDelayed': serializer.toJson<String?>(consequenceIfDelayed),
      'requiresInspection': serializer.toJson<bool>(requiresInspection),
    };
  }

  RecommendationItem copyWith({
    int? id,
    int? recommendationId,
    int? componentTypeId,
    Value<int?> sparepartId = const Value.absent(),
    String? priority,
    String? decision,
    Value<int?> estimatedCost = const Value.absent(),
    Value<int?> estimatedLaborCost = const Value.absent(),
    String? reason,
    Value<String?> consequenceIfDelayed = const Value.absent(),
    bool? requiresInspection,
  }) => RecommendationItem(
    id: id ?? this.id,
    recommendationId: recommendationId ?? this.recommendationId,
    componentTypeId: componentTypeId ?? this.componentTypeId,
    sparepartId: sparepartId.present ? sparepartId.value : this.sparepartId,
    priority: priority ?? this.priority,
    decision: decision ?? this.decision,
    estimatedCost: estimatedCost.present
        ? estimatedCost.value
        : this.estimatedCost,
    estimatedLaborCost: estimatedLaborCost.present
        ? estimatedLaborCost.value
        : this.estimatedLaborCost,
    reason: reason ?? this.reason,
    consequenceIfDelayed: consequenceIfDelayed.present
        ? consequenceIfDelayed.value
        : this.consequenceIfDelayed,
    requiresInspection: requiresInspection ?? this.requiresInspection,
  );
  RecommendationItem copyWithCompanion(RecommendationItemsCompanion data) {
    return RecommendationItem(
      id: data.id.present ? data.id.value : this.id,
      recommendationId: data.recommendationId.present
          ? data.recommendationId.value
          : this.recommendationId,
      componentTypeId: data.componentTypeId.present
          ? data.componentTypeId.value
          : this.componentTypeId,
      sparepartId: data.sparepartId.present
          ? data.sparepartId.value
          : this.sparepartId,
      priority: data.priority.present ? data.priority.value : this.priority,
      decision: data.decision.present ? data.decision.value : this.decision,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
      estimatedLaborCost: data.estimatedLaborCost.present
          ? data.estimatedLaborCost.value
          : this.estimatedLaborCost,
      reason: data.reason.present ? data.reason.value : this.reason,
      consequenceIfDelayed: data.consequenceIfDelayed.present
          ? data.consequenceIfDelayed.value
          : this.consequenceIfDelayed,
      requiresInspection: data.requiresInspection.present
          ? data.requiresInspection.value
          : this.requiresInspection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationItem(')
          ..write('id: $id, ')
          ..write('recommendationId: $recommendationId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('sparepartId: $sparepartId, ')
          ..write('priority: $priority, ')
          ..write('decision: $decision, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('estimatedLaborCost: $estimatedLaborCost, ')
          ..write('reason: $reason, ')
          ..write('consequenceIfDelayed: $consequenceIfDelayed, ')
          ..write('requiresInspection: $requiresInspection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recommendationId,
    componentTypeId,
    sparepartId,
    priority,
    decision,
    estimatedCost,
    estimatedLaborCost,
    reason,
    consequenceIfDelayed,
    requiresInspection,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecommendationItem &&
          other.id == this.id &&
          other.recommendationId == this.recommendationId &&
          other.componentTypeId == this.componentTypeId &&
          other.sparepartId == this.sparepartId &&
          other.priority == this.priority &&
          other.decision == this.decision &&
          other.estimatedCost == this.estimatedCost &&
          other.estimatedLaborCost == this.estimatedLaborCost &&
          other.reason == this.reason &&
          other.consequenceIfDelayed == this.consequenceIfDelayed &&
          other.requiresInspection == this.requiresInspection);
}

class RecommendationItemsCompanion extends UpdateCompanion<RecommendationItem> {
  final Value<int> id;
  final Value<int> recommendationId;
  final Value<int> componentTypeId;
  final Value<int?> sparepartId;
  final Value<String> priority;
  final Value<String> decision;
  final Value<int?> estimatedCost;
  final Value<int?> estimatedLaborCost;
  final Value<String> reason;
  final Value<String?> consequenceIfDelayed;
  final Value<bool> requiresInspection;
  const RecommendationItemsCompanion({
    this.id = const Value.absent(),
    this.recommendationId = const Value.absent(),
    this.componentTypeId = const Value.absent(),
    this.sparepartId = const Value.absent(),
    this.priority = const Value.absent(),
    this.decision = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.estimatedLaborCost = const Value.absent(),
    this.reason = const Value.absent(),
    this.consequenceIfDelayed = const Value.absent(),
    this.requiresInspection = const Value.absent(),
  });
  RecommendationItemsCompanion.insert({
    this.id = const Value.absent(),
    required int recommendationId,
    required int componentTypeId,
    this.sparepartId = const Value.absent(),
    required String priority,
    required String decision,
    this.estimatedCost = const Value.absent(),
    this.estimatedLaborCost = const Value.absent(),
    required String reason,
    this.consequenceIfDelayed = const Value.absent(),
    this.requiresInspection = const Value.absent(),
  }) : recommendationId = Value(recommendationId),
       componentTypeId = Value(componentTypeId),
       priority = Value(priority),
       decision = Value(decision),
       reason = Value(reason);
  static Insertable<RecommendationItem> custom({
    Expression<int>? id,
    Expression<int>? recommendationId,
    Expression<int>? componentTypeId,
    Expression<int>? sparepartId,
    Expression<String>? priority,
    Expression<String>? decision,
    Expression<int>? estimatedCost,
    Expression<int>? estimatedLaborCost,
    Expression<String>? reason,
    Expression<String>? consequenceIfDelayed,
    Expression<bool>? requiresInspection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recommendationId != null) 'recommendation_id': recommendationId,
      if (componentTypeId != null) 'component_type_id': componentTypeId,
      if (sparepartId != null) 'sparepart_id': sparepartId,
      if (priority != null) 'priority': priority,
      if (decision != null) 'decision': decision,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (estimatedLaborCost != null)
        'estimated_labor_cost': estimatedLaborCost,
      if (reason != null) 'reason': reason,
      if (consequenceIfDelayed != null)
        'consequence_if_delayed': consequenceIfDelayed,
      if (requiresInspection != null) 'requires_inspection': requiresInspection,
    });
  }

  RecommendationItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? recommendationId,
    Value<int>? componentTypeId,
    Value<int?>? sparepartId,
    Value<String>? priority,
    Value<String>? decision,
    Value<int?>? estimatedCost,
    Value<int?>? estimatedLaborCost,
    Value<String>? reason,
    Value<String?>? consequenceIfDelayed,
    Value<bool>? requiresInspection,
  }) {
    return RecommendationItemsCompanion(
      id: id ?? this.id,
      recommendationId: recommendationId ?? this.recommendationId,
      componentTypeId: componentTypeId ?? this.componentTypeId,
      sparepartId: sparepartId ?? this.sparepartId,
      priority: priority ?? this.priority,
      decision: decision ?? this.decision,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      estimatedLaborCost: estimatedLaborCost ?? this.estimatedLaborCost,
      reason: reason ?? this.reason,
      consequenceIfDelayed: consequenceIfDelayed ?? this.consequenceIfDelayed,
      requiresInspection: requiresInspection ?? this.requiresInspection,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recommendationId.present) {
      map['recommendation_id'] = Variable<int>(recommendationId.value);
    }
    if (componentTypeId.present) {
      map['component_type_id'] = Variable<int>(componentTypeId.value);
    }
    if (sparepartId.present) {
      map['sparepart_id'] = Variable<int>(sparepartId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<int>(estimatedCost.value);
    }
    if (estimatedLaborCost.present) {
      map['estimated_labor_cost'] = Variable<int>(estimatedLaborCost.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (consequenceIfDelayed.present) {
      map['consequence_if_delayed'] = Variable<String>(
        consequenceIfDelayed.value,
      );
    }
    if (requiresInspection.present) {
      map['requires_inspection'] = Variable<bool>(requiresInspection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationItemsCompanion(')
          ..write('id: $id, ')
          ..write('recommendationId: $recommendationId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('sparepartId: $sparepartId, ')
          ..write('priority: $priority, ')
          ..write('decision: $decision, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('estimatedLaborCost: $estimatedLaborCost, ')
          ..write('reason: $reason, ')
          ..write('consequenceIfDelayed: $consequenceIfDelayed, ')
          ..write('requiresInspection: $requiresInspection')
          ..write(')'))
        .toString();
  }
}

class $LocalRemindersTable extends LocalReminders
    with TableInfo<$LocalRemindersTable, LocalReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motorcycleIdMeta = const VerificationMeta(
    'motorcycleId',
  );
  @override
  late final GeneratedColumn<int> motorcycleId = GeneratedColumn<int>(
    'motorcycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES motorcycles (id)',
    ),
  );
  static const VerificationMeta _componentTypeIdMeta = const VerificationMeta(
    'componentTypeId',
  );
  @override
  late final GeneratedColumn<int> componentTypeId = GeneratedColumn<int>(
    'component_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES component_types (id)',
    ),
  );
  static const VerificationMeta _reminderTypeMeta = const VerificationMeta(
    'reminderType',
  );
  @override
  late final GeneratedColumn<String> reminderType = GeneratedColumn<String>(
    'reminder_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueOdometerKmMeta = const VerificationMeta(
    'dueOdometerKm',
  );
  @override
  late final GeneratedColumn<double> dueOdometerKm = GeneratedColumn<double>(
    'due_odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastScheduledAtMeta = const VerificationMeta(
    'lastScheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastScheduledAt =
      GeneratedColumn<DateTime>(
        'last_scheduled_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motorcycleId,
    componentTypeId,
    reminderType,
    dueOdometerKm,
    dueDate,
    enabled,
    lastScheduledAt,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motorcycle_id')) {
      context.handle(
        _motorcycleIdMeta,
        motorcycleId.isAcceptableOrUnknown(
          data['motorcycle_id']!,
          _motorcycleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motorcycleIdMeta);
    }
    if (data.containsKey('component_type_id')) {
      context.handle(
        _componentTypeIdMeta,
        componentTypeId.isAcceptableOrUnknown(
          data['component_type_id']!,
          _componentTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('reminder_type')) {
      context.handle(
        _reminderTypeMeta,
        reminderType.isAcceptableOrUnknown(
          data['reminder_type']!,
          _reminderTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTypeMeta);
    }
    if (data.containsKey('due_odometer_km')) {
      context.handle(
        _dueOdometerKmMeta,
        dueOdometerKm.isAcceptableOrUnknown(
          data['due_odometer_km']!,
          _dueOdometerKmMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('last_scheduled_at')) {
      context.handle(
        _lastScheduledAtMeta,
        lastScheduledAt.isAcceptableOrUnknown(
          data['last_scheduled_at']!,
          _lastScheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motorcycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}motorcycle_id'],
      )!,
      componentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}component_type_id'],
      ),
      reminderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_type'],
      )!,
      dueOdometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}due_odometer_km'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      lastScheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_scheduled_at'],
      ),
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      ),
    );
  }

  @override
  $LocalRemindersTable createAlias(String alias) {
    return $LocalRemindersTable(attachedDatabase, alias);
  }
}

class LocalReminder extends DataClass implements Insertable<LocalReminder> {
  final int id;
  final int motorcycleId;
  final int? componentTypeId;
  final String reminderType;
  final double? dueOdometerKm;
  final DateTime? dueDate;
  final bool enabled;
  final DateTime? lastScheduledAt;
  final int? notificationId;
  const LocalReminder({
    required this.id,
    required this.motorcycleId,
    this.componentTypeId,
    required this.reminderType,
    this.dueOdometerKm,
    this.dueDate,
    required this.enabled,
    this.lastScheduledAt,
    this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motorcycle_id'] = Variable<int>(motorcycleId);
    if (!nullToAbsent || componentTypeId != null) {
      map['component_type_id'] = Variable<int>(componentTypeId);
    }
    map['reminder_type'] = Variable<String>(reminderType);
    if (!nullToAbsent || dueOdometerKm != null) {
      map['due_odometer_km'] = Variable<double>(dueOdometerKm);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || lastScheduledAt != null) {
      map['last_scheduled_at'] = Variable<DateTime>(lastScheduledAt);
    }
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    return map;
  }

  LocalRemindersCompanion toCompanion(bool nullToAbsent) {
    return LocalRemindersCompanion(
      id: Value(id),
      motorcycleId: Value(motorcycleId),
      componentTypeId: componentTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(componentTypeId),
      reminderType: Value(reminderType),
      dueOdometerKm: dueOdometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOdometerKm),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      enabled: Value(enabled),
      lastScheduledAt: lastScheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScheduledAt),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
    );
  }

  factory LocalReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReminder(
      id: serializer.fromJson<int>(json['id']),
      motorcycleId: serializer.fromJson<int>(json['motorcycleId']),
      componentTypeId: serializer.fromJson<int?>(json['componentTypeId']),
      reminderType: serializer.fromJson<String>(json['reminderType']),
      dueOdometerKm: serializer.fromJson<double?>(json['dueOdometerKm']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      lastScheduledAt: serializer.fromJson<DateTime?>(json['lastScheduledAt']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motorcycleId': serializer.toJson<int>(motorcycleId),
      'componentTypeId': serializer.toJson<int?>(componentTypeId),
      'reminderType': serializer.toJson<String>(reminderType),
      'dueOdometerKm': serializer.toJson<double?>(dueOdometerKm),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'enabled': serializer.toJson<bool>(enabled),
      'lastScheduledAt': serializer.toJson<DateTime?>(lastScheduledAt),
      'notificationId': serializer.toJson<int?>(notificationId),
    };
  }

  LocalReminder copyWith({
    int? id,
    int? motorcycleId,
    Value<int?> componentTypeId = const Value.absent(),
    String? reminderType,
    Value<double?> dueOdometerKm = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    bool? enabled,
    Value<DateTime?> lastScheduledAt = const Value.absent(),
    Value<int?> notificationId = const Value.absent(),
  }) => LocalReminder(
    id: id ?? this.id,
    motorcycleId: motorcycleId ?? this.motorcycleId,
    componentTypeId: componentTypeId.present
        ? componentTypeId.value
        : this.componentTypeId,
    reminderType: reminderType ?? this.reminderType,
    dueOdometerKm: dueOdometerKm.present
        ? dueOdometerKm.value
        : this.dueOdometerKm,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    enabled: enabled ?? this.enabled,
    lastScheduledAt: lastScheduledAt.present
        ? lastScheduledAt.value
        : this.lastScheduledAt,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
  );
  LocalReminder copyWithCompanion(LocalRemindersCompanion data) {
    return LocalReminder(
      id: data.id.present ? data.id.value : this.id,
      motorcycleId: data.motorcycleId.present
          ? data.motorcycleId.value
          : this.motorcycleId,
      componentTypeId: data.componentTypeId.present
          ? data.componentTypeId.value
          : this.componentTypeId,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      dueOdometerKm: data.dueOdometerKm.present
          ? data.dueOdometerKm.value
          : this.dueOdometerKm,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      lastScheduledAt: data.lastScheduledAt.present
          ? data.lastScheduledAt.value
          : this.lastScheduledAt,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReminder(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('reminderType: $reminderType, ')
          ..write('dueOdometerKm: $dueOdometerKm, ')
          ..write('dueDate: $dueDate, ')
          ..write('enabled: $enabled, ')
          ..write('lastScheduledAt: $lastScheduledAt, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    motorcycleId,
    componentTypeId,
    reminderType,
    dueOdometerKm,
    dueDate,
    enabled,
    lastScheduledAt,
    notificationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReminder &&
          other.id == this.id &&
          other.motorcycleId == this.motorcycleId &&
          other.componentTypeId == this.componentTypeId &&
          other.reminderType == this.reminderType &&
          other.dueOdometerKm == this.dueOdometerKm &&
          other.dueDate == this.dueDate &&
          other.enabled == this.enabled &&
          other.lastScheduledAt == this.lastScheduledAt &&
          other.notificationId == this.notificationId);
}

class LocalRemindersCompanion extends UpdateCompanion<LocalReminder> {
  final Value<int> id;
  final Value<int> motorcycleId;
  final Value<int?> componentTypeId;
  final Value<String> reminderType;
  final Value<double?> dueOdometerKm;
  final Value<DateTime?> dueDate;
  final Value<bool> enabled;
  final Value<DateTime?> lastScheduledAt;
  final Value<int?> notificationId;
  const LocalRemindersCompanion({
    this.id = const Value.absent(),
    this.motorcycleId = const Value.absent(),
    this.componentTypeId = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.dueOdometerKm = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastScheduledAt = const Value.absent(),
    this.notificationId = const Value.absent(),
  });
  LocalRemindersCompanion.insert({
    this.id = const Value.absent(),
    required int motorcycleId,
    this.componentTypeId = const Value.absent(),
    required String reminderType,
    this.dueOdometerKm = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastScheduledAt = const Value.absent(),
    this.notificationId = const Value.absent(),
  }) : motorcycleId = Value(motorcycleId),
       reminderType = Value(reminderType);
  static Insertable<LocalReminder> custom({
    Expression<int>? id,
    Expression<int>? motorcycleId,
    Expression<int>? componentTypeId,
    Expression<String>? reminderType,
    Expression<double>? dueOdometerKm,
    Expression<DateTime>? dueDate,
    Expression<bool>? enabled,
    Expression<DateTime>? lastScheduledAt,
    Expression<int>? notificationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motorcycleId != null) 'motorcycle_id': motorcycleId,
      if (componentTypeId != null) 'component_type_id': componentTypeId,
      if (reminderType != null) 'reminder_type': reminderType,
      if (dueOdometerKm != null) 'due_odometer_km': dueOdometerKm,
      if (dueDate != null) 'due_date': dueDate,
      if (enabled != null) 'enabled': enabled,
      if (lastScheduledAt != null) 'last_scheduled_at': lastScheduledAt,
      if (notificationId != null) 'notification_id': notificationId,
    });
  }

  LocalRemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? motorcycleId,
    Value<int?>? componentTypeId,
    Value<String>? reminderType,
    Value<double?>? dueOdometerKm,
    Value<DateTime?>? dueDate,
    Value<bool>? enabled,
    Value<DateTime?>? lastScheduledAt,
    Value<int?>? notificationId,
  }) {
    return LocalRemindersCompanion(
      id: id ?? this.id,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      componentTypeId: componentTypeId ?? this.componentTypeId,
      reminderType: reminderType ?? this.reminderType,
      dueOdometerKm: dueOdometerKm ?? this.dueOdometerKm,
      dueDate: dueDate ?? this.dueDate,
      enabled: enabled ?? this.enabled,
      lastScheduledAt: lastScheduledAt ?? this.lastScheduledAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motorcycleId.present) {
      map['motorcycle_id'] = Variable<int>(motorcycleId.value);
    }
    if (componentTypeId.present) {
      map['component_type_id'] = Variable<int>(componentTypeId.value);
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(reminderType.value);
    }
    if (dueOdometerKm.present) {
      map['due_odometer_km'] = Variable<double>(dueOdometerKm.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (lastScheduledAt.present) {
      map['last_scheduled_at'] = Variable<DateTime>(lastScheduledAt.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRemindersCompanion(')
          ..write('id: $id, ')
          ..write('motorcycleId: $motorcycleId, ')
          ..write('componentTypeId: $componentTypeId, ')
          ..write('reminderType: $reminderType, ')
          ..write('dueOdometerKm: $dueOdometerKm, ')
          ..write('dueDate: $dueDate, ')
          ..write('enabled: $enabled, ')
          ..write('lastScheduledAt: $lastScheduledAt, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }
}

class $AiModelInstallsTable extends AiModelInstalls
    with TableInfo<$AiModelInstallsTable, AiModelInstall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiModelInstallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadStatusMeta = const VerificationMeta(
    'downloadStatus',
  );
  @override
  late final GeneratedColumn<String> downloadStatus = GeneratedColumn<String>(
    'download_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelName,
    version,
    filePath,
    sha256,
    fileSizeBytes,
    downloadStatus,
    installedAt,
    sourceUrl,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_model_installs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiModelInstall> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('download_status')) {
      context.handle(
        _downloadStatusMeta,
        downloadStatus.isAcceptableOrUnknown(
          data['download_status']!,
          _downloadStatusMeta,
        ),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiModelInstall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiModelInstall(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      ),
      downloadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_status'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $AiModelInstallsTable createAlias(String alias) {
    return $AiModelInstallsTable(attachedDatabase, alias);
  }
}

class AiModelInstall extends DataClass implements Insertable<AiModelInstall> {
  final int id;
  final String modelName;
  final String version;
  final String filePath;
  final String sha256;
  final int? fileSizeBytes;
  final String downloadStatus;
  final DateTime? installedAt;
  final String? sourceUrl;
  final String? lastError;
  const AiModelInstall({
    required this.id,
    required this.modelName,
    required this.version,
    required this.filePath,
    required this.sha256,
    this.fileSizeBytes,
    required this.downloadStatus,
    this.installedAt,
    this.sourceUrl,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['model_name'] = Variable<String>(modelName);
    map['version'] = Variable<String>(version);
    map['file_path'] = Variable<String>(filePath);
    map['sha256'] = Variable<String>(sha256);
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    map['download_status'] = Variable<String>(downloadStatus);
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<DateTime>(installedAt);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  AiModelInstallsCompanion toCompanion(bool nullToAbsent) {
    return AiModelInstallsCompanion(
      id: Value(id),
      modelName: Value(modelName),
      version: Value(version),
      filePath: Value(filePath),
      sha256: Value(sha256),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      downloadStatus: Value(downloadStatus),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory AiModelInstall.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiModelInstall(
      id: serializer.fromJson<int>(json['id']),
      modelName: serializer.fromJson<String>(json['modelName']),
      version: serializer.fromJson<String>(json['version']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      downloadStatus: serializer.fromJson<String>(json['downloadStatus']),
      installedAt: serializer.fromJson<DateTime?>(json['installedAt']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelName': serializer.toJson<String>(modelName),
      'version': serializer.toJson<String>(version),
      'filePath': serializer.toJson<String>(filePath),
      'sha256': serializer.toJson<String>(sha256),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'downloadStatus': serializer.toJson<String>(downloadStatus),
      'installedAt': serializer.toJson<DateTime?>(installedAt),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  AiModelInstall copyWith({
    int? id,
    String? modelName,
    String? version,
    String? filePath,
    String? sha256,
    Value<int?> fileSizeBytes = const Value.absent(),
    String? downloadStatus,
    Value<DateTime?> installedAt = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => AiModelInstall(
    id: id ?? this.id,
    modelName: modelName ?? this.modelName,
    version: version ?? this.version,
    filePath: filePath ?? this.filePath,
    sha256: sha256 ?? this.sha256,
    fileSizeBytes: fileSizeBytes.present
        ? fileSizeBytes.value
        : this.fileSizeBytes,
    downloadStatus: downloadStatus ?? this.downloadStatus,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  AiModelInstall copyWithCompanion(AiModelInstallsCompanion data) {
    return AiModelInstall(
      id: data.id.present ? data.id.value : this.id,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      version: data.version.present ? data.version.value : this.version,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      downloadStatus: data.downloadStatus.present
          ? data.downloadStatus.value
          : this.downloadStatus,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiModelInstall(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('version: $version, ')
          ..write('filePath: $filePath, ')
          ..write('sha256: $sha256, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('installedAt: $installedAt, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelName,
    version,
    filePath,
    sha256,
    fileSizeBytes,
    downloadStatus,
    installedAt,
    sourceUrl,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiModelInstall &&
          other.id == this.id &&
          other.modelName == this.modelName &&
          other.version == this.version &&
          other.filePath == this.filePath &&
          other.sha256 == this.sha256 &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.downloadStatus == this.downloadStatus &&
          other.installedAt == this.installedAt &&
          other.sourceUrl == this.sourceUrl &&
          other.lastError == this.lastError);
}

class AiModelInstallsCompanion extends UpdateCompanion<AiModelInstall> {
  final Value<int> id;
  final Value<String> modelName;
  final Value<String> version;
  final Value<String> filePath;
  final Value<String> sha256;
  final Value<int?> fileSizeBytes;
  final Value<String> downloadStatus;
  final Value<DateTime?> installedAt;
  final Value<String?> sourceUrl;
  final Value<String?> lastError;
  const AiModelInstallsCompanion({
    this.id = const Value.absent(),
    this.modelName = const Value.absent(),
    this.version = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  AiModelInstallsCompanion.insert({
    this.id = const Value.absent(),
    required String modelName,
    required String version,
    required String filePath,
    required String sha256,
    this.fileSizeBytes = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : modelName = Value(modelName),
       version = Value(version),
       filePath = Value(filePath),
       sha256 = Value(sha256);
  static Insertable<AiModelInstall> custom({
    Expression<int>? id,
    Expression<String>? modelName,
    Expression<String>? version,
    Expression<String>? filePath,
    Expression<String>? sha256,
    Expression<int>? fileSizeBytes,
    Expression<String>? downloadStatus,
    Expression<DateTime>? installedAt,
    Expression<String>? sourceUrl,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelName != null) 'model_name': modelName,
      if (version != null) 'version': version,
      if (filePath != null) 'file_path': filePath,
      if (sha256 != null) 'sha256': sha256,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (downloadStatus != null) 'download_status': downloadStatus,
      if (installedAt != null) 'installed_at': installedAt,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (lastError != null) 'last_error': lastError,
    });
  }

  AiModelInstallsCompanion copyWith({
    Value<int>? id,
    Value<String>? modelName,
    Value<String>? version,
    Value<String>? filePath,
    Value<String>? sha256,
    Value<int?>? fileSizeBytes,
    Value<String>? downloadStatus,
    Value<DateTime?>? installedAt,
    Value<String?>? sourceUrl,
    Value<String?>? lastError,
  }) {
    return AiModelInstallsCompanion(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      version: version ?? this.version,
      filePath: filePath ?? this.filePath,
      sha256: sha256 ?? this.sha256,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      installedAt: installedAt ?? this.installedAt,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (downloadStatus.present) {
      map['download_status'] = Variable<String>(downloadStatus.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiModelInstallsCompanion(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('version: $version, ')
          ..write('filePath: $filePath, ')
          ..write('sha256: $sha256, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('installedAt: $installedAt, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MotorcycleModelsTable motorcycleModels = $MotorcycleModelsTable(
    this,
  );
  late final $MotorcyclesTable motorcycles = $MotorcyclesTable(this);
  late final $OdometerLogsTable odometerLogs = $OdometerLogsTable(this);
  late final $ComponentTypesTable componentTypes = $ComponentTypesTable(this);
  late final $MaintenanceRulesTable maintenanceRules = $MaintenanceRulesTable(
    this,
  );
  late final $ComponentStatusesTable componentStatuses =
      $ComponentStatusesTable(this);
  late final $ServiceRecordsTable serviceRecords = $ServiceRecordsTable(this);
  late final $ServiceItemsTable serviceItems = $ServiceItemsTable(this);
  late final $SelfInspectionsTable selfInspections = $SelfInspectionsTable(
    this,
  );
  late final $InspectionAnswersTable inspectionAnswers =
      $InspectionAnswersTable(this);
  late final $ComplaintsTable complaints = $ComplaintsTable(this);
  late final $ComplaintMessagesTable complaintMessages =
      $ComplaintMessagesTable(this);
  late final $ComplaintAnalysesTable complaintAnalyses =
      $ComplaintAnalysesTable(this);
  late final $CatalogSourcesTable catalogSources = $CatalogSourcesTable(this);
  late final $SparepartsTable spareparts = $SparepartsTable(this);
  late final $SparepartFitmentsTable sparepartFitments =
      $SparepartFitmentsTable(this);
  late final $BudgetPlansTable budgetPlans = $BudgetPlansTable(this);
  late final $ServiceRecommendationsTable serviceRecommendations =
      $ServiceRecommendationsTable(this);
  late final $RecommendationItemsTable recommendationItems =
      $RecommendationItemsTable(this);
  late final $LocalRemindersTable localReminders = $LocalRemindersTable(this);
  late final $AiModelInstallsTable aiModelInstalls = $AiModelInstallsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    motorcycleModels,
    motorcycles,
    odometerLogs,
    componentTypes,
    maintenanceRules,
    componentStatuses,
    serviceRecords,
    serviceItems,
    selfInspections,
    inspectionAnswers,
    complaints,
    complaintMessages,
    complaintAnalyses,
    catalogSources,
    spareparts,
    sparepartFitments,
    budgetPlans,
    serviceRecommendations,
    recommendationItems,
    localReminders,
    aiModelInstalls,
    appSettings,
  ];
}

typedef $$MotorcycleModelsTableCreateCompanionBuilder =
    MotorcycleModelsCompanion Function({
      Value<int> id,
      required String brand,
      required String model,
      Value<String?> variant,
      Value<String?> generation,
      required int yearStart,
      Value<int?> yearEnd,
      Value<String?> sourceUrl,
      Value<DateTime?> verifiedAt,
    });
typedef $$MotorcycleModelsTableUpdateCompanionBuilder =
    MotorcycleModelsCompanion Function({
      Value<int> id,
      Value<String> brand,
      Value<String> model,
      Value<String?> variant,
      Value<String?> generation,
      Value<int> yearStart,
      Value<int?> yearEnd,
      Value<String?> sourceUrl,
      Value<DateTime?> verifiedAt,
    });

final class $$MotorcycleModelsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MotorcycleModelsTable, MotorcycleModel> {
  $$MotorcycleModelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MotorcyclesTable, List<Motorcycle>>
  _motorcyclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.motorcycles,
    aliasName: $_aliasNameGenerator(
      db.motorcycleModels.id,
      db.motorcycles.modelId,
    ),
  );

  $$MotorcyclesTableProcessedTableManager get motorcyclesRefs {
    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_motorcyclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceRulesTable, List<MaintenanceRule>>
  _maintenanceRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceRules,
    aliasName: $_aliasNameGenerator(
      db.motorcycleModels.id,
      db.maintenanceRules.modelId,
    ),
  );

  $$MaintenanceRulesTableProcessedTableManager get maintenanceRulesRefs {
    final manager = $$MaintenanceRulesTableTableManager(
      $_db,
      $_db.maintenanceRules,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SparepartFitmentsTable, List<SparepartFitment>>
  _sparepartFitmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sparepartFitments,
        aliasName: $_aliasNameGenerator(
          db.motorcycleModels.id,
          db.sparepartFitments.modelId,
        ),
      );

  $$SparepartFitmentsTableProcessedTableManager get sparepartFitmentsRefs {
    final manager = $$SparepartFitmentsTableTableManager(
      $_db,
      $_db.sparepartFitments,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sparepartFitmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MotorcycleModelsTableFilterComposer
    extends Composer<_$AppDatabase, $MotorcycleModelsTable> {
  $$MotorcycleModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearStart => $composableBuilder(
    column: $table.yearStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearEnd => $composableBuilder(
    column: $table.yearEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> motorcyclesRefs(
    Expression<bool> Function($$MotorcyclesTableFilterComposer f) f,
  ) {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceRulesRefs(
    Expression<bool> Function($$MaintenanceRulesTableFilterComposer f) f,
  ) {
    final $$MaintenanceRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRules,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRulesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sparepartFitmentsRefs(
    Expression<bool> Function($$SparepartFitmentsTableFilterComposer f) f,
  ) {
    final $$SparepartFitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sparepartFitments,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartFitmentsTableFilterComposer(
            $db: $db,
            $table: $db.sparepartFitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MotorcycleModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $MotorcycleModelsTable> {
  $$MotorcycleModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearStart => $composableBuilder(
    column: $table.yearStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearEnd => $composableBuilder(
    column: $table.yearEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MotorcycleModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MotorcycleModelsTable> {
  $$MotorcycleModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearStart =>
      $composableBuilder(column: $table.yearStart, builder: (column) => column);

  GeneratedColumn<int> get yearEnd =>
      $composableBuilder(column: $table.yearEnd, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  Expression<T> motorcyclesRefs<T extends Object>(
    Expression<T> Function($$MotorcyclesTableAnnotationComposer a) f,
  ) {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceRulesRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRulesTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRules,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sparepartFitmentsRefs<T extends Object>(
    Expression<T> Function($$SparepartFitmentsTableAnnotationComposer a) f,
  ) {
    final $$SparepartFitmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sparepartFitments,
          getReferencedColumn: (t) => t.modelId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SparepartFitmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.sparepartFitments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MotorcycleModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MotorcycleModelsTable,
          MotorcycleModel,
          $$MotorcycleModelsTableFilterComposer,
          $$MotorcycleModelsTableOrderingComposer,
          $$MotorcycleModelsTableAnnotationComposer,
          $$MotorcycleModelsTableCreateCompanionBuilder,
          $$MotorcycleModelsTableUpdateCompanionBuilder,
          (MotorcycleModel, $$MotorcycleModelsTableReferences),
          MotorcycleModel,
          PrefetchHooks Function({
            bool motorcyclesRefs,
            bool maintenanceRulesRefs,
            bool sparepartFitmentsRefs,
          })
        > {
  $$MotorcycleModelsTableTableManager(
    _$AppDatabase db,
    $MotorcycleModelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MotorcycleModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MotorcycleModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MotorcycleModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<String?> generation = const Value.absent(),
                Value<int> yearStart = const Value.absent(),
                Value<int?> yearEnd = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
              }) => MotorcycleModelsCompanion(
                id: id,
                brand: brand,
                model: model,
                variant: variant,
                generation: generation,
                yearStart: yearStart,
                yearEnd: yearEnd,
                sourceUrl: sourceUrl,
                verifiedAt: verifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String brand,
                required String model,
                Value<String?> variant = const Value.absent(),
                Value<String?> generation = const Value.absent(),
                required int yearStart,
                Value<int?> yearEnd = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
              }) => MotorcycleModelsCompanion.insert(
                id: id,
                brand: brand,
                model: model,
                variant: variant,
                generation: generation,
                yearStart: yearStart,
                yearEnd: yearEnd,
                sourceUrl: sourceUrl,
                verifiedAt: verifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MotorcycleModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                motorcyclesRefs = false,
                maintenanceRulesRefs = false,
                sparepartFitmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (motorcyclesRefs) db.motorcycles,
                    if (maintenanceRulesRefs) db.maintenanceRules,
                    if (sparepartFitmentsRefs) db.sparepartFitments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (motorcyclesRefs)
                        await $_getPrefetchedData<
                          MotorcycleModel,
                          $MotorcycleModelsTable,
                          Motorcycle
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcycleModelsTableReferences
                              ._motorcyclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcycleModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).motorcyclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceRulesRefs)
                        await $_getPrefetchedData<
                          MotorcycleModel,
                          $MotorcycleModelsTable,
                          MaintenanceRule
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcycleModelsTableReferences
                              ._maintenanceRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcycleModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sparepartFitmentsRefs)
                        await $_getPrefetchedData<
                          MotorcycleModel,
                          $MotorcycleModelsTable,
                          SparepartFitment
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcycleModelsTableReferences
                              ._sparepartFitmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcycleModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).sparepartFitmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MotorcycleModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MotorcycleModelsTable,
      MotorcycleModel,
      $$MotorcycleModelsTableFilterComposer,
      $$MotorcycleModelsTableOrderingComposer,
      $$MotorcycleModelsTableAnnotationComposer,
      $$MotorcycleModelsTableCreateCompanionBuilder,
      $$MotorcycleModelsTableUpdateCompanionBuilder,
      (MotorcycleModel, $$MotorcycleModelsTableReferences),
      MotorcycleModel,
      PrefetchHooks Function({
        bool motorcyclesRefs,
        bool maintenanceRulesRefs,
        bool sparepartFitmentsRefs,
      })
    >;
typedef $$MotorcyclesTableCreateCompanionBuilder =
    MotorcyclesCompanion Function({
      Value<int> id,
      Value<int?> modelId,
      required String nickname,
      required int manufactureYear,
      Value<String?> plateNumber,
      Value<String> emoji,
      Value<String> usageProfile,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isPrimary,
    });
typedef $$MotorcyclesTableUpdateCompanionBuilder =
    MotorcyclesCompanion Function({
      Value<int> id,
      Value<int?> modelId,
      Value<String> nickname,
      Value<int> manufactureYear,
      Value<String?> plateNumber,
      Value<String> emoji,
      Value<String> usageProfile,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isPrimary,
    });

final class $$MotorcyclesTableReferences
    extends BaseReferences<_$AppDatabase, $MotorcyclesTable, Motorcycle> {
  $$MotorcyclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MotorcycleModelsTable _modelIdTable(_$AppDatabase db) =>
      db.motorcycleModels.createAlias(
        $_aliasNameGenerator(db.motorcycles.modelId, db.motorcycleModels.id),
      );

  $$MotorcycleModelsTableProcessedTableManager? get modelId {
    final $_column = $_itemColumn<int>('model_id');
    if ($_column == null) return null;
    final manager = $$MotorcycleModelsTableTableManager(
      $_db,
      $_db.motorcycleModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OdometerLogsTable, List<OdometerLog>>
  _odometerLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.odometerLogs,
    aliasName: $_aliasNameGenerator(
      db.motorcycles.id,
      db.odometerLogs.motorcycleId,
    ),
  );

  $$OdometerLogsTableProcessedTableManager get odometerLogsRefs {
    final manager = $$OdometerLogsTableTableManager(
      $_db,
      $_db.odometerLogs,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_odometerLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComponentStatusesTable, List<ComponentStatus>>
  _componentStatusesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.componentStatuses,
        aliasName: $_aliasNameGenerator(
          db.motorcycles.id,
          db.componentStatuses.motorcycleId,
        ),
      );

  $$ComponentStatusesTableProcessedTableManager get componentStatusesRefs {
    final manager = $$ComponentStatusesTableTableManager(
      $_db,
      $_db.componentStatuses,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _componentStatusesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceRecordsTable, List<ServiceRecord>>
  _serviceRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceRecords,
    aliasName: $_aliasNameGenerator(
      db.motorcycles.id,
      db.serviceRecords.motorcycleId,
    ),
  );

  $$ServiceRecordsTableProcessedTableManager get serviceRecordsRefs {
    final manager = $$ServiceRecordsTableTableManager(
      $_db,
      $_db.serviceRecords,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SelfInspectionsTable, List<SelfInspection>>
  _selfInspectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.selfInspections,
    aliasName: $_aliasNameGenerator(
      db.motorcycles.id,
      db.selfInspections.motorcycleId,
    ),
  );

  $$SelfInspectionsTableProcessedTableManager get selfInspectionsRefs {
    final manager = $$SelfInspectionsTableTableManager(
      $_db,
      $_db.selfInspections,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _selfInspectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>>
  _complaintsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.complaints,
    aliasName: $_aliasNameGenerator(
      db.motorcycles.id,
      db.complaints.motorcycleId,
    ),
  );

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetPlansTable, List<BudgetPlan>>
  _budgetPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetPlans,
    aliasName: $_aliasNameGenerator(
      db.motorcycles.id,
      db.budgetPlans.motorcycleId,
    ),
  );

  $$BudgetPlansTableProcessedTableManager get budgetPlansRefs {
    final manager = $$BudgetPlansTableTableManager(
      $_db,
      $_db.budgetPlans,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocalRemindersTable, List<LocalReminder>>
  _localRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localReminders,
    aliasName: $_aliasNameGenerator(
      db.motorcycles.id,
      db.localReminders.motorcycleId,
    ),
  );

  $$LocalRemindersTableProcessedTableManager get localRemindersRefs {
    final manager = $$LocalRemindersTableTableManager(
      $_db,
      $_db.localReminders,
    ).filter((f) => f.motorcycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_localRemindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MotorcyclesTableFilterComposer
    extends Composer<_$AppDatabase, $MotorcyclesTable> {
  $$MotorcyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manufactureYear => $composableBuilder(
    column: $table.manufactureYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plateNumber => $composableBuilder(
    column: $table.plateNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageProfile => $composableBuilder(
    column: $table.usageProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcycleModelsTableFilterComposer get modelId {
    final $$MotorcycleModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableFilterComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> odometerLogsRefs(
    Expression<bool> Function($$OdometerLogsTableFilterComposer f) f,
  ) {
    final $$OdometerLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.odometerLogs,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OdometerLogsTableFilterComposer(
            $db: $db,
            $table: $db.odometerLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> componentStatusesRefs(
    Expression<bool> Function($$ComponentStatusesTableFilterComposer f) f,
  ) {
    final $$ComponentStatusesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.componentStatuses,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentStatusesTableFilterComposer(
            $db: $db,
            $table: $db.componentStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceRecordsRefs(
    Expression<bool> Function($$ServiceRecordsTableFilterComposer f) f,
  ) {
    final $$ServiceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> selfInspectionsRefs(
    Expression<bool> Function($$SelfInspectionsTableFilterComposer f) f,
  ) {
    final $$SelfInspectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableFilterComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintsRefs(
    Expression<bool> Function($$ComplaintsTableFilterComposer f) f,
  ) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetPlansRefs(
    Expression<bool> Function($$BudgetPlansTableFilterComposer f) f,
  ) {
    final $$BudgetPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetPlans,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPlansTableFilterComposer(
            $db: $db,
            $table: $db.budgetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localRemindersRefs(
    Expression<bool> Function($$LocalRemindersTableFilterComposer f) f,
  ) {
    final $$LocalRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localReminders,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRemindersTableFilterComposer(
            $db: $db,
            $table: $db.localReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MotorcyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $MotorcyclesTable> {
  $$MotorcyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manufactureYear => $composableBuilder(
    column: $table.manufactureYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plateNumber => $composableBuilder(
    column: $table.plateNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageProfile => $composableBuilder(
    column: $table.usageProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcycleModelsTableOrderingComposer get modelId {
    final $$MotorcycleModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MotorcyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MotorcyclesTable> {
  $$MotorcyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<int> get manufactureYear => $composableBuilder(
    column: $table.manufactureYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plateNumber => $composableBuilder(
    column: $table.plateNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get usageProfile => $composableBuilder(
    column: $table.usageProfile,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$MotorcycleModelsTableAnnotationComposer get modelId {
    final $$MotorcycleModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> odometerLogsRefs<T extends Object>(
    Expression<T> Function($$OdometerLogsTableAnnotationComposer a) f,
  ) {
    final $$OdometerLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.odometerLogs,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OdometerLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.odometerLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> componentStatusesRefs<T extends Object>(
    Expression<T> Function($$ComponentStatusesTableAnnotationComposer a) f,
  ) {
    final $$ComponentStatusesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.componentStatuses,
          getReferencedColumn: (t) => t.motorcycleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComponentStatusesTableAnnotationComposer(
                $db: $db,
                $table: $db.componentStatuses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> serviceRecordsRefs<T extends Object>(
    Expression<T> Function($$ServiceRecordsTableAnnotationComposer a) f,
  ) {
    final $$ServiceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> selfInspectionsRefs<T extends Object>(
    Expression<T> Function($$SelfInspectionsTableAnnotationComposer a) f,
  ) {
    final $$SelfInspectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> complaintsRefs<T extends Object>(
    Expression<T> Function($$ComplaintsTableAnnotationComposer a) f,
  ) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetPlansRefs<T extends Object>(
    Expression<T> Function($$BudgetPlansTableAnnotationComposer a) f,
  ) {
    final $$BudgetPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetPlans,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> localRemindersRefs<T extends Object>(
    Expression<T> Function($$LocalRemindersTableAnnotationComposer a) f,
  ) {
    final $$LocalRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localReminders,
      getReferencedColumn: (t) => t.motorcycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.localReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MotorcyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MotorcyclesTable,
          Motorcycle,
          $$MotorcyclesTableFilterComposer,
          $$MotorcyclesTableOrderingComposer,
          $$MotorcyclesTableAnnotationComposer,
          $$MotorcyclesTableCreateCompanionBuilder,
          $$MotorcyclesTableUpdateCompanionBuilder,
          (Motorcycle, $$MotorcyclesTableReferences),
          Motorcycle,
          PrefetchHooks Function({
            bool modelId,
            bool odometerLogsRefs,
            bool componentStatusesRefs,
            bool serviceRecordsRefs,
            bool selfInspectionsRefs,
            bool complaintsRefs,
            bool budgetPlansRefs,
            bool localRemindersRefs,
          })
        > {
  $$MotorcyclesTableTableManager(_$AppDatabase db, $MotorcyclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MotorcyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MotorcyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MotorcyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> manufactureYear = const Value.absent(),
                Value<String?> plateNumber = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> usageProfile = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
              }) => MotorcyclesCompanion(
                id: id,
                modelId: modelId,
                nickname: nickname,
                manufactureYear: manufactureYear,
                plateNumber: plateNumber,
                emoji: emoji,
                usageProfile: usageProfile,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isPrimary: isPrimary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                required String nickname,
                required int manufactureYear,
                Value<String?> plateNumber = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> usageProfile = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
              }) => MotorcyclesCompanion.insert(
                id: id,
                modelId: modelId,
                nickname: nickname,
                manufactureYear: manufactureYear,
                plateNumber: plateNumber,
                emoji: emoji,
                usageProfile: usageProfile,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isPrimary: isPrimary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MotorcyclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                modelId = false,
                odometerLogsRefs = false,
                componentStatusesRefs = false,
                serviceRecordsRefs = false,
                selfInspectionsRefs = false,
                complaintsRefs = false,
                budgetPlansRefs = false,
                localRemindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (odometerLogsRefs) db.odometerLogs,
                    if (componentStatusesRefs) db.componentStatuses,
                    if (serviceRecordsRefs) db.serviceRecords,
                    if (selfInspectionsRefs) db.selfInspections,
                    if (complaintsRefs) db.complaints,
                    if (budgetPlansRefs) db.budgetPlans,
                    if (localRemindersRefs) db.localReminders,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (modelId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.modelId,
                                    referencedTable:
                                        $$MotorcyclesTableReferences
                                            ._modelIdTable(db),
                                    referencedColumn:
                                        $$MotorcyclesTableReferences
                                            ._modelIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (odometerLogsRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          OdometerLog
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._odometerLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).odometerLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (componentStatusesRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          ComponentStatus
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._componentStatusesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).componentStatusesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceRecordsRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          ServiceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._serviceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (selfInspectionsRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          SelfInspection
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._selfInspectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).selfInspectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (complaintsRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          Complaint
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._complaintsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetPlansRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          BudgetPlan
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._budgetPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localRemindersRefs)
                        await $_getPrefetchedData<
                          Motorcycle,
                          $MotorcyclesTable,
                          LocalReminder
                        >(
                          currentTable: table,
                          referencedTable: $$MotorcyclesTableReferences
                              ._localRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MotorcyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).localRemindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.motorcycleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MotorcyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MotorcyclesTable,
      Motorcycle,
      $$MotorcyclesTableFilterComposer,
      $$MotorcyclesTableOrderingComposer,
      $$MotorcyclesTableAnnotationComposer,
      $$MotorcyclesTableCreateCompanionBuilder,
      $$MotorcyclesTableUpdateCompanionBuilder,
      (Motorcycle, $$MotorcyclesTableReferences),
      Motorcycle,
      PrefetchHooks Function({
        bool modelId,
        bool odometerLogsRefs,
        bool componentStatusesRefs,
        bool serviceRecordsRefs,
        bool selfInspectionsRefs,
        bool complaintsRefs,
        bool budgetPlansRefs,
        bool localRemindersRefs,
      })
    >;
typedef $$OdometerLogsTableCreateCompanionBuilder =
    OdometerLogsCompanion Function({
      Value<int> id,
      required int motorcycleId,
      required double odometerKm,
      required DateTime recordedAt,
      Value<String> source,
      Value<String?> note,
    });
typedef $$OdometerLogsTableUpdateCompanionBuilder =
    OdometerLogsCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<double> odometerKm,
      Value<DateTime> recordedAt,
      Value<String> source,
      Value<String?> note,
    });

final class $$OdometerLogsTableReferences
    extends BaseReferences<_$AppDatabase, $OdometerLogsTable, OdometerLog> {
  $$OdometerLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(db.odometerLogs.motorcycleId, db.motorcycles.id),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OdometerLogsTableFilterComposer
    extends Composer<_$AppDatabase, $OdometerLogsTable> {
  $$OdometerLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OdometerLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $OdometerLogsTable> {
  $$OdometerLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OdometerLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OdometerLogsTable> {
  $$OdometerLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OdometerLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OdometerLogsTable,
          OdometerLog,
          $$OdometerLogsTableFilterComposer,
          $$OdometerLogsTableOrderingComposer,
          $$OdometerLogsTableAnnotationComposer,
          $$OdometerLogsTableCreateCompanionBuilder,
          $$OdometerLogsTableUpdateCompanionBuilder,
          (OdometerLog, $$OdometerLogsTableReferences),
          OdometerLog,
          PrefetchHooks Function({bool motorcycleId})
        > {
  $$OdometerLogsTableTableManager(_$AppDatabase db, $OdometerLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OdometerLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OdometerLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OdometerLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<double> odometerKm = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => OdometerLogsCompanion(
                id: id,
                motorcycleId: motorcycleId,
                odometerKm: odometerKm,
                recordedAt: recordedAt,
                source: source,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                required double odometerKm,
                required DateTime recordedAt,
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => OdometerLogsCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                odometerKm: odometerKm,
                recordedAt: recordedAt,
                source: source,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OdometerLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({motorcycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (motorcycleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.motorcycleId,
                                referencedTable: $$OdometerLogsTableReferences
                                    ._motorcycleIdTable(db),
                                referencedColumn: $$OdometerLogsTableReferences
                                    ._motorcycleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OdometerLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OdometerLogsTable,
      OdometerLog,
      $$OdometerLogsTableFilterComposer,
      $$OdometerLogsTableOrderingComposer,
      $$OdometerLogsTableAnnotationComposer,
      $$OdometerLogsTableCreateCompanionBuilder,
      $$OdometerLogsTableUpdateCompanionBuilder,
      (OdometerLog, $$OdometerLogsTableReferences),
      OdometerLog,
      PrefetchHooks Function({bool motorcycleId})
    >;
typedef $$ComponentTypesTableCreateCompanionBuilder =
    ComponentTypesCompanion Function({
      Value<int> id,
      required String name,
      required String category,
      Value<bool> safetyCritical,
      Value<String?> appliesTo,
    });
typedef $$ComponentTypesTableUpdateCompanionBuilder =
    ComponentTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<bool> safetyCritical,
      Value<String?> appliesTo,
    });

final class $$ComponentTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ComponentTypesTable, ComponentType> {
  $$ComponentTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MaintenanceRulesTable, List<MaintenanceRule>>
  _maintenanceRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceRules,
    aliasName: $_aliasNameGenerator(
      db.componentTypes.id,
      db.maintenanceRules.componentTypeId,
    ),
  );

  $$MaintenanceRulesTableProcessedTableManager get maintenanceRulesRefs {
    final manager = $$MaintenanceRulesTableTableManager(
      $_db,
      $_db.maintenanceRules,
    ).filter((f) => f.componentTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComponentStatusesTable, List<ComponentStatus>>
  _componentStatusesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.componentStatuses,
        aliasName: $_aliasNameGenerator(
          db.componentTypes.id,
          db.componentStatuses.componentTypeId,
        ),
      );

  $$ComponentStatusesTableProcessedTableManager get componentStatusesRefs {
    final manager = $$ComponentStatusesTableTableManager(
      $_db,
      $_db.componentStatuses,
    ).filter((f) => f.componentTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _componentStatusesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceItemsTable, List<ServiceItem>>
  _serviceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceItems,
    aliasName: $_aliasNameGenerator(
      db.componentTypes.id,
      db.serviceItems.componentTypeId,
    ),
  );

  $$ServiceItemsTableProcessedTableManager get serviceItemsRefs {
    final manager = $$ServiceItemsTableTableManager(
      $_db,
      $_db.serviceItems,
    ).filter((f) => f.componentTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecommendationItemsTable,
    List<RecommendationItem>
  >
  _recommendationItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recommendationItems,
        aliasName: $_aliasNameGenerator(
          db.componentTypes.id,
          db.recommendationItems.componentTypeId,
        ),
      );

  $$RecommendationItemsTableProcessedTableManager get recommendationItemsRefs {
    final manager = $$RecommendationItemsTableTableManager(
      $_db,
      $_db.recommendationItems,
    ).filter((f) => f.componentTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recommendationItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocalRemindersTable, List<LocalReminder>>
  _localRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localReminders,
    aliasName: $_aliasNameGenerator(
      db.componentTypes.id,
      db.localReminders.componentTypeId,
    ),
  );

  $$LocalRemindersTableProcessedTableManager get localRemindersRefs {
    final manager = $$LocalRemindersTableTableManager(
      $_db,
      $_db.localReminders,
    ).filter((f) => f.componentTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_localRemindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComponentTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ComponentTypesTable> {
  $$ComponentTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get safetyCritical => $composableBuilder(
    column: $table.safetyCritical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliesTo => $composableBuilder(
    column: $table.appliesTo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> maintenanceRulesRefs(
    Expression<bool> Function($$MaintenanceRulesTableFilterComposer f) f,
  ) {
    final $$MaintenanceRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRules,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRulesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> componentStatusesRefs(
    Expression<bool> Function($$ComponentStatusesTableFilterComposer f) f,
  ) {
    final $$ComponentStatusesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.componentStatuses,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentStatusesTableFilterComposer(
            $db: $db,
            $table: $db.componentStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceItemsRefs(
    Expression<bool> Function($$ServiceItemsTableFilterComposer f) f,
  ) {
    final $$ServiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recommendationItemsRefs(
    Expression<bool> Function($$RecommendationItemsTableFilterComposer f) f,
  ) {
    final $$RecommendationItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recommendationItems,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecommendationItemsTableFilterComposer(
            $db: $db,
            $table: $db.recommendationItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localRemindersRefs(
    Expression<bool> Function($$LocalRemindersTableFilterComposer f) f,
  ) {
    final $$LocalRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localReminders,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRemindersTableFilterComposer(
            $db: $db,
            $table: $db.localReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComponentTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ComponentTypesTable> {
  $$ComponentTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get safetyCritical => $composableBuilder(
    column: $table.safetyCritical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliesTo => $composableBuilder(
    column: $table.appliesTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ComponentTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComponentTypesTable> {
  $$ComponentTypesTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get safetyCritical => $composableBuilder(
    column: $table.safetyCritical,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appliesTo =>
      $composableBuilder(column: $table.appliesTo, builder: (column) => column);

  Expression<T> maintenanceRulesRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRulesTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRules,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> componentStatusesRefs<T extends Object>(
    Expression<T> Function($$ComponentStatusesTableAnnotationComposer a) f,
  ) {
    final $$ComponentStatusesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.componentStatuses,
          getReferencedColumn: (t) => t.componentTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComponentStatusesTableAnnotationComposer(
                $db: $db,
                $table: $db.componentStatuses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> serviceItemsRefs<T extends Object>(
    Expression<T> Function($$ServiceItemsTableAnnotationComposer a) f,
  ) {
    final $$ServiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recommendationItemsRefs<T extends Object>(
    Expression<T> Function($$RecommendationItemsTableAnnotationComposer a) f,
  ) {
    final $$RecommendationItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recommendationItems,
          getReferencedColumn: (t) => t.componentTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecommendationItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.recommendationItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localRemindersRefs<T extends Object>(
    Expression<T> Function($$LocalRemindersTableAnnotationComposer a) f,
  ) {
    final $$LocalRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localReminders,
      getReferencedColumn: (t) => t.componentTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.localReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComponentTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComponentTypesTable,
          ComponentType,
          $$ComponentTypesTableFilterComposer,
          $$ComponentTypesTableOrderingComposer,
          $$ComponentTypesTableAnnotationComposer,
          $$ComponentTypesTableCreateCompanionBuilder,
          $$ComponentTypesTableUpdateCompanionBuilder,
          (ComponentType, $$ComponentTypesTableReferences),
          ComponentType,
          PrefetchHooks Function({
            bool maintenanceRulesRefs,
            bool componentStatusesRefs,
            bool serviceItemsRefs,
            bool recommendationItemsRefs,
            bool localRemindersRefs,
          })
        > {
  $$ComponentTypesTableTableManager(
    _$AppDatabase db,
    $ComponentTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComponentTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComponentTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComponentTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> safetyCritical = const Value.absent(),
                Value<String?> appliesTo = const Value.absent(),
              }) => ComponentTypesCompanion(
                id: id,
                name: name,
                category: category,
                safetyCritical: safetyCritical,
                appliesTo: appliesTo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                Value<bool> safetyCritical = const Value.absent(),
                Value<String?> appliesTo = const Value.absent(),
              }) => ComponentTypesCompanion.insert(
                id: id,
                name: name,
                category: category,
                safetyCritical: safetyCritical,
                appliesTo: appliesTo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComponentTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                maintenanceRulesRefs = false,
                componentStatusesRefs = false,
                serviceItemsRefs = false,
                recommendationItemsRefs = false,
                localRemindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (maintenanceRulesRefs) db.maintenanceRules,
                    if (componentStatusesRefs) db.componentStatuses,
                    if (serviceItemsRefs) db.serviceItems,
                    if (recommendationItemsRefs) db.recommendationItems,
                    if (localRemindersRefs) db.localReminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (maintenanceRulesRefs)
                        await $_getPrefetchedData<
                          ComponentType,
                          $ComponentTypesTable,
                          MaintenanceRule
                        >(
                          currentTable: table,
                          referencedTable: $$ComponentTypesTableReferences
                              ._maintenanceRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComponentTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.componentTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (componentStatusesRefs)
                        await $_getPrefetchedData<
                          ComponentType,
                          $ComponentTypesTable,
                          ComponentStatus
                        >(
                          currentTable: table,
                          referencedTable: $$ComponentTypesTableReferences
                              ._componentStatusesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComponentTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).componentStatusesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.componentTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceItemsRefs)
                        await $_getPrefetchedData<
                          ComponentType,
                          $ComponentTypesTable,
                          ServiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$ComponentTypesTableReferences
                              ._serviceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComponentTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.componentTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recommendationItemsRefs)
                        await $_getPrefetchedData<
                          ComponentType,
                          $ComponentTypesTable,
                          RecommendationItem
                        >(
                          currentTable: table,
                          referencedTable: $$ComponentTypesTableReferences
                              ._recommendationItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComponentTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).recommendationItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.componentTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localRemindersRefs)
                        await $_getPrefetchedData<
                          ComponentType,
                          $ComponentTypesTable,
                          LocalReminder
                        >(
                          currentTable: table,
                          referencedTable: $$ComponentTypesTableReferences
                              ._localRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComponentTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).localRemindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.componentTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComponentTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComponentTypesTable,
      ComponentType,
      $$ComponentTypesTableFilterComposer,
      $$ComponentTypesTableOrderingComposer,
      $$ComponentTypesTableAnnotationComposer,
      $$ComponentTypesTableCreateCompanionBuilder,
      $$ComponentTypesTableUpdateCompanionBuilder,
      (ComponentType, $$ComponentTypesTableReferences),
      ComponentType,
      PrefetchHooks Function({
        bool maintenanceRulesRefs,
        bool componentStatusesRefs,
        bool serviceItemsRefs,
        bool recommendationItemsRefs,
        bool localRemindersRefs,
      })
    >;
typedef $$MaintenanceRulesTableCreateCompanionBuilder =
    MaintenanceRulesCompanion Function({
      Value<int> id,
      Value<int?> modelId,
      required int componentTypeId,
      Value<double?> intervalKm,
      Value<int?> intervalDays,
      Value<String?> severeUseRule,
      Value<String?> sourceUrl,
      Value<String> ruleVersion,
      Value<DateTime?> verifiedAt,
    });
typedef $$MaintenanceRulesTableUpdateCompanionBuilder =
    MaintenanceRulesCompanion Function({
      Value<int> id,
      Value<int?> modelId,
      Value<int> componentTypeId,
      Value<double?> intervalKm,
      Value<int?> intervalDays,
      Value<String?> severeUseRule,
      Value<String?> sourceUrl,
      Value<String> ruleVersion,
      Value<DateTime?> verifiedAt,
    });

final class $$MaintenanceRulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MaintenanceRulesTable, MaintenanceRule> {
  $$MaintenanceRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MotorcycleModelsTable _modelIdTable(_$AppDatabase db) =>
      db.motorcycleModels.createAlias(
        $_aliasNameGenerator(
          db.maintenanceRules.modelId,
          db.motorcycleModels.id,
        ),
      );

  $$MotorcycleModelsTableProcessedTableManager? get modelId {
    final $_column = $_itemColumn<int>('model_id');
    if ($_column == null) return null;
    final manager = $$MotorcycleModelsTableTableManager(
      $_db,
      $_db.motorcycleModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ComponentTypesTable _componentTypeIdTable(_$AppDatabase db) =>
      db.componentTypes.createAlias(
        $_aliasNameGenerator(
          db.maintenanceRules.componentTypeId,
          db.componentTypes.id,
        ),
      );

  $$ComponentTypesTableProcessedTableManager get componentTypeId {
    final $_column = $_itemColumn<int>('component_type_id')!;

    final manager = $$ComponentTypesTableTableManager(
      $_db,
      $_db.componentTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_componentTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceRulesTable> {
  $$MaintenanceRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severeUseRule => $composableBuilder(
    column: $table.severeUseRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcycleModelsTableFilterComposer get modelId {
    final $$MotorcycleModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableFilterComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableFilterComposer get componentTypeId {
    final $$ComponentTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableFilterComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceRulesTable> {
  $$MaintenanceRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severeUseRule => $composableBuilder(
    column: $table.severeUseRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcycleModelsTableOrderingComposer get modelId {
    final $$MotorcycleModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableOrderingComposer get componentTypeId {
    final $$ComponentTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableOrderingComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceRulesTable> {
  $$MaintenanceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severeUseRule => $composableBuilder(
    column: $table.severeUseRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  $$MotorcycleModelsTableAnnotationComposer get modelId {
    final $$MotorcycleModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableAnnotationComposer get componentTypeId {
    final $$ComponentTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceRulesTable,
          MaintenanceRule,
          $$MaintenanceRulesTableFilterComposer,
          $$MaintenanceRulesTableOrderingComposer,
          $$MaintenanceRulesTableAnnotationComposer,
          $$MaintenanceRulesTableCreateCompanionBuilder,
          $$MaintenanceRulesTableUpdateCompanionBuilder,
          (MaintenanceRule, $$MaintenanceRulesTableReferences),
          MaintenanceRule,
          PrefetchHooks Function({bool modelId, bool componentTypeId})
        > {
  $$MaintenanceRulesTableTableManager(
    _$AppDatabase db,
    $MaintenanceRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<int> componentTypeId = const Value.absent(),
                Value<double?> intervalKm = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<String?> severeUseRule = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> ruleVersion = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
              }) => MaintenanceRulesCompanion(
                id: id,
                modelId: modelId,
                componentTypeId: componentTypeId,
                intervalKm: intervalKm,
                intervalDays: intervalDays,
                severeUseRule: severeUseRule,
                sourceUrl: sourceUrl,
                ruleVersion: ruleVersion,
                verifiedAt: verifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                required int componentTypeId,
                Value<double?> intervalKm = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<String?> severeUseRule = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> ruleVersion = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
              }) => MaintenanceRulesCompanion.insert(
                id: id,
                modelId: modelId,
                componentTypeId: componentTypeId,
                intervalKm: intervalKm,
                intervalDays: intervalDays,
                severeUseRule: severeUseRule,
                sourceUrl: sourceUrl,
                ruleVersion: ruleVersion,
                verifiedAt: verifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({modelId = false, componentTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (modelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.modelId,
                                referencedTable:
                                    $$MaintenanceRulesTableReferences
                                        ._modelIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRulesTableReferences
                                        ._modelIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (componentTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.componentTypeId,
                                referencedTable:
                                    $$MaintenanceRulesTableReferences
                                        ._componentTypeIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRulesTableReferences
                                        ._componentTypeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceRulesTable,
      MaintenanceRule,
      $$MaintenanceRulesTableFilterComposer,
      $$MaintenanceRulesTableOrderingComposer,
      $$MaintenanceRulesTableAnnotationComposer,
      $$MaintenanceRulesTableCreateCompanionBuilder,
      $$MaintenanceRulesTableUpdateCompanionBuilder,
      (MaintenanceRule, $$MaintenanceRulesTableReferences),
      MaintenanceRule,
      PrefetchHooks Function({bool modelId, bool componentTypeId})
    >;
typedef $$ComponentStatusesTableCreateCompanionBuilder =
    ComponentStatusesCompanion Function({
      Value<int> id,
      required int motorcycleId,
      required int componentTypeId,
      required String estimatedStatus,
      Value<double?> score,
      required String explanation,
      Value<double?> confidence,
      required DateTime calculatedAt,
      required String ruleVersion,
    });
typedef $$ComponentStatusesTableUpdateCompanionBuilder =
    ComponentStatusesCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<int> componentTypeId,
      Value<String> estimatedStatus,
      Value<double?> score,
      Value<String> explanation,
      Value<double?> confidence,
      Value<DateTime> calculatedAt,
      Value<String> ruleVersion,
    });

final class $$ComponentStatusesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ComponentStatusesTable,
          ComponentStatus
        > {
  $$ComponentStatusesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(
          db.componentStatuses.motorcycleId,
          db.motorcycles.id,
        ),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ComponentTypesTable _componentTypeIdTable(_$AppDatabase db) =>
      db.componentTypes.createAlias(
        $_aliasNameGenerator(
          db.componentStatuses.componentTypeId,
          db.componentTypes.id,
        ),
      );

  $$ComponentTypesTableProcessedTableManager get componentTypeId {
    final $_column = $_itemColumn<int>('component_type_id')!;

    final manager = $$ComponentTypesTableTableManager(
      $_db,
      $_db.componentTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_componentTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComponentStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $ComponentStatusesTable> {
  $$ComponentStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estimatedStatus => $composableBuilder(
    column: $table.estimatedStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableFilterComposer get componentTypeId {
    final $$ComponentTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableFilterComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComponentStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $ComponentStatusesTable> {
  $$ComponentStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estimatedStatus => $composableBuilder(
    column: $table.estimatedStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableOrderingComposer get componentTypeId {
    final $$ComponentTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableOrderingComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComponentStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComponentStatusesTable> {
  $$ComponentStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get estimatedStatus => $composableBuilder(
    column: $table.estimatedStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableAnnotationComposer get componentTypeId {
    final $$ComponentTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComponentStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComponentStatusesTable,
          ComponentStatus,
          $$ComponentStatusesTableFilterComposer,
          $$ComponentStatusesTableOrderingComposer,
          $$ComponentStatusesTableAnnotationComposer,
          $$ComponentStatusesTableCreateCompanionBuilder,
          $$ComponentStatusesTableUpdateCompanionBuilder,
          (ComponentStatus, $$ComponentStatusesTableReferences),
          ComponentStatus,
          PrefetchHooks Function({bool motorcycleId, bool componentTypeId})
        > {
  $$ComponentStatusesTableTableManager(
    _$AppDatabase db,
    $ComponentStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComponentStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComponentStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComponentStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<int> componentTypeId = const Value.absent(),
                Value<String> estimatedStatus = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> calculatedAt = const Value.absent(),
                Value<String> ruleVersion = const Value.absent(),
              }) => ComponentStatusesCompanion(
                id: id,
                motorcycleId: motorcycleId,
                componentTypeId: componentTypeId,
                estimatedStatus: estimatedStatus,
                score: score,
                explanation: explanation,
                confidence: confidence,
                calculatedAt: calculatedAt,
                ruleVersion: ruleVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                required int componentTypeId,
                required String estimatedStatus,
                Value<double?> score = const Value.absent(),
                required String explanation,
                Value<double?> confidence = const Value.absent(),
                required DateTime calculatedAt,
                required String ruleVersion,
              }) => ComponentStatusesCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                componentTypeId: componentTypeId,
                estimatedStatus: estimatedStatus,
                score: score,
                explanation: explanation,
                confidence: confidence,
                calculatedAt: calculatedAt,
                ruleVersion: ruleVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComponentStatusesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({motorcycleId = false, componentTypeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (motorcycleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motorcycleId,
                                    referencedTable:
                                        $$ComponentStatusesTableReferences
                                            ._motorcycleIdTable(db),
                                    referencedColumn:
                                        $$ComponentStatusesTableReferences
                                            ._motorcycleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (componentTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.componentTypeId,
                                    referencedTable:
                                        $$ComponentStatusesTableReferences
                                            ._componentTypeIdTable(db),
                                    referencedColumn:
                                        $$ComponentStatusesTableReferences
                                            ._componentTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ComponentStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComponentStatusesTable,
      ComponentStatus,
      $$ComponentStatusesTableFilterComposer,
      $$ComponentStatusesTableOrderingComposer,
      $$ComponentStatusesTableAnnotationComposer,
      $$ComponentStatusesTableCreateCompanionBuilder,
      $$ComponentStatusesTableUpdateCompanionBuilder,
      (ComponentStatus, $$ComponentStatusesTableReferences),
      ComponentStatus,
      PrefetchHooks Function({bool motorcycleId, bool componentTypeId})
    >;
typedef $$ServiceRecordsTableCreateCompanionBuilder =
    ServiceRecordsCompanion Function({
      Value<int> id,
      required int motorcycleId,
      required DateTime servicedAt,
      Value<double?> odometerKm,
      Value<String?> workshopName,
      Value<String?> notes,
      Value<int> totalCost,
      Value<DateTime> createdAt,
    });
typedef $$ServiceRecordsTableUpdateCompanionBuilder =
    ServiceRecordsCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<DateTime> servicedAt,
      Value<double?> odometerKm,
      Value<String?> workshopName,
      Value<String?> notes,
      Value<int> totalCost,
      Value<DateTime> createdAt,
    });

final class $$ServiceRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ServiceRecordsTable, ServiceRecord> {
  $$ServiceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(db.serviceRecords.motorcycleId, db.motorcycles.id),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ServiceItemsTable, List<ServiceItem>>
  _serviceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceItems,
    aliasName: $_aliasNameGenerator(
      db.serviceRecords.id,
      db.serviceItems.serviceRecordId,
    ),
  );

  $$ServiceItemsTableProcessedTableManager get serviceItemsRefs {
    final manager = $$ServiceItemsTableTableManager(
      $_db,
      $_db.serviceItems,
    ).filter((f) => f.serviceRecordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>>
  _complaintsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.complaints,
    aliasName: $_aliasNameGenerator(
      db.serviceRecords.id,
      db.complaints.resolvedByServiceId,
    ),
  );

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager($_db, $_db.complaints).filter(
      (f) => f.resolvedByServiceId.id.sqlEquals($_itemColumn<int>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServiceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceRecordsTable> {
  $$ServiceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get servicedAt => $composableBuilder(
    column: $table.servicedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workshopName => $composableBuilder(
    column: $table.workshopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> serviceItemsRefs(
    Expression<bool> Function($$ServiceItemsTableFilterComposer f) f,
  ) {
    final $$ServiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.serviceRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintsRefs(
    Expression<bool> Function($$ComplaintsTableFilterComposer f) f,
  ) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.resolvedByServiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceRecordsTable> {
  $$ServiceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get servicedAt => $composableBuilder(
    column: $table.servicedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workshopName => $composableBuilder(
    column: $table.workshopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceRecordsTable> {
  $$ServiceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get servicedAt => $composableBuilder(
    column: $table.servicedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workshopName => $composableBuilder(
    column: $table.workshopName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> serviceItemsRefs<T extends Object>(
    Expression<T> Function($$ServiceItemsTableAnnotationComposer a) f,
  ) {
    final $$ServiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.serviceRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> complaintsRefs<T extends Object>(
    Expression<T> Function($$ComplaintsTableAnnotationComposer a) f,
  ) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.resolvedByServiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceRecordsTable,
          ServiceRecord,
          $$ServiceRecordsTableFilterComposer,
          $$ServiceRecordsTableOrderingComposer,
          $$ServiceRecordsTableAnnotationComposer,
          $$ServiceRecordsTableCreateCompanionBuilder,
          $$ServiceRecordsTableUpdateCompanionBuilder,
          (ServiceRecord, $$ServiceRecordsTableReferences),
          ServiceRecord,
          PrefetchHooks Function({
            bool motorcycleId,
            bool serviceItemsRefs,
            bool complaintsRefs,
          })
        > {
  $$ServiceRecordsTableTableManager(
    _$AppDatabase db,
    $ServiceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<DateTime> servicedAt = const Value.absent(),
                Value<double?> odometerKm = const Value.absent(),
                Value<String?> workshopName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> totalCost = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ServiceRecordsCompanion(
                id: id,
                motorcycleId: motorcycleId,
                servicedAt: servicedAt,
                odometerKm: odometerKm,
                workshopName: workshopName,
                notes: notes,
                totalCost: totalCost,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                required DateTime servicedAt,
                Value<double?> odometerKm = const Value.absent(),
                Value<String?> workshopName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> totalCost = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ServiceRecordsCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                servicedAt: servicedAt,
                odometerKm: odometerKm,
                workshopName: workshopName,
                notes: notes,
                totalCost: totalCost,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                motorcycleId = false,
                serviceItemsRefs = false,
                complaintsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (serviceItemsRefs) db.serviceItems,
                    if (complaintsRefs) db.complaints,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (motorcycleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motorcycleId,
                                    referencedTable:
                                        $$ServiceRecordsTableReferences
                                            ._motorcycleIdTable(db),
                                    referencedColumn:
                                        $$ServiceRecordsTableReferences
                                            ._motorcycleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (serviceItemsRefs)
                        await $_getPrefetchedData<
                          ServiceRecord,
                          $ServiceRecordsTable,
                          ServiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$ServiceRecordsTableReferences
                              ._serviceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServiceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serviceRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (complaintsRefs)
                        await $_getPrefetchedData<
                          ServiceRecord,
                          $ServiceRecordsTable,
                          Complaint
                        >(
                          currentTable: table,
                          referencedTable: $$ServiceRecordsTableReferences
                              ._complaintsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServiceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resolvedByServiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ServiceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceRecordsTable,
      ServiceRecord,
      $$ServiceRecordsTableFilterComposer,
      $$ServiceRecordsTableOrderingComposer,
      $$ServiceRecordsTableAnnotationComposer,
      $$ServiceRecordsTableCreateCompanionBuilder,
      $$ServiceRecordsTableUpdateCompanionBuilder,
      (ServiceRecord, $$ServiceRecordsTableReferences),
      ServiceRecord,
      PrefetchHooks Function({
        bool motorcycleId,
        bool serviceItemsRefs,
        bool complaintsRefs,
      })
    >;
typedef $$ServiceItemsTableCreateCompanionBuilder =
    ServiceItemsCompanion Function({
      Value<int> id,
      required int serviceRecordId,
      Value<int?> componentTypeId,
      Value<int?> sparepartId,
      required String action,
      Value<int> partsCost,
      Value<int> laborCost,
      Value<int> totalCost,
      Value<String?> notes,
    });
typedef $$ServiceItemsTableUpdateCompanionBuilder =
    ServiceItemsCompanion Function({
      Value<int> id,
      Value<int> serviceRecordId,
      Value<int?> componentTypeId,
      Value<int?> sparepartId,
      Value<String> action,
      Value<int> partsCost,
      Value<int> laborCost,
      Value<int> totalCost,
      Value<String?> notes,
    });

final class $$ServiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ServiceItemsTable, ServiceItem> {
  $$ServiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ServiceRecordsTable _serviceRecordIdTable(_$AppDatabase db) =>
      db.serviceRecords.createAlias(
        $_aliasNameGenerator(
          db.serviceItems.serviceRecordId,
          db.serviceRecords.id,
        ),
      );

  $$ServiceRecordsTableProcessedTableManager get serviceRecordId {
    final $_column = $_itemColumn<int>('service_record_id')!;

    final manager = $$ServiceRecordsTableTableManager(
      $_db,
      $_db.serviceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ComponentTypesTable _componentTypeIdTable(_$AppDatabase db) =>
      db.componentTypes.createAlias(
        $_aliasNameGenerator(
          db.serviceItems.componentTypeId,
          db.componentTypes.id,
        ),
      );

  $$ComponentTypesTableProcessedTableManager? get componentTypeId {
    final $_column = $_itemColumn<int>('component_type_id');
    if ($_column == null) return null;
    final manager = $$ComponentTypesTableTableManager(
      $_db,
      $_db.componentTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_componentTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ServiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sparepartId => $composableBuilder(
    column: $table.sparepartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partsCost => $composableBuilder(
    column: $table.partsCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ServiceRecordsTableFilterComposer get serviceRecordId {
    final $$ServiceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRecordId,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableFilterComposer get componentTypeId {
    final $$ComponentTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableFilterComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sparepartId => $composableBuilder(
    column: $table.sparepartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partsCost => $composableBuilder(
    column: $table.partsCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServiceRecordsTableOrderingComposer get serviceRecordId {
    final $$ServiceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRecordId,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableOrderingComposer get componentTypeId {
    final $$ComponentTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableOrderingComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sparepartId => $composableBuilder(
    column: $table.sparepartId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get partsCost =>
      $composableBuilder(column: $table.partsCost, builder: (column) => column);

  GeneratedColumn<int> get laborCost =>
      $composableBuilder(column: $table.laborCost, builder: (column) => column);

  GeneratedColumn<int> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ServiceRecordsTableAnnotationComposer get serviceRecordId {
    final $$ServiceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRecordId,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableAnnotationComposer get componentTypeId {
    final $$ComponentTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceItemsTable,
          ServiceItem,
          $$ServiceItemsTableFilterComposer,
          $$ServiceItemsTableOrderingComposer,
          $$ServiceItemsTableAnnotationComposer,
          $$ServiceItemsTableCreateCompanionBuilder,
          $$ServiceItemsTableUpdateCompanionBuilder,
          (ServiceItem, $$ServiceItemsTableReferences),
          ServiceItem,
          PrefetchHooks Function({bool serviceRecordId, bool componentTypeId})
        > {
  $$ServiceItemsTableTableManager(_$AppDatabase db, $ServiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> serviceRecordId = const Value.absent(),
                Value<int?> componentTypeId = const Value.absent(),
                Value<int?> sparepartId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int> partsCost = const Value.absent(),
                Value<int> laborCost = const Value.absent(),
                Value<int> totalCost = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ServiceItemsCompanion(
                id: id,
                serviceRecordId: serviceRecordId,
                componentTypeId: componentTypeId,
                sparepartId: sparepartId,
                action: action,
                partsCost: partsCost,
                laborCost: laborCost,
                totalCost: totalCost,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int serviceRecordId,
                Value<int?> componentTypeId = const Value.absent(),
                Value<int?> sparepartId = const Value.absent(),
                required String action,
                Value<int> partsCost = const Value.absent(),
                Value<int> laborCost = const Value.absent(),
                Value<int> totalCost = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ServiceItemsCompanion.insert(
                id: id,
                serviceRecordId: serviceRecordId,
                componentTypeId: componentTypeId,
                sparepartId: sparepartId,
                action: action,
                partsCost: partsCost,
                laborCost: laborCost,
                totalCost: totalCost,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({serviceRecordId = false, componentTypeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (serviceRecordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.serviceRecordId,
                                    referencedTable:
                                        $$ServiceItemsTableReferences
                                            ._serviceRecordIdTable(db),
                                    referencedColumn:
                                        $$ServiceItemsTableReferences
                                            ._serviceRecordIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (componentTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.componentTypeId,
                                    referencedTable:
                                        $$ServiceItemsTableReferences
                                            ._componentTypeIdTable(db),
                                    referencedColumn:
                                        $$ServiceItemsTableReferences
                                            ._componentTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ServiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceItemsTable,
      ServiceItem,
      $$ServiceItemsTableFilterComposer,
      $$ServiceItemsTableOrderingComposer,
      $$ServiceItemsTableAnnotationComposer,
      $$ServiceItemsTableCreateCompanionBuilder,
      $$ServiceItemsTableUpdateCompanionBuilder,
      (ServiceItem, $$ServiceItemsTableReferences),
      ServiceItem,
      PrefetchHooks Function({bool serviceRecordId, bool componentTypeId})
    >;
typedef $$SelfInspectionsTableCreateCompanionBuilder =
    SelfInspectionsCompanion Function({
      Value<int> id,
      required int motorcycleId,
      Value<DateTime> inspectedAt,
      Value<String?> notes,
      Value<String?> riskLevel,
      Value<String> status,
    });
typedef $$SelfInspectionsTableUpdateCompanionBuilder =
    SelfInspectionsCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<DateTime> inspectedAt,
      Value<String?> notes,
      Value<String?> riskLevel,
      Value<String> status,
    });

final class $$SelfInspectionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SelfInspectionsTable, SelfInspection> {
  $$SelfInspectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(
          db.selfInspections.motorcycleId,
          db.motorcycles.id,
        ),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InspectionAnswersTable, List<InspectionAnswer>>
  _inspectionAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inspectionAnswers,
        aliasName: $_aliasNameGenerator(
          db.selfInspections.id,
          db.inspectionAnswers.inspectionId,
        ),
      );

  $$InspectionAnswersTableProcessedTableManager get inspectionAnswersRefs {
    final manager = $$InspectionAnswersTableTableManager(
      $_db,
      $_db.inspectionAnswers,
    ).filter((f) => f.inspectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inspectionAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>>
  _complaintsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.complaints,
    aliasName: $_aliasNameGenerator(
      db.selfInspections.id,
      db.complaints.inspectionId,
    ),
  );

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.inspectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SelfInspectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SelfInspectionsTable> {
  $$SelfInspectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> inspectionAnswersRefs(
    Expression<bool> Function($$InspectionAnswersTableFilterComposer f) f,
  ) {
    final $$InspectionAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inspectionAnswers,
      getReferencedColumn: (t) => t.inspectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InspectionAnswersTableFilterComposer(
            $db: $db,
            $table: $db.inspectionAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintsRefs(
    Expression<bool> Function($$ComplaintsTableFilterComposer f) f,
  ) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.inspectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SelfInspectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SelfInspectionsTable> {
  $$SelfInspectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelfInspectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SelfInspectionsTable> {
  $$SelfInspectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> inspectionAnswersRefs<T extends Object>(
    Expression<T> Function($$InspectionAnswersTableAnnotationComposer a) f,
  ) {
    final $$InspectionAnswersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inspectionAnswers,
          getReferencedColumn: (t) => t.inspectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InspectionAnswersTableAnnotationComposer(
                $db: $db,
                $table: $db.inspectionAnswers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> complaintsRefs<T extends Object>(
    Expression<T> Function($$ComplaintsTableAnnotationComposer a) f,
  ) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.inspectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SelfInspectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SelfInspectionsTable,
          SelfInspection,
          $$SelfInspectionsTableFilterComposer,
          $$SelfInspectionsTableOrderingComposer,
          $$SelfInspectionsTableAnnotationComposer,
          $$SelfInspectionsTableCreateCompanionBuilder,
          $$SelfInspectionsTableUpdateCompanionBuilder,
          (SelfInspection, $$SelfInspectionsTableReferences),
          SelfInspection,
          PrefetchHooks Function({
            bool motorcycleId,
            bool inspectionAnswersRefs,
            bool complaintsRefs,
          })
        > {
  $$SelfInspectionsTableTableManager(
    _$AppDatabase db,
    $SelfInspectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SelfInspectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SelfInspectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SelfInspectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<DateTime> inspectedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> riskLevel = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SelfInspectionsCompanion(
                id: id,
                motorcycleId: motorcycleId,
                inspectedAt: inspectedAt,
                notes: notes,
                riskLevel: riskLevel,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                Value<DateTime> inspectedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> riskLevel = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SelfInspectionsCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                inspectedAt: inspectedAt,
                notes: notes,
                riskLevel: riskLevel,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SelfInspectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                motorcycleId = false,
                inspectionAnswersRefs = false,
                complaintsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inspectionAnswersRefs) db.inspectionAnswers,
                    if (complaintsRefs) db.complaints,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (motorcycleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motorcycleId,
                                    referencedTable:
                                        $$SelfInspectionsTableReferences
                                            ._motorcycleIdTable(db),
                                    referencedColumn:
                                        $$SelfInspectionsTableReferences
                                            ._motorcycleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inspectionAnswersRefs)
                        await $_getPrefetchedData<
                          SelfInspection,
                          $SelfInspectionsTable,
                          InspectionAnswer
                        >(
                          currentTable: table,
                          referencedTable: $$SelfInspectionsTableReferences
                              ._inspectionAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SelfInspectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).inspectionAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inspectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (complaintsRefs)
                        await $_getPrefetchedData<
                          SelfInspection,
                          $SelfInspectionsTable,
                          Complaint
                        >(
                          currentTable: table,
                          referencedTable: $$SelfInspectionsTableReferences
                              ._complaintsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SelfInspectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inspectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SelfInspectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SelfInspectionsTable,
      SelfInspection,
      $$SelfInspectionsTableFilterComposer,
      $$SelfInspectionsTableOrderingComposer,
      $$SelfInspectionsTableAnnotationComposer,
      $$SelfInspectionsTableCreateCompanionBuilder,
      $$SelfInspectionsTableUpdateCompanionBuilder,
      (SelfInspection, $$SelfInspectionsTableReferences),
      SelfInspection,
      PrefetchHooks Function({
        bool motorcycleId,
        bool inspectionAnswersRefs,
        bool complaintsRefs,
      })
    >;
typedef $$InspectionAnswersTableCreateCompanionBuilder =
    InspectionAnswersCompanion Function({
      Value<int> id,
      required int inspectionId,
      required String questionCode,
      required String answer,
      Value<String?> answerType,
      Value<bool> riskFlag,
    });
typedef $$InspectionAnswersTableUpdateCompanionBuilder =
    InspectionAnswersCompanion Function({
      Value<int> id,
      Value<int> inspectionId,
      Value<String> questionCode,
      Value<String> answer,
      Value<String?> answerType,
      Value<bool> riskFlag,
    });

final class $$InspectionAnswersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InspectionAnswersTable,
          InspectionAnswer
        > {
  $$InspectionAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SelfInspectionsTable _inspectionIdTable(_$AppDatabase db) =>
      db.selfInspections.createAlias(
        $_aliasNameGenerator(
          db.inspectionAnswers.inspectionId,
          db.selfInspections.id,
        ),
      );

  $$SelfInspectionsTableProcessedTableManager get inspectionId {
    final $_column = $_itemColumn<int>('inspection_id')!;

    final manager = $$SelfInspectionsTableTableManager(
      $_db,
      $_db.selfInspections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inspectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InspectionAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $InspectionAnswersTable> {
  $$InspectionAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionCode => $composableBuilder(
    column: $table.questionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerType => $composableBuilder(
    column: $table.answerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get riskFlag => $composableBuilder(
    column: $table.riskFlag,
    builder: (column) => ColumnFilters(column),
  );

  $$SelfInspectionsTableFilterComposer get inspectionId {
    final $$SelfInspectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inspectionId,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableFilterComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InspectionAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $InspectionAnswersTable> {
  $$InspectionAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionCode => $composableBuilder(
    column: $table.questionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerType => $composableBuilder(
    column: $table.answerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get riskFlag => $composableBuilder(
    column: $table.riskFlag,
    builder: (column) => ColumnOrderings(column),
  );

  $$SelfInspectionsTableOrderingComposer get inspectionId {
    final $$SelfInspectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inspectionId,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableOrderingComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InspectionAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $InspectionAnswersTable> {
  $$InspectionAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionCode => $composableBuilder(
    column: $table.questionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<String> get answerType => $composableBuilder(
    column: $table.answerType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get riskFlag =>
      $composableBuilder(column: $table.riskFlag, builder: (column) => column);

  $$SelfInspectionsTableAnnotationComposer get inspectionId {
    final $$SelfInspectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inspectionId,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InspectionAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InspectionAnswersTable,
          InspectionAnswer,
          $$InspectionAnswersTableFilterComposer,
          $$InspectionAnswersTableOrderingComposer,
          $$InspectionAnswersTableAnnotationComposer,
          $$InspectionAnswersTableCreateCompanionBuilder,
          $$InspectionAnswersTableUpdateCompanionBuilder,
          (InspectionAnswer, $$InspectionAnswersTableReferences),
          InspectionAnswer,
          PrefetchHooks Function({bool inspectionId})
        > {
  $$InspectionAnswersTableTableManager(
    _$AppDatabase db,
    $InspectionAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InspectionAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InspectionAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InspectionAnswersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> inspectionId = const Value.absent(),
                Value<String> questionCode = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<String?> answerType = const Value.absent(),
                Value<bool> riskFlag = const Value.absent(),
              }) => InspectionAnswersCompanion(
                id: id,
                inspectionId: inspectionId,
                questionCode: questionCode,
                answer: answer,
                answerType: answerType,
                riskFlag: riskFlag,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int inspectionId,
                required String questionCode,
                required String answer,
                Value<String?> answerType = const Value.absent(),
                Value<bool> riskFlag = const Value.absent(),
              }) => InspectionAnswersCompanion.insert(
                id: id,
                inspectionId: inspectionId,
                questionCode: questionCode,
                answer: answer,
                answerType: answerType,
                riskFlag: riskFlag,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InspectionAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({inspectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (inspectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.inspectionId,
                                referencedTable:
                                    $$InspectionAnswersTableReferences
                                        ._inspectionIdTable(db),
                                referencedColumn:
                                    $$InspectionAnswersTableReferences
                                        ._inspectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InspectionAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InspectionAnswersTable,
      InspectionAnswer,
      $$InspectionAnswersTableFilterComposer,
      $$InspectionAnswersTableOrderingComposer,
      $$InspectionAnswersTableAnnotationComposer,
      $$InspectionAnswersTableCreateCompanionBuilder,
      $$InspectionAnswersTableUpdateCompanionBuilder,
      (InspectionAnswer, $$InspectionAnswersTableReferences),
      InspectionAnswer,
      PrefetchHooks Function({bool inspectionId})
    >;
typedef $$ComplaintsTableCreateCompanionBuilder =
    ComplaintsCompanion Function({
      Value<int> id,
      required int motorcycleId,
      Value<int?> inspectionId,
      Value<int?> resolvedByServiceId,
      required String title,
      required String description,
      Value<String> status,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<double?> odometerKm,
      Value<DateTime> updatedAt,
    });
typedef $$ComplaintsTableUpdateCompanionBuilder =
    ComplaintsCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<int?> inspectionId,
      Value<int?> resolvedByServiceId,
      Value<String> title,
      Value<String> description,
      Value<String> status,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<double?> odometerKm,
      Value<DateTime> updatedAt,
    });

final class $$ComplaintsTableReferences
    extends BaseReferences<_$AppDatabase, $ComplaintsTable, Complaint> {
  $$ComplaintsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(db.complaints.motorcycleId, db.motorcycles.id),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SelfInspectionsTable _inspectionIdTable(_$AppDatabase db) =>
      db.selfInspections.createAlias(
        $_aliasNameGenerator(db.complaints.inspectionId, db.selfInspections.id),
      );

  $$SelfInspectionsTableProcessedTableManager? get inspectionId {
    final $_column = $_itemColumn<int>('inspection_id');
    if ($_column == null) return null;
    final manager = $$SelfInspectionsTableTableManager(
      $_db,
      $_db.selfInspections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inspectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ServiceRecordsTable _resolvedByServiceIdTable(_$AppDatabase db) =>
      db.serviceRecords.createAlias(
        $_aliasNameGenerator(
          db.complaints.resolvedByServiceId,
          db.serviceRecords.id,
        ),
      );

  $$ServiceRecordsTableProcessedTableManager? get resolvedByServiceId {
    final $_column = $_itemColumn<int>('resolved_by_service_id');
    if ($_column == null) return null;
    final manager = $$ServiceRecordsTableTableManager(
      $_db,
      $_db.serviceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resolvedByServiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ComplaintMessagesTable, List<ComplaintMessage>>
  _complaintMessagesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.complaintMessages,
        aliasName: $_aliasNameGenerator(
          db.complaints.id,
          db.complaintMessages.complaintId,
        ),
      );

  $$ComplaintMessagesTableProcessedTableManager get complaintMessagesRefs {
    final manager = $$ComplaintMessagesTableTableManager(
      $_db,
      $_db.complaintMessages,
    ).filter((f) => f.complaintId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _complaintMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComplaintAnalysesTable, List<ComplaintAnalysis>>
  _complaintAnalysesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.complaintAnalyses,
        aliasName: $_aliasNameGenerator(
          db.complaints.id,
          db.complaintAnalyses.complaintId,
        ),
      );

  $$ComplaintAnalysesTableProcessedTableManager get complaintAnalysesRefs {
    final manager = $$ComplaintAnalysesTableTableManager(
      $_db,
      $_db.complaintAnalyses,
    ).filter((f) => f.complaintId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _complaintAnalysesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComplaintsTableFilterComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SelfInspectionsTableFilterComposer get inspectionId {
    final $$SelfInspectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inspectionId,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableFilterComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServiceRecordsTableFilterComposer get resolvedByServiceId {
    final $$ServiceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resolvedByServiceId,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> complaintMessagesRefs(
    Expression<bool> Function($$ComplaintMessagesTableFilterComposer f) f,
  ) {
    final $$ComplaintMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaintMessages,
      getReferencedColumn: (t) => t.complaintId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintMessagesTableFilterComposer(
            $db: $db,
            $table: $db.complaintMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintAnalysesRefs(
    Expression<bool> Function($$ComplaintAnalysesTableFilterComposer f) f,
  ) {
    final $$ComplaintAnalysesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaintAnalyses,
      getReferencedColumn: (t) => t.complaintId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintAnalysesTableFilterComposer(
            $db: $db,
            $table: $db.complaintAnalyses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComplaintsTableOrderingComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SelfInspectionsTableOrderingComposer get inspectionId {
    final $$SelfInspectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inspectionId,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableOrderingComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServiceRecordsTableOrderingComposer get resolvedByServiceId {
    final $$ServiceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resolvedByServiceId,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SelfInspectionsTableAnnotationComposer get inspectionId {
    final $$SelfInspectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inspectionId,
      referencedTable: $db.selfInspections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelfInspectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.selfInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServiceRecordsTableAnnotationComposer get resolvedByServiceId {
    final $$ServiceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resolvedByServiceId,
      referencedTable: $db.serviceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> complaintMessagesRefs<T extends Object>(
    Expression<T> Function($$ComplaintMessagesTableAnnotationComposer a) f,
  ) {
    final $$ComplaintMessagesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.complaintMessages,
          getReferencedColumn: (t) => t.complaintId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComplaintMessagesTableAnnotationComposer(
                $db: $db,
                $table: $db.complaintMessages,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> complaintAnalysesRefs<T extends Object>(
    Expression<T> Function($$ComplaintAnalysesTableAnnotationComposer a) f,
  ) {
    final $$ComplaintAnalysesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.complaintAnalyses,
          getReferencedColumn: (t) => t.complaintId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComplaintAnalysesTableAnnotationComposer(
                $db: $db,
                $table: $db.complaintAnalyses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ComplaintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplaintsTable,
          Complaint,
          $$ComplaintsTableFilterComposer,
          $$ComplaintsTableOrderingComposer,
          $$ComplaintsTableAnnotationComposer,
          $$ComplaintsTableCreateCompanionBuilder,
          $$ComplaintsTableUpdateCompanionBuilder,
          (Complaint, $$ComplaintsTableReferences),
          Complaint,
          PrefetchHooks Function({
            bool motorcycleId,
            bool inspectionId,
            bool resolvedByServiceId,
            bool complaintMessagesRefs,
            bool complaintAnalysesRefs,
          })
        > {
  $$ComplaintsTableTableManager(_$AppDatabase db, $ComplaintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComplaintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComplaintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComplaintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<int?> inspectionId = const Value.absent(),
                Value<int?> resolvedByServiceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<double?> odometerKm = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ComplaintsCompanion(
                id: id,
                motorcycleId: motorcycleId,
                inspectionId: inspectionId,
                resolvedByServiceId: resolvedByServiceId,
                title: title,
                description: description,
                status: status,
                openedAt: openedAt,
                closedAt: closedAt,
                odometerKm: odometerKm,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                Value<int?> inspectionId = const Value.absent(),
                Value<int?> resolvedByServiceId = const Value.absent(),
                required String title,
                required String description,
                Value<String> status = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<double?> odometerKm = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ComplaintsCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                inspectionId: inspectionId,
                resolvedByServiceId: resolvedByServiceId,
                title: title,
                description: description,
                status: status,
                openedAt: openedAt,
                closedAt: closedAt,
                odometerKm: odometerKm,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComplaintsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                motorcycleId = false,
                inspectionId = false,
                resolvedByServiceId = false,
                complaintMessagesRefs = false,
                complaintAnalysesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (complaintMessagesRefs) db.complaintMessages,
                    if (complaintAnalysesRefs) db.complaintAnalyses,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (motorcycleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motorcycleId,
                                    referencedTable: $$ComplaintsTableReferences
                                        ._motorcycleIdTable(db),
                                    referencedColumn:
                                        $$ComplaintsTableReferences
                                            ._motorcycleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (inspectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.inspectionId,
                                    referencedTable: $$ComplaintsTableReferences
                                        ._inspectionIdTable(db),
                                    referencedColumn:
                                        $$ComplaintsTableReferences
                                            ._inspectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (resolvedByServiceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.resolvedByServiceId,
                                    referencedTable: $$ComplaintsTableReferences
                                        ._resolvedByServiceIdTable(db),
                                    referencedColumn:
                                        $$ComplaintsTableReferences
                                            ._resolvedByServiceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (complaintMessagesRefs)
                        await $_getPrefetchedData<
                          Complaint,
                          $ComplaintsTable,
                          ComplaintMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ComplaintsTableReferences
                              ._complaintMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComplaintsTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.complaintId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (complaintAnalysesRefs)
                        await $_getPrefetchedData<
                          Complaint,
                          $ComplaintsTable,
                          ComplaintAnalysis
                        >(
                          currentTable: table,
                          referencedTable: $$ComplaintsTableReferences
                              ._complaintAnalysesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComplaintsTableReferences(
                                db,
                                table,
                                p0,
                              ).complaintAnalysesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.complaintId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComplaintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplaintsTable,
      Complaint,
      $$ComplaintsTableFilterComposer,
      $$ComplaintsTableOrderingComposer,
      $$ComplaintsTableAnnotationComposer,
      $$ComplaintsTableCreateCompanionBuilder,
      $$ComplaintsTableUpdateCompanionBuilder,
      (Complaint, $$ComplaintsTableReferences),
      Complaint,
      PrefetchHooks Function({
        bool motorcycleId,
        bool inspectionId,
        bool resolvedByServiceId,
        bool complaintMessagesRefs,
        bool complaintAnalysesRefs,
      })
    >;
typedef $$ComplaintMessagesTableCreateCompanionBuilder =
    ComplaintMessagesCompanion Function({
      Value<int> id,
      required int complaintId,
      required String role,
      required String content,
      Value<DateTime> createdAt,
      Value<String?> analysisMode,
    });
typedef $$ComplaintMessagesTableUpdateCompanionBuilder =
    ComplaintMessagesCompanion Function({
      Value<int> id,
      Value<int> complaintId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<String?> analysisMode,
    });

final class $$ComplaintMessagesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ComplaintMessagesTable,
          ComplaintMessage
        > {
  $$ComplaintMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ComplaintsTable _complaintIdTable(_$AppDatabase db) =>
      db.complaints.createAlias(
        $_aliasNameGenerator(
          db.complaintMessages.complaintId,
          db.complaints.id,
        ),
      );

  $$ComplaintsTableProcessedTableManager get complaintId {
    final $_column = $_itemColumn<int>('complaint_id')!;

    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_complaintIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComplaintMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ComplaintMessagesTable> {
  $$ComplaintMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisMode => $composableBuilder(
    column: $table.analysisMode,
    builder: (column) => ColumnFilters(column),
  );

  $$ComplaintsTableFilterComposer get complaintId {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ComplaintMessagesTable> {
  $$ComplaintMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisMode => $composableBuilder(
    column: $table.analysisMode,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComplaintsTableOrderingComposer get complaintId {
    final $$ComplaintsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableOrderingComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComplaintMessagesTable> {
  $$ComplaintMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get analysisMode => $composableBuilder(
    column: $table.analysisMode,
    builder: (column) => column,
  );

  $$ComplaintsTableAnnotationComposer get complaintId {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplaintMessagesTable,
          ComplaintMessage,
          $$ComplaintMessagesTableFilterComposer,
          $$ComplaintMessagesTableOrderingComposer,
          $$ComplaintMessagesTableAnnotationComposer,
          $$ComplaintMessagesTableCreateCompanionBuilder,
          $$ComplaintMessagesTableUpdateCompanionBuilder,
          (ComplaintMessage, $$ComplaintMessagesTableReferences),
          ComplaintMessage,
          PrefetchHooks Function({bool complaintId})
        > {
  $$ComplaintMessagesTableTableManager(
    _$AppDatabase db,
    $ComplaintMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComplaintMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComplaintMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComplaintMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> complaintId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> analysisMode = const Value.absent(),
              }) => ComplaintMessagesCompanion(
                id: id,
                complaintId: complaintId,
                role: role,
                content: content,
                createdAt: createdAt,
                analysisMode: analysisMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int complaintId,
                required String role,
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> analysisMode = const Value.absent(),
              }) => ComplaintMessagesCompanion.insert(
                id: id,
                complaintId: complaintId,
                role: role,
                content: content,
                createdAt: createdAt,
                analysisMode: analysisMode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComplaintMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({complaintId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (complaintId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.complaintId,
                                referencedTable:
                                    $$ComplaintMessagesTableReferences
                                        ._complaintIdTable(db),
                                referencedColumn:
                                    $$ComplaintMessagesTableReferences
                                        ._complaintIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComplaintMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplaintMessagesTable,
      ComplaintMessage,
      $$ComplaintMessagesTableFilterComposer,
      $$ComplaintMessagesTableOrderingComposer,
      $$ComplaintMessagesTableAnnotationComposer,
      $$ComplaintMessagesTableCreateCompanionBuilder,
      $$ComplaintMessagesTableUpdateCompanionBuilder,
      (ComplaintMessage, $$ComplaintMessagesTableReferences),
      ComplaintMessage,
      PrefetchHooks Function({bool complaintId})
    >;
typedef $$ComplaintAnalysesTableCreateCompanionBuilder =
    ComplaintAnalysesCompanion Function({
      Value<int> id,
      required int complaintId,
      required String symptomsJson,
      Value<String?> componentCandidatesJson,
      Value<String?> followUpJson,
      Value<String?> historicalMatchesJson,
      required String riskLevel,
      required String summary,
      Value<String?> modelVersion,
      required String analysisMode,
      Value<DateTime> analyzedAt,
    });
typedef $$ComplaintAnalysesTableUpdateCompanionBuilder =
    ComplaintAnalysesCompanion Function({
      Value<int> id,
      Value<int> complaintId,
      Value<String> symptomsJson,
      Value<String?> componentCandidatesJson,
      Value<String?> followUpJson,
      Value<String?> historicalMatchesJson,
      Value<String> riskLevel,
      Value<String> summary,
      Value<String?> modelVersion,
      Value<String> analysisMode,
      Value<DateTime> analyzedAt,
    });

final class $$ComplaintAnalysesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ComplaintAnalysesTable,
          ComplaintAnalysis
        > {
  $$ComplaintAnalysesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ComplaintsTable _complaintIdTable(_$AppDatabase db) =>
      db.complaints.createAlias(
        $_aliasNameGenerator(
          db.complaintAnalyses.complaintId,
          db.complaints.id,
        ),
      );

  $$ComplaintsTableProcessedTableManager get complaintId {
    final $_column = $_itemColumn<int>('complaint_id')!;

    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_complaintIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComplaintAnalysesTableFilterComposer
    extends Composer<_$AppDatabase, $ComplaintAnalysesTable> {
  $$ComplaintAnalysesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentCandidatesJson => $composableBuilder(
    column: $table.componentCandidatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followUpJson => $composableBuilder(
    column: $table.followUpJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get historicalMatchesJson => $composableBuilder(
    column: $table.historicalMatchesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisMode => $composableBuilder(
    column: $table.analysisMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ComplaintsTableFilterComposer get complaintId {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintAnalysesTableOrderingComposer
    extends Composer<_$AppDatabase, $ComplaintAnalysesTable> {
  $$ComplaintAnalysesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentCandidatesJson => $composableBuilder(
    column: $table.componentCandidatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followUpJson => $composableBuilder(
    column: $table.followUpJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get historicalMatchesJson => $composableBuilder(
    column: $table.historicalMatchesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisMode => $composableBuilder(
    column: $table.analysisMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComplaintsTableOrderingComposer get complaintId {
    final $$ComplaintsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableOrderingComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintAnalysesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComplaintAnalysesTable> {
  $$ComplaintAnalysesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get componentCandidatesJson => $composableBuilder(
    column: $table.componentCandidatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get followUpJson => $composableBuilder(
    column: $table.followUpJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get historicalMatchesJson => $composableBuilder(
    column: $table.historicalMatchesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisMode => $composableBuilder(
    column: $table.analysisMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

  $$ComplaintsTableAnnotationComposer get complaintId {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintAnalysesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplaintAnalysesTable,
          ComplaintAnalysis,
          $$ComplaintAnalysesTableFilterComposer,
          $$ComplaintAnalysesTableOrderingComposer,
          $$ComplaintAnalysesTableAnnotationComposer,
          $$ComplaintAnalysesTableCreateCompanionBuilder,
          $$ComplaintAnalysesTableUpdateCompanionBuilder,
          (ComplaintAnalysis, $$ComplaintAnalysesTableReferences),
          ComplaintAnalysis,
          PrefetchHooks Function({bool complaintId})
        > {
  $$ComplaintAnalysesTableTableManager(
    _$AppDatabase db,
    $ComplaintAnalysesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComplaintAnalysesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComplaintAnalysesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComplaintAnalysesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> complaintId = const Value.absent(),
                Value<String> symptomsJson = const Value.absent(),
                Value<String?> componentCandidatesJson = const Value.absent(),
                Value<String?> followUpJson = const Value.absent(),
                Value<String?> historicalMatchesJson = const Value.absent(),
                Value<String> riskLevel = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<String> analysisMode = const Value.absent(),
                Value<DateTime> analyzedAt = const Value.absent(),
              }) => ComplaintAnalysesCompanion(
                id: id,
                complaintId: complaintId,
                symptomsJson: symptomsJson,
                componentCandidatesJson: componentCandidatesJson,
                followUpJson: followUpJson,
                historicalMatchesJson: historicalMatchesJson,
                riskLevel: riskLevel,
                summary: summary,
                modelVersion: modelVersion,
                analysisMode: analysisMode,
                analyzedAt: analyzedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int complaintId,
                required String symptomsJson,
                Value<String?> componentCandidatesJson = const Value.absent(),
                Value<String?> followUpJson = const Value.absent(),
                Value<String?> historicalMatchesJson = const Value.absent(),
                required String riskLevel,
                required String summary,
                Value<String?> modelVersion = const Value.absent(),
                required String analysisMode,
                Value<DateTime> analyzedAt = const Value.absent(),
              }) => ComplaintAnalysesCompanion.insert(
                id: id,
                complaintId: complaintId,
                symptomsJson: symptomsJson,
                componentCandidatesJson: componentCandidatesJson,
                followUpJson: followUpJson,
                historicalMatchesJson: historicalMatchesJson,
                riskLevel: riskLevel,
                summary: summary,
                modelVersion: modelVersion,
                analysisMode: analysisMode,
                analyzedAt: analyzedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComplaintAnalysesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({complaintId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (complaintId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.complaintId,
                                referencedTable:
                                    $$ComplaintAnalysesTableReferences
                                        ._complaintIdTable(db),
                                referencedColumn:
                                    $$ComplaintAnalysesTableReferences
                                        ._complaintIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComplaintAnalysesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplaintAnalysesTable,
      ComplaintAnalysis,
      $$ComplaintAnalysesTableFilterComposer,
      $$ComplaintAnalysesTableOrderingComposer,
      $$ComplaintAnalysesTableAnnotationComposer,
      $$ComplaintAnalysesTableCreateCompanionBuilder,
      $$ComplaintAnalysesTableUpdateCompanionBuilder,
      (ComplaintAnalysis, $$ComplaintAnalysesTableReferences),
      ComplaintAnalysis,
      PrefetchHooks Function({bool complaintId})
    >;
typedef $$CatalogSourcesTableCreateCompanionBuilder =
    CatalogSourcesCompanion Function({
      Value<int> id,
      required String providerName,
      required String websiteUrl,
      Value<String?> licenseOrPermission,
      Value<DateTime?> verifiedAt,
      Value<DateTime?> lastCheckedAt,
    });
typedef $$CatalogSourcesTableUpdateCompanionBuilder =
    CatalogSourcesCompanion Function({
      Value<int> id,
      Value<String> providerName,
      Value<String> websiteUrl,
      Value<String?> licenseOrPermission,
      Value<DateTime?> verifiedAt,
      Value<DateTime?> lastCheckedAt,
    });

final class $$CatalogSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogSourcesTable, CatalogSource> {
  $$CatalogSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SparepartsTable, List<Sparepart>>
  _sparepartsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.spareparts,
    aliasName: $_aliasNameGenerator(
      db.catalogSources.id,
      db.spareparts.sourceId,
    ),
  );

  $$SparepartsTableProcessedTableManager get sparepartsRefs {
    final manager = $$SparepartsTableTableManager(
      $_db,
      $_db.spareparts,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sparepartsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogSourcesTable> {
  $$CatalogSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseOrPermission => $composableBuilder(
    column: $table.licenseOrPermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sparepartsRefs(
    Expression<bool> Function($$SparepartsTableFilterComposer f) f,
  ) {
    final $$SparepartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spareparts,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartsTableFilterComposer(
            $db: $db,
            $table: $db.spareparts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogSourcesTable> {
  $$CatalogSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseOrPermission => $composableBuilder(
    column: $table.licenseOrPermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogSourcesTable> {
  $$CatalogSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseOrPermission => $composableBuilder(
    column: $table.licenseOrPermission,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  Expression<T> sparepartsRefs<T extends Object>(
    Expression<T> Function($$SparepartsTableAnnotationComposer a) f,
  ) {
    final $$SparepartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spareparts,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartsTableAnnotationComposer(
            $db: $db,
            $table: $db.spareparts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogSourcesTable,
          CatalogSource,
          $$CatalogSourcesTableFilterComposer,
          $$CatalogSourcesTableOrderingComposer,
          $$CatalogSourcesTableAnnotationComposer,
          $$CatalogSourcesTableCreateCompanionBuilder,
          $$CatalogSourcesTableUpdateCompanionBuilder,
          (CatalogSource, $$CatalogSourcesTableReferences),
          CatalogSource,
          PrefetchHooks Function({bool sparepartsRefs})
        > {
  $$CatalogSourcesTableTableManager(
    _$AppDatabase db,
    $CatalogSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerName = const Value.absent(),
                Value<String> websiteUrl = const Value.absent(),
                Value<String?> licenseOrPermission = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
              }) => CatalogSourcesCompanion(
                id: id,
                providerName: providerName,
                websiteUrl: websiteUrl,
                licenseOrPermission: licenseOrPermission,
                verifiedAt: verifiedAt,
                lastCheckedAt: lastCheckedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerName,
                required String websiteUrl,
                Value<String?> licenseOrPermission = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
              }) => CatalogSourcesCompanion.insert(
                id: id,
                providerName: providerName,
                websiteUrl: websiteUrl,
                licenseOrPermission: licenseOrPermission,
                verifiedAt: verifiedAt,
                lastCheckedAt: lastCheckedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CatalogSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sparepartsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sparepartsRefs) db.spareparts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sparepartsRefs)
                    await $_getPrefetchedData<
                      CatalogSource,
                      $CatalogSourcesTable,
                      Sparepart
                    >(
                      currentTable: table,
                      referencedTable: $$CatalogSourcesTableReferences
                          ._sparepartsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CatalogSourcesTableReferences(
                            db,
                            table,
                            p0,
                          ).sparepartsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sourceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CatalogSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogSourcesTable,
      CatalogSource,
      $$CatalogSourcesTableFilterComposer,
      $$CatalogSourcesTableOrderingComposer,
      $$CatalogSourcesTableAnnotationComposer,
      $$CatalogSourcesTableCreateCompanionBuilder,
      $$CatalogSourcesTableUpdateCompanionBuilder,
      (CatalogSource, $$CatalogSourcesTableReferences),
      CatalogSource,
      PrefetchHooks Function({bool sparepartsRefs})
    >;
typedef $$SparepartsTableCreateCompanionBuilder =
    SparepartsCompanion Function({
      Value<int> id,
      Value<int?> sourceId,
      Value<String?> partNumber,
      required String name,
      Value<String?> brand,
      required String category,
      Value<int?> referencePrice,
      Value<String?> productUrl,
      Value<DateTime?> priceUpdatedAt,
      Value<String?> catalogVersion,
      Value<bool> isVerified,
    });
typedef $$SparepartsTableUpdateCompanionBuilder =
    SparepartsCompanion Function({
      Value<int> id,
      Value<int?> sourceId,
      Value<String?> partNumber,
      Value<String> name,
      Value<String?> brand,
      Value<String> category,
      Value<int?> referencePrice,
      Value<String?> productUrl,
      Value<DateTime?> priceUpdatedAt,
      Value<String?> catalogVersion,
      Value<bool> isVerified,
    });

final class $$SparepartsTableReferences
    extends BaseReferences<_$AppDatabase, $SparepartsTable, Sparepart> {
  $$SparepartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogSourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.catalogSources.createAlias(
        $_aliasNameGenerator(db.spareparts.sourceId, db.catalogSources.id),
      );

  $$CatalogSourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<int>('source_id');
    if ($_column == null) return null;
    final manager = $$CatalogSourcesTableTableManager(
      $_db,
      $_db.catalogSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SparepartFitmentsTable, List<SparepartFitment>>
  _sparepartFitmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sparepartFitments,
        aliasName: $_aliasNameGenerator(
          db.spareparts.id,
          db.sparepartFitments.sparepartId,
        ),
      );

  $$SparepartFitmentsTableProcessedTableManager get sparepartFitmentsRefs {
    final manager = $$SparepartFitmentsTableTableManager(
      $_db,
      $_db.sparepartFitments,
    ).filter((f) => f.sparepartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sparepartFitmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SparepartsTableFilterComposer
    extends Composer<_$AppDatabase, $SparepartsTable> {
  $$SparepartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referencePrice => $composableBuilder(
    column: $table.referencePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productUrl => $composableBuilder(
    column: $table.productUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get priceUpdatedAt => $composableBuilder(
    column: $table.priceUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogSourcesTableFilterComposer get sourceId {
    final $$CatalogSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.catalogSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogSourcesTableFilterComposer(
            $db: $db,
            $table: $db.catalogSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sparepartFitmentsRefs(
    Expression<bool> Function($$SparepartFitmentsTableFilterComposer f) f,
  ) {
    final $$SparepartFitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sparepartFitments,
      getReferencedColumn: (t) => t.sparepartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartFitmentsTableFilterComposer(
            $db: $db,
            $table: $db.sparepartFitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SparepartsTableOrderingComposer
    extends Composer<_$AppDatabase, $SparepartsTable> {
  $$SparepartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referencePrice => $composableBuilder(
    column: $table.referencePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productUrl => $composableBuilder(
    column: $table.productUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get priceUpdatedAt => $composableBuilder(
    column: $table.priceUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogSourcesTableOrderingComposer get sourceId {
    final $$CatalogSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.catalogSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.catalogSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SparepartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SparepartsTable> {
  $$SparepartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get referencePrice => $composableBuilder(
    column: $table.referencePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productUrl => $composableBuilder(
    column: $table.productUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get priceUpdatedAt => $composableBuilder(
    column: $table.priceUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  $$CatalogSourcesTableAnnotationComposer get sourceId {
    final $$CatalogSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.catalogSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sparepartFitmentsRefs<T extends Object>(
    Expression<T> Function($$SparepartFitmentsTableAnnotationComposer a) f,
  ) {
    final $$SparepartFitmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sparepartFitments,
          getReferencedColumn: (t) => t.sparepartId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SparepartFitmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.sparepartFitments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SparepartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SparepartsTable,
          Sparepart,
          $$SparepartsTableFilterComposer,
          $$SparepartsTableOrderingComposer,
          $$SparepartsTableAnnotationComposer,
          $$SparepartsTableCreateCompanionBuilder,
          $$SparepartsTableUpdateCompanionBuilder,
          (Sparepart, $$SparepartsTableReferences),
          Sparepart,
          PrefetchHooks Function({bool sourceId, bool sparepartFitmentsRefs})
        > {
  $$SparepartsTableTableManager(_$AppDatabase db, $SparepartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SparepartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SparepartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SparepartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<String?> partNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int?> referencePrice = const Value.absent(),
                Value<String?> productUrl = const Value.absent(),
                Value<DateTime?> priceUpdatedAt = const Value.absent(),
                Value<String?> catalogVersion = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
              }) => SparepartsCompanion(
                id: id,
                sourceId: sourceId,
                partNumber: partNumber,
                name: name,
                brand: brand,
                category: category,
                referencePrice: referencePrice,
                productUrl: productUrl,
                priceUpdatedAt: priceUpdatedAt,
                catalogVersion: catalogVersion,
                isVerified: isVerified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<String?> partNumber = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required String category,
                Value<int?> referencePrice = const Value.absent(),
                Value<String?> productUrl = const Value.absent(),
                Value<DateTime?> priceUpdatedAt = const Value.absent(),
                Value<String?> catalogVersion = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
              }) => SparepartsCompanion.insert(
                id: id,
                sourceId: sourceId,
                partNumber: partNumber,
                name: name,
                brand: brand,
                category: category,
                referencePrice: referencePrice,
                productUrl: productUrl,
                priceUpdatedAt: priceUpdatedAt,
                catalogVersion: catalogVersion,
                isVerified: isVerified,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SparepartsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceId = false, sparepartFitmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sparepartFitmentsRefs) db.sparepartFitments,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable: $$SparepartsTableReferences
                                        ._sourceIdTable(db),
                                    referencedColumn:
                                        $$SparepartsTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sparepartFitmentsRefs)
                        await $_getPrefetchedData<
                          Sparepart,
                          $SparepartsTable,
                          SparepartFitment
                        >(
                          currentTable: table,
                          referencedTable: $$SparepartsTableReferences
                              ._sparepartFitmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SparepartsTableReferences(
                                db,
                                table,
                                p0,
                              ).sparepartFitmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sparepartId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SparepartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SparepartsTable,
      Sparepart,
      $$SparepartsTableFilterComposer,
      $$SparepartsTableOrderingComposer,
      $$SparepartsTableAnnotationComposer,
      $$SparepartsTableCreateCompanionBuilder,
      $$SparepartsTableUpdateCompanionBuilder,
      (Sparepart, $$SparepartsTableReferences),
      Sparepart,
      PrefetchHooks Function({bool sourceId, bool sparepartFitmentsRefs})
    >;
typedef $$SparepartFitmentsTableCreateCompanionBuilder =
    SparepartFitmentsCompanion Function({
      Value<int> id,
      required int sparepartId,
      Value<int?> modelId,
      required int yearStart,
      Value<int?> yearEnd,
      Value<String?> notes,
      Value<DateTime?> verifiedAt,
      Value<String?> sourceUrl,
    });
typedef $$SparepartFitmentsTableUpdateCompanionBuilder =
    SparepartFitmentsCompanion Function({
      Value<int> id,
      Value<int> sparepartId,
      Value<int?> modelId,
      Value<int> yearStart,
      Value<int?> yearEnd,
      Value<String?> notes,
      Value<DateTime?> verifiedAt,
      Value<String?> sourceUrl,
    });

final class $$SparepartFitmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SparepartFitmentsTable,
          SparepartFitment
        > {
  $$SparepartFitmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SparepartsTable _sparepartIdTable(_$AppDatabase db) =>
      db.spareparts.createAlias(
        $_aliasNameGenerator(
          db.sparepartFitments.sparepartId,
          db.spareparts.id,
        ),
      );

  $$SparepartsTableProcessedTableManager get sparepartId {
    final $_column = $_itemColumn<int>('sparepart_id')!;

    final manager = $$SparepartsTableTableManager(
      $_db,
      $_db.spareparts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sparepartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MotorcycleModelsTable _modelIdTable(_$AppDatabase db) =>
      db.motorcycleModels.createAlias(
        $_aliasNameGenerator(
          db.sparepartFitments.modelId,
          db.motorcycleModels.id,
        ),
      );

  $$MotorcycleModelsTableProcessedTableManager? get modelId {
    final $_column = $_itemColumn<int>('model_id');
    if ($_column == null) return null;
    final manager = $$MotorcycleModelsTableTableManager(
      $_db,
      $_db.motorcycleModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SparepartFitmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SparepartFitmentsTable> {
  $$SparepartFitmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearStart => $composableBuilder(
    column: $table.yearStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearEnd => $composableBuilder(
    column: $table.yearEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  $$SparepartsTableFilterComposer get sparepartId {
    final $$SparepartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sparepartId,
      referencedTable: $db.spareparts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartsTableFilterComposer(
            $db: $db,
            $table: $db.spareparts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MotorcycleModelsTableFilterComposer get modelId {
    final $$MotorcycleModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableFilterComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SparepartFitmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SparepartFitmentsTable> {
  $$SparepartFitmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearStart => $composableBuilder(
    column: $table.yearStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearEnd => $composableBuilder(
    column: $table.yearEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  $$SparepartsTableOrderingComposer get sparepartId {
    final $$SparepartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sparepartId,
      referencedTable: $db.spareparts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartsTableOrderingComposer(
            $db: $db,
            $table: $db.spareparts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MotorcycleModelsTableOrderingComposer get modelId {
    final $$MotorcycleModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SparepartFitmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SparepartFitmentsTable> {
  $$SparepartFitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get yearStart =>
      $composableBuilder(column: $table.yearStart, builder: (column) => column);

  GeneratedColumn<int> get yearEnd =>
      $composableBuilder(column: $table.yearEnd, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  $$SparepartsTableAnnotationComposer get sparepartId {
    final $$SparepartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sparepartId,
      referencedTable: $db.spareparts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SparepartsTableAnnotationComposer(
            $db: $db,
            $table: $db.spareparts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MotorcycleModelsTableAnnotationComposer get modelId {
    final $$MotorcycleModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.motorcycleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcycleModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SparepartFitmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SparepartFitmentsTable,
          SparepartFitment,
          $$SparepartFitmentsTableFilterComposer,
          $$SparepartFitmentsTableOrderingComposer,
          $$SparepartFitmentsTableAnnotationComposer,
          $$SparepartFitmentsTableCreateCompanionBuilder,
          $$SparepartFitmentsTableUpdateCompanionBuilder,
          (SparepartFitment, $$SparepartFitmentsTableReferences),
          SparepartFitment,
          PrefetchHooks Function({bool sparepartId, bool modelId})
        > {
  $$SparepartFitmentsTableTableManager(
    _$AppDatabase db,
    $SparepartFitmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SparepartFitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SparepartFitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SparepartFitmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sparepartId = const Value.absent(),
                Value<int?> modelId = const Value.absent(),
                Value<int> yearStart = const Value.absent(),
                Value<int?> yearEnd = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
              }) => SparepartFitmentsCompanion(
                id: id,
                sparepartId: sparepartId,
                modelId: modelId,
                yearStart: yearStart,
                yearEnd: yearEnd,
                notes: notes,
                verifiedAt: verifiedAt,
                sourceUrl: sourceUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sparepartId,
                Value<int?> modelId = const Value.absent(),
                required int yearStart,
                Value<int?> yearEnd = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
              }) => SparepartFitmentsCompanion.insert(
                id: id,
                sparepartId: sparepartId,
                modelId: modelId,
                yearStart: yearStart,
                yearEnd: yearEnd,
                notes: notes,
                verifiedAt: verifiedAt,
                sourceUrl: sourceUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SparepartFitmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sparepartId = false, modelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (sparepartId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sparepartId,
                                referencedTable:
                                    $$SparepartFitmentsTableReferences
                                        ._sparepartIdTable(db),
                                referencedColumn:
                                    $$SparepartFitmentsTableReferences
                                        ._sparepartIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (modelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.modelId,
                                referencedTable:
                                    $$SparepartFitmentsTableReferences
                                        ._modelIdTable(db),
                                referencedColumn:
                                    $$SparepartFitmentsTableReferences
                                        ._modelIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SparepartFitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SparepartFitmentsTable,
      SparepartFitment,
      $$SparepartFitmentsTableFilterComposer,
      $$SparepartFitmentsTableOrderingComposer,
      $$SparepartFitmentsTableAnnotationComposer,
      $$SparepartFitmentsTableCreateCompanionBuilder,
      $$SparepartFitmentsTableUpdateCompanionBuilder,
      (SparepartFitment, $$SparepartFitmentsTableReferences),
      SparepartFitment,
      PrefetchHooks Function({bool sparepartId, bool modelId})
    >;
typedef $$BudgetPlansTableCreateCompanionBuilder =
    BudgetPlansCompanion Function({
      Value<int> id,
      required int motorcycleId,
      required int budgetAmount,
      Value<String?> period,
      Value<DateTime> createdAt,
      Value<String?> notes,
    });
typedef $$BudgetPlansTableUpdateCompanionBuilder =
    BudgetPlansCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<int> budgetAmount,
      Value<String?> period,
      Value<DateTime> createdAt,
      Value<String?> notes,
    });

final class $$BudgetPlansTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetPlansTable, BudgetPlan> {
  $$BudgetPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(db.budgetPlans.motorcycleId, db.motorcycles.id),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ServiceRecommendationsTable,
    List<ServiceRecommendation>
  >
  _serviceRecommendationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.serviceRecommendations,
        aliasName: $_aliasNameGenerator(
          db.budgetPlans.id,
          db.serviceRecommendations.budgetPlanId,
        ),
      );

  $$ServiceRecommendationsTableProcessedTableManager
  get serviceRecommendationsRefs {
    final manager = $$ServiceRecommendationsTableTableManager(
      $_db,
      $_db.serviceRecommendations,
    ).filter((f) => f.budgetPlanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _serviceRecommendationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BudgetPlansTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetPlansTable> {
  $$BudgetPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> serviceRecommendationsRefs(
    Expression<bool> Function($$ServiceRecommendationsTableFilterComposer f) f,
  ) {
    final $$ServiceRecommendationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.serviceRecommendations,
          getReferencedColumn: (t) => t.budgetPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceRecommendationsTableFilterComposer(
                $db: $db,
                $table: $db.serviceRecommendations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BudgetPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetPlansTable> {
  $$BudgetPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetPlansTable> {
  $$BudgetPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> serviceRecommendationsRefs<T extends Object>(
    Expression<T> Function($$ServiceRecommendationsTableAnnotationComposer a) f,
  ) {
    final $$ServiceRecommendationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.serviceRecommendations,
          getReferencedColumn: (t) => t.budgetPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceRecommendationsTableAnnotationComposer(
                $db: $db,
                $table: $db.serviceRecommendations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BudgetPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetPlansTable,
          BudgetPlan,
          $$BudgetPlansTableFilterComposer,
          $$BudgetPlansTableOrderingComposer,
          $$BudgetPlansTableAnnotationComposer,
          $$BudgetPlansTableCreateCompanionBuilder,
          $$BudgetPlansTableUpdateCompanionBuilder,
          (BudgetPlan, $$BudgetPlansTableReferences),
          BudgetPlan,
          PrefetchHooks Function({
            bool motorcycleId,
            bool serviceRecommendationsRefs,
          })
        > {
  $$BudgetPlansTableTableManager(_$AppDatabase db, $BudgetPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<int> budgetAmount = const Value.absent(),
                Value<String?> period = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BudgetPlansCompanion(
                id: id,
                motorcycleId: motorcycleId,
                budgetAmount: budgetAmount,
                period: period,
                createdAt: createdAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                required int budgetAmount,
                Value<String?> period = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BudgetPlansCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                budgetAmount: budgetAmount,
                period: period,
                createdAt: createdAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({motorcycleId = false, serviceRecommendationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (serviceRecommendationsRefs) db.serviceRecommendations,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (motorcycleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motorcycleId,
                                    referencedTable:
                                        $$BudgetPlansTableReferences
                                            ._motorcycleIdTable(db),
                                    referencedColumn:
                                        $$BudgetPlansTableReferences
                                            ._motorcycleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (serviceRecommendationsRefs)
                        await $_getPrefetchedData<
                          BudgetPlan,
                          $BudgetPlansTable,
                          ServiceRecommendation
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetPlansTableReferences
                              ._serviceRecommendationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceRecommendationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetPlanId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BudgetPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetPlansTable,
      BudgetPlan,
      $$BudgetPlansTableFilterComposer,
      $$BudgetPlansTableOrderingComposer,
      $$BudgetPlansTableAnnotationComposer,
      $$BudgetPlansTableCreateCompanionBuilder,
      $$BudgetPlansTableUpdateCompanionBuilder,
      (BudgetPlan, $$BudgetPlansTableReferences),
      BudgetPlan,
      PrefetchHooks Function({
        bool motorcycleId,
        bool serviceRecommendationsRefs,
      })
    >;
typedef $$ServiceRecommendationsTableCreateCompanionBuilder =
    ServiceRecommendationsCompanion Function({
      Value<int> id,
      required int budgetPlanId,
      required int estimatedTotal,
      required String ruleVersion,
      Value<DateTime> generatedAt,
      Value<String?> dataFreshness,
      Value<String?> explanation,
    });
typedef $$ServiceRecommendationsTableUpdateCompanionBuilder =
    ServiceRecommendationsCompanion Function({
      Value<int> id,
      Value<int> budgetPlanId,
      Value<int> estimatedTotal,
      Value<String> ruleVersion,
      Value<DateTime> generatedAt,
      Value<String?> dataFreshness,
      Value<String?> explanation,
    });

final class $$ServiceRecommendationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ServiceRecommendationsTable,
          ServiceRecommendation
        > {
  $$ServiceRecommendationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BudgetPlansTable _budgetPlanIdTable(_$AppDatabase db) =>
      db.budgetPlans.createAlias(
        $_aliasNameGenerator(
          db.serviceRecommendations.budgetPlanId,
          db.budgetPlans.id,
        ),
      );

  $$BudgetPlansTableProcessedTableManager get budgetPlanId {
    final $_column = $_itemColumn<int>('budget_plan_id')!;

    final manager = $$BudgetPlansTableTableManager(
      $_db,
      $_db.budgetPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $RecommendationItemsTable,
    List<RecommendationItem>
  >
  _recommendationItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recommendationItems,
        aliasName: $_aliasNameGenerator(
          db.serviceRecommendations.id,
          db.recommendationItems.recommendationId,
        ),
      );

  $$RecommendationItemsTableProcessedTableManager get recommendationItemsRefs {
    final manager = $$RecommendationItemsTableTableManager(
      $_db,
      $_db.recommendationItems,
    ).filter((f) => f.recommendationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recommendationItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServiceRecommendationsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceRecommendationsTable> {
  $$ServiceRecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedTotal => $composableBuilder(
    column: $table.estimatedTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataFreshness => $composableBuilder(
    column: $table.dataFreshness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  $$BudgetPlansTableFilterComposer get budgetPlanId {
    final $$BudgetPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPlanId,
      referencedTable: $db.budgetPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPlansTableFilterComposer(
            $db: $db,
            $table: $db.budgetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> recommendationItemsRefs(
    Expression<bool> Function($$RecommendationItemsTableFilterComposer f) f,
  ) {
    final $$RecommendationItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recommendationItems,
      getReferencedColumn: (t) => t.recommendationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecommendationItemsTableFilterComposer(
            $db: $db,
            $table: $db.recommendationItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceRecommendationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceRecommendationsTable> {
  $$ServiceRecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedTotal => $composableBuilder(
    column: $table.estimatedTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataFreshness => $composableBuilder(
    column: $table.dataFreshness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  $$BudgetPlansTableOrderingComposer get budgetPlanId {
    final $$BudgetPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPlanId,
      referencedTable: $db.budgetPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPlansTableOrderingComposer(
            $db: $db,
            $table: $db.budgetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceRecommendationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceRecommendationsTable> {
  $$ServiceRecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get estimatedTotal => $composableBuilder(
    column: $table.estimatedTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataFreshness => $composableBuilder(
    column: $table.dataFreshness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  $$BudgetPlansTableAnnotationComposer get budgetPlanId {
    final $$BudgetPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPlanId,
      referencedTable: $db.budgetPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> recommendationItemsRefs<T extends Object>(
    Expression<T> Function($$RecommendationItemsTableAnnotationComposer a) f,
  ) {
    final $$RecommendationItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recommendationItems,
          getReferencedColumn: (t) => t.recommendationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecommendationItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.recommendationItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ServiceRecommendationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceRecommendationsTable,
          ServiceRecommendation,
          $$ServiceRecommendationsTableFilterComposer,
          $$ServiceRecommendationsTableOrderingComposer,
          $$ServiceRecommendationsTableAnnotationComposer,
          $$ServiceRecommendationsTableCreateCompanionBuilder,
          $$ServiceRecommendationsTableUpdateCompanionBuilder,
          (ServiceRecommendation, $$ServiceRecommendationsTableReferences),
          ServiceRecommendation,
          PrefetchHooks Function({
            bool budgetPlanId,
            bool recommendationItemsRefs,
          })
        > {
  $$ServiceRecommendationsTableTableManager(
    _$AppDatabase db,
    $ServiceRecommendationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceRecommendationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ServiceRecommendationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ServiceRecommendationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> budgetPlanId = const Value.absent(),
                Value<int> estimatedTotal = const Value.absent(),
                Value<String> ruleVersion = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String?> dataFreshness = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => ServiceRecommendationsCompanion(
                id: id,
                budgetPlanId: budgetPlanId,
                estimatedTotal: estimatedTotal,
                ruleVersion: ruleVersion,
                generatedAt: generatedAt,
                dataFreshness: dataFreshness,
                explanation: explanation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int budgetPlanId,
                required int estimatedTotal,
                required String ruleVersion,
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String?> dataFreshness = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => ServiceRecommendationsCompanion.insert(
                id: id,
                budgetPlanId: budgetPlanId,
                estimatedTotal: estimatedTotal,
                ruleVersion: ruleVersion,
                generatedAt: generatedAt,
                dataFreshness: dataFreshness,
                explanation: explanation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceRecommendationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({budgetPlanId = false, recommendationItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recommendationItemsRefs) db.recommendationItems,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (budgetPlanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.budgetPlanId,
                                    referencedTable:
                                        $$ServiceRecommendationsTableReferences
                                            ._budgetPlanIdTable(db),
                                    referencedColumn:
                                        $$ServiceRecommendationsTableReferences
                                            ._budgetPlanIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recommendationItemsRefs)
                        await $_getPrefetchedData<
                          ServiceRecommendation,
                          $ServiceRecommendationsTable,
                          RecommendationItem
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ServiceRecommendationsTableReferences
                                  ._recommendationItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServiceRecommendationsTableReferences(
                                db,
                                table,
                                p0,
                              ).recommendationItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recommendationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ServiceRecommendationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceRecommendationsTable,
      ServiceRecommendation,
      $$ServiceRecommendationsTableFilterComposer,
      $$ServiceRecommendationsTableOrderingComposer,
      $$ServiceRecommendationsTableAnnotationComposer,
      $$ServiceRecommendationsTableCreateCompanionBuilder,
      $$ServiceRecommendationsTableUpdateCompanionBuilder,
      (ServiceRecommendation, $$ServiceRecommendationsTableReferences),
      ServiceRecommendation,
      PrefetchHooks Function({bool budgetPlanId, bool recommendationItemsRefs})
    >;
typedef $$RecommendationItemsTableCreateCompanionBuilder =
    RecommendationItemsCompanion Function({
      Value<int> id,
      required int recommendationId,
      required int componentTypeId,
      Value<int?> sparepartId,
      required String priority,
      required String decision,
      Value<int?> estimatedCost,
      Value<int?> estimatedLaborCost,
      required String reason,
      Value<String?> consequenceIfDelayed,
      Value<bool> requiresInspection,
    });
typedef $$RecommendationItemsTableUpdateCompanionBuilder =
    RecommendationItemsCompanion Function({
      Value<int> id,
      Value<int> recommendationId,
      Value<int> componentTypeId,
      Value<int?> sparepartId,
      Value<String> priority,
      Value<String> decision,
      Value<int?> estimatedCost,
      Value<int?> estimatedLaborCost,
      Value<String> reason,
      Value<String?> consequenceIfDelayed,
      Value<bool> requiresInspection,
    });

final class $$RecommendationItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecommendationItemsTable,
          RecommendationItem
        > {
  $$RecommendationItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ServiceRecommendationsTable _recommendationIdTable(
    _$AppDatabase db,
  ) => db.serviceRecommendations.createAlias(
    $_aliasNameGenerator(
      db.recommendationItems.recommendationId,
      db.serviceRecommendations.id,
    ),
  );

  $$ServiceRecommendationsTableProcessedTableManager get recommendationId {
    final $_column = $_itemColumn<int>('recommendation_id')!;

    final manager = $$ServiceRecommendationsTableTableManager(
      $_db,
      $_db.serviceRecommendations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recommendationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ComponentTypesTable _componentTypeIdTable(_$AppDatabase db) =>
      db.componentTypes.createAlias(
        $_aliasNameGenerator(
          db.recommendationItems.componentTypeId,
          db.componentTypes.id,
        ),
      );

  $$ComponentTypesTableProcessedTableManager get componentTypeId {
    final $_column = $_itemColumn<int>('component_type_id')!;

    final manager = $$ComponentTypesTableTableManager(
      $_db,
      $_db.componentTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_componentTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecommendationItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationItemsTable> {
  $$RecommendationItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sparepartId => $composableBuilder(
    column: $table.sparepartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedLaborCost => $composableBuilder(
    column: $table.estimatedLaborCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consequenceIfDelayed => $composableBuilder(
    column: $table.consequenceIfDelayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresInspection => $composableBuilder(
    column: $table.requiresInspection,
    builder: (column) => ColumnFilters(column),
  );

  $$ServiceRecommendationsTableFilterComposer get recommendationId {
    final $$ServiceRecommendationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recommendationId,
          referencedTable: $db.serviceRecommendations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceRecommendationsTableFilterComposer(
                $db: $db,
                $table: $db.serviceRecommendations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ComponentTypesTableFilterComposer get componentTypeId {
    final $$ComponentTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableFilterComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecommendationItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationItemsTable> {
  $$RecommendationItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sparepartId => $composableBuilder(
    column: $table.sparepartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedLaborCost => $composableBuilder(
    column: $table.estimatedLaborCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consequenceIfDelayed => $composableBuilder(
    column: $table.consequenceIfDelayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresInspection => $composableBuilder(
    column: $table.requiresInspection,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServiceRecommendationsTableOrderingComposer get recommendationId {
    final $$ServiceRecommendationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recommendationId,
          referencedTable: $db.serviceRecommendations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceRecommendationsTableOrderingComposer(
                $db: $db,
                $table: $db.serviceRecommendations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ComponentTypesTableOrderingComposer get componentTypeId {
    final $$ComponentTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableOrderingComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecommendationItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationItemsTable> {
  $$RecommendationItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sparepartId => $composableBuilder(
    column: $table.sparepartId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<int> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedLaborCost => $composableBuilder(
    column: $table.estimatedLaborCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get consequenceIfDelayed => $composableBuilder(
    column: $table.consequenceIfDelayed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requiresInspection => $composableBuilder(
    column: $table.requiresInspection,
    builder: (column) => column,
  );

  $$ServiceRecommendationsTableAnnotationComposer get recommendationId {
    final $$ServiceRecommendationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recommendationId,
          referencedTable: $db.serviceRecommendations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceRecommendationsTableAnnotationComposer(
                $db: $db,
                $table: $db.serviceRecommendations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ComponentTypesTableAnnotationComposer get componentTypeId {
    final $$ComponentTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecommendationItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecommendationItemsTable,
          RecommendationItem,
          $$RecommendationItemsTableFilterComposer,
          $$RecommendationItemsTableOrderingComposer,
          $$RecommendationItemsTableAnnotationComposer,
          $$RecommendationItemsTableCreateCompanionBuilder,
          $$RecommendationItemsTableUpdateCompanionBuilder,
          (RecommendationItem, $$RecommendationItemsTableReferences),
          RecommendationItem,
          PrefetchHooks Function({bool recommendationId, bool componentTypeId})
        > {
  $$RecommendationItemsTableTableManager(
    _$AppDatabase db,
    $RecommendationItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecommendationItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecommendationItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recommendationId = const Value.absent(),
                Value<int> componentTypeId = const Value.absent(),
                Value<int?> sparepartId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<int?> estimatedCost = const Value.absent(),
                Value<int?> estimatedLaborCost = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> consequenceIfDelayed = const Value.absent(),
                Value<bool> requiresInspection = const Value.absent(),
              }) => RecommendationItemsCompanion(
                id: id,
                recommendationId: recommendationId,
                componentTypeId: componentTypeId,
                sparepartId: sparepartId,
                priority: priority,
                decision: decision,
                estimatedCost: estimatedCost,
                estimatedLaborCost: estimatedLaborCost,
                reason: reason,
                consequenceIfDelayed: consequenceIfDelayed,
                requiresInspection: requiresInspection,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recommendationId,
                required int componentTypeId,
                Value<int?> sparepartId = const Value.absent(),
                required String priority,
                required String decision,
                Value<int?> estimatedCost = const Value.absent(),
                Value<int?> estimatedLaborCost = const Value.absent(),
                required String reason,
                Value<String?> consequenceIfDelayed = const Value.absent(),
                Value<bool> requiresInspection = const Value.absent(),
              }) => RecommendationItemsCompanion.insert(
                id: id,
                recommendationId: recommendationId,
                componentTypeId: componentTypeId,
                sparepartId: sparepartId,
                priority: priority,
                decision: decision,
                estimatedCost: estimatedCost,
                estimatedLaborCost: estimatedLaborCost,
                reason: reason,
                consequenceIfDelayed: consequenceIfDelayed,
                requiresInspection: requiresInspection,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecommendationItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recommendationId = false, componentTypeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (recommendationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recommendationId,
                                    referencedTable:
                                        $$RecommendationItemsTableReferences
                                            ._recommendationIdTable(db),
                                    referencedColumn:
                                        $$RecommendationItemsTableReferences
                                            ._recommendationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (componentTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.componentTypeId,
                                    referencedTable:
                                        $$RecommendationItemsTableReferences
                                            ._componentTypeIdTable(db),
                                    referencedColumn:
                                        $$RecommendationItemsTableReferences
                                            ._componentTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RecommendationItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecommendationItemsTable,
      RecommendationItem,
      $$RecommendationItemsTableFilterComposer,
      $$RecommendationItemsTableOrderingComposer,
      $$RecommendationItemsTableAnnotationComposer,
      $$RecommendationItemsTableCreateCompanionBuilder,
      $$RecommendationItemsTableUpdateCompanionBuilder,
      (RecommendationItem, $$RecommendationItemsTableReferences),
      RecommendationItem,
      PrefetchHooks Function({bool recommendationId, bool componentTypeId})
    >;
typedef $$LocalRemindersTableCreateCompanionBuilder =
    LocalRemindersCompanion Function({
      Value<int> id,
      required int motorcycleId,
      Value<int?> componentTypeId,
      required String reminderType,
      Value<double?> dueOdometerKm,
      Value<DateTime?> dueDate,
      Value<bool> enabled,
      Value<DateTime?> lastScheduledAt,
      Value<int?> notificationId,
    });
typedef $$LocalRemindersTableUpdateCompanionBuilder =
    LocalRemindersCompanion Function({
      Value<int> id,
      Value<int> motorcycleId,
      Value<int?> componentTypeId,
      Value<String> reminderType,
      Value<double?> dueOdometerKm,
      Value<DateTime?> dueDate,
      Value<bool> enabled,
      Value<DateTime?> lastScheduledAt,
      Value<int?> notificationId,
    });

final class $$LocalRemindersTableReferences
    extends BaseReferences<_$AppDatabase, $LocalRemindersTable, LocalReminder> {
  $$LocalRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MotorcyclesTable _motorcycleIdTable(_$AppDatabase db) =>
      db.motorcycles.createAlias(
        $_aliasNameGenerator(db.localReminders.motorcycleId, db.motorcycles.id),
      );

  $$MotorcyclesTableProcessedTableManager get motorcycleId {
    final $_column = $_itemColumn<int>('motorcycle_id')!;

    final manager = $$MotorcyclesTableTableManager(
      $_db,
      $_db.motorcycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motorcycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ComponentTypesTable _componentTypeIdTable(_$AppDatabase db) =>
      db.componentTypes.createAlias(
        $_aliasNameGenerator(
          db.localReminders.componentTypeId,
          db.componentTypes.id,
        ),
      );

  $$ComponentTypesTableProcessedTableManager? get componentTypeId {
    final $_column = $_itemColumn<int>('component_type_id');
    if ($_column == null) return null;
    final manager = $$ComponentTypesTableTableManager(
      $_db,
      $_db.componentTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_componentTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRemindersTable> {
  $$LocalRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dueOdometerKm => $composableBuilder(
    column: $table.dueOdometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastScheduledAt => $composableBuilder(
    column: $table.lastScheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  $$MotorcyclesTableFilterComposer get motorcycleId {
    final $$MotorcyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableFilterComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableFilterComposer get componentTypeId {
    final $$ComponentTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableFilterComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRemindersTable> {
  $$LocalRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dueOdometerKm => $composableBuilder(
    column: $table.dueOdometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastScheduledAt => $composableBuilder(
    column: $table.lastScheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$MotorcyclesTableOrderingComposer get motorcycleId {
    final $$MotorcyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableOrderingComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableOrderingComposer get componentTypeId {
    final $$ComponentTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableOrderingComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRemindersTable> {
  $$LocalRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dueOdometerKm => $composableBuilder(
    column: $table.dueOdometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastScheduledAt => $composableBuilder(
    column: $table.lastScheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  $$MotorcyclesTableAnnotationComposer get motorcycleId {
    final $$MotorcyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motorcycleId,
      referencedTable: $db.motorcycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MotorcyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.motorcycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComponentTypesTableAnnotationComposer get componentTypeId {
    final $$ComponentTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentTypeId,
      referencedTable: $db.componentTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComponentTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.componentTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRemindersTable,
          LocalReminder,
          $$LocalRemindersTableFilterComposer,
          $$LocalRemindersTableOrderingComposer,
          $$LocalRemindersTableAnnotationComposer,
          $$LocalRemindersTableCreateCompanionBuilder,
          $$LocalRemindersTableUpdateCompanionBuilder,
          (LocalReminder, $$LocalRemindersTableReferences),
          LocalReminder,
          PrefetchHooks Function({bool motorcycleId, bool componentTypeId})
        > {
  $$LocalRemindersTableTableManager(
    _$AppDatabase db,
    $LocalRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motorcycleId = const Value.absent(),
                Value<int?> componentTypeId = const Value.absent(),
                Value<String> reminderType = const Value.absent(),
                Value<double?> dueOdometerKm = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastScheduledAt = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
              }) => LocalRemindersCompanion(
                id: id,
                motorcycleId: motorcycleId,
                componentTypeId: componentTypeId,
                reminderType: reminderType,
                dueOdometerKm: dueOdometerKm,
                dueDate: dueDate,
                enabled: enabled,
                lastScheduledAt: lastScheduledAt,
                notificationId: notificationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motorcycleId,
                Value<int?> componentTypeId = const Value.absent(),
                required String reminderType,
                Value<double?> dueOdometerKm = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastScheduledAt = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
              }) => LocalRemindersCompanion.insert(
                id: id,
                motorcycleId: motorcycleId,
                componentTypeId: componentTypeId,
                reminderType: reminderType,
                dueOdometerKm: dueOdometerKm,
                dueDate: dueDate,
                enabled: enabled,
                lastScheduledAt: lastScheduledAt,
                notificationId: notificationId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({motorcycleId = false, componentTypeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (motorcycleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motorcycleId,
                                    referencedTable:
                                        $$LocalRemindersTableReferences
                                            ._motorcycleIdTable(db),
                                    referencedColumn:
                                        $$LocalRemindersTableReferences
                                            ._motorcycleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (componentTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.componentTypeId,
                                    referencedTable:
                                        $$LocalRemindersTableReferences
                                            ._componentTypeIdTable(db),
                                    referencedColumn:
                                        $$LocalRemindersTableReferences
                                            ._componentTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$LocalRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRemindersTable,
      LocalReminder,
      $$LocalRemindersTableFilterComposer,
      $$LocalRemindersTableOrderingComposer,
      $$LocalRemindersTableAnnotationComposer,
      $$LocalRemindersTableCreateCompanionBuilder,
      $$LocalRemindersTableUpdateCompanionBuilder,
      (LocalReminder, $$LocalRemindersTableReferences),
      LocalReminder,
      PrefetchHooks Function({bool motorcycleId, bool componentTypeId})
    >;
typedef $$AiModelInstallsTableCreateCompanionBuilder =
    AiModelInstallsCompanion Function({
      Value<int> id,
      required String modelName,
      required String version,
      required String filePath,
      required String sha256,
      Value<int?> fileSizeBytes,
      Value<String> downloadStatus,
      Value<DateTime?> installedAt,
      Value<String?> sourceUrl,
      Value<String?> lastError,
    });
typedef $$AiModelInstallsTableUpdateCompanionBuilder =
    AiModelInstallsCompanion Function({
      Value<int> id,
      Value<String> modelName,
      Value<String> version,
      Value<String> filePath,
      Value<String> sha256,
      Value<int?> fileSizeBytes,
      Value<String> downloadStatus,
      Value<DateTime?> installedAt,
      Value<String?> sourceUrl,
      Value<String?> lastError,
    });

class $$AiModelInstallsTableFilterComposer
    extends Composer<_$AppDatabase, $AiModelInstallsTable> {
  $$AiModelInstallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiModelInstallsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiModelInstallsTable> {
  $$AiModelInstallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiModelInstallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiModelInstallsTable> {
  $$AiModelInstallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$AiModelInstallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiModelInstallsTable,
          AiModelInstall,
          $$AiModelInstallsTableFilterComposer,
          $$AiModelInstallsTableOrderingComposer,
          $$AiModelInstallsTableAnnotationComposer,
          $$AiModelInstallsTableCreateCompanionBuilder,
          $$AiModelInstallsTableUpdateCompanionBuilder,
          (
            AiModelInstall,
            BaseReferences<
              _$AppDatabase,
              $AiModelInstallsTable,
              AiModelInstall
            >,
          ),
          AiModelInstall,
          PrefetchHooks Function()
        > {
  $$AiModelInstallsTableTableManager(
    _$AppDatabase db,
    $AiModelInstallsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiModelInstallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiModelInstallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiModelInstallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => AiModelInstallsCompanion(
                id: id,
                modelName: modelName,
                version: version,
                filePath: filePath,
                sha256: sha256,
                fileSizeBytes: fileSizeBytes,
                downloadStatus: downloadStatus,
                installedAt: installedAt,
                sourceUrl: sourceUrl,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String modelName,
                required String version,
                required String filePath,
                required String sha256,
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => AiModelInstallsCompanion.insert(
                id: id,
                modelName: modelName,
                version: version,
                filePath: filePath,
                sha256: sha256,
                fileSizeBytes: fileSizeBytes,
                downloadStatus: downloadStatus,
                installedAt: installedAt,
                sourceUrl: sourceUrl,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiModelInstallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiModelInstallsTable,
      AiModelInstall,
      $$AiModelInstallsTableFilterComposer,
      $$AiModelInstallsTableOrderingComposer,
      $$AiModelInstallsTableAnnotationComposer,
      $$AiModelInstallsTableCreateCompanionBuilder,
      $$AiModelInstallsTableUpdateCompanionBuilder,
      (
        AiModelInstall,
        BaseReferences<_$AppDatabase, $AiModelInstallsTable, AiModelInstall>,
      ),
      AiModelInstall,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MotorcycleModelsTableTableManager get motorcycleModels =>
      $$MotorcycleModelsTableTableManager(_db, _db.motorcycleModels);
  $$MotorcyclesTableTableManager get motorcycles =>
      $$MotorcyclesTableTableManager(_db, _db.motorcycles);
  $$OdometerLogsTableTableManager get odometerLogs =>
      $$OdometerLogsTableTableManager(_db, _db.odometerLogs);
  $$ComponentTypesTableTableManager get componentTypes =>
      $$ComponentTypesTableTableManager(_db, _db.componentTypes);
  $$MaintenanceRulesTableTableManager get maintenanceRules =>
      $$MaintenanceRulesTableTableManager(_db, _db.maintenanceRules);
  $$ComponentStatusesTableTableManager get componentStatuses =>
      $$ComponentStatusesTableTableManager(_db, _db.componentStatuses);
  $$ServiceRecordsTableTableManager get serviceRecords =>
      $$ServiceRecordsTableTableManager(_db, _db.serviceRecords);
  $$ServiceItemsTableTableManager get serviceItems =>
      $$ServiceItemsTableTableManager(_db, _db.serviceItems);
  $$SelfInspectionsTableTableManager get selfInspections =>
      $$SelfInspectionsTableTableManager(_db, _db.selfInspections);
  $$InspectionAnswersTableTableManager get inspectionAnswers =>
      $$InspectionAnswersTableTableManager(_db, _db.inspectionAnswers);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db, _db.complaints);
  $$ComplaintMessagesTableTableManager get complaintMessages =>
      $$ComplaintMessagesTableTableManager(_db, _db.complaintMessages);
  $$ComplaintAnalysesTableTableManager get complaintAnalyses =>
      $$ComplaintAnalysesTableTableManager(_db, _db.complaintAnalyses);
  $$CatalogSourcesTableTableManager get catalogSources =>
      $$CatalogSourcesTableTableManager(_db, _db.catalogSources);
  $$SparepartsTableTableManager get spareparts =>
      $$SparepartsTableTableManager(_db, _db.spareparts);
  $$SparepartFitmentsTableTableManager get sparepartFitments =>
      $$SparepartFitmentsTableTableManager(_db, _db.sparepartFitments);
  $$BudgetPlansTableTableManager get budgetPlans =>
      $$BudgetPlansTableTableManager(_db, _db.budgetPlans);
  $$ServiceRecommendationsTableTableManager get serviceRecommendations =>
      $$ServiceRecommendationsTableTableManager(
        _db,
        _db.serviceRecommendations,
      );
  $$RecommendationItemsTableTableManager get recommendationItems =>
      $$RecommendationItemsTableTableManager(_db, _db.recommendationItems);
  $$LocalRemindersTableTableManager get localReminders =>
      $$LocalRemindersTableTableManager(_db, _db.localReminders);
  $$AiModelInstallsTableTableManager get aiModelInstalls =>
      $$AiModelInstallsTableTableManager(_db, _db.aiModelInstalls);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}

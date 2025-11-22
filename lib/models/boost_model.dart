import 'package:festou/models/user_model.dart';

class BoostModel {
  final String id;
  final String partyId;
  final String userId;
  final List<String> targetGenders;
  final int minAge;
  final int maxAge;
  final List<String> targetCities;
  final double radiusKm;
  final List<String> targetStyles;
  final int totalImpressions;
  final int remainingImpressions;
  final double dailyImpressionLimit;
  final int impressionsToday;
  final DateTime lastImpressionResetDate;
  final double amountPaid;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  BoostModel({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.targetGenders,
    required this.minAge,
    required this.maxAge,
    required this.targetCities,
    required this.radiusKm,
    required this.targetStyles,
    required this.totalImpressions,
    required this.remainingImpressions,
    required this.dailyImpressionLimit,
    this.impressionsToday = 0,
    required this.lastImpressionResetDate,
    required this.amountPaid,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory BoostModel.fromJson(Map<String, dynamic> json) => BoostModel(
    id: json['id'] as String,
    partyId: json['partyId'] as String,
    userId: json['userId'] as String,
    targetGenders: (json['targetGenders'] as List<dynamic>).map((e) => e as String).toList(),
    minAge: json['minAge'] as int,
    maxAge: json['maxAge'] as int,
    targetCities: (json['targetCities'] as List<dynamic>).map((e) => e as String).toList(),
    radiusKm: (json['radiusKm'] as num).toDouble(),
    targetStyles: (json['targetStyles'] as List<dynamic>).map((e) => e as String).toList(),
    totalImpressions: json['totalImpressions'] as int,
    remainingImpressions: json['remainingImpressions'] as int,
    dailyImpressionLimit: (json['dailyImpressionLimit'] as num).toDouble(),
    impressionsToday: json['impressionsToday'] as int? ?? 0,
    lastImpressionResetDate: DateTime.parse(json['lastImpressionResetDate'] as String),
    amountPaid: (json['amountPaid'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'partyId': partyId,
    'userId': userId,
    'targetGenders': targetGenders,
    'minAge': minAge,
    'maxAge': maxAge,
    'targetCities': targetCities,
    'radiusKm': radiusKm,
    'targetStyles': targetStyles,
    'totalImpressions': totalImpressions,
    'remainingImpressions': remainingImpressions,
    'dailyImpressionLimit': dailyImpressionLimit,
    'impressionsToday': impressionsToday,
    'lastImpressionResetDate': lastImpressionResetDate.toIso8601String(),
    'amountPaid': amountPaid,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'isActive': isActive,
  };

  BoostModel copyWith({
    String? id,
    String? partyId,
    String? userId,
    List<String>? targetGenders,
    int? minAge,
    int? maxAge,
    List<String>? targetCities,
    double? radiusKm,
    List<String>? targetStyles,
    int? totalImpressions,
    int? remainingImpressions,
    double? dailyImpressionLimit,
    int? impressionsToday,
    DateTime? lastImpressionResetDate,
    double? amountPaid,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
  }) => BoostModel(
    id: id ?? this.id,
    partyId: partyId ?? this.partyId,
    userId: userId ?? this.userId,
    targetGenders: targetGenders ?? this.targetGenders,
    minAge: minAge ?? this.minAge,
    maxAge: maxAge ?? this.maxAge,
    targetCities: targetCities ?? this.targetCities,
    radiusKm: radiusKm ?? this.radiusKm,
    targetStyles: targetStyles ?? this.targetStyles,
    totalImpressions: totalImpressions ?? this.totalImpressions,
    remainingImpressions: remainingImpressions ?? this.remainingImpressions,
    dailyImpressionLimit: dailyImpressionLimit ?? this.dailyImpressionLimit,
    impressionsToday: impressionsToday ?? this.impressionsToday,
    lastImpressionResetDate: lastImpressionResetDate ?? this.lastImpressionResetDate,
    amountPaid: amountPaid ?? this.amountPaid,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    isActive: isActive ?? this.isActive,
  );

  bool matchesUser(UserModel user) {
    if (!targetGenders.contains(user.gender)) return false;
    if (user.age != null && (user.age! < minAge || user.age! > maxAge)) return false;
    if (targetCities.isNotEmpty && user.city != null) {
      final matches = targetCities.any((city) => 
        user.city!.toLowerCase().contains(city.toLowerCase())
      );
      if (!matches) return false;
    }
    if (targetStyles.isNotEmpty && user.favoriteStyles.isNotEmpty) {
      final hasMatchingStyle = user.favoriteStyles.any((style) => 
        targetStyles.contains(style)
      );
      if (!hasMatchingStyle) return false;
    }
    return true;
  }
}

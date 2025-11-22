class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final List<String> favoriteStyles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastFreePartyCreatedAt;
  final bool isPremiumUser;
  final String gender;
  final String relationshipStatus;
  final int reportCount;
  final List<String> likedByUserIds;
  final int? age;
  final String? city;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.favoriteStyles,
    required this.createdAt,
    required this.updatedAt,
    this.lastFreePartyCreatedAt,
    this.isPremiumUser = false,
    this.gender = 'Não informado',
    this.relationshipStatus = 'Não informado',
    this.reportCount = 0,
    this.likedByUserIds = const [],
    this.age,
    this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    photoUrl: json['photoUrl'] as String?,
    bio: json['bio'] as String?,
    favoriteStyles: (json['favoriteStyles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    lastFreePartyCreatedAt: json['lastFreePartyCreatedAt'] != null ? DateTime.parse(json['lastFreePartyCreatedAt'] as String) : null,
    isPremiumUser: json['isPremiumUser'] as bool? ?? false,
    gender: json['gender'] as String? ?? 'Não informado',
    relationshipStatus: json['relationshipStatus'] as String? ?? 'Não informado',
    reportCount: json['reportCount'] as int? ?? 0,
    likedByUserIds: (json['likedByUserIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    age: json['age'] as int?,
    city: json['city'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'bio': bio,
    'favoriteStyles': favoriteStyles,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastFreePartyCreatedAt': lastFreePartyCreatedAt?.toIso8601String(),
    'isPremiumUser': isPremiumUser,
    'gender': gender,
    'relationshipStatus': relationshipStatus,
    'reportCount': reportCount,
    'likedByUserIds': likedByUserIds,
    'age': age,
    'city': city,
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? favoriteStyles,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastFreePartyCreatedAt,
    bool? isPremiumUser,
    String? gender,
    String? relationshipStatus,
    int? reportCount,
    List<String>? likedByUserIds,
    int? age,
    String? city,
  }) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    favoriteStyles: favoriteStyles ?? this.favoriteStyles,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastFreePartyCreatedAt: lastFreePartyCreatedAt ?? this.lastFreePartyCreatedAt,
    isPremiumUser: isPremiumUser ?? this.isPremiumUser,
    gender: gender ?? this.gender,
    relationshipStatus: relationshipStatus ?? this.relationshipStatus,
    reportCount: reportCount ?? this.reportCount,
    likedByUserIds: likedByUserIds ?? this.likedByUserIds,
    age: age ?? this.age,
    city: city ?? this.city,
  );
}

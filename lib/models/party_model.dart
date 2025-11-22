class PartyModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime dateTime;
  final String location;
  final String city;
  final double latitude;
  final double longitude;
  final String style;
  final double price;
  final String organizerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final DateTime? expiresAt;
  final List<String> mediaUrls;
  final int premiumDays;
  final List<String> attendeeIds;
  final List<String> storyUrls;
  final int reportCount;
  final bool isPremiumPaid;

  PartyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.dateTime,
    required this.location,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.style,
    required this.price,
    required this.organizerId,
    required this.createdAt,
    required this.updatedAt,
    this.type = 'free',
    this.expiresAt,
    this.mediaUrls = const [],
    this.premiumDays = 0,
    this.attendeeIds = const [],
    this.storyUrls = const [],
    this.reportCount = 0,
    this.isPremiumPaid = false,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) => PartyModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    location: json['location'] as String,
    city: json['city'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    style: json['style'] as String,
    price: (json['price'] as num).toDouble(),
    organizerId: json['organizerId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    type: json['type'] as String? ?? 'free',
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
    mediaUrls: (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    premiumDays: json['premiumDays'] as int? ?? 0,
    attendeeIds: (json['attendeeIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    storyUrls: (json['storyUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    reportCount: json['reportCount'] as int? ?? 0,
    isPremiumPaid: json['isPremiumPaid'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'dateTime': dateTime.toIso8601String(),
    'location': location,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'style': style,
    'price': price,
    'organizerId': organizerId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'type': type,
    'expiresAt': expiresAt?.toIso8601String(),
    'mediaUrls': mediaUrls,
    'premiumDays': premiumDays,
    'attendeeIds': attendeeIds,
    'storyUrls': storyUrls,
    'reportCount': reportCount,
    'isPremiumPaid': isPremiumPaid,
  };

  PartyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? dateTime,
    String? location,
    String? city,
    double? latitude,
    double? longitude,
    String? style,
    double? price,
    String? organizerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    DateTime? expiresAt,
    List<String>? mediaUrls,
    int? premiumDays,
    List<String>? attendeeIds,
    List<String>? storyUrls,
    int? reportCount,
    bool? isPremiumPaid,
  }) => PartyModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    dateTime: dateTime ?? this.dateTime,
    location: location ?? this.location,
    city: city ?? this.city,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    style: style ?? this.style,
    price: price ?? this.price,
    organizerId: organizerId ?? this.organizerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    type: type ?? this.type,
    expiresAt: expiresAt ?? this.expiresAt,
    mediaUrls: mediaUrls ?? this.mediaUrls,
    premiumDays: premiumDays ?? this.premiumDays,
    attendeeIds: attendeeIds ?? this.attendeeIds,
    storyUrls: storyUrls ?? this.storyUrls,
    reportCount: reportCount ?? this.reportCount,
    isPremiumPaid: isPremiumPaid ?? this.isPremiumPaid,
  );

  double distanceFrom(double lat, double lon) {
    const double earthRadius = 6371;
    final dLat = _toRadians(latitude - lat);
    final dLon = _toRadians(longitude - lon);
    final a = (dLat / 2).abs() * (dLat / 2).abs() + 
              (lat * lon).abs() * 
              (dLon / 2).abs() * (dLon / 2).abs();
    final c = 2 * (a < 1 ? a : 1);
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;
}

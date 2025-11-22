import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:festou/models/user_model.dart';

class UserService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  final Map<String, UserModel> _usersCache = {};

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  static const String _storageKey = 'current_user_data';

  UserService() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_storageKey);

      if (storedData != null) {
        final decoded = jsonDecode(storedData) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(decoded);
      } else {
        _createDefaultUser();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _createDefaultUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _createDefaultUser() {
    final now = DateTime.now();
    _currentUser = UserModel(
      id: 'user1',
      name: 'João Silva',
      email: 'joao@festou.com',
      photoUrl: null,
      bio: 'Amante de festas e música eletrônica',
      favoriteStyles: ['Eletrônica', 'House', 'Techno'],
      createdAt: now,
      updatedAt: now,
      gender: 'Homem',
      relationshipStatus: 'Solteiro',
    );
  }

  Future<void> _saveToStorage() async {
    if (_currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_currentUser!.toJson());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user.copyWith(updatedAt: DateTime.now());
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? bio, String? photoUrl, List<String>? favoriteStyles, String? gender, String? relationshipStatus, int? age, String? city}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      bio: bio ?? _currentUser!.bio,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      favoriteStyles: favoriteStyles ?? _currentUser!.favoriteStyles,
      gender: gender ?? _currentUser!.gender,
      relationshipStatus: relationshipStatus ?? _currentUser!.relationshipStatus,
      age: age ?? _currentUser!.age,
      city: city ?? _currentUser!.city,
      updatedAt: DateTime.now(),
    );
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> toggleLike(String userId) async {
    if (_currentUser == null) return;
    final targetUser = getUserById(userId);
    List<String> updatedLikes = List.from(targetUser.likedByUserIds);
    
    if (updatedLikes.contains(_currentUser!.id)) {
      updatedLikes.remove(_currentUser!.id);
    } else {
      updatedLikes.add(_currentUser!.id);
    }
    
    final updatedUser = targetUser.copyWith(likedByUserIds: updatedLikes, updatedAt: DateTime.now());
    _usersCache[userId] = updatedUser;
    notifyListeners();
  }

  Future<void> reportUser(String userId) async {
    final targetUser = getUserById(userId);
    final updatedUser = targetUser.copyWith(reportCount: targetUser.reportCount + 1, updatedAt: DateTime.now());
    _usersCache[userId] = updatedUser;
    notifyListeners();
  }

  UserModel getUserById(String userId) {
    if (_currentUser?.id == userId) return _currentUser!;
    if (_usersCache.containsKey(userId)) return _usersCache[userId]!;
    
    final sampleUsers = {
      'user2': UserModel(
        id: 'user2',
        name: 'Maria Santos',
        email: 'maria@festou.com',
        photoUrl: null,
        bio: 'DJ e produtora musical',
        favoriteStyles: ['Samba', 'MPB', 'Bossa Nova'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        gender: 'Mulher',
        relationshipStatus: 'Solteiro',
      ),
      'user3': UserModel(
        id: 'user3',
        name: 'Pedro Costa',
        email: 'pedro@festou.com',
        photoUrl: null,
        bio: 'Organizador de eventos',
        favoriteStyles: ['Funk Brasileiro', 'Axé', 'Forró'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        gender: 'Homem',
        relationshipStatus: 'Compromisso',
      ),
    };
    
    if (sampleUsers.containsKey(userId)) {
      _usersCache[userId] = sampleUsers[userId]!;
      return sampleUsers[userId]!;
    }
    
    final defaultUser = UserModel(
      id: userId,
      name: 'Usuário Festou',
      email: 'usuario@festou.com',
      photoUrl: null,
      bio: 'Amante de festas',
      favoriteStyles: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _usersCache[userId] = defaultUser;
    return defaultUser;
  }
}

import 'package:flutter/foundation.dart';
import 'package:festou/models/boost_model.dart';
import 'package:festou/models/user_model.dart';
import 'package:festou/models/party_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BoostService extends ChangeNotifier {
  List<BoostModel> _boosts = [];
  final Map<String, int> _userImpressionCache = {};

  List<BoostModel> get boosts => _boosts;

  BoostService() {
    _loadBoosts();
  }

  Future<void> _loadBoosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boostsJson = prefs.getString('boosts');
      if (boostsJson != null) {
        final List<dynamic> decoded = json.decode(boostsJson);
        _boosts = decoded.map((e) {
          try {
            return BoostModel.fromJson(e as Map<String, dynamic>);
          } catch (err) {
            debugPrint('Error loading boost: \$err');
            return null;
          }
        }).whereType<BoostModel>().toList();
        _resetDailyImpressionsIfNeeded();
        _deactivateExpiredBoosts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading boosts: \$e');
      _boosts = [];
    }
  }

  Future<void> _saveBoosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boostsJson = json.encode(_boosts.map((e) => e.toJson()).toList());
      await prefs.setString('boosts', boostsJson);
    } catch (e) {
      debugPrint('Error saving boosts: \$e');
    }
  }

  void _resetDailyImpressionsIfNeeded() {
    final now = DateTime.now();
    bool hasChanges = false;
    
    for (int i = 0; i < _boosts.length; i++) {
      final boost = _boosts[i];
      if (boost.isActive && 
          boost.lastImpressionResetDate.day != now.day) {
        _boosts[i] = boost.copyWith(
          impressionsToday: 0,
          lastImpressionResetDate: now,
        );
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      _saveBoosts();
    }
  }

  void _deactivateExpiredBoosts() {
    final now = DateTime.now();
    bool hasChanges = false;
    
    for (int i = 0; i < _boosts.length; i++) {
      final boost = _boosts[i];
      if (boost.isActive && now.isAfter(boost.expiresAt)) {
        _boosts[i] = boost.copyWith(isActive: false);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      _saveBoosts();
      notifyListeners();
    }
  }

  Future<void> createBoost({
    required String partyId,
    required String userId,
    required PartyModel party,
    required List<String> targetGenders,
    required int minAge,
    required int maxAge,
    required List<String> targetCities,
    required double radiusKm,
    required List<String> targetStyles,
    required int totalImpressions,
  }) async {
    final amountPaid = (totalImpressions / 1000) * 21.90;
    final dailyLimit = totalImpressions / party.premiumDays;
    
    final boost = BoostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      partyId: partyId,
      userId: userId,
      targetGenders: targetGenders,
      minAge: minAge,
      maxAge: maxAge,
      targetCities: targetCities,
      radiusKm: radiusKm,
      targetStyles: targetStyles,
      totalImpressions: totalImpressions,
      remainingImpressions: totalImpressions,
      dailyImpressionLimit: dailyLimit,
      impressionsToday: 0,
      lastImpressionResetDate: DateTime.now(),
      amountPaid: amountPaid,
      createdAt: DateTime.now(),
      expiresAt: party.expiresAt ?? DateTime.now().add(Duration(days: party.premiumDays)),
      isActive: true,
    );

    _boosts.add(boost);
    await _saveBoosts();
    notifyListeners();
  }

  List<BoostModel> getActiveBoosts() {
    _resetDailyImpressionsIfNeeded();
    _deactivateExpiredBoosts();
    return _boosts.where((b) => b.isActive && b.remainingImpressions > 0).toList();
  }

  BoostModel? getMatchingBoost(UserModel user, String? excludePartyId) {
    final activeBoosts = getActiveBoosts()
        .where((boost) => boost.partyId != excludePartyId)
        .toList();

    activeBoosts.sort((a, b) {
      final aPriority = (a.amountPaid / a.totalImpressions) * 1000000;
      final bPriority = (b.amountPaid / b.totalImpressions) * 1000000;
      return bPriority.compareTo(aPriority);
    });

    for (final boost in activeBoosts) {
      if (boost.impressionsToday >= boost.dailyImpressionLimit) continue;
      if (boost.remainingImpressions <= 0) continue;
      if (boost.matchesUser(user)) {
        return boost;
      }
    }

    return null;
  }

  Future<void> recordImpression(String boostId, String userId) async {
    final cacheKey = '\$boostId-\$userId';
    if (_userImpressionCache.containsKey(cacheKey)) {
      return;
    }

    final index = _boosts.indexWhere((b) => b.id == boostId);
    if (index == -1) return;

    final boost = _boosts[index];
    if (!boost.isActive || boost.remainingImpressions <= 0) return;
    if (boost.impressionsToday >= boost.dailyImpressionLimit) return;

    _boosts[index] = boost.copyWith(
      remainingImpressions: boost.remainingImpressions - 1,
      impressionsToday: boost.impressionsToday + 1,
    );

    _userImpressionCache[cacheKey] = DateTime.now().millisecondsSinceEpoch;

    await _saveBoosts();
    notifyListeners();
  }

  List<BoostModel> getBoostsByParty(String partyId) {
    return _boosts.where((b) => b.partyId == partyId).toList();
  }

  BoostModel? getBoostById(String id) {
    try {
      return _boosts.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}

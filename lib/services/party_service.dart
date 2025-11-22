import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:festou/models/party_model.dart';

class PartyService extends ChangeNotifier {
  List<PartyModel> _parties = [];
  bool _isLoading = false;

  List<PartyModel> get parties => _parties;
  bool get isLoading => _isLoading;

  static const String _storageKey = 'parties_data';

  PartyService() {
    _initializeSampleData();
  }

  Future<void> _initializeSampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_storageKey);

      if (storedData != null) {
        final List<dynamic> decoded = jsonDecode(storedData);
        _parties = decoded.map((json) {
          try {
            return PartyModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error parsing party: $e');
            return null;
          }
        }).whereType<PartyModel>().toList();

        _removeExpiredParties();

        if (_parties.isEmpty) {
          _createSampleData();
          await _saveToStorage();
        }
      } else {
        _createSampleData();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Error loading parties: $e');
      _createSampleData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _createSampleData() {
    final now = DateTime.now();
    _parties = [
      PartyModel(
        id: '1',
        name: 'Forró do Bom',
        description: 'Autêntico forró nordestino com sanfoneiro ao vivo',
        imageUrl: 'assets/images/Electronic_Music_Festival_null_1763753245022.jpg',
        dateTime: now.add(const Duration(days: 2)),
        location: 'Casa do Forró',
        city: 'São Paulo',
        latitude: -23.5505,
        longitude: -46.6333,
        style: 'Forró',
        price: 30.0,
        organizerId: 'user1',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '2',
        name: 'Samba na Vila',
        description: 'Roda de samba com os melhores sambistas da região',
        imageUrl: 'assets/images/Rock_Concert_Crowd_null_1763753245639.jpg',
        dateTime: now.add(const Duration(days: 5)),
        location: 'Quadra da Vila',
        city: 'São Paulo',
        latitude: -23.5489,
        longitude: -46.6388,
        style: 'Samba',
        price: 25.0,
        organizerId: 'user2',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '3',
        name: 'Sertanejo Raiz',
        description: 'O melhor do sertanejo universitário e raiz',
        imageUrl: 'assets/images/DJ_Performance_null_1763753246270.jpg',
        dateTime: now.add(const Duration(days: 1)),
        location: 'Arena Sertaneja',
        city: 'São Paulo',
        latitude: -23.5475,
        longitude: -46.6361,
        style: 'Sertanejo',
        price: 40.0,
        organizerId: 'user1',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '4',
        name: 'Funk da Favela',
        description: 'Baile funk com os melhores MCs e DJs',
        imageUrl: 'assets/images/Beach_Party_Sunset_null_1763753247197.jpg',
        dateTime: now.add(const Duration(days: 7)),
        location: 'Quadra do Morro',
        city: 'Rio de Janeiro',
        latitude: -23.5520,
        longitude: -46.6300,
        style: 'Funk Brasileiro',
        price: 20.0,
        organizerId: 'user3',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '5',
        name: 'Axé no Verão',
        description: 'Festa de axé com trios elétricos e muito carnaval',
        imageUrl: 'assets/images/Live_Band_Performance_null_1763753247821.jpg',
        dateTime: now.add(const Duration(days: 3)),
        location: 'Praia da Barra',
        city: 'Salvador',
        latitude: -23.5495,
        longitude: -46.6310,
        style: 'Axé',
        price: 35.0,
        organizerId: 'user2',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '6',
        name: 'MPB ao Vivo',
        description: 'Os clássicos da música popular brasileira',
        imageUrl: 'assets/images/Night_Club_Party_null_1763753244490.jpg',
        dateTime: now.add(const Duration(days: 4)),
        location: 'Teatro Municipal',
        city: 'São Paulo',
        latitude: -23.5510,
        longitude: -46.6340,
        style: 'MPB',
        price: 50.0,
        organizerId: 'user3',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '7',
        name: 'Piseiro do Povo',
        description: 'O ritmo que está bombando no Brasil inteiro',
        imageUrl: 'assets/images/Electronic_Music_Festival_null_1763753245022.jpg',
        dateTime: now.add(const Duration(days: 6)),
        location: 'Arena Piseiro',
        city: 'Fortaleza',
        latitude: -23.5500,
        longitude: -46.6320,
        style: 'Piseiro',
        price: 28.0,
        organizerId: 'user1',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '8',
        name: 'Bossa Nova no Jardim',
        description: 'Bossa nova em ambiente intimista e sofisticado',
        imageUrl: 'assets/images/DJ_Performance_null_1763753246270.jpg',
        dateTime: now.add(const Duration(days: 8)),
        location: 'Jardim Botânico',
        city: 'Rio de Janeiro',
        latitude: -23.5485,
        longitude: -46.6350,
        style: 'Bossa Nova',
        price: 60.0,
        organizerId: 'user2',
        createdAt: now,
        updatedAt: now,
      ),
      PartyModel(
        id: '9',
        name: 'Tecnobrega Paraense',
        description: 'O ritmo paraense que conquista todo o Brasil',
        imageUrl: 'assets/images/Beach_Party_Sunset_null_1763753247197.jpg',
        dateTime: now.add(const Duration(days: 9)),
        location: 'Espaço Amazônia',
        city: 'Belém',
        latitude: -23.5515,
        longitude: -46.6325,
        style: 'Tecnobrega',
        price: 25.0,
        organizerId: 'user3',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_parties.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving parties: $e');
    }
  }

  Future<void> addParty(PartyModel party) async {
    _parties.insert(0, party);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateParty(PartyModel party) async {
    final index = _parties.indexWhere((p) => p.id == party.id);
    if (index != -1) {
      _parties[index] = party;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteParty(String id) async {
    _parties.removeWhere((p) => p.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  List<PartyModel> getPartiesByStyle(String? style) {
    if (style == null || style.isEmpty) return _parties;
    return _parties.where((p) => p.style == style).toList();
  }

  List<PartyModel> getPartiesByLocation(String? location) {
    if (location == null || location.isEmpty) return _parties;
    return _parties.where((p) => p.location.toLowerCase().contains(location.toLowerCase())).toList();
  }

  List<PartyModel> getNearbyParties(double lat, double lon, double radiusKm) {
    return _parties.where((p) => p.distanceFrom(lat, lon) <= radiusKm).toList();
  }

  List<String> getAvailableStyles() {
    return _parties.map((p) => p.style).toSet().toList()..sort();
  }

  List<String> getAvailableLocations() {
    return _parties.map((p) => p.location).toSet().toList()..sort();
  }

  List<String> getAvailableCities() {
    return _parties.map((p) => p.city).toSet().toList()..sort();
  }

  void _removeExpiredParties() {
    final now = DateTime.now();
    _parties.removeWhere((party) {
      if (party.expiresAt != null && party.expiresAt!.isBefore(now)) {
        debugPrint('Removing expired party: ${party.name}');
        return true;
      }
      return false;
    });
  }

  bool canCreateFreeParty(DateTime? lastFreePartyDate) {
    if (lastFreePartyDate == null) return true;
    final daysSinceLastParty = DateTime.now().difference(lastFreePartyDate).inDays;
    return daysSinceLastParty >= 30;
  }

  PartyModel? getPartyById(String id) => _parties.firstWhere((p) => p.id == id, orElse: () => _parties.first);

  Future<void> addAttendee(String partyId, String userId) async {
    final party = getPartyById(partyId);
    if (party != null && !party.attendeeIds.contains(userId)) {
      final updatedAttendees = [...party.attendeeIds, userId];
      final updatedParty = party.copyWith(attendeeIds: updatedAttendees);
      await updateParty(updatedParty);
    }
  }

  Future<void> reportParty(String partyId) async {
    final party = getPartyById(partyId);
    if (party != null) {
      final updatedParty = party.copyWith(reportCount: party.reportCount + 1);
      await updateParty(updatedParty);
      debugPrint('Party reported. Total reports: ${updatedParty.reportCount}');
    }
  }

  Future<void> addStory(String partyId, String storyUrl) async {
    final party = getPartyById(partyId);
    if (party != null) {
      final updatedStories = [...party.storyUrls, storyUrl];
      if (updatedStories.length > 10) {
        updatedStories.removeAt(0);
      }
      final updatedParty = party.copyWith(storyUrls: updatedStories);
      await updateParty(updatedParty);
    }
  }
}

import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import '../data/static_data.dart';

class GroupProvider extends ChangeNotifier {
  List<GroupModel> _groups = [];
  String _searchQuery = '';
  List<String> _selectedTags = [];
  bool _isLoading = false;

  List<GroupModel> get groups => _groups;
  String get searchQuery => _searchQuery;
  List<String> get selectedTags => _selectedTags;
  bool get isLoading => _isLoading;
  List<String> get availableTags => StaticData.availableTags;

  List<GroupModel> get filteredGroups {
    return _groups.where((group) {
      final matchesSearch = group.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTags = _selectedTags.isEmpty ||
          _selectedTags.any((tag) => group.tags.contains(tag));
      return matchesSearch && matchesTags;
    }).toList();
  }

  void loadGroups(String userId) {
    _isLoading = true;
    notifyListeners();

    _groups = StaticData.groups
        .where((group) => group.memberIds.contains(userId))
        .toList();

    _groups.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTags.clear();
    notifyListeners();
  }

  GroupModel? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (e) {
      return StaticData.groups.firstWhere((g) => g.id == id);
    }
  }

  List<UserModel> getGroupMembers(String groupId) {
    final group = getGroupById(groupId);
    if (group == null) return [];
    return StaticData.users
        .where((user) => group.memberIds.contains(user.id))
        .toList();
  }

  Future<GroupModel> createGroup({
    required String name,
    required List<String> tags,
    required List<String> memberIds,
    required String createdBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final newGroup = GroupModel(
      id: 'group${StaticData.groups.length + 1}',
      name: name,
      tags: tags,
      memberIds: [...memberIds, createdBy],
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    StaticData.groups.add(newGroup);
    _groups.insert(0, newGroup);

    _isLoading = false;
    notifyListeners();

    return newGroup;
  }

  void updateGroupLastMessage(String groupId, String message) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index] = _groups[index].copyWith(
        lastMessage: message,
        lastMessageTime: DateTime.now(),
      );

      final staticIndex = StaticData.groups.indexWhere((g) => g.id == groupId);
      if (staticIndex != -1) {
        StaticData.groups[staticIndex] = _groups[index];
      }

      notifyListeners();
    }
  }
}
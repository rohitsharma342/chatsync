import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../models/user_model.dart';
import '../data/static_data.dart';
import '../widgets/member_chip.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _memberSearchController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<UserModel> _selectedMembers = [];
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  void _searchMembers(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final results = StaticData.users.where((user) {
      final matchesQuery = user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase());
      final isNotCurrentUser = user.id != currentUserId;
      final isNotAlreadySelected =
          !_selectedMembers.any((m) => m.id == user.id);
      return matchesQuery && isNotCurrentUser && isNotAlreadySelected;
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = true;
    });
  }

  void _addMember(UserModel user) {
    setState(() {
      _selectedMembers.add(user);
      _searchResults = [];
      _memberSearchController.clear();
      _isSearching = false;
    });
  }

  void _removeMember(UserModel user) {
    setState(() {
      _selectedMembers.removeWhere((m) => m.id == user.id);
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMembers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one member'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();

      final newGroup = await groupProvider.createGroup(
        name: _groupNameController.text.trim(),
        tags: _selectedTags,
        memberIds: _selectedMembers.map((m) => m.id).toList(),
        createdBy: authProvider.currentUser!.id,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.groupChat,
          arguments: {'groupId': newGroup.id},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Group Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _groupNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Enter group name',
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a group name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: groupProvider.availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        final colorIndex =
                            tag.hashCode % AppTheme.tagColors.length;
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) => _toggleTag(tag),
                          backgroundColor: AppTheme.tagColors[colorIndex],
                          selectedColor:
                              AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Add Members',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _memberSearchController,
                      onChanged: _searchMembers,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    if (_isSearching && _searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.pastelBlue,
                                child: Text(
                                  user.initials,
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(user.name),
                              subtitle: Text(
                                user.email,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: AppTheme.primaryColor,
                                ),
                                onPressed: () => _addMember(user),
                              ),
                              onTap: () => _addMember(user),
                            );
                          },
                        ),
                      ),
                    if (_isSearching && _searchResults.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No users found',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ),
                    if (_selectedMembers.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Selected Members',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedMembers.map((user) {
                          return MemberChip(
                            user: user,
                            onRemove: () => _removeMember(user),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          groupProvider.isLoading ? null : _createGroup,
                      child: groupProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create Group'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
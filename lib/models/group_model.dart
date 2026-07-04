class GroupModel {
  final String id;
  final String name;
  final List<String> tags;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  GroupModel({
    required this.id,
    required this.name,
    required this.tags,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    List<String>? tags,
    List<String>? memberIds,
    String? createdBy,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}
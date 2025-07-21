// lib/models/profile_model.dart

class Profile {
  final String id;
  final String username;
  final String? avatarUrl;

  Profile({required this.id, required this.username, this.avatarUrl});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'avatar_url': avatarUrl};
  }
}

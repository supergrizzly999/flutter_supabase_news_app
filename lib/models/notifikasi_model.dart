class NotifikasiModel {
  final String id;
  final String? judul;
  final String? pesan;
  final DateTime createdAt;
  final String? userId;
  final String? username;
  final String? imageUrl;

  NotifikasiModel({
    required this.id,
    this.judul,
    this.pesan,
    required this.createdAt,
    this.userId,
    this.username,
    this.imageUrl,
  });

  factory NotifikasiModel.fromMap(Map<String, dynamic> map) {
    return NotifikasiModel(
      id: map['id'].toString(),
      judul: map['judul'] as String?,
      pesan: map['pesan'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      userId: map['user_id'] as String?,
      username: map['profiles'] != null ? map['profiles']['username'] as String? : null,
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pesan': pesan,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'image_url': imageUrl,
    };
  }
}

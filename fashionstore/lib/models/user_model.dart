class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isAdmin;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.isAdmin = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? 'User',
      photoUrl: map['photoUrl'],
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
    };
  }
}
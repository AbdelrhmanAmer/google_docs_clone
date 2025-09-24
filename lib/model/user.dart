class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String profilePic;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.profilePic,
  });

  // ✅ Map representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'profilePic': profilePic,
    };
  }

  // ✅ Factory constructor from Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      profilePic: json['profilePic'] ?? '',
    );
  }

  // ✅ CopyWith for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? profilePic,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}

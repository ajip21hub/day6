/// User Entity
/// Entity adalah business object yang digunakan di ViewModel dan business logic
/// Entity tidak tergantung pada framework atau external library
/// Entity tidak punya fromJson/toJson (pure Dart class)

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  /// Copy with method untuk immutable object
  /// Berguna untuk update partial data tanpa mutate original object
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

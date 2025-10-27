import '../../domain/entities/user.dart';

/// User Model
/// Model adalah representasi data dari API (data transfer object)
/// Model punya fromJson dan toJson untuk convert dari/ke JSON
/// Model bisa di-convert ke Entity untuk digunakan di business logic

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final String createdAt; // String karena dari API format ISO 8601

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  /// Factory constructor untuk convert JSON ke UserModel
  /// JSON biasanya dari API response
  /// 
  /// Contoh JSON:
  /// {
  ///   "id": "123",
  ///   "email": "user@example.com",
  ///   "name": "John Doe",
  ///   "phone": "08123456789",
  ///   "photoUrl": "https://example.com/photo.jpg",
  ///   "createdAt": "2024-01-15T10:30:00Z"
  /// }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convert UserModel ke JSON
  /// Digunakan saat mengirim data ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }

  /// Convert UserModel ke User Entity
  /// Entity digunakan di ViewModel dan business logic
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      createdAt: DateTime.parse(createdAt), // Convert string ke DateTime
    );
  }

  /// Factory constructor untuk convert Entity ke Model
  /// Digunakan saat mau save entity ke API
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt.toIso8601String(), // Convert DateTime ke string
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name)';
  }
}

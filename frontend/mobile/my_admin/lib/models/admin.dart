class Admin {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'],
    );
  }
}

class AdminUpdateDTO {
  final String name;
  final String email;
  final String? profilePicture;

  AdminUpdateDTO({
    required this.name,
    required this.email,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
    };
  }
}

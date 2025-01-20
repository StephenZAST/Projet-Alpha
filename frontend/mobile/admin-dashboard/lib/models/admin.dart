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
}

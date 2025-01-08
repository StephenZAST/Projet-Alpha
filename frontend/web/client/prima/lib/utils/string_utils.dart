String getInitials(String? firstName, String? lastName) {
  if (firstName == null || firstName.isEmpty) {
    return 'U';
  }

  String firstInitial = firstName[0].toUpperCase();
  String secondInitial =
      lastName != null && lastName.isNotEmpty ? lastName[0].toUpperCase() : '';

  return '$firstInitial$secondInitial';
}

String getDisplayName(String? firstName, String? lastName) {
  if (firstName == null || firstName.isEmpty) {
    return 'Mr';
  }

  return lastName != null && lastName.isNotEmpty
      ? '$firstName $lastName'
      : firstName;
}

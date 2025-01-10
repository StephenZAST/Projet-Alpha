class NameFormatter {
  static String getInitials(String? firstName, String? lastName) {
    if (firstName == null || lastName == null) return '??';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  static String getFullName(String? firstName, String? lastName) {
    if (firstName == null || lastName == null) return 'Utilisateur';
    return '$firstName $lastName';
  }

  static String getFormattedName(String? firstName, String? lastName) {
    if (firstName == null || lastName == null) return 'M./Mme.';
    return 'M./Mme. $lastName';
  }
}

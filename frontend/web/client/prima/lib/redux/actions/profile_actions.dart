// Actions de chargement du profil
class LoadProfileAction {}

class LoadProfileSuccessAction {
  final Map<String, dynamic> profile;
  LoadProfileSuccessAction(this.profile);
}

class LoadProfileFailureAction {
  final String error;
  LoadProfileFailureAction(this.error);
}

// Actions de mise à jour du profil
class UpdateProfileAction {
  final Map<String, dynamic> profile;
  UpdateProfileAction(this.profile);
}

class UpdateProfileSuccessAction {
  final Map<String, dynamic> profile;
  UpdateProfileSuccessAction(this.profile);
}

class UpdateProfileFailureAction {
  final String error;
  UpdateProfileFailureAction(this.error);
}

// Action de nettoyage du profil
class ClearProfileAction {}

import os
import re
import time
import threading
from typing import List

# Zone où coller les chemins des fichiers (un par ligne)
PATHS_TO_PROCESS = """
frontend/mobile/admin-dashboard/lib/controllers/users_controller.dart
frontend/mobile/admin-dashboard/lib/screens/users/users_screen.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/active_filter_indicator.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/adaptive_user_view.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_grid_item.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_grid.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_list.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_search_bar.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/view_toggle.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/active_filter_indicator.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/adaptive_user_view.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_grid_item.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_grid.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_list.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_search_bar.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/view_toggle.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/active_filter_indicator.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/adaptive_user_view.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_grid_item.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_grid.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_list.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/user_search_bar.dart
frontend/mobile/admin-dashboard/lib/screens/users/components/view_toggle.dart
frontend/mobile/admin-dashboard/lib/screens/users/users_screen.dart
frontend/mobile/admin-dashboard/lib/widgets/shared/pagination_controls.dart
frontend/mobile/admin-dashboard/lib/widgets/shared/pagination_controls.dart
frontend/mobile/admin-dashboard/lib/constants.dart
""".strip()

# Configuration
COMMENT = "// Ceci est un commentaire ajouté en bulk"
DELAY_MINUTES = 1  # Délai en minutes avant la suppression automatique

def clean_paths(paths_text: str) -> List[str]:
    """Nettoie et valide les chemins fournis."""
    paths = []
    seen_paths = set()  # Pour éliminer les doublons
    for line in paths_text.split('\n'):
        path = line.strip()
        if path and not path.startswith('#'):  # Ignore les lignes vides et commentées
            if path not in seen_paths:  # Éviter les doublons
                if os.path.exists(path):
                    paths.append(path)
                    seen_paths.add(path)
                else:
                    print(f"Attention: Le chemin n'existe pas: {path}")
    return paths

def process_file(file_path: str, comment: str, operation: str = "ajouter") -> None:
    """Traite un fichier individuel pour ajouter ou supprimer le commentaire."""
    try:
        with open(file_path, 'r+', encoding='utf-8') as f:
            content = f.read()
            f.seek(0, 0)

            if operation == "ajouter":
                if not content.startswith(comment):
                    f.write(f"{comment}\n{content}")
                    print(f"Commentaire ajouté : {file_path}")
                else:
                    print(f"Commentaire déjà présent : {file_path}")
                    return
            elif operation == "supprimer":
                if content.startswith(comment):
                    new_content = content.replace(f"{comment}\n", "", 1)
                    f.seek(0)
                    f.write(new_content)
                    f.truncate()
                    print(f"Commentaire supprimé : {file_path}")
                else:
                    print(f"Aucun commentaire trouvé : {file_path}")
                    return

            f.truncate()
    except Exception as e:
        print(f"Erreur lors du traitement de {file_path}: {e}")

def delayed_removal(paths: List[str], comment: str, delay_minutes: float) -> None:
    """Fonction qui s'exécute après un délai pour supprimer les commentaires."""
    print(f"\nProgrammation de la suppression des commentaires dans {delay_minutes} minutes...")
    time.sleep(delay_minutes * 120)  # Convertir minutes en secondes
    print("\nSuppression des commentaires...")
    
    for path in paths:
        process_file(path, comment, "supprimer")
    
    print("\nSuppression des commentaires terminée.")

def main():
    # Nettoyer et valider les chemins
    paths = clean_paths(PATHS_TO_PROCESS)
    
    if not paths:
        print("Aucun chemin valide trouvé.")
        return

    print(f"\nTraitement de {len(paths)} fichiers...")
    
    # Ajouter les commentaires
    for path in paths:
        process_file(path, COMMENT, "ajouter")
    
    print("\nAjout des commentaires terminé.")
    
    # Lancer la suppression automatique dans un thread séparé
    if DELAY_MINUTES > 0:
        removal_thread = threading.Thread(
            target=delayed_removal,
            args=(paths, COMMENT, DELAY_MINUTES)
        )
        removal_thread.daemon = True  # Le thread s'arrêtera quand le programme principal s'arrête
        removal_thread.start()
        
        print(f"\nAppuyez sur Ctrl+C pour arrêter le programme avant la suppression automatique...")
        try:
            # Attendre que le thread de suppression se termine
            removal_thread.join()
        except KeyboardInterrupt:
            print("\nProgramme arrêté par l'utilisateur.")

if __name__ == "__main__":
    main()
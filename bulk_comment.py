import os
import re

# Liste des dossiers à traiter avec leurs extensions
DIRECTORIES_TO_PROCESS = [
    {
        "path": "frontend/mobile/admin-dashboard/lib",
        "extension": ".dart"
    },
    # {
    #     "path": "backend/src",
    #     "extension": ".ts"
    # },
    {
        "path": "backend\prisma\db_functions",
        "extension": ".md"
    }
]

# Liste des chemins à exclure - Ajoutez simplement vos chemins ici
PATHS_TO_EXCLUDE = [
    # Exemple de chemins à exclure (un par ligne)
    "frontend/mobile/admin-dashboard/lib/screens/settings",
    "frontend/mobile/admin-dashboard/lib/screens/services",
    "frontend/mobile/admin-dashboard/lib/screens/reports",
    "frontend/mobile/admin-dashboard/lib/screens/profile",
    "frontend/mobile/admin-dashboard/lib/screens/orders",
    "frontend/mobile/admin-dashboard/lib/screens/notifications",
    "frontend/mobile/admin-dashboard/lib/screens/delivery",
    "frontend/mobile/admin-dashboard/lib/screens/dashboard",
    "frontend/mobile/admin-dashboard/lib/screens/components",
    "frontend/mobile/admin-dashboard/lib/screens/categories",
    "frontend/mobile/admin-dashboard/lib/screens/articles",
    "frontend/mobile/admin-dashboard/lib/screens/analytics",
    "frontend/mobile/admin-dashboard/lib/screens/affiliates",
    "frontend/mobile/admin-dashboard/lib/screens/auth",
    "frontend/mobile/admin-dashboard/lib/screens/logs",
    # Ajoutez d'autres chemins à exclure ici
]

def should_process_file(file_path: str) -> bool:
    """Vérifie si un fichier doit être traité ou exclu."""
    # Normaliser le chemin pour la comparaison
    normalized_path = os.path.normpath(file_path)
    
    # Vérifier si le chemin est dans la liste des exclusions
    for exclude_path in PATHS_TO_EXCLUDE:
        normalized_exclude = os.path.normpath(exclude_path)
        if normalized_path.startswith(normalized_exclude):
            return False
    return True

def process_file(file_path: str, comment: str, operation: str) -> None:
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

def process_directories(comment: str, operation: str) -> None:
    """Traite tous les dossiers configurés."""
    for dir_config in DIRECTORIES_TO_PROCESS:
        path = dir_config["path"]
        extension = dir_config["extension"]
        
        if not os.path.exists(path):
            print(f"Dossier non trouvé : {path}")
            continue

        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith(extension):
                    file_path = os.path.join(root, file)
                    if should_process_file(file_path):
                        process_file(file_path, comment, operation)

def main():
    # Configuration
    comment = "// context bulk comment"  # Modifiez le commentaire ici
    operation = "supprimer"  # "ajouter" ou "supprimer"
    
    # Exécution
    process_directories(comment, operation)
    print("\nScript terminé.")

if __name__ == "__main__":
    main()
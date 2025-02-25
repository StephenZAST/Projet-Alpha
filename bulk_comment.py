import os
import re

def process_files(root_dir, file_extension, comment, operation):
    """
    Ajoute ou supprime un commentaire en header de tous les fichiers avec l'extension spécifiée.

    Args:
        root_dir (str): Le dossier racine à parcourir.
        file_extension (str): L'extension des fichiers à traiter (ex: "dart", "ts").
        comment (str): Le commentaire à ajouter ou supprimer.
        operation (str): "ajouter" ou "supprimer".
    """
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(f".{file_extension}"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r+', encoding='utf-8') as f:
                        content = f.read()
                        f.seek(0, 0)  # Retourne au début du fichier

                        if operation == "ajouter":
                            f.write(comment.rstrip('\r\n') + '\n' + content)
                        elif operation == "supprimer":
                            comment_pattern = re.escape(comment.rstrip('\r\n'))  # Échappe les caractères spéciaux pour la regex
                            new_content = re.sub(f"^{comment_pattern}\n?", '', content, flags=re.MULTILINE)
                            f.write(new_content)
                        else:
                            print(f"Opération non reconnue: {operation}")
                            continue

                        f.truncate()  # Supprime le reste du fichier après l'écriture
                    print(f"Fichier modifié: {file_path}")
                except Exception as e:
                    print(f"Erreur lors du traitement de {file_path}: {e}")

# Configuration
folders = [
    ("frontend/mobile/admin-dashboard/lib", "dart"),
    ("backend/src", "ts")
    ("backend\prisma\db_functions", "md")
]
comment_to_add = "// context comment"  # Remplacez par votre commentaire
operation_type = "ajouter"  # "ajouter" ou "supprimer"

# Exécution
for folder, extension in folders:
    process_files(folder, extension, comment_to_add, operation_type)

print("Script terminé.")
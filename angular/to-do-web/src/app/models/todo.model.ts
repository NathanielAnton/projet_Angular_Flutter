export interface Todo {
  id?: string; // ID Firestore (optionnel)
  title: string; // Titre de la tâche
  description: string; // Description
  status: number; // Statut : 1 = terminé, 0 = en cours
  created_at: string; // Date de création
  updated_at: string; // Date de mise à jour
}

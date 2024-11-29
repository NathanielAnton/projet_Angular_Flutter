import { Injectable } from '@angular/core';
import { AngularFirestore } from '@angular/fire/compat/firestore';
import { map, Observable } from 'rxjs';
import { Todo } from '../models/todo.model';

@Injectable({
  providedIn: 'root'
})
export class TodoService {
  private collectionName = 'tasks';

  constructor(private firestore: AngularFirestore) { }

  getTodos(): Observable<Todo[]> {
    return this.firestore.collection<Todo>(this.collectionName).snapshotChanges().pipe(
      map(actions => actions.map(a => {
        const data = a.payload.doc.data() as Todo;
        const id = a.payload.doc.id;
        return { id, ...data };
      }))
    );
  }

  createTodo(todo: Todo): Promise<void> {
    const id = this.firestore.createId();
    return this.firestore.collection(this.collectionName).doc(id).set(todo);
  }

  updateTodoStatus(todo: Todo): Promise<void> {
    return this.firestore.collection(this.collectionName)
      .doc(todo.id)
      .update({ status: todo.status });
  }

  deleteTodo(todoId: string): Promise<void> {
    return this.firestore.collection(this.collectionName)
      .doc(todoId)
      .delete();
  }

  updateTodo(todo: Todo): Promise<void> {
    if (!todo.id) {
      return Promise.reject('ID du document manquant');
    }

    return this.firestore.collection(this.collectionName).doc(todo.id).update({
      title: todo.title,
      description: todo.description,
      status: todo.status,
      updated_at: todo.updated_at
    });
  }
}

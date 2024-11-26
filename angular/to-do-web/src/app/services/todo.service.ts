import { Injectable } from '@angular/core';
import { AngularFirestore } from '@angular/fire/compat/firestore';
import { Observable } from 'rxjs';
import { Todo } from '../models/todo.model';

@Injectable({
  providedIn: 'root'
})
export class TodoService {
  private collectionName = 'tasks';

  constructor(private firestore: AngularFirestore) { }

  getTodos(): Observable<Todo[]> {
    return this.firestore.collection<Todo>(this.collectionName).valueChanges({ idField: 'id' });
  }

  createTodo(todo: Todo): Promise<void> {
    const id = this.firestore.createId();
    return this.firestore.collection(this.collectionName).doc(id).set(todo);
  }
}

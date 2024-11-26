import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { Todo } from '../../models/todo.model';
import { TodoService } from '../../services/todo.service';
import * as bootstrap from 'bootstrap';

@Component({
  selector: 'app-todo',
  templateUrl: './todo.component.html',
  styleUrls: ['./todo.component.scss']
})
export class TodoComponent implements OnInit {
  @ViewChild('addTaskModal', { static: false }) addTaskModal!: ElementRef;

  openModal() {
    const modalElement = this.addTaskModal.nativeElement;
    const modal = new bootstrap.Modal(modalElement);
    modal.show();
  }
  todos: Todo[] = [];
  todosToDo: Todo[] = [];
  todosInProgress: Todo[] = [];
  todosDone: Todo[] = [];
  newTodo: Todo = {
    title: '',
    description: '',
    status: 0, // Par défaut, "en cours"
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  constructor(private todoService: TodoService) { }

  ngOnInit(): void {
    this.getTodos();
  }

  getTodos(): void {
    this.todoService.getTodos().subscribe((todos) => {
      this.todos = todos;
      this.todosToDo = this.todos.filter(todo => todo.status === 0);
      this.todosInProgress = this.todos.filter(todo => todo.status === 1);
      this.todosDone = this.todos.filter(todo => todo.status === 2);
    });
  }

  createTodo(): void {
    this.newTodo.created_at = new Date().toISOString();
    this.newTodo.updated_at = new Date().toISOString();
    this.newTodo.status = parseInt(this.newTodo.status.toString(), 10);

    this.todoService.createTodo(this.newTodo).then(() => {
      // Réinitialise le formulaire
      this.newTodo = {
        title: '',
        description: '',
        status: 0,
        created_at: '',
        updated_at: ''
      };

      // Recharge la liste des tâches
      this.getTodos();
    }).catch((error) => {
      console.error('Erreur lors de la création de la tâche :', error);
    });
  }

  changeStatus(todo: Todo): void {
    if (todo.status === 0) {
      todo.status = 1;  // "En cours"
    } else if (todo.status === 1) {
      todo.status = 2;  // "Terminé"
    } else if (todo.status === 2) {
      todo.status = 0;  // "À faire"
    }

    this.todoService.updateTodoStatus(todo).then(() => {
      console.log('Statut mis à jour');
    }).catch((error) => {
      console.error('Erreur lors de la mise à jour du statut:', error);
    });
  }

  deleteTodo(todo: Todo): void {
    if (todo.id) {  // Vérifie si l'ID est défini
      this.todoService.deleteTodo(todo.id).then(() => {
        console.log('Tâche supprimée');
        // Recharger la liste après suppression
        this.getTodos();
      }).catch((error) => {
        console.error('Erreur lors de la suppression de la tâche:', error);
      });
    } else {
      console.error('L\'ID de la tâche est manquant');
    }
  }
}

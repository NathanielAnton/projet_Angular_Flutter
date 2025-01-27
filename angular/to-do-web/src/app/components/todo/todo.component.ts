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
  @ViewChild('editTaskModal', { static: false }) editTaskModal!: ElementRef;
  selectedTodo: Todo = {
    title: '',
    description: '',
    status: 0,
    created_at: '',
    updated_at: '',
    id: ''
  };

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
    status: 0,
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
      this.newTodo = {
        title: '',
        description: '',
        status: 0,
        created_at: '',
        updated_at: ''
      };

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
    }

    this.todoService.updateTodoStatus(todo).then(() => {
      console.log('Statut mis à jour');
    }).catch((error) => {
      console.error('Erreur lors de la mise à jour du statut:', error);
    });
  }

  deleteTodo(todo: Todo): void {
    if (todo.id) {
      this.todoService.deleteTodo(todo.id).then(() => {
        console.log('Tâche supprimée');
        this.getTodos();
      }).catch((error) => {
        console.error('Erreur lors de la suppression de la tâche:', error);
      });
    } else {
      console.error('L\'ID de la tâche est manquant');
    }
  }

  editTodo(todo: Todo): void {
    this.selectedTodo = { ...todo, status: Number(todo.status) };

    const modalElement = this.editTaskModal.nativeElement;
    const modal = new bootstrap.Modal(modalElement);
    modal.show();
  }


  updateTodo(): void {
    this.selectedTodo.status = Number(this.selectedTodo.status);

    this.selectedTodo.updated_at = new Date().toISOString();

    if (this.selectedTodo.id) {
      this.todoService.updateTodo(this.selectedTodo).then(() => {
        console.log('Tâche mise à jour');
        this.getTodos();
      }).catch((error) => {
        console.error('Erreur lors de la mise à jour de la tâche :', error);
      });
    } else {
      console.error('ID de la tâche manquant');
    }
  }
}

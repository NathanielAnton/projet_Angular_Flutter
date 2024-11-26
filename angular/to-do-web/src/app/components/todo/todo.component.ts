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

  // Récupère les tâches depuis Firestore
  getTodos(): void {
    this.todoService.getTodos().subscribe((todos) => {
      this.todos = todos;
    });
  }

  // Crée une nouvelle tâche
  createTodo(): void {
    this.newTodo.created_at = new Date().toISOString();
    this.newTodo.updated_at = new Date().toISOString();

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
}

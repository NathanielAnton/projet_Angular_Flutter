import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { TodoComponent } from './components/todo/todo.component';

const routes: Routes = [
  { path: '', component: TodoComponent },
  { path: '**', redirectTo: '' } // Redirection par défaut
];
@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

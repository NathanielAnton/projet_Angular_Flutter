import { Component } from '@angular/core';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  email = '';
  password = '';
  errorMessage = '';

  constructor(private authService: AuthService) {}

  login() {
    this.authService.signIn(this.email, this.password)
      .then(() => {
        console.log('Login successful');
        // Redirigez vers la page des tâches ou un tableau de bord
      })
      .catch((error) => {
        console.error('Login error:', error);
        this.errorMessage = 'Invalid email or password.';
      });
  }
}

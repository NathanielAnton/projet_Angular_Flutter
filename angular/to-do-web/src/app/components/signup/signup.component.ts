import { Component } from '@angular/core';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-signup',
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.css']
})
export class SignUpComponent {
  email = '';
  password = '';
  errorMessage = '';

  constructor(private authService: AuthService) {}

  signUp() {
    this.authService.signUp(this.email, this.password)
      .then(() => {
        console.log('Sign Up successful');
        // Redirigez vers la page de connexion ou autre
      })
      .catch((error) => {
        console.error('Sign Up error:', error);
        this.errorMessage = 'Could not create account. Please try again.';
      });
  }
}

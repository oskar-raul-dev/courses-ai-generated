import { HttpErrorResponse } from '@angular/common/http';
import { Component } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';

import { AuthService } from '../../../core/auth.service';

/**
 * El tipo del formulario, escrito a mano porque la migración de Angular 14 lo
 * dejó a medias. Ver la nota de abajo: ese `| null` no significa nada.
 */
interface LoginForm {
  email: FormControl<string | null>;
  password: FormControl<string | null>;
}

@Component({
  selector: 'cc-login',
  templateUrl: './login.component.html',
})
export class LoginComponent {
  readonly form: FormGroup<LoginForm>;

  errorMessage: string | null = null;
  submitting = false;

  constructor(
    private readonly formBuilder: FormBuilder,
    private readonly authService: AuthService,
    private readonly router: Router,
    private readonly route: ActivatedRoute,
  ) {
    // El formulario se arma en el constructor y no en el campo, porque el
    // campo se inicializaría antes de que formBuilder exista.
    this.form = this.formBuilder.group<LoginForm>({
      email: this.formBuilder.control('', [Validators.required, Validators.email]),
      password: this.formBuilder.control('', [Validators.required]),
    });
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const { email, password } = this.form.getRawValue();

    // Esta guarda no puede dispararse nunca: los dos controles son requeridos
    // y el formulario ya pasó por invalid. Está aquí porque los controles se
    // tipan como `string | null` y strict exige tratarlo. Es el costo exacto
    // del `nonNullable` que nadie puso en 2024 — ver la nota de migración.
    if (email === null || password === null) {
      return;
    }

    this.submitting = true;
    this.errorMessage = null;

    this.authService.login({ email, password }).subscribe({
      next: () => {
        // returnUrl: a dónde iba el usuario cuando el guard lo interceptó.
        // Sin esto, todo el mundo aterriza en el panel y tiene que volver a
        // navegar, que es la clase de fricción que nadie reporta y todos odian.
        const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') ?? '/dashboard';
        void this.router.navigateByUrl(returnUrl);
      },
      error: (error: unknown) => {
        this.submitting = false;
        this.errorMessage =
          error instanceof HttpErrorResponse && error.status === 401
            ? 'Credenciales inválidas. Revisa el correo y la contraseña.'
            : 'No se pudo conectar con el servidor. Intenta de nuevo.';
      },
    });
  }
}

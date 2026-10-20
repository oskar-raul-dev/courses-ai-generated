import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { SharedModule } from '../shared/shared.module';
import { ShellComponent } from './shell/shell.component';

@NgModule({
  declarations: [ShellComponent],
  // RouterModule aparte de SharedModule: el shell necesita router-outlet y
  // routerLink, que son directivas del router y no de Material.
  imports: [SharedModule, RouterModule],
  exports: [ShellComponent],
})
export class LayoutModule {}

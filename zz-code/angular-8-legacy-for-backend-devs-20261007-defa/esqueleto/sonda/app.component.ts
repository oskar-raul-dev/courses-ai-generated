// Probe page: renders the same instants three ways so a headless browser in any zone can be checked.
import { Component } from '@angular/core';
import { environment } from '../environments/environment';
import { AppConfigService } from './core/config/app-config.service';

@Component({
  selector: 'app-root',
  template: `
    <table id="sonda">
      <tr *ngFor="let at of instants">
        <td class="at">{{ at }}</td>
        <td class="env-medium">{{ at | appDate:'medium':envZone }}</td>
        <td class="cfg-short">{{ at | appDate:'short':configZone }}</td>
        <td class="date-iana">{{ at | date:'medium':envZone }}</td>
      </tr>
    </table>
    <p id="config">{{ configName }} {{ configZone }}</p>
  `
})
export class AppComponent {
  instants = [
    '2022-01-03T08:15:00-05:00',   // incidente 04: lastOrderDate, winter
    '2021-12-31T20:15:00-05:00',   // incidente 07: sample 612
    '2022-01-04T01:30:00-05:00',   // Fase 13 ex. 13: 01:30 in Ottawa
    '2021-07-01T03:40:00Z'         // summer: 23:40 of June 30 in Ottawa (-04:00)
  ];
  envZone = environment.timeZone;
  configZone: string;
  configName: string;
  constructor(config: AppConfigService) {
    this.configZone = config.timeZone;
    this.configName = config.environmentName;
  }
}

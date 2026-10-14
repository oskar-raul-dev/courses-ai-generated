// src/app/shared/app-date.pipe.ts
import { Inject, LOCALE_ID, Pipe, PipeTransform } from '@angular/core';
import { formatDate } from '@angular/common';

// Same contract as DatePipe (value, format, timezone), but the timezone is an
// IANA id. DatePipe in Angular 8 silently ignores IANA ids and falls back to
// the browser's zone; this pipe turns the id into the offset that zone had at
// that instant, which is the only form formatDate understands.
@Pipe({ name: 'appDate' })
export class AppDatePipe implements PipeTransform {

  constructor(@Inject(LOCALE_ID) private locale: string) { }

  transform(value: any, format: string = 'mediumDate', timeZone?: string): string | null {
    if (value == null || value === '') {
      return null;
    }
    var date = new Date(value);
    return formatDate(date, format, this.locale, timeZone ? offsetAt(date, timeZone) : undefined);
  }
}

// Offset of `timeZone` at the instant `date`, as '-0500' / '-0400'.
// Intl knows the zone rules, daylight saving included; formatDate does not.
export function offsetAt(date: Date, timeZone: string): string {
  var parts: any = {};
  new Intl.DateTimeFormat('en-US', {
    timeZone: timeZone, hour12: false,
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', second: '2-digit'
  }).formatToParts(date).forEach(function (part) { parts[part.type] = part.value; });

  // Some engines write midnight as "24" when hour12 is false.
  var hour = parts.hour === '24' ? 0 : +parts.hour;
  // The wall-clock time in that zone, read as if it were UTC, minus the real
  // instant: what is left is the zone's offset at that moment.
  var wallClockAsUtc = Date.UTC(+parts.year, +parts.month - 1, +parts.day,
                                hour, +parts.minute, +parts.second);
  var minutes = Math.round((wallClockAsUtc - Math.floor(date.getTime() / 1000) * 1000) / 60000);

  var sign = minutes < 0 ? '-' : '+';
  var abs = Math.abs(minutes);
  return sign + ('0' + Math.floor(abs / 60)).slice(-2) + ('0' + abs % 60).slice(-2);
}

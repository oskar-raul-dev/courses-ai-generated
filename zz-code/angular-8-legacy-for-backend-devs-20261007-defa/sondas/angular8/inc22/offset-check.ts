// src/app/shared/offset-check.ts
import { offsetAt } from './app-date.pipe';

// True when an ISO string carries a hand-written offset that the zone did not
// have at that instant: the Era 1 '-05:00' written in summer. 'Z' and strings
// without an offset are not judged here.
export function offsetDoesNotMatchZone(iso: string, timeZone: string): boolean {
  var match = /([+-])(\d\d):(\d\d)$/.exec(iso);
  if (!match) { return false; }
  return match[1] + match[2] + match[3] !== offsetAt(new Date(iso), timeZone);
}

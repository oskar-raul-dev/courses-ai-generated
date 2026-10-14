  formatDate(iso: string): string {
    if (!iso) { return ''; }
    return new Date(iso).toLocaleString('es', { timeZone: environment.timeZone });
  }

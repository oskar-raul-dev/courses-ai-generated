function toLocalDate(isoDate: string): Date {
  var parts = isoDate.split('-');
  return new Date(+parts[0], +parts[1] - 1, +parts[2]);
}

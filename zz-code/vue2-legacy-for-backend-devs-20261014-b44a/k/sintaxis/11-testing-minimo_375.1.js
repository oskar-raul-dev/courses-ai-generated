function __f(){


describe("ticketTransitions", function () {
  it("un ticket abierto solo puede pasar a en progreso", function () {
    expect(nextStatuses("open")).toEqual(["in_progress"]);
  });

  it("un ticket resuelto puede cerrarse o reabrirse", function () {
    expect(nextStatuses("resolved")).toEqual(["closed", "open"]);
  });

  it("un estado desconocido no ofrece transiciones (y no revienta)", function () {
    expect(nextStatuses("estado-corrupto")).toEqual([]);
    expect(nextStatuses(undefined)).toEqual([]);
  });

  it("ningún estado permite quedarse donde está", function () {
    Object.keys(TRANSITIONS).forEach(function (status) {
      expect(TRANSITIONS[status]).not.toContain(status);
    });
  });
});
}
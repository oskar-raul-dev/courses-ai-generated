function __f(){



describe("TicketStatusBadge", function () {
  function build(status) {
    return shallowMount(TicketStatusBadge, { propsData: { status: status } });
  }

  it("muestra el label y el color de un estado conocido", function () {
    var wrapper = build("open");

    expect(wrapper.text()).toBe("Abierto");
    expect(wrapper.classes()).toContain("badge-danger");
  });

  it("cae al fallback con un estado desconocido, sin romper", function () {
    var wrapper = build("estado-marciano");

    expect(wrapper.text()).toBe("estado-marciano"); // muestra el crudo
    expect(wrapper.classes()).toContain("badge-light");
  });
});
}
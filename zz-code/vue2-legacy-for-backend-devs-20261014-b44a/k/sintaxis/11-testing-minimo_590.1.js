function __f(){



describe("StatusActions", function () {
  it("genera un botón por transición válida del estado", function () {
    var wrapper = shallowMount(StatusActions, {
      propsData: { status: "resolved" } // resolved → [closed, open]
    });

    var buttons = wrapper.findAll("button");
    expect(buttons).toHaveLength(2);
    expect(buttons.at(0).text()).toContain("Cerrar");
    expect(buttons.at(1).text()).toContain("Reabrir");
  });

  it("al hacer clic emite change con el estado destino", function () {
    var wrapper = shallowMount(StatusActions, {
      propsData: { status: "open" }
    });

    wrapper.find("button").trigger("click");

    expect(wrapper.emitted("change")).toHaveLength(1);
    expect(wrapper.emitted("change")[0]).toEqual(["in_progress"]); // [payload]
  });

  it("con busy=true los botones quedan deshabilitados y no emiten", function () {
    var wrapper = shallowMount(StatusActions, {
      propsData: { status: "open", busy: true }
    });

    var button = wrapper.find("button");
    expect(button.attributes("disabled")).toBeDefined();

    button.trigger("click");
    expect(wrapper.emitted("change")).toBeUndefined(); // disabled no dispara click en jsdom
  });
});
}
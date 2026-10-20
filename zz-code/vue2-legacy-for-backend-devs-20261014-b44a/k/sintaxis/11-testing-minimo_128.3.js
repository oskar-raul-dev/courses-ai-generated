var __a = [


var wrapper = shallowMount(TicketStatusBadge, {
  propsData: { status: "open" }
});

wrapper.text();                    // el texto renderizado
wrapper.classes();                 // las clases del elemento raíz
wrapper.find("button");            // buscar en el DOM interno
wrapper.findAll("button");         // todos
wrapper.trigger("click");          // disparar un evento nativo
wrapper.emitted("change");         // qué eventos personalizados emitió (¡y con qué payload!)
wrapper.setProps({ status: "x" }); // cambiar props (devuelve Promise en v1)
];
import { shallowMount } from "@vue/test-utils";
import TicketsTable from "@/components/tickets/TicketsTable.vue";
it("muestra el estado del ticket", function () {
  var wrapper = shallowMount(TicketsTable, { propsData: { tickets: [{ id: 1, title: "X", status: "open", priority: "high" }] }, stubs: ["router-link"] });
  expect(wrapper.find(".col-md-6 > div:nth-child(2)").text()).toContain("open");
});

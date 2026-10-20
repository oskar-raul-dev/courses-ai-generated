// tests/unit/StatusDoughnut.spec.js
import { shallowMount } from "@vue/test-utils";
import Chart from "chart.js";
import StatusDoughnut from "@/components/metrics/StatusDoughnut.vue";

jest.mock("chart.js"); // jsdom no tiene canvas de verdad: el chart es un doble

describe("StatusDoughnut", function () {
  beforeEach(function () {
    Chart.mockReset();
  });

  it("destruye la instancia del chart al desmontarse", function () {
    var destroy = jest.fn();
    Chart.mockImplementation(function () { return { destroy: destroy, update: jest.fn() }; });

    var wrapper = shallowMount(StatusDoughnut, { propsData: { counts: {} } });
    wrapper.destroy();

    expect(destroy).toHaveBeenCalledTimes(1);
  });

  it("no expone la instancia como dato reactivo", function () {
    Chart.mockImplementation(function () { return { destroy: jest.fn(), update: jest.fn() }; });
    var wrapper = shallowMount(StatusDoughnut, { propsData: { counts: {} } });
    expect(Object.keys(wrapper.vm.$data)).not.toContain("chart");
  });
});

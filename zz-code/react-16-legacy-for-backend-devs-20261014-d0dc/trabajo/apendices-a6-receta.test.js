// A6 §11, extraído del .md (copia de zz-code): el clásico y el de Toolkit agregan igual.
import { WHEEL_ADDED, wheelAdded as classicAdded, wheelReducer } from "./ejemplos/a6Classic";
import toolkitReducer, { wheelAdded } from "./ejemplos/a6Toolkit";
test("la receta conserva el comportamiento y cambia el type", () => {
  const w = { id: 1, name: "Esclusa de Oro" };
  expect(wheelReducer(undefined, classicAdded(w)).items).toEqual([w]);
  expect(toolkitReducer(undefined, wheelAdded(w)).items).toEqual([w]);
  expect(classicAdded(w).type).toBe(WHEEL_ADDED);
  expect(wheelAdded.type).toBe("wheels/wheelAdded");
});

// Incidente 14 de punta a punta, con la pantalla montada (copia de zz-code; no va al curso).
// Responde: ¿el logout desde la consola deja consultas vivas, o la limpieza de la pantalla las corta?
import React from "react";
import { render, act } from "@testing-library/react";
import { Provider } from "react-redux";
import { Router, Switch, Route } from "react-router-dom";
import { createMemoryHistory } from "history";
import apiStore from "../api/apiStore";
import { store } from "../app/store";
import { login, logout } from "../features/auth/authSlice";
import { startPolling } from "../features/purchases/purchaseSlice";
import PurchasesPage from "../features/purchases/PurchasesPage";
import PrivateRoute from "../components/PrivateRoute";
import axios from "axios";

const wait = (ms) => new Promise((r) => setTimeout(r, ms));

test("con la pantalla de compras abierta, el logout no deja consultas al 3002", async () => {
  await axios.post("http://localhost:3002/purchases", { purchaseToken: "tok-oxxo-9", method: "cash" });
  await store.dispatch(login({ email: "ypinzon@esclusa.test", password: "esclusa123" }));
  const history = createMemoryHistory({ initialEntries: ["/purchases"] });
  render(
    <Provider store={store}>
      <Router history={history}>
        <Switch>
          <Route path="/login">login</Route>
          <PrivateRoute path="/purchases" component={PurchasesPage} />
        </Switch>
      </Router>
    </Provider>
  );
  const get = jest.spyOn(apiStore, "get");
  act(() => { store.dispatch(startPolling("tok-oxxo-9")); });
  await act(() => wait(2500));
  const before = get.mock.calls.length;
  act(() => { store.dispatch(logout()); });
  await act(() => wait(6000));
  expect(history.location.pathname).toBe("/login");
  expect(get.mock.calls.length - before).toBe(0); // con el leak: tres más, sin sesión
}, 20000);

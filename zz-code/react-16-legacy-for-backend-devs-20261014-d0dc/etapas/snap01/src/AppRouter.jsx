import React from "react";
import { BrowserRouter, Switch, Route, Redirect } from "react-router-dom";
import AppLayout from "./components/AppLayout";
import WheelListPage from "./pages/WheelListPage";
import WheelDetailPage from "./pages/WheelDetailPage";
import PlayersPage from "./pages/PlayersPage";
import BitacoraPage from "./pages/BitacoraPage";
import DashboardPage from "./pages/DashboardPage";
import NotFoundPage from "./pages/NotFoundPage";

function AppRouter() {
  return (
    <BrowserRouter>
      <AppLayout>
        {/* Switch: solo la PRIMERA ruta que matchea se renderiza. */}
        <Switch>
          {/* La raíz redirige al listado de ruedas. */}
          <Route exact path="/">
            <Redirect to="/wheels" />
          </Route>

          {/* exact acá es CLAVE: sin él, /wheels matchearía también
              /wheels/1 y nunca llegaríamos al detalle. */}
          <Route exact path="/wheels" component={WheelListPage} />
          <Route path="/wheels/:id" component={WheelDetailPage} />

          <Route path="/players" component={PlayersPage} />
          <Route path="/bitacora" component={BitacoraPage} />
          <Route path="/dashboard" component={DashboardPage} />

          {/* Sin path: matchea todo lo que no matcheó antes. El 404. */}
          <Route component={NotFoundPage} />
        </Switch>
      </AppLayout>
    </BrowserRouter>
  );
}

export default AppRouter;

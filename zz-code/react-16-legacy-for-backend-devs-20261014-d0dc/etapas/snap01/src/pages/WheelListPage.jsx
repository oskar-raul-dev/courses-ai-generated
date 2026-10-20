import React from "react";
import { withRouter } from "react-router-dom";
import { demoWheels } from "../mock/wheels";
import WheelCard from "../components/WheelCard";

// Class component al estilo pre-16.8: sin hooks, métodos con function-binding.
// withRouter le inyecta history/location/match como props.
class WheelListPage extends React.Component {
  // Arrow como property para no pelear con el binding de 'this'.
  // (En bases muy viejas verás .bind(this) en el constructor; mismo fin.)
  goToDetail = (id) => {
    // history viene de withRouter. push = navegar sin recargar.
    this.props.history.push(`/wheels/${id}`);
  };

  render() {
    return (
      <div>
        <h1 className="mb-3">Ruedas</h1>
        <div className="row">
          {demoWheels.map((wheel) => (
            <div
              key={wheel.id}
              className="col-md-4 mb-3"
              style={{ cursor: "pointer" }}
              onClick={() => this.goToDetail(wheel.id)}
            >
              {/* Reusamos WheelCard de Fase 0: recibe la rueda por la prop wheel. */}
              <WheelCard wheel={wheel} />
            </div>
          ))}
        </div>
      </div>
    );
  }
}

// withRouter envuelve la clase y le pasa las props del router.
export default withRouter(WheelListPage);

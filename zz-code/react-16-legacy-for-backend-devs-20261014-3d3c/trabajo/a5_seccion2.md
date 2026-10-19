**Clase (legacy):**

```jsx
// WheelDetail.jsx — estilo clase, el que vas a encontrar en módulos viejos
import React from 'react';
import { findWheel } from '../mock/wheels';

class WheelDetail extends React.Component {
  constructor(props) {
    super(props);
    // estado local: lo que la pantalla muestra, ya resuelto
    this.state = { wheel: null };
  }

  componentDidMount() {
    // al montar: buscamos la rueda de la URL
    this.setState({ wheel: findWheel(this.props.match.params.id) });
  }

  componentDidUpdate(prevProps) {
    // si cambia el id de la URL, la buscamos de nuevo (navegar de /wheels/1 a /wheels/2)
    if (prevProps.match.params.id !== this.props.match.params.id) {
      this.setState({ wheel: findWheel(this.props.match.params.id) });
    }
  }

  render() {
    const { wheel } = this.state;
    if (!wheel) return null;
    return <h1>{wheel.name}</h1>;
  }
}

export default WheelDetail;
```

**Función con hooks (moderno):**

```jsx
// WheelDetail.jsx — estilo hooks, el de los módulos nuevos
import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { findWheel } from '../mock/wheels';

function WheelDetail() {
  const { id } = useParams();               // la URL, sin this.props.match
  const [wheel, setWheel] = useState(null);

  useEffect(() => {
    // corre al montar Y cada vez que cambia id: cubre didMount + didUpdate de un saque
    setWheel(findWheel(id));
  }, [id]);                                  // deps: de qué depende este efecto

  if (!wheel) return null;
  return <h1>{wheel.name}</h1>;
}

export default WheelDetail;
```

Lo que la versión de clase reparte en dos métodos (`componentDidMount` y `componentDidUpdate`), la de hooks lo junta en **un solo `useEffect`**. Esa es la idea de fondo: los hooks agrupan por *preocupación* ("buscar la rueda de esta URL"), no por *momento del ciclo de vida*.

> 📝 **Qué falta a propósito.** Ninguna de las dos versiones necesita limpiar nada al desmontar: `findWheel` es síncrono y no deja nada abierto. Cuando el efecto sí deja algo abierto (un temporizador, un polling, una suscripción), aparece el `componentWillUnmount` de la clase y el `return` del `useEffect`. Es el caso de la Fase 7 con el polling de compras.

> 📝 **Nota de época.** Cuando el detalle viene del store, la versión de clase usa `connect()` y la de hooks, `useSelector()`/`useDispatch()`. Ese es su propio tema: vive en el **Apéndice A6 — Redux clásico vs Toolkit**. Acá lo dejamos sin Redux para que la diferencia que se ve sea la del ciclo de vida.


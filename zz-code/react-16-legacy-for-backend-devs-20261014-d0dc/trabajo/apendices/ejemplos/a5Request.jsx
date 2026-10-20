import React, { useReducer } from "react";
// máquina chica de estados para un pedido local (no es el store)
function requestReducer(state, action) {
  switch (action.type) {
    case 'start':   return { status: 'loading', error: null };
    case 'success': return { status: 'done', error: null };
    case 'fail':    return { status: 'idle', error: action.error };
    default:        return state;
  }
}

function ResendButton({ playerName }) {
  const [state, localDispatch] = useReducer(requestReducer, { status: 'idle', error: null });
  // state.status controla el render; las transiciones viven en un solo lugar
  return (
    <button disabled={state.status === 'loading'} onClick={() => localDispatch({ type: 'start' })}>
      Reenviar a {playerName}
    </button>
  );
}

export { requestReducer, ResendButton };

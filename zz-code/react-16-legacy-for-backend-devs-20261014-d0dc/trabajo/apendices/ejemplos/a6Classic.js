// types
export const WHEEL_ADDED = 'WHEEL_ADDED';
// creator
export const wheelAdded = (wheel) => ({ type: WHEEL_ADDED, payload: wheel });
// reducer
export function wheelReducer(state = { items: [] }, action) {
  switch (action.type) {
    case WHEEL_ADDED:
      return { ...state, items: [...state.items, action.payload] };
    default:
      return state;
  }
}

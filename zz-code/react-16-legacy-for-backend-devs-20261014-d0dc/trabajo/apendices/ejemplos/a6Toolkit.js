import { createSlice } from '@reduxjs/toolkit';

const wheelSlice = createSlice({
  name: 'wheels',
  initialState: { items: [] },
  reducers: {
    wheelAdded(state, action) {
      state.items.push(action.payload); // Immer: seguro
    },
  },
});

export const { wheelAdded } = wheelSlice.actions;
export default wheelSlice.reducer;

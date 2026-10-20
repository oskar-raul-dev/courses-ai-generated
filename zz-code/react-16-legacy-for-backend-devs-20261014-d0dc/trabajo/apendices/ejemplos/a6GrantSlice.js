// src/features/grants/grantSlice.js — una versión reducida del de F05: dos de sus casos
import { createSlice } from '@reduxjs/toolkit';

const grantSlice = createSlice({
  name: 'grants',
  initialState: { byId: {}, order: [] },
  reducers: {
    // cada key genera un action creator y un action type:
    //   grantSlice.actions.grantQueued  →  type 'grants/grantQueued'
    grantQueued(state, action) {
      const grant = action.payload;
      state.byId[grant.id] = grant;
      state.order.push(grant.id);
    },
    // el rollback del envío optimista: por id, y nunca sobre lo confirmado
    rollbackGrant(state, action) {
      const grant = state.byId[action.payload.grantId];
      if (grant && !grant.confirmed && grant.status === 'sent') {
        grant.status = 'failed';
        grant.error = action.payload.error;
      }
    },
  },
});

// esto es lo que exportas: los creators y el reducer
export const { grantQueued, rollbackGrant } = grantSlice.actions;
export default grantSlice.reducer;

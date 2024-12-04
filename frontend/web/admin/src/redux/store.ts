import { configureStore } from '@reduxjs/toolkit';
import teamReducer from './slices/teamSlice';
import authReducer from './slices/authSlice';
import dashboardReducer from './slices/dashboardSlice';

const store = configureStore({
  reducer: {
    teams: teamReducer,
    auth: authReducer,
    dashboard: dashboardReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;

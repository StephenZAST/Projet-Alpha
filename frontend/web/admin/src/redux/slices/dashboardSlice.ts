import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

interface DashboardMetrics {
  totalOrders: number;
  totalRevenue: number;
  activeUsers: number;
  conversionRate: number;
}

interface DashboardState {
  metrics: DashboardMetrics;
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

const initialState: DashboardState = {
  metrics: {
    totalOrders: 0,
    totalRevenue: 0,
    activeUsers: 0,
    conversionRate: 0
  },
  status: 'idle',
  error: null
};

export const fetchDashboardMetrics = createAsyncThunk(
  'dashboard/fetchMetrics',
  async () => {
    // Ici viendra l'appel API
    const response = await fetch('/api/dashboard/metrics');
    return response.json();
  }
);

const dashboardSlice = createSlice({
  name: 'dashboard',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchDashboardMetrics.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchDashboardMetrics.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.metrics = action.payload;
      })
      .addCase(fetchDashboardMetrics.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message || null;
      });
  },
});

export default dashboardSlice.reducer;

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import AuthService from '../../services/auth.service';

export interface Log {
  id: string;
  timestamp: string;
  level: 'info' | 'warning' | 'error';
  message: string;
  userId?: string;
  metadata?: Record<string, unknown>;
}

interface LogsState {
  logs: Log[];
  loading: boolean;
  error: string | null;
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  filters: {
    level?: string;
    startDate?: string;
    endDate?: string;
    search?: string;
  };
}

const initialState: LogsState = {
  logs: [],
  loading: false,
  error: null,
  pagination: {
    page: 1,
    limit: 10,
    total: 0,
  },
  filters: {},
};

export const fetchLogs = createAsyncThunk(
  'logs/fetchLogs',
  async (params: { 
    page?: number; 
    limit?: number;
    level?: string;
    startDate?: string;
    endDate?: string;
    search?: string;
  }, { rejectWithValue }) => {
    try {
      const response = await AuthService.api.get<{
        logs: Log[];
        total: number;
      }>('/admin/logs', { params });
      return response.data;
    } catch (error: unknown) {
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      return rejectWithValue('Erreur lors du chargement des logs');
    }
  }
);

export const clearLogs = createAsyncThunk(
  'logs/clearLogs',
  async (_, { rejectWithValue }) => {
    try {
      await AuthService.api.delete('/admin/logs');
      return true;
    } catch (error: unknown) {
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      return rejectWithValue('Erreur lors de la suppression des logs');
    }
  }
);

const logsSlice = createSlice({
  name: 'logs',
  initialState,
  reducers: {
    setFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload };
      state.pagination.page = 1; // Reset page when filters change
    },
    clearFilters: (state) => {
      state.filters = {};
      state.pagination.page = 1;
    },
    setPage: (state, action) => {
      state.pagination.page = action.payload;
    },
    setLimit: (state, action) => {
      state.pagination.limit = action.payload;
      state.pagination.page = 1; // Reset page when limit changes
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch Logs
      .addCase(fetchLogs.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchLogs.fulfilled, (state, action) => {
        state.loading = false;
        state.logs = action.payload.logs;
        state.pagination.total = action.payload.total;
      })
      .addCase(fetchLogs.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Clear Logs
      .addCase(clearLogs.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(clearLogs.fulfilled, (state) => {
        state.loading = false;
        state.logs = [];
        state.pagination.total = 0;
        state.pagination.page = 1;
      })
      .addCase(clearLogs.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { setFilters, clearFilters, setPage, setLimit } = logsSlice.actions;

export default logsSlice.reducer;

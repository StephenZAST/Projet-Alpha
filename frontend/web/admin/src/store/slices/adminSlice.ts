import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { User } from '../../types/user';
import AuthService from '../../services/auth.service';

interface AdminState {
  admins: User[];
  loading: boolean;
  error: string | null;
  selectedAdmin: User | null;
}

const initialState: AdminState = {
  admins: [],
  loading: false,
  error: null,
  selectedAdmin: null,
};

export const fetchAdmins = createAsyncThunk(
  'admin/fetchAdmins',
  async (_, { rejectWithValue }) => {
    try {
      const response = await AuthService.api.get<User[]>('/admin/users');
      return response.data;
    } catch (error: unknown) {
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      return rejectWithValue('Erreur lors du chargement des administrateurs');
    }
  }
);

export const createAdmin = createAsyncThunk(
  'admin/createAdmin',
  async (adminData: Partial<User>, { rejectWithValue }) => {
    try {
      const response = await AuthService.api.post<User>('/admin/users', adminData);
      return response.data;
    } catch (error: unknown) {
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      return rejectWithValue('Erreur lors de la création de l\'administrateur');
    }
  }
);

export const updateAdmin = createAsyncThunk(
  'admin/updateAdmin',
  async ({ id, data }: { id: string; data: Partial<User> }, { rejectWithValue }) => {
    try {
      const response = await AuthService.api.put<User>(`/admin/users/${id}`, data);
      return response.data;
    } catch (error: unknown) {
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      return rejectWithValue('Erreur lors de la mise à jour de l\'administrateur');
    }
  }
);

export const deleteAdmin = createAsyncThunk(
  'admin/deleteAdmin',
  async (id: string, { rejectWithValue }) => {
    try {
      await AuthService.api.delete(`/admin/users/${id}`);
      return id;
    } catch (error: unknown) {
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      return rejectWithValue('Erreur lors de la suppression de l\'administrateur');
    }
  }
);

const adminSlice = createSlice({
  name: 'admin',
  initialState,
  reducers: {
    setSelectedAdmin: (state, action) => {
      state.selectedAdmin = action.payload;
    },
    clearSelectedAdmin: (state) => {
      state.selectedAdmin = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch Admins
      .addCase(fetchAdmins.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchAdmins.fulfilled, (state, action) => {
        state.loading = false;
        state.admins = action.payload;
      })
      .addCase(fetchAdmins.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Create Admin
      .addCase(createAdmin.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createAdmin.fulfilled, (state, action) => {
        state.loading = false;
        state.admins.push(action.payload);
      })
      .addCase(createAdmin.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Update Admin
      .addCase(updateAdmin.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateAdmin.fulfilled, (state, action) => {
        state.loading = false;
        const index = state.admins.findIndex(admin => admin.id === action.payload.id);
        if (index !== -1) {
          state.admins[index] = action.payload;
        }
      })
      .addCase(updateAdmin.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Delete Admin
      .addCase(deleteAdmin.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(deleteAdmin.fulfilled, (state, action) => {
        state.loading = false;
        state.admins = state.admins.filter(admin => admin.id !== action.payload);
      })
      .addCase(deleteAdmin.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { setSelectedAdmin, clearSelectedAdmin, clearError } = adminSlice.actions;

export default adminSlice.reducer;

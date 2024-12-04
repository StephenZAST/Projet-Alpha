import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import authService from '../../services/AuthService';
import { AdminRole } from '../../types/admin';

interface AdminUser {
  id: string;
  role: AdminRole;
  name: string;
  email: string;
  phone: string;
  permissions: string[];
  lastActive: Date;
}

interface AuthState {
  user: AdminUser | null;
  isLoggedIn: boolean;
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

interface LoginCredentials {
  email: string;
  password: string;
}

const initialState: AuthState = {
  user: null,
  isLoggedIn: false,
  status: 'idle',
  error: null,
};

export const login = createAsyncThunk('auth/login', async (credentials: LoginCredentials) => {
  try {
    const user = await authService.login(credentials.email, credentials.password);
    return user;
  } catch (error: unknown) {
    throw new Error((error as Error).message);
  }
});

export const logout = createAsyncThunk('auth/logout', async () => {
  authService.logout();
});

export const createMasterAdmin = createAsyncThunk(
  'auth/createMasterAdmin',
  async (adminData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phoneNumber: string;
  }) => {
    const response = await authService.createMasterAdmin(adminData);
    return response;
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    // Other reducers if needed
  },
  extraReducers(builder) {
    builder
      .addCase(login.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(login.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.user = action.payload;
        state.isLoggedIn = true;
      })
      .addCase(login.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message || null;
      })
      .addCase(logout.fulfilled, (state) => {
        state.user = null;
        state.isLoggedIn = false;
        state.status = 'succeeded';
      })
      .addCase(createMasterAdmin.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(createMasterAdmin.fulfilled, (state) => {
        state.status = 'succeeded';
      })
      .addCase(createMasterAdmin.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message || null;
      });
  },
});

export default authSlice.reducer;

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import app from '../../firebaseConfig'; // Import the initialized Firebase app
import { getFirestore, collection, getDocs, addDoc, doc, updateDoc, deleteDoc } from 'firebase/firestore';

interface Team {
  id?: string;
  name: string;
  description: string;
  members: string[];
}

interface TeamState {
  teams: Team[];
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

const initialState: TeamState = {
  teams: [],
  status: 'idle',
  error: null,
};

// Initialize Firestore
const db = getFirestore(app);

export const fetchTeams = createAsyncThunk('teams/fetchTeams', async () => {
  try {
    const querySnapshot = await getDocs(collection(db, 'teams'));
    return querySnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() } as Team));
  } catch (error: any) {
    console.error('Error fetching teams:', error);
    throw new Error('Failed to fetch teams');
  }
});

export const addTeam = createAsyncThunk('teams/addTeam', async (team: Team) => {
  try {
    const docRef = await addDoc(collection(db, 'teams'), team);
    return { id: docRef.id, ...team };
  } catch (error: any) {
    console.error('Error adding team:', error);
    throw new Error('Failed to add team');
  }
});

export const updateTeam = createAsyncThunk(
  'teams/updateTeam',
  async ({ id, ...updatedTeam }: Team) => {
    try {
      await updateDoc(doc(db, 'teams', id), updatedTeam);
      return { id, ...updatedTeam };
    } catch (error: any) {
      console.error('Error updating team:', error);
      throw new Error('Failed to update team');
    }
  }
);

export const deleteTeam = createAsyncThunk('teams/deleteTeam', async (id: string) => {
  try {
    await deleteDoc(doc(db, 'teams', id));
    return id;
  } catch (error: any) {
    console.error('Error deleting team:', error);
    throw new Error('Failed to delete team');
  }
});

const teamSlice = createSlice({
  name: 'teams',
  initialState,
  reducers: {},
  extraReducers(builder) {
    builder
      .addCase(fetchTeams.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchTeams.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.teams = action.payload;
      })
      .addCase(fetchTeams.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message || null;
      })
      .addCase(addTeam.fulfilled, (state, action) => {
        state.teams.push(action.payload);
      })
      .addCase(updateTeam.fulfilled, (state, action) => {
        const index = state.teams.findIndex((team) => team.id === action.payload.id);
        if (index !== -1) {
          state.teams[index] = action.payload;
        }
      })
      .addCase(deleteTeam.fulfilled, (state, action) => {
        state.teams = state.teams.filter((team) => team.id !== action.payload);
      });
  },
});

export default teamSlice.reducer;

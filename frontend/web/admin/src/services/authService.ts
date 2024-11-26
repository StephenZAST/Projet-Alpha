import axios from 'axios';

const apiBaseUrl = 'https://us-central1-alpha-79c09.cloudfunctions.net/api'; // Replace with your actual base URL

class AuthService {
  async login(email: string, password: string) {
    try {
      const response = await axios.post(`${apiBaseUrl}/admins/login`, { email, password });
      if (response.data.success) {
        const { token, admin } = response.data.data;
        localStorage.setItem('token', token);
        // You might want to store the admin data in local storage or Redux as well
        return admin;
      } else {
        throw new Error(response.data.message);
      }
    } catch (error: unknown) {
      console.error('Login failed:', error);
      throw new Error('Login failed. Please check your credentials.');
    }
  }

  logout() {
    localStorage.removeItem('token');
  }

  getCurrentUser() {
    const token = localStorage.getItem('token');
    if (token) {
      // Decode the JWT token to get user information
      // You might need to use a library like jwt-decode for this
      return null; // Replace with the decoded user information
    } else {
      return null;
    }
  }

  isAuthenticated() {
    const token = localStorage.getItem('token');
    if (token) {
      // Verify the token's validity (e.g., check expiration date)
      return true; // Replace with actual token validation logic
    } else {
      return false;
    }
  }
}

export default new AuthService();

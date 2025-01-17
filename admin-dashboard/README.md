### Step 1: Set Up the Project

1. **Create a New Vite Project**:
   Open your terminal and run the following command to create a new Vite project with React and TypeScript:

   ```bash
   npm create vite@latest affiliate-dashboard -- --template react-ts
   ```

   Navigate into the project directory:

   ```bash
   cd affiliate-dashboard
   ```

2. **Install Dependencies**:
   Install the necessary dependencies for routing and state management:

   ```bash
   npm install react-router-dom axios
   ```

### Step 2: Project Structure

Create the following folder structure inside the `src` directory:

```
src/
├── components/
│   ├── AdminDashboard.tsx
│   ├── DeliveryDashboard.tsx
│   ├── SuperAdminDashboard.tsx
│   ├── Navbar.tsx
│   └── PrivateRoute.tsx
├── context/
│   └── AuthContext.tsx
├── hooks/
│   └── useAuth.ts
├── pages/
│   ├── Login.tsx
│   └── NotFound.tsx
├── App.tsx
└── main.tsx
```

### Step 3: Implement Authentication Context

Create an `AuthContext.tsx` file in the `context` folder to manage user authentication and roles.

```tsx
// src/context/AuthContext.tsx
import React, { createContext, useContext, useState } from 'react';

interface AuthContextType {
  user: { role: string } | null;
  login: (role: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<{ role: string } | null>(null);

  const login = (role: string) => {
    setUser({ role });
  };

  const logout = () => {
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

### Step 4: Create Private Route Component

Create a `PrivateRoute.tsx` component to handle role-based access.

```tsx
// src/components/PrivateRoute.tsx
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

interface PrivateRouteProps {
  children: React.ReactNode;
  allowedRoles: string[];
}

const PrivateRoute: React.FC<PrivateRouteProps> = ({ children, allowedRoles }) => {
  const { user } = useAuth();

  if (!user) {
    return <Navigate to="/login" />;
  }

  if (!allowedRoles.includes(user.role)) {
    return <Navigate to="/not-found" />;
  }

  return <>{children}</>;
};

export default PrivateRoute;
```

### Step 5: Create Dashboard Components

Create simple dashboard components for Admin, Delivery, and Super Admin users.

```tsx
// src/components/AdminDashboard.tsx
import React from 'react';

const AdminDashboard: React.FC = () => {
  return <h1>Admin Dashboard</h1>;
};

export default AdminDashboard;

// src/components/DeliveryDashboard.tsx
import React from 'react';

const DeliveryDashboard: React.FC = () => {
  return <h1>Delivery Dashboard</h1>;
};

export default DeliveryDashboard;

// src/components/SuperAdminDashboard.tsx
import React from 'react';

const SuperAdminDashboard: React.FC = () => {
  return <h1>Super Admin Dashboard</h1>;
};

export default SuperAdminDashboard;
```

### Step 6: Implement Routing in App Component

Update the `App.tsx` file to include routing and the authentication provider.

```tsx
// src/App.tsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import AdminDashboard from './components/AdminDashboard';
import DeliveryDashboard from './components/DeliveryDashboard';
import SuperAdminDashboard from './components/SuperAdminDashboard';
import PrivateRoute from './components/PrivateRoute';
import Login from './pages/Login';
import NotFound from './pages/NotFound';

const App: React.FC = () => {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/admin"
            element={
              <PrivateRoute allowedRoles={['ADMIN', 'SUPER_ADMIN']}>
                <AdminDashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/delivery"
            element={
              <PrivateRoute allowedRoles={['DELIVERY', 'SUPER_ADMIN']}>
                <DeliveryDashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/super-admin"
            element={
              <PrivateRoute allowedRoles={['SUPER_ADMIN']}>
                <SuperAdminDashboard />
              </PrivateRoute>
            }
          />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
};

export default App;
```

### Step 7: Create Login Page

Create a simple login page to simulate user login.

```tsx
// src/pages/Login.tsx
import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const Login: React.FC = () => {
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = (role: string) => {
    login(role);
    navigate(`/${role.toLowerCase()}`);
  };

  return (
    <div>
      <h1>Login</h1>
      <button onClick={() => handleLogin('ADMIN')}>Login as Admin</button>
      <button onClick={() => handleLogin('DELIVERY')}>Login as Delivery</button>
      <button onClick={() => handleLogin('SUPER_ADMIN')}>Login as Super Admin</button>
    </div>
  );
};

export default Login;
```

### Step 8: Create Not Found Page

Create a simple Not Found page.

```tsx
// src/pages/NotFound.tsx
import React from 'react';

const NotFound: React.FC = () => {
  return <h1>404 - Not Found</h1>;
};

export default NotFound;
```

### Step 9: Run the Application

Now that everything is set up, you can run your application:

```bash
npm run dev
```

### Conclusion

You now have a basic React + Vite TypeScript project for an affiliate dashboard with role-based access for admin, delivery, and super admin users. You can expand upon this foundation by adding more features, styling, and integrating with your backend API.
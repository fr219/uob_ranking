import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import Cookies from 'js-cookie';

const AuthContext = createContext(null);
const SESSION_KEY = 'uob_auth_session';

const DEMO_ADMIN = {
  id: 1,
  name: 'Admin User',
  email: 'admin@uob.example',
  role: 'admin'
};

const DEMO_USER = {
  id: 2,
  name: 'Regular User',
  email: 'user@uob.example',
  role: 'user'
};

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try {
      const savedUser = window.localStorage.getItem(SESSION_KEY);
      return savedUser ? JSON.parse(savedUser) : null;
    } catch (error) {
      return null;
    }
  });

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const sessionCookie = Cookies.get('uob_session');

    if (!user && sessionCookie) {
      try {
        setUser(JSON.parse(sessionCookie));
      } catch (error) {
        Cookies.remove('uob_session');
      }
    }

    if (user) {
      Cookies.set('uob_session', JSON.stringify(user), {
        sameSite: 'Lax',
        secure: window.location.protocol === 'https:',
        expires: 7
      });
      window.localStorage.setItem(SESSION_KEY, JSON.stringify(user));
    } else {
      Cookies.remove('uob_session');
      window.localStorage.removeItem(SESSION_KEY);
    }

    setLoading(false);
  }, [user]);

  const login = ({ email, password, role = 'user' }) => {
    const nextUser = {
      id: role === 'admin' ? 1 : 2,
      name: role === 'admin' ? DEMO_ADMIN.name : DEMO_USER.name,
      email,
      role: role === 'admin' ? 'admin' : 'user'
    };

    if (password && email) {
      setUser(nextUser);
      return nextUser;
    }

    setUser(role === 'admin' ? DEMO_ADMIN : DEMO_USER);
    return role === 'admin' ? DEMO_ADMIN : DEMO_USER;
  };

  const logout = () => {
    setUser(null);
  };

  const value = useMemo(
    () => ({
      user,
      loading,
      isAuthenticated: Boolean(user),
      isAdmin: user?.role === 'admin',
      login,
      logout
    }),
    [user, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }

  return context;
}

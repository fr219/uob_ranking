import { useEffect, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import PageMeta from '../components/PageMeta';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { login, isAuthenticated } = useAuth();
  const [form, setForm] = useState({ email: '', password: '' });
  const [state, setState] = useState({ loading: false, error: '' });

  useEffect(() => {
    if (isAuthenticated) navigate('/dashboard', { replace: true });
  }, [isAuthenticated, navigate]);

  const submit = async (event) => {
    event.preventDefault();
    setState({ loading: true, error: '' });
    try {
      const user = await login(form);
      navigate(user.role === 'admin' ? '/admin' : location.state?.from || '/dashboard', { replace: true });
    } catch (error) {
      setState({ loading: false, error: error.response?.data?.error || 'Unable to sign in. Please try again.' });
    }
  };

  return (
    <div className="auth-page">
      <PageMeta title="Login" description="Sign in to the UOB Ranking platform." path="/login" />
      <div className="container auth-shell">
        <form className="card auth-card" onSubmit={submit} noValidate>
          <h1>Welcome back</h1>
          <p className="subtle">Sign in to continue to your dashboard.</p>
          {state.error && <p role="alert" className="form-error">{state.error}</p>}
          <label>Email<input name="email" type="email" autoComplete="email" required value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} /></label>
          <label>Password<input name="password" type="password" autoComplete="current-password" required minLength="8" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} /></label>
          <button className="btn btn-primary" type="submit" disabled={state.loading}>{state.loading ? 'Signing in…' : 'Sign in'}</button>
          <p className="auth-link">Need an account? <Link to="/register">Create one</Link></p>
        </form>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import PageMeta from '../components/PageMeta';
import { useAuth } from '../context/AuthContext';

export default function RegisterPage() {
  const navigate = useNavigate();
  const { register } = useAuth();
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [state, setState] = useState({ loading: false, error: '' });

  const submit = async (event) => {
    event.preventDefault();
    setState({ loading: true, error: '' });
    try {
      await register(form);
      navigate('/dashboard', { replace: true });
    } catch (error) {
      setState({ loading: false, error: error.response?.data?.error || 'Unable to register. Please try again.' });
    }
  };

  return (
    <div className="auth-page">
      <PageMeta title="Register" description="Create a UOB Ranking account." path="/register" />
      <div className="container auth-shell">
        <form className="card auth-card" onSubmit={submit} noValidate>
          <h1>Create account</h1>
          <p className="subtle">Set up your profile to start using the platform.</p>
          {state.error && <p role="alert" className="form-error">{state.error}</p>}
          <label>Full name<input name="name" autoComplete="name" required minLength="2" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} /></label>
          <label>Email<input name="email" type="email" autoComplete="email" required value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} /></label>
          <label>Password<input name="password" type="password" autoComplete="new-password" required minLength="8" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} /></label>
          <button className="btn btn-primary" type="submit" disabled={state.loading}>{state.loading ? 'Creating account…' : 'Register'}</button>
          <p className="auth-link">Already have an account? <Link to="/login">Log in</Link></p>
        </form>
      </div>
    </div>
  );
}

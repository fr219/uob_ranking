import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import PageMeta from '../components/PageMeta';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();
  const [form, setForm] = useState({ email: '', password: '' });

  if (isAuthenticated) {
    navigate('/dashboard');
  }

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    const user = login({ email: form.email, password: form.password, role: 'user' });
    if (user?.role === 'admin') {
      navigate('/admin');
      return;
    }
    navigate('/dashboard');
  };

  return (
    <div className="auth-page">
      <PageMeta title="Login" description="Sign in to the user portal." path="/login" />
      <div className="container auth-shell">
        <form className="card auth-card" onSubmit={handleSubmit}>
          <h1>Welcome back</h1>
          <p className="subtle">Sign in to continue to your dashboard.</p>

          <label>
            Email
            <input name="email" type="email" value={form.email} onChange={handleChange} required />
          </label>

          <label>
            Password
            <input name="password" type="password" value={form.password} onChange={handleChange} required />
          </label>

          <button className="btn btn-primary" type="submit">Sign in</button>

          <p className="auth-link">
            Need an account? <Link to="/register">Create one</Link>
          </p>
        </form>
      </div>
    </div>
  );
}

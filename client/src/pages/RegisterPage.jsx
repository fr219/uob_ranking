import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import PageMeta from '../components/PageMeta';
import { useAuth } from '../context/AuthContext';

export default function RegisterPage() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [form, setForm] = useState({ name: '', email: '', password: '' });

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    login({ email: form.email, password: form.password, role: 'user' });
    navigate('/dashboard');
  };

  return (
    <div className="auth-page">
      <PageMeta title="Register" description="Create a new account." path="/register" />
      <div className="container auth-shell">
        <form className="card auth-card" onSubmit={handleSubmit}>
          <h1>Create account</h1>
          <p className="subtle">Set up your profile to start using the platform.</p>

          <label>
            Full name
            <input name="name" value={form.name} onChange={handleChange} required />
          </label>

          <label>
            Email
            <input name="email" type="email" value={form.email} onChange={handleChange} required />
          </label>

          <label>
            Password
            <input name="password" type="password" value={form.password} onChange={handleChange} required />
          </label>

          <button className="btn btn-primary" type="submit">Register</button>

          <p className="auth-link">
            Already have an account? <Link to="/login">Log in</Link>
          </p>
        </form>
      </div>
    </div>
  );
}

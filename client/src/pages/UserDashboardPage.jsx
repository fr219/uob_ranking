import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';
import { useAuth } from '../context/AuthContext';

export default function UserDashboardPage() {
  const { user, logout } = useAuth();

  return (
    <div className="admin-page">
      <PageMeta title="User Dashboard" description="User dashboard overview." path="/dashboard" />

      <aside className="sidebar">
        <div className="brand">UOB Ranking</div>
        <nav>
          <Link to="/dashboard">Overview</Link>
          <Link to="/dashboard/forms">Active forms</Link>
          <button className="btn btn-secondary" type="button" onClick={logout}>Logout</button>
        </nav>
      </aside>

      <main className="main-panel">
        <header className="page-header">
          <div>
            <p className="eyebrow">Dashboard</p>
            <h1>Welcome, {user?.name || 'User'}</h1>
          </div>
        </header>

        <section className="stats-grid">
          <div className="card stat-card"><span>Open tasks</span><strong>12</strong></div>
          <div className="card stat-card"><span>Submitted</span><strong>8</strong></div>
          <div className="card stat-card"><span>Pending review</span><strong>3</strong></div>
        </section>
      </main>
    </div>
  );
}

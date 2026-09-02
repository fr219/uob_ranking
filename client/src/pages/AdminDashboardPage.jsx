import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function AdminDashboardPage() {
  return (
    <div className="admin-page">
      <PageMeta title="Admin Dashboard" description="Admin overview and operational dashboard." path="/admin" />

      <aside className="sidebar">
        <div className="brand">UOB Admin</div>
        <nav>
          <Link to="/admin">Overview</Link>
          <Link to="/admin/users">User management</Link>
          <Link to="/admin/forms">Form builder</Link>
          <Link to="/admin/logs">Audit logs</Link>
        </nav>
      </aside>

      <main className="main-panel">
        <header className="page-header">
          <div>
            <p className="eyebrow">Operations</p>
            <h1>Admin dashboard</h1>
          </div>
        </header>

        <section className="stats-grid">
          <div className="card stat-card"><span>Departments</span><strong>8</strong></div>
          <div className="card stat-card"><span>Users</span><strong>156</strong></div>
          <div className="card stat-card"><span>Forms</span><strong>24</strong></div>
        </section>
      </main>
    </div>
  );
}

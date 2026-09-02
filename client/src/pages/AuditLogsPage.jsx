import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function AuditLogsPage() {
  return (
    <div className="admin-page">
      <PageMeta title="Audit Logs" description="Review actions and changes across the platform." path="/admin/logs" />

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
            <p className="eyebrow">Security & traceability</p>
            <h1>Audit logs</h1>
          </div>
        </header>

        <section className="card table-wrap">
          <table>
            <thead>
              <tr>
                <th>Time</th>
                <th>Action</th>
                <th>User</th>
                <th>Entity</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>2026-08-31 14:00</td>
                <td>Form published</td>
                <td>System</td>
                <td>Performance Review</td>
              </tr>
            </tbody>
          </table>
        </section>
      </main>
    </div>
  );
}

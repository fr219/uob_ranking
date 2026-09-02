import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function UserManagementPage() {
  return (
    <div className="admin-page">
      <PageMeta title="User Management" description="Manage users and permissions." path="/admin/users" />

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
            <p className="eyebrow">Admin panel</p>
            <h1>User management</h1>
          </div>
        </header>

        <section className="card table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Department</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Jane Doe</td>
                <td>jane@uob.example</td>
                <td><span className="badge badge-info">Manager</span></td>
                <td>Operations</td>
              </tr>
            </tbody>
          </table>
        </section>
      </main>
    </div>
  );
}

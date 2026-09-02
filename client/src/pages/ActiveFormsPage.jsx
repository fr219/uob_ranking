import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function ActiveFormsPage() {
  return (
    <div className="admin-page">
      <PageMeta title="Active Forms" description="Manage active employee ranking forms." path="/dashboard/forms" />

      <aside className="sidebar">
        <div className="brand">UOB Ranking</div>
        <nav>
          <Link to="/dashboard">Overview</Link>
          <Link to="/dashboard/forms">Active forms</Link>
        </nav>
      </aside>

      <main className="main-panel">
        <header className="page-header">
          <div>
            <p className="eyebrow">User area</p>
            <h1>Active forms</h1>
          </div>
        </header>

        <section className="card table-wrap">
          <table>
            <thead>
              <tr>
                <th>Form</th>
                <th>Department</th>
                <th>Status</th>
                <th>Deadline</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Performance Review 2025</td>
                <td>Operations</td>
                <td><span className="badge badge-success">Active</span></td>
                <td>2026-09-14</td>
              </tr>
            </tbody>
          </table>
        </section>
      </main>
    </div>
  );
}

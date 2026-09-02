import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function FormBuilderPage() {
  return (
    <div className="admin-page">
      <PageMeta title="Form Builder" description="Create and edit ranking forms." path="/admin/forms" />

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
            <p className="eyebrow">Configuration</p>
            <h1>Form builder</h1>
          </div>
        </header>

        <section className="card builder-panel">
          <h2>Performance review template</h2>
          <p>Form metadata, questions, department assignments, and publication controls will appear here.</p>
        </section>
      </main>
    </div>
  );
}

import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function HomePage() {
  return (
    <div className="home-page">
      <PageMeta
        title="Home"
        description="Modern public home page for UOB ranking and review workflows."
        path="/"
      />

      <header className="site-header">
        <div className="container nav-wrap">
          <div className="brand">UOB Ranking</div>
          <nav className="nav" aria-label="Main navigation">
            <Link to="/">Home</Link>
            <Link to="/login">Login</Link>
            <Link to="/register">Register</Link>
            <Link to="/admin">Admin</Link>
          </nav>
        </div>
      </header>

      <main>
        <section className="hero-section">
          <div className="container hero-grid">
            <div className="hero-copy">
              <span className="eyebrow">Production-ready platform</span>
              <h1>Streamline ranking forms, reviews, and staff workflows.</h1>
              <p>
                Centralize form management, department assignments, user access, and reporting in one secure,
                mobile-first experience.
              </p>
              <div className="hero-actions">
                <Link className="btn btn-primary" to="/register">
                  Create account
                </Link>
                <Link className="btn btn-secondary" to="/login">
                  Sign in
                </Link>
              </div>
            </div>
            <div className="hero-panel card">
              <h2>Live platform snapshot</h2>
              <ul>
                <li>35 active forms</li>
                <li>8 departments assigned</li>
                <li>96% task completion</li>
              </ul>
            </div>
          </div>
        </section>

        <section className="feature-section">
          <div className="container">
            <div className="section-heading">
              <span className="eyebrow">Why teams choose us</span>
              <h2>Built for secure, measurable collaboration.</h2>
            </div>

            <div className="feature-grid">
              <article className="card feature-item">
                <h3>Role-based access</h3>
                <p>Protect workflows with user and admin permissions aligned to real operational needs.</p>
              </article>
              <article className="card feature-item">
                <h3>Audit ready</h3>
                <p>Capture actions, submissions, and changes with strong historical visibility.</p>
              </article>
              <article className="card feature-item">
                <h3>Fast performance</h3>
                <p>Optimized for responsive browsing, clean routing, and production-grade reliability.</p>
              </article>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}

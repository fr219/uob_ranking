import { Link } from 'react-router-dom';
import PageMeta from '../components/PageMeta';

export default function NotFoundPage() {
  return (
    <div className="not-found-page container">
      <PageMeta title="Page Not Found" description="The page you requested does not exist." path="/404" />
      <div className="card not-found-card">
        <p className="eyebrow">404</p>
        <h1>Page not found</h1>
        <p>The page you were looking for doesn’t exist or may have moved.</p>
        <Link className="btn btn-primary" to="/">
          Return home
        </Link>
      </div>
    </div>
  );
}

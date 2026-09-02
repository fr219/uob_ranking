import { Helmet } from 'react-helmet-async';

export default function PageMeta({ title, description, image, path = '/' }) {
  const metaTitle = title ? `${title} | UOB Ranking` : 'UOB Ranking';
  const metaDescription = description || 'Modern performance-first ranking and review platform.';
  const canonicalUrl = `https://example.com${path}`;

  return (
    <Helmet>
      <title>{metaTitle}</title>
      <meta name="description" content={metaDescription} />
      <meta property="og:title" content={metaTitle} />
      <meta property="og:description" content={metaDescription} />
      <meta property="og:type" content="website" />
      {image ? <meta property="og:image" content={image} /> : null}
      <meta property="og:url" content={canonicalUrl} />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={metaTitle} />
      <meta name="twitter:description" content={metaDescription} />
    </Helmet>
  );
}

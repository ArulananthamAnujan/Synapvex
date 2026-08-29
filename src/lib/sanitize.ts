import DOMPurify from 'dompurify';

const SANITIZE_OPTIONS = {
  USE_PROFILES: { html: true },
  FORBID_TAGS: ['script', 'style', 'iframe', 'object', 'embed', 'form', 'input', 'button'],
  FORBID_ATTR: ['srcdoc'],
};

/** Sanitize rich lesson content before it is parsed, previewed, or rendered. */
export function sanitizeHtml(value: string | null | undefined): string {
  return DOMPurify.sanitize(value ?? '', SANITIZE_OPTIONS);
}

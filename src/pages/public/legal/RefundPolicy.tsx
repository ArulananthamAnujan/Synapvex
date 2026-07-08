import { Link } from 'react-router-dom';
import LegalLayout from './LegalLayout';

export default function RefundPolicy() {
  return (
    <LegalLayout title="Refund Policy" lastUpdated="8 July 2026">
      <div>
        <h2>Course Purchases</h2>
        <p>
          Paid courses on Synapvex Learn come with a <strong>30-day money-back guarantee</strong>. If a
          course isn't what you expected, request a refund within 30 days of purchase and we'll return
          your payment in full to the original payment method.
        </p>
        <ul>
          <li>Refunds are not available where a course has been substantially completed (more than 80% of lessons) or a certificate has already been issued.</li>
          <li>Refunds are processed within 5–10 business days of approval.</li>
        </ul>
      </div>

      <div>
        <h2>Teacher Subscriptions</h2>
        <ul>
          <li>Plans are paid per period (monthly or annual). You can cancel anytime; your plan stays active until the end of the period you paid for. Partial periods are not refunded.</li>
          <li>If we materially fail to provide the service you paid for, contact us and we'll make it right.</li>
        </ul>
      </div>

      <div>
        <h2>How to Request a Refund</h2>
        <p>
          Email <a href="mailto:info@synapvex.com" className="text-sky-600 hover:underline">info@synapvex.com</a>{' '}
          from your account email with your order details, or use our{' '}
          <Link to="/contact" className="text-sky-600 hover:underline">contact form</Link> with the subject
          "Refund request". We aim to respond within 2 business days.
        </p>
      </div>
    </LegalLayout>
  );
}

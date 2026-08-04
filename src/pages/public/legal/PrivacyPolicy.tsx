import { Link } from 'react-router-dom';
import LegalLayout from './LegalLayout';

export default function PrivacyPolicy() {
  return (
    <LegalLayout title="Privacy Policy" lastUpdated="8 July 2026">
      <div>
        <p>
          SynapVex Technologies ("Synapvex", "we", "us") is committed to protecting your privacy.
          This policy explains what information we collect, how we use it, and the choices you have.
          It applies to our website, our services, and our products including Synapvex Learn.
        </p>
      </div>

      <div>
        <h2>Information We Collect</h2>
        <ul>
          <li><strong>Account information</strong> — name, email address and password (stored as a secure hash), or your Google/Microsoft profile details if you sign in with those providers.</li>
          <li><strong>Profile & learning data</strong> — courses you create or enrol in, lesson progress, quiz and exam results, certificates, and messages you post in course discussions.</li>
          <li><strong>Payment information</strong> — payments are processed by our payment provider; we never store your full card details. We keep records of transactions (amount, date, item purchased).</li>
          <li><strong>Contact submissions</strong> — messages you send through our contact form or newsletter signups.</li>
          <li><strong>Technical data</strong> — we use strictly necessary browser storage to keep you signed in. We do not run third-party advertising trackers.</li>
        </ul>
      </div>

      <div>
        <h2>How We Use Your Information</h2>
        <ul>
          <li>To provide and operate our products and services, including course delivery, progress tracking and certificate issuance.</li>
          <li>To process payments, subscriptions and payouts.</li>
          <li>To respond to enquiries and provide support.</li>
          <li>To send service communications (e.g. enrolment confirmations). Marketing emails are only sent if you opt in, and every one includes an unsubscribe option.</li>
          <li>To keep the platform secure and prevent abuse.</li>
        </ul>
      </div>

      <div>
        <h2>Sharing</h2>
        <p>
          We do not sell your personal information. We share data only with service providers needed to
          run the platform (hosting, database, authentication and payment processing), and with a course's
          teacher or organisation where you enrol in their course (name, email and course progress, so they
          can teach and support you).
        </p>
      </div>

      <div>
        <h2>Data Retention & Your Rights</h2>
        <p>
          We keep your data while your account is active. You may request a copy of your data, correction
          of inaccurate data, or deletion of your account and associated personal data at any time by
          contacting us at <a href="mailto:info@synapvex.com.au" className="text-sky-600 hover:underline">info@synapvex.com.au</a>.
          Some records (e.g. tax and payment records) may be retained where the law requires it.
        </p>
      </div>

      <div>
        <h2>Contact</h2>
        <p>
          Questions about this policy? Reach us at{' '}
          <a href="mailto:info@synapvex.com.au" className="text-sky-600 hover:underline">info@synapvex.com.au</a>{' '}
          or through our <Link to="/contact" className="text-sky-600 hover:underline">contact page</Link>.
        </p>
      </div>
    </LegalLayout>
  );
}

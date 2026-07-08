import { Link } from 'react-router-dom';
import LegalLayout from './LegalLayout';

export default function TermsOfService() {
  return (
    <LegalLayout title="Terms of Service" lastUpdated="8 July 2026">
      <div>
        <p>
          These terms govern your use of the SynapVex Technologies website, services and products,
          including Synapvex Learn. By creating an account or using our services you agree to these terms.
        </p>
      </div>

      <div>
        <h2>Accounts</h2>
        <ul>
          <li>You must provide accurate information when creating an account and keep your credentials secure.</li>
          <li>You are responsible for activity that happens under your account.</li>
          <li>We may suspend accounts that violate these terms, abuse the platform, or infringe others' rights.</li>
        </ul>
      </div>

      <div>
        <h2>Teachers & Course Content</h2>
        <ul>
          <li>Teachers and organisations retain ownership of the course content they create and upload.</li>
          <li>By publishing content you grant us the licence needed to host, display and deliver it to your enrolled students.</li>
          <li>You are responsible for ensuring your content is accurate, lawful, and does not infringe third-party rights.</li>
          <li>Branded course pages must not impersonate other businesses or mislead students.</li>
        </ul>
      </div>

      <div>
        <h2>Subscriptions & Payments</h2>
        <ul>
          <li>Teacher plans are billed monthly and can be cancelled anytime; access continues to the end of the paid period.</li>
          <li>Course prices are set by the teacher or organisation offering the course.</li>
          <li>Refunds are handled under our <Link to="/refund-policy" className="text-sky-600 hover:underline">Refund Policy</Link>.</li>
        </ul>
      </div>

      <div>
        <h2>Acceptable Use</h2>
        <p>
          You may not use the platform to distribute unlawful, harmful or infringing content, attempt to
          gain unauthorised access to systems or data, or interfere with other users' use of the service.
        </p>
      </div>

      <div>
        <h2>Disclaimer & Liability</h2>
        <p>
          Services are provided "as is". To the maximum extent permitted by law, Synapvex is not liable
          for indirect or consequential losses arising from use of the platform. Nothing in these terms
          excludes liability that cannot be excluded by law.
        </p>
      </div>

      <div>
        <h2>Changes & Contact</h2>
        <p>
          We may update these terms from time to time; material changes will be notified on this page.
          Questions? Contact <a href="mailto:info@synapvex.com" className="text-sky-600 hover:underline">info@synapvex.com</a>.
        </p>
      </div>
    </LegalLayout>
  );
}

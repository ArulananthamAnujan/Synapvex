import { useQuery } from '@tanstack/react-query';
import DashboardLayout from '../../components/layout/DashboardLayout';
import { orgNavItems } from './orgNav';
import CoursePageEditor from '../../components/storefront/CoursePageEditor';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';

export default function OrgCoursePage() {
  const { orgMembership } = useAuth();
  const orgId = (orgMembership?.organization as { id?: string })?.id ?? orgMembership?.org_id;

  const { data: org } = useQuery({
    queryKey: ['org-detail', orgId],
    enabled: !!orgId,
    queryFn: async () => {
      const { data } = await supabase.from('organizations').select('*').eq('id', orgId!).maybeSingle();
      return data;
    },
  });

  return (
    <DashboardLayout
      navItems={orgNavItems}
      title="Course Page"
      subtitle="Your organisation's branded page where students browse and buy your courses"
    >
      {orgId && (
        <CoursePageEditor
          owner={{ type: 'org', orgId }}
          defaults={{
            display_name: org?.name ?? '',
            logo_url: org?.logo_url ?? '',
            website: org?.website ?? '',
            description: org?.description ?? '',
          }}
        />
      )}
    </DashboardLayout>
  );
}

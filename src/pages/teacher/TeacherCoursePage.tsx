import DashboardLayout from '../../components/layout/DashboardLayout';
import { teacherNavItems } from './teacherNav';
import CoursePageEditor from '../../components/storefront/CoursePageEditor';
import { useAuth } from '../../contexts/AuthContext';

export default function TeacherCoursePage() {
  const { user, profile } = useAuth();

  return (
    <DashboardLayout
      navItems={teacherNavItems}
      title="My Course Page"
      subtitle="Your own branded page where students browse and buy your courses"
    >
      {user && (
        <CoursePageEditor
          owner={{ type: 'teacher', teacherId: user.id }}
          defaults={{ display_name: profile?.full_name ?? '', description: profile?.bio ?? '' }}
        />
      )}
    </DashboardLayout>
  );
}

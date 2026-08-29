import { useState, useEffect } from 'react';
import { BookOpen, Pencil, Users, Star, Clock, Globe, EyeOff, Share2, Plus, SlidersHorizontal, Trash2 } from 'lucide-react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../components/layout/DashboardLayout';
import { teacherNavItems } from './teacherNav';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';
import { useToast } from '../../contexts/ToastContext';
import { useOwnCoursePage, coursePageCourseUrl } from '../../hooks/useCoursePage';
import type { Course } from '../../types';
import ConfirmDialog from '../../components/ui/ConfirmDialog';

export default function TeacherCourses() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [editCourse, setEditCourse] = useState<Course | null>(null);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState<string | null>(null);
  const [deleteCourse, setDeleteCourse] = useState<Course | null>(null);
  const [deleting, setDeleting] = useState(false);
  const { profile } = useAuth();
  const { toast } = useToast();
  // Branded course page (if configured) so share links carry the teacher's brand
  const { data: coursePage } = useOwnCoursePage(profile ? { type: 'teacher', teacherId: profile.id } : null);

  const handleShare = (course: Course) => {
    const url = coursePage?.is_published
      ? coursePageCourseUrl(coursePage.slug, course.id)
      : `${window.location.origin}/courses/${course.id}`;
    navigator.clipboard.writeText(url);
    toast.success(coursePage?.is_published
      ? 'Branded course link copied — students will see your course page.'
      : 'Course link copied. Tip: set up "My Course Page" to share a branded link.');
  };

  const fetchCourses = async () => {
    if (!profile) return;
    const { data } = await supabase.from('courses').select('*').eq('teacher_id', profile.id).eq('is_archived', false).order('created_at', { ascending: false });
    if (data) setCourses(data as Course[]);
    setLoading(false);
  };

  useEffect(() => { fetchCourses(); }, [profile]);

  const handleTogglePublish = async (course: Course) => {
    setPublishing(course.id);
    const newStatus = !course.is_published;
    const { error } = await supabase.from('courses').update({ is_published: newStatus }).eq('id', course.id);
    if (!error) {
      toast.success(newStatus ? 'Course published — students can now find and enrol.' : 'Course unpublished — hidden from students.');
      setCourses(prev => prev.map(c => c.id === course.id ? { ...c, is_published: newStatus } : c));
    } else {
      toast.error('Failed to update publish status');
    }
    setPublishing(null);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editCourse) return;
    setSaving(true);
    const { error } = await supabase.from('courses').update({
      title: editCourse.title,
      short_description: editCourse.short_description,
      description: editCourse.description,
      thumbnail_url: editCourse.thumbnail_url,
      price: editCourse.price,
    }).eq('id', editCourse.id);
    if (!error) { toast.success('Course updated'); setEditCourse(null); fetchCourses(); }
    else toast.error('Failed to update course');
    setSaving(false);
  };

  const handleDelete = async () => {
    if (!deleteCourse || !profile) return;
    setDeleting(true);
    // Archive instead of hard-deleting so enrolments, payments and student
    // progress retain referential integrity. The course disappears everywhere
    // teachers and students browse active content.
    const { error } = await supabase
      .from('courses')
      .update({ is_archived: true, is_published: false })
      .eq('id', deleteCourse.id)
      .eq('teacher_id', profile.id);

    if (error) {
      toast.error('Could not delete the course. Please try again.');
    } else {
      setCourses(previous => previous.filter(course => course.id !== deleteCourse.id));
      toast.success(`“${deleteCourse.title}” was deleted.`);
      setDeleteCourse(null);
    }
    setDeleting(false);
  };

  return (
    <DashboardLayout navItems={teacherNavItems} title="My Courses" subtitle="Create, edit and publish your courses">
      <div className="space-y-6">
        {/* Header row with primary action */}
        <div className="flex items-center justify-between gap-3">
          <div>
            <h2 className="text-lg font-bold text-slate-900 dark:text-white">Your courses</h2>
            <p className="text-sm text-slate-400">{loading ? 'Loading…' : `${courses.length} course${courses.length === 1 ? '' : 's'}`}</p>
          </div>
          <Link to="/teacher/builder" className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold bg-sky-600 hover:bg-sky-700 text-white rounded-xl transition-colors shadow-sm">
            <Plus className="w-4 h-4" /> New Course
          </Link>
        </div>

        {loading ? (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {[1,2,3].map(i => <div key={i} className="rounded-2xl border border-slate-200 dark:border-navy-700 overflow-hidden animate-pulse"><div className="h-32 bg-slate-200 dark:bg-navy-700" /><div className="p-4 space-y-3"><div className="h-5 bg-slate-200 dark:bg-navy-700 rounded w-3/4" /><div className="h-8 bg-slate-200 dark:bg-navy-700 rounded" /></div></div>)}
          </div>
        ) : courses.length === 0 ? (
          <div className="relative overflow-hidden rounded-3xl border border-slate-200 dark:border-navy-700 bg-gradient-to-br from-white to-slate-50 dark:from-navy-800 dark:to-navy-900">
            <div className="absolute -top-16 -right-10 w-72 h-72 bg-sky-400/10 rounded-full blur-3xl" />
            <div className="relative px-6 py-14 text-center max-w-md mx-auto">
              <div className="w-16 h-16 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-sky-500 to-blue-700 flex items-center justify-center shadow-lg shadow-sky-500/30">
                <BookOpen className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-bold text-slate-900 dark:text-white mb-2">Create your first course</h3>
              <p className="text-sm text-slate-500 dark:text-slate-400 mb-7">Build it your way or let AI draft a full outline in seconds.</p>
              <Link to="/teacher/builder" className="inline-flex items-center gap-2 px-6 py-3 bg-sky-600 hover:bg-sky-700 text-white font-bold rounded-xl transition-colors shadow-lg shadow-sky-600/25">
                <Plus className="w-5 h-5" /> Create Course
              </Link>
            </div>
          </div>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {courses.map(course => (
              <div key={course.id} className="group rounded-2xl border border-slate-200 dark:border-navy-700 bg-white dark:bg-navy-800 overflow-hidden hover:shadow-xl hover:-translate-y-1 transition-all duration-200">
                <div className="relative h-32 overflow-hidden bg-gradient-to-br from-sky-100 to-indigo-50 dark:from-navy-700 dark:to-navy-900">
                  {course.thumbnail_url
                    ? <img src={course.thumbnail_url} alt="" className="w-full h-full object-cover" />
                    : <BookOpen className="w-9 h-9 text-sky-400 absolute inset-0 m-auto" />}
                  <span className={`absolute top-3 left-3 text-[10px] font-bold uppercase tracking-wide px-2 py-0.5 rounded-full ${course.is_published ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700'}`}>
                    {course.is_published ? 'Live' : 'Draft'}
                  </span>
                </div>
                <div className="p-4">
                  <h3 className="font-bold text-slate-900 dark:text-white mb-2 line-clamp-2 text-sm leading-snug group-hover:text-sky-600 transition-colors">{course.title}</h3>
                  <div className="flex items-center gap-3 text-xs text-slate-400 mb-4">
                    <span className="flex items-center gap-1"><Users className="w-3 h-3" />{course.total_students}</span>
                    <span className="flex items-center gap-1"><Star className="w-3 h-3 fill-amber-400 text-amber-400" />{course.rating}</span>
                    <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{course.duration_hours}h</span>
                  </div>
                  <div className="flex gap-2">
                    {/* Primary: full editor (edit all course components) */}
                    <Link to={`/teacher/builder?courseId=${course.id}`} className="flex-1 inline-flex items-center justify-center gap-1.5 px-3 py-2 bg-sky-600 hover:bg-sky-700 text-white text-xs font-bold rounded-lg transition-colors">
                      <Pencil className="w-3.5 h-3.5" /> Edit
                    </Link>
                    <button
                      onClick={() => handleTogglePublish(course)}
                      disabled={publishing === course.id}
                      title={course.is_published ? 'Unpublish course' : 'Publish course'}
                      className={`p-2 rounded-lg transition-colors disabled:opacity-60 ${
                        course.is_published
                          ? 'border border-emerald-200 dark:border-emerald-700 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20'
                          : 'border border-amber-200 dark:border-amber-700 text-amber-600 dark:text-amber-400 hover:bg-amber-50 dark:hover:bg-amber-900/20'
                      }`}
                    >
                      {publishing === course.id
                        ? <div className="w-3.5 h-3.5 border-2 border-current border-t-transparent rounded-full animate-spin" />
                        : course.is_published ? <EyeOff className="w-3.5 h-3.5" /> : <Globe className="w-3.5 h-3.5" />}
                    </button>
                    {course.is_published && (
                      <button
                        onClick={() => handleShare(course)}
                        title="Copy share link for students"
                        className="p-2 border border-sky-200 dark:border-sky-700 rounded-lg text-sky-600 dark:text-sky-400 hover:bg-sky-50 dark:hover:bg-sky-900/20 transition-colors"
                      >
                        <Share2 className="w-3.5 h-3.5" />
                      </button>
                    )}
                    <button onClick={() => setEditCourse(course)} title="Quick edit details" className="p-2 border border-slate-200 dark:border-navy-600 rounded-lg text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-navy-700 transition-colors">
                      <SlidersHorizontal className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => setDeleteCourse(course)}
                      title="Delete course"
                      aria-label={`Delete ${course.title}`}
                      className="p-2 border border-red-200 dark:border-red-800 rounded-lg text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {editCourse && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={() => setEditCourse(null)} />
          <div className="relative bg-white dark:bg-navy-800 rounded-2xl shadow-2xl w-full max-w-lg p-6 animate-slide-up max-h-[90vh] overflow-y-auto">
            <h3 className="font-playfair text-xl font-bold text-gray-900 dark:text-white mb-5">Edit Course</h3>
            <form onSubmit={handleSave} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Title</label>
                <input type="text" value={editCourse.title} onChange={e => setEditCourse(c => c ? { ...c, title: e.target.value } : null)} className="input-field" required />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Short Description</label>
                <input type="text" value={editCourse.short_description || ''} onChange={e => setEditCourse(c => c ? { ...c, short_description: e.target.value } : null)} className="input-field" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Full Description</label>
                <textarea value={editCourse.description || ''} onChange={e => setEditCourse(c => c ? { ...c, description: e.target.value } : null)} className="input-field resize-none" rows={4} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Thumbnail URL</label>
                <input type="url" value={editCourse.thumbnail_url || ''} onChange={e => setEditCourse(c => c ? { ...c, thumbnail_url: e.target.value } : null)} className="input-field" placeholder="https://..." />
              </div>
              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setEditCourse(null)} className="px-4 py-2 text-sm border border-gray-200 dark:border-navy-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-navy-700 transition-colors">Cancel</button>
                <button type="submit" disabled={saving} className="btn-primary text-sm py-2 disabled:opacity-60">{saving ? 'Saving...' : 'Save Changes'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        isOpen={Boolean(deleteCourse)}
        title="Delete this course?"
        message={`“${deleteCourse?.title ?? 'This course'}” will be removed from your workspace and hidden from students. Existing payment and progress records will be preserved.`}
        confirmText="Delete course"
        variant="danger"
        loading={deleting}
        onConfirm={handleDelete}
        onCancel={() => !deleting && setDeleteCourse(null)}
      />
    </DashboardLayout>
  );
}

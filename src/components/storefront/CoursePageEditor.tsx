import { useState, useEffect } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import {
  Save, Globe, Mail, Palette, Image as ImageIcon, Link as LinkIcon,
  Copy, ExternalLink, Eye, EyeOff, Store, CheckCircle2, BookOpen,
} from 'lucide-react';
import { toast } from 'sonner';
import { supabase } from '../../lib/supabase';
import {
  useOwnCoursePage, slugify, validateSlug, coursePageUrl, coursePageCourseUrl,
  type CoursePageOwner,
} from '../../hooks/useCoursePage';
import type { Course } from '../../types';

interface Props {
  owner: CoursePageOwner;
  /** Prefill for first-time setup (e.g. org name/logo). */
  defaults?: { display_name?: string; logo_url?: string; website?: string; description?: string };
}

const EMPTY_FORM = {
  slug: '',
  display_name: '',
  tagline: '',
  description: '',
  logo_url: '',
  hero_image_url: '',
  brand_color: '#0f172a',
  accent_color: '#0284c7',
  website: '',
  contact_email: '',
  hide_platform_branding: false,
  is_published: false,
};

export default function CoursePageEditor({ owner, defaults }: Props) {
  const qc = useQueryClient();
  const { data: page, isLoading } = useOwnCoursePage(owner);
  const [form, setForm] = useState(EMPTY_FORM);
  const [slugEdited, setSlugEdited] = useState(false);
  const [saving, setSaving] = useState(false);

  const ownerId = owner.type === 'teacher' ? owner.teacherId : owner.orgId;

  const { data: courses } = useQuery({
    queryKey: ['course-page-courses', owner.type, ownerId],
    queryFn: async () => {
      let query = supabase
        .from('courses')
        .select('id, title, is_published')
        .eq('is_archived', false)
        .order('created_at', { ascending: false });
      query = owner.type === 'teacher' ? query.eq('teacher_id', ownerId) : query.eq('org_id', ownerId);
      const { data } = await query;
      return (data ?? []) as Pick<Course, 'id' | 'title' | 'is_published'>[];
    },
  });

  useEffect(() => {
    if (page) {
      setForm({
        slug: page.slug,
        display_name: page.display_name,
        tagline: page.tagline ?? '',
        description: page.description ?? '',
        logo_url: page.logo_url ?? '',
        hero_image_url: page.hero_image_url ?? '',
        brand_color: page.brand_color,
        accent_color: page.accent_color,
        website: page.website ?? '',
        contact_email: page.contact_email ?? '',
        hide_platform_branding: page.hide_platform_branding,
        is_published: page.is_published,
      });
      setSlugEdited(true);
    } else if (!isLoading && defaults) {
      // prefill only untouched forms so late-arriving defaults never clobber edits
      setForm(f => f.display_name ? f : ({
        ...f,
        display_name: defaults.display_name ?? '',
        logo_url: defaults.logo_url ?? '',
        website: defaults.website ?? '',
        description: defaults.description ?? '',
        slug: defaults.display_name ? slugify(defaults.display_name) : '',
      }));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, isLoading, defaults?.display_name]);

  const setField = <K extends keyof typeof EMPTY_FORM>(key: K, value: (typeof EMPTY_FORM)[K]) => {
    setForm(f => ({ ...f, [key]: value }));
  };

  const handleNameChange = (name: string) => {
    setForm(f => ({
      ...f,
      display_name: name,
      // keep slug in sync until the user customizes it (only pre-publish)
      slug: !slugEdited && !page ? slugify(name) : f.slug,
    }));
  };

  const save = async (e: React.FormEvent) => {
    e.preventDefault();
    const slugError = validateSlug(form.slug);
    if (slugError) { toast.error(slugError); return; }
    if (!form.display_name.trim()) { toast.error('Please enter a page name'); return; }

    setSaving(true);
    const payload = {
      slug: form.slug,
      display_name: form.display_name.trim(),
      tagline: form.tagline.trim(),
      description: form.description.trim(),
      logo_url: form.logo_url.trim() || null,
      hero_image_url: form.hero_image_url.trim() || null,
      brand_color: form.brand_color,
      accent_color: form.accent_color,
      website: form.website.trim() || null,
      contact_email: form.contact_email.trim() || null,
      hide_platform_branding: form.hide_platform_branding,
      is_published: form.is_published,
    };

    const result = page
      ? await supabase.from('course_pages').update(payload).eq('id', page.id)
      : await supabase.from('course_pages').insert({
          ...payload,
          owner_type: owner.type,
          teacher_id: owner.type === 'teacher' ? owner.teacherId : null,
          org_id: owner.type === 'org' ? owner.orgId : null,
        });

    if (result.error) {
      if (result.error.code === '23505') toast.error('That page link is already taken — please choose another.');
      else toast.error(result.error.message);
    } else {
      toast.success(page ? 'Course page updated' : 'Course page created');
      qc.invalidateQueries({ queryKey: ['own-course-page'] });
      qc.invalidateQueries({ queryKey: ['course-page', form.slug] });
    }
    setSaving(false);
  };

  const copyLink = (url: string) => {
    navigator.clipboard.writeText(url);
    toast.success('Link copied to clipboard');
  };

  if (isLoading) {
    return <div className="card p-6 animate-pulse h-64" />;
  }

  const pageUrl = form.slug ? coursePageUrl(form.slug) : '';
  const publishedCourses = (courses ?? []).filter(c => c.is_published);

  return (
    <div className="grid lg:grid-cols-3 gap-6 items-start">
      {/* ── Editor form ── */}
      <form onSubmit={save} className="lg:col-span-2 space-y-4">
        <div className="card p-6 space-y-5">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-slate-100 rounded-xl flex items-center justify-center">
              <Store className="w-5 h-5 text-slate-500" />
            </div>
            <div>
              <h3 className="font-semibold text-slate-800">Your Branded Course Page</h3>
              <p className="text-xs text-slate-400">Students see YOUR brand — your logo, name and colors, not the platform's.</p>
            </div>
          </div>

          <div className="grid sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5">Page Name *</label>
              <input type="text" required value={form.display_name} onChange={e => handleNameChange(e.target.value)} className="input-field" placeholder="Jane's Coding Academy" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><LinkIcon className="w-3 h-3" /> Page Link *</label>
              <div className="flex items-center">
                <span className="text-xs text-slate-400 bg-slate-50 border border-r-0 border-slate-200 rounded-l-lg px-2.5 py-2.5 whitespace-nowrap">/school/</span>
                <input
                  type="text" required value={form.slug}
                  onChange={e => { setSlugEdited(true); setField('slug', slugify(e.target.value) || e.target.value.toLowerCase()); }}
                  className="input-field rounded-l-none flex-1" placeholder="janes-academy"
                />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1.5">Tagline</label>
            <input type="text" value={form.tagline} onChange={e => setField('tagline', e.target.value)} className="input-field" placeholder="Learn practical skills that advance your career" />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1.5">About / Description</label>
            <textarea rows={4} value={form.description} onChange={e => setField('description', e.target.value)} className="input-field resize-none" placeholder="Tell your students who you are and what you teach..." />
          </div>

          <div className="grid sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><ImageIcon className="w-3 h-3" /> Logo URL</label>
              <input type="url" value={form.logo_url} onChange={e => setField('logo_url', e.target.value)} className="input-field" placeholder="https://..." />
              {form.logo_url && <img src={form.logo_url} alt="Logo preview" className="mt-2 h-10 rounded-lg border border-slate-200 object-contain" onError={e => { (e.target as HTMLImageElement).style.display = 'none'; }} />}
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><ImageIcon className="w-3 h-3" /> Hero Banner Image URL</label>
              <input type="url" value={form.hero_image_url} onChange={e => setField('hero_image_url', e.target.value)} className="input-field" placeholder="https://... (optional background)" />
            </div>
          </div>

          <div className="grid sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><Palette className="w-3 h-3" /> Brand Color (header & hero)</label>
              <div className="flex items-center gap-2">
                <input type="color" value={form.brand_color} onChange={e => setField('brand_color', e.target.value)} className="w-10 h-10 rounded-lg border border-slate-200 cursor-pointer p-0.5" />
                <input type="text" value={form.brand_color} onChange={e => setField('brand_color', e.target.value)} className="input-field flex-1 font-mono text-sm" />
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><Palette className="w-3 h-3" /> Accent Color (buttons & links)</label>
              <div className="flex items-center gap-2">
                <input type="color" value={form.accent_color} onChange={e => setField('accent_color', e.target.value)} className="w-10 h-10 rounded-lg border border-slate-200 cursor-pointer p-0.5" />
                <input type="text" value={form.accent_color} onChange={e => setField('accent_color', e.target.value)} className="input-field flex-1 font-mono text-sm" />
              </div>
            </div>
          </div>

          <div className="grid sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><Globe className="w-3 h-3" /> Website</label>
              <input type="url" value={form.website} onChange={e => setField('website', e.target.value)} className="input-field" placeholder="https://yoursite.com" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1.5 flex items-center gap-1"><Mail className="w-3 h-3" /> Contact Email</label>
              <input type="email" value={form.contact_email} onChange={e => setField('contact_email', e.target.value)} className="input-field" placeholder="hello@yoursite.com" />
            </div>
          </div>

          <div className="space-y-3 pt-2 border-t border-slate-100">
            <label className="flex items-center justify-between cursor-pointer">
              <span className="text-sm text-slate-700 flex items-center gap-2">
                {form.is_published ? <Eye className="w-4 h-4 text-emerald-500" /> : <EyeOff className="w-4 h-4 text-slate-400" />}
                <span>
                  <span className="font-semibold block">Publish page</span>
                  <span className="text-xs text-slate-400">Make your course page publicly visible at your link</span>
                </span>
              </span>
              <input type="checkbox" checked={form.is_published} onChange={e => setField('is_published', e.target.checked)} className="w-5 h-5 rounded accent-emerald-600" />
            </label>
            <label className="flex items-center justify-between cursor-pointer">
              <span className="text-sm text-slate-700">
                <span className="font-semibold block">Hide platform branding</span>
                <span className="text-xs text-slate-400">Remove the "Powered by Synapvex" note from your page footer</span>
              </span>
              <input type="checkbox" checked={form.hide_platform_branding} onChange={e => setField('hide_platform_branding', e.target.checked)} className="w-5 h-5 rounded accent-emerald-600" />
            </label>
          </div>

          <button type="submit" disabled={saving} className="btn-primary flex items-center gap-2">
            <Save className="w-4 h-4" />
            {saving ? 'Saving...' : page ? 'Save Changes' : 'Create Course Page'}
          </button>
        </div>
      </form>

      {/* ── Share links & status ── */}
      <div className="space-y-4">
        <div className="card p-5">
          <h3 className="font-semibold text-slate-800 text-sm mb-3">Page Status</h3>
          {page ? (
            page.is_published ? (
              <div className="flex items-center gap-2 text-emerald-600 text-sm font-semibold bg-emerald-50 rounded-xl px-3 py-2.5">
                <CheckCircle2 className="w-4 h-4 shrink-0" /> Live — students can visit your page
              </div>
            ) : (
              <div className="flex items-center gap-2 text-amber-600 text-sm font-semibold bg-amber-50 rounded-xl px-3 py-2.5">
                <EyeOff className="w-4 h-4 shrink-0" /> Draft — enable "Publish page" to go live
              </div>
            )
          ) : (
            <p className="text-sm text-slate-500">Fill in the form and create your page to get a shareable link.</p>
          )}

          {page && pageUrl && (
            <div className="mt-4 space-y-2">
              <p className="text-xs font-semibold text-slate-500">Your page link</p>
              <div className="flex items-center gap-1.5">
                <code className="flex-1 text-xs bg-slate-50 border border-slate-200 rounded-lg px-2.5 py-2 truncate">{pageUrl}</code>
                <button type="button" onClick={() => copyLink(pageUrl)} className="p-2 rounded-lg text-slate-500 hover:bg-slate-100 transition-colors" title="Copy link">
                  <Copy className="w-4 h-4" />
                </button>
                <a href={`/school/${page.slug}`} target="_blank" rel="noopener noreferrer" className="p-2 rounded-lg text-slate-500 hover:bg-slate-100 transition-colors" title="Open page">
                  <ExternalLink className="w-4 h-4" />
                </a>
              </div>
              {!page.is_published && <p className="text-xs text-slate-400">The link works once your page is published.</p>}
            </div>
          )}
        </div>

        {page && (
          <div className="card p-5">
            <h3 className="font-semibold text-slate-800 text-sm mb-1 flex items-center gap-2"><BookOpen className="w-4 h-4 text-slate-400" /> Course Share Links</h3>
            <p className="text-xs text-slate-400 mb-3">Share these instead of the platform links — students will see the course under your brand.</p>
            {publishedCourses.length === 0 ? (
              <p className="text-sm text-slate-500">No published courses yet. Publish a course and its branded link will appear here.</p>
            ) : (
              <div className="space-y-2">
                {publishedCourses.map(course => {
                  const url = coursePageCourseUrl(page.slug, course.id);
                  return (
                    <div key={course.id} className="flex items-center gap-1.5 py-1.5 border-b border-slate-50 last:border-0">
                      <span className="flex-1 text-sm text-slate-700 truncate" title={course.title}>{course.title}</span>
                      <button type="button" onClick={() => copyLink(url)} className="p-1.5 rounded-lg text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors" title="Copy branded course link">
                        <Copy className="w-3.5 h-3.5" />
                      </button>
                      <a href={`/school/${page.slug}/courses/${course.id}`} target="_blank" rel="noopener noreferrer" className="p-1.5 rounded-lg text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors" title="Open branded course page">
                        <ExternalLink className="w-3.5 h-3.5" />
                      </a>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

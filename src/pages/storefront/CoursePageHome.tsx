import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Search, Star, Clock, BookOpen, GraduationCap } from 'lucide-react';
import StorefrontLayout from '../../components/storefront/StorefrontLayout';
import { usePublicCoursePage } from '../../hooks/useCoursePage';
import type { Course, CoursePage } from '../../types';

export default function CoursePageHome() {
  const { slug } = useParams<{ slug: string }>();
  const { data, isLoading } = usePublicCoursePage(slug);
  const [search, setSearch] = useState('');

  if (isLoading) {
    return (
      <div className="min-h-screen bg-white flex items-center justify-center">
        <div className="w-10 h-10 border-4 border-slate-300 border-t-slate-600 rounded-full animate-spin" />
      </div>
    );
  }

  if (!data) {
    return (
      <div className="min-h-screen bg-white flex items-center justify-center p-6">
        <div className="text-center max-w-md">
          <GraduationCap className="w-14 h-14 text-slate-300 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-slate-900 mb-2">Page not found</h1>
          <p className="text-slate-500 mb-6">This course page doesn't exist or isn't published yet.</p>
          <Link to="/" className="inline-block px-6 py-2.5 bg-slate-900 text-white text-sm font-semibold rounded-xl hover:bg-slate-800 transition-colors">
            Go to Synapvex
          </Link>
        </div>
      </div>
    );
  }

  const { page, courses } = data;
  const filtered = search
    ? courses.filter(c =>
        c.title.toLowerCase().includes(search.toLowerCase()) ||
        (c.short_description ?? '').toLowerCase().includes(search.toLowerCase()))
    : courses;

  return (
    <StorefrontLayout page={page}>
      {/* Hero — creator's brand colors */}
      <section className="relative py-16 lg:py-24 overflow-hidden" style={{ backgroundColor: page.brand_color }}>
        {page.hero_image_url && (
          <>
            <img src={page.hero_image_url} alt="" className="absolute inset-0 w-full h-full object-cover opacity-25" />
            <div className="absolute inset-0" style={{ backgroundColor: page.brand_color, opacity: 0.6 }} />
          </>
        )}
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          {page.logo_url && (
            <img src={page.logo_url} alt={page.display_name} className="h-16 lg:h-20 w-auto object-contain mx-auto mb-6" />
          )}
          <h1 className="font-playfair text-4xl lg:text-5xl font-bold text-white mb-4">{page.display_name}</h1>
          {page.tagline && <p className="text-white/80 text-lg lg:text-xl mb-8 max-w-2xl mx-auto">{page.tagline}</p>}
          <div className="max-w-xl mx-auto relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
            <input
              type="text"
              placeholder="Search our courses..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full pl-12 pr-4 py-3.5 rounded-xl bg-white border-0 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 shadow-lg"
              style={{ ['--tw-ring-color' as string]: page.accent_color }}
            />
          </div>
        </div>
      </section>

      {/* Courses */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="flex items-center justify-between mb-8">
          <h2 className="font-playfair text-2xl lg:text-3xl font-bold text-slate-900">Our Courses</h2>
          <p className="text-sm text-slate-500">
            <span className="font-bold text-slate-900">{filtered.length}</span> course{filtered.length === 1 ? '' : 's'}
          </p>
        </div>

        {courses.length === 0 ? (
          <div className="text-center py-16">
            <BookOpen className="w-12 h-12 text-slate-300 mx-auto mb-4" />
            <h3 className="text-lg font-bold text-slate-900 mb-1">No courses published yet</h3>
            <p className="text-slate-500 text-sm">Check back soon — new courses are on the way.</p>
          </div>
        ) : filtered.length === 0 ? (
          <div className="text-center py-16">
            <Search className="w-12 h-12 text-slate-300 mx-auto mb-4" />
            <p className="text-slate-500">No courses match "{search}".</p>
          </div>
        ) : (
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
            {filtered.map(course => (
              <StorefrontCourseCard key={course.id} course={course} page={page} />
            ))}
          </div>
        )}
      </section>

      {/* About */}
      {page.description && (
        <section className="bg-slate-50 border-t border-slate-100">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-14 text-center">
            <h2 className="font-playfair text-2xl font-bold text-slate-900 mb-4">About {page.display_name}</h2>
            <p className="text-slate-600 leading-relaxed whitespace-pre-line">{page.description}</p>
          </div>
        </section>
      )}
    </StorefrontLayout>
  );
}

function StorefrontCourseCard({ course, page }: { course: Course; page: CoursePage }) {
  const price = Number(course.price_amount ?? course.price ?? 0);
  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm group hover:shadow-xl transition-all duration-300 hover:-translate-y-1 overflow-hidden">
      <div className="relative h-44 overflow-hidden">
        <img
          src={course.thumbnail_url || 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg'}
          alt={course.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
        <div className="absolute top-3 left-3">
          {course.is_free
            ? <span className="bg-emerald-500 text-white text-xs font-bold px-2.5 py-1 rounded-full">Free</span>
            : <span className="bg-white/90 text-slate-800 text-xs font-bold px-2.5 py-1 rounded-full capitalize">{course.level}</span>}
        </div>
      </div>
      <div className="p-4">
        <div className="flex items-center gap-1 mb-2">
          {[1, 2, 3, 4, 5].map(i => (
            <Star key={i} className={`w-3 h-3 ${i <= Math.round(course.rating) ? 'fill-amber-400 text-amber-400' : 'text-slate-200'}`} />
          ))}
          <span className="text-xs text-slate-400 ml-1">{course.rating}</span>
        </div>
        <h3 className="font-bold text-slate-900 mb-1.5 line-clamp-2 text-sm leading-snug">{course.title}</h3>
        <p className="text-xs text-slate-500 mb-3 line-clamp-2">{course.short_description}</p>
        <div className="flex items-center gap-3 text-xs text-slate-400 mb-3">
          <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{course.duration_hours}h</span>
          <span className="flex items-center gap-1"><BookOpen className="w-3 h-3" />{course.total_lessons} lessons</span>
        </div>
        <div className="flex items-center justify-between pt-3 border-t border-slate-100">
          <span className="font-bold text-slate-900 text-sm">{course.is_free ? 'Free' : `A$${price.toFixed(2)}`}</span>
          <Link
            to={`/school/${page.slug}/courses/${course.id}`}
            className="px-4 py-1.5 text-white text-xs font-bold rounded-lg transition-opacity hover:opacity-90"
            style={{ backgroundColor: page.accent_color }}
          >
            View Course
          </Link>
        </div>
      </div>
    </div>
  );
}

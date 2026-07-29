/**
 * Synapvex office locations. Displayed in the footer and on the Contact page.
 * Update the address lines as new offices open.
 */
export interface OfficeLocation {
  key: string;
  city: string;
  country: string;
  flag: string;
  /** Full address lines (first line is used where space is tight). */
  lines: string[];
  /** Google Maps query used for the embedded map / directions link. */
  mapQuery: string;
}

export const LOCATIONS: OfficeLocation[] = [
  {
    key: 'melbourne',
    city: 'Melbourne',
    country: 'Australia',
    flag: '🇦🇺',
    lines: ['Melbourne, VIC', 'Australia'],
    mapQuery: 'Melbourne VIC Australia',
  },
  {
    key: 'srilanka',
    city: 'Colombo',
    country: 'Sri Lanka',
    flag: '🇱🇰',
    lines: ['Colombo', 'Sri Lanka'],
    mapQuery: 'Colombo Sri Lanka',
  },
  {
    key: 'bangladesh',
    city: 'Dhaka',
    country: 'Bangladesh',
    flag: '🇧🇩',
    lines: ['Building 33, Level 4, Suite 4A', 'Shah Makhdum Avenue, Sector-12', 'Uttara, Dhaka, 1230'],
    mapQuery: 'Uttara Dhaka Bangladesh',
  },
];

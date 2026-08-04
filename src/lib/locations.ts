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
    lines: ['Suite 403, Level 4', '343 Little Collins Street', 'Melbourne VIC 3000'],
    mapQuery: '343 Little Collins Street Melbourne VIC 3000',
  },
  {
    key: 'srilanka',
    city: 'Dehiwala-Mount Lavinia',
    country: 'Sri Lanka',
    flag: '🇱🇰',
    lines: ['151 Sri Saranankara Road', 'Dehiwala-Mount Lavinia', 'Sri Lanka'],
    mapQuery: '151 Sri Saranankara Road Dehiwala-Mount Lavinia Sri Lanka',
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

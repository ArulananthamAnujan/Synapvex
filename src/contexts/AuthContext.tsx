import { createContext, useContext, useEffect, useState } from 'react';
import type { Session, User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import type { Profile, OrgMember } from '../types';

interface AuthContextType {
  user: User | null;
  profile: Profile | null;
  session: Session | null;
  orgMembership: OrgMember | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<{ error: Error | null }>;
  signUp: (email: string, password: string, fullName: string, role?: string) => Promise<{ error: Error | null; data: { user: User | null } | null }>;
  signOut: () => Promise<void>;
  signInWithGoogle: (nextPath?: string) => Promise<{ error: Error | null }>;
  signInWithMicrosoft: (nextPath?: string) => Promise<{ error: Error | null }>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null, profile: null, session: null, orgMembership: null, loading: true,
  signIn: async () => ({ error: null }),
  signUp: async () => ({ error: null, data: null }),
  signOut: async () => {},
  signInWithGoogle: async () => ({ error: null }),
  signInWithMicrosoft: async () => ({ error: null }),
  refreshProfile: async () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [orgMembership, setOrgMembership] = useState<OrgMember | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchProfile = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();
      if (data && !error) {
        setProfile(data as Profile);
        // fetch org membership for org_admin / teacher roles
        if (data.role === 'org_admin' || data.role === 'teacher') {
          const { data: mem } = await supabase
            .from('org_members')
            .select('*, organization:organizations(*)')
            .eq('user_id', userId)
            .maybeSingle();
          setOrgMembership(mem as OrgMember | null);
        } else {
          setOrgMembership(null);
        }
      }
    } catch {
      // silently fail — user is still authenticated
    }
  };

  useEffect(() => {
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) await fetchProfile(session.user.id);
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        (async () => {
          await fetchProfile(session.user.id);
          setLoading(false);
        })();
      } else {
        setProfile(null);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error: error as Error | null };
  };

  const signUp = async (email: string, password: string, fullName: string, role = 'student') => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName, role } },
    });
    // callers need the new user id (e.g. to attach a subscription record)
    return { error: error as Error | null, data: data ? { user: data.user } : null };
  };

  const signOut = async () => {
    setProfile(null);
    setUser(null);
    setSession(null);
    setOrgMembership(null);
    await supabase.auth.signOut();
  };

  // OAuth errors must reach the caller: if the provider isn't enabled in
  // Supabase, signInWithOAuth fails without redirecting and the button
  // would otherwise appear to do nothing.
  const signInWithGoogle = async (nextPath?: string) => {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: `${window.location.origin}${nextPath ?? '/dashboard'}` },
    });
    return { error: error as Error | null };
  };

  const signInWithMicrosoft = async (nextPath?: string) => {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'azure',
      options: { redirectTo: `${window.location.origin}${nextPath ?? '/dashboard'}` },
    });
    return { error: error as Error | null };
  };

  const refreshProfile = async () => {
    if (user) await fetchProfile(user.id);
  };

  return (
    <AuthContext.Provider value={{ user, profile, session, orgMembership, loading, signIn, signUp, signOut, signInWithGoogle, signInWithMicrosoft, refreshProfile }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);

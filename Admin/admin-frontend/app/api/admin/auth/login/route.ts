import { cookies as nextCookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { createServerClient } from '@supabase/ssr';

export async function POST(req: Request) {
  const cookieStore = await nextCookies();

  // Use getAll and setAll methods
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          // return array of cookies in { name, value } format
          return cookieStore.getAll().map(c => ({ name: c.name, value: c.value }));
        },
        setAll(cookiesToSet) {
          // set cookies for response
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        },
      },
    }
  );

  const { email, password } = await req.json();

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error || data.user?.app_metadata?.role !== 'admin') {
    return NextResponse.json({ error: 'Unauthorized admin' }, { status: 403 });
  }

  // sets the session in cookies
  await supabase.auth.setSession(data.session!);

  return NextResponse.json({ user: data.user });
}

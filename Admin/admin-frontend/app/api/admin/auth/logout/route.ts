import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '../../../../../lib/supabase-server'

export async function POST() {
  const supabaseServer = await createServerSupabaseClient();
  await supabaseServer.auth.signOut();
  const response = NextResponse.json({ success: true });
  response.headers.set('Cache-Control', 'no-store');
  return response;
}

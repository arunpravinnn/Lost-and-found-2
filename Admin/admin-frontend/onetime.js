import { createClient } from '@supabase/supabase-js'
import "dotenv/config"
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function run() {
  const { error } = await supabase.auth.admin.updateUserById(
    '60eebfc7-f70c-4a9f-b2c5-2c9fcc8196d0',
    {
      app_metadata: { role: 'admin' },
    }
  )

  if (error) {
    console.error('Error:', error)
  } else {
    console.log('Admin role assigned successfully')
  }
}

run()

import { icons } from "lucide-react";
import { AuthProvider } from "./AuthContext";
import "./globals.css";
import { Providers } from "./providers";

export const metadata = {
  title: 'Admin - Lost and Found',
  icons:{
    icon: '/logo.png',
  }
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
          <Providers>
            {children}
          </Providers>
        </AuthProvider>
      </body>
    </html>
  );
}

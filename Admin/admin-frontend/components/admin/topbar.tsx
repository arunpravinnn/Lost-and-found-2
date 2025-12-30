"use client"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import Sidebar from "./sidebar"
import { Menu, Bell } from "lucide-react"
import { ThemeToggle } from "./theme-toggle"
import { useRouter } from "next/navigation"
import axios from "axios"
import { useEffect, useState } from "react"
import { createClient } from "@/lib/supabase-client"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { ScrollArea } from "@/components/ui/scroll-area"

interface Notification {
  id: string
  message: string
  timestamp: Date
  read: boolean
}

export default function Topbar() {
  const router = useRouter();
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [unreadCount, setUnreadCount] = useState(0)
  const supabase = createClient()

  useEffect(() => {
    // Initial fetch of unread notifications could be here if we persisted them
    // For now, we'll start fresh on reload as per requirements "whenever user claims"

    const channel = supabase
      .channel('claim-notifications')
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'Lost_items',
        },
        (payload) => {
          const newData = payload.new as any
          const oldData = payload.old as any

          // Check if item was just claimed
          if (newData.claimed === true && oldData.claimed === false) {
            const newNotification: Notification = {
              id: crypto.randomUUID(),
              message: `Item ${newData.item_name || newData.item_id} has been claimed!`,
              timestamp: new Date(),
              read: false
            }

            setNotifications(prev => [newNotification, ...prev])
            setUnreadCount(prev => prev + 1)
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [supabase])

  const handleLogout = async () => {
    try {
      await axios.post("/api/admin/auth/logout")
    } catch (error) {
      console.error("Logout failed:", error)
    }
    router.replace("/Login")
    router.refresh()
    window.history.pushState(null, "", "/Login")
  }

  const handleNotificationClick = () => {
    setUnreadCount(0)
  }

  return (
    <header className="sticky top-0 z-30 w-full border-b bg-background/80 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="mx-auto flex h-14 max-w-7xl items-center gap-3 px-4 md:px-6">
        <Sheet>
          <SheetTrigger asChild className="md:hidden">
            <Button size="icon" variant="outline" aria-label="Open navigation menu">
              <Menu className="size-4" aria-hidden />
            </Button>
          </SheetTrigger>
          <SheetContent side="bottom" className="p-0">
            <SheetHeader className="sr-only">
              <SheetTitle>Navigation</SheetTitle>
            </SheetHeader>
            <Sidebar />
          </SheetContent>
        </Sheet>

        <div className="ml-0 w-full md:ml-2 md:w-auto md:flex-1">
          <form role="search" className="w-full max-w-sm">
            <Input type="search" placeholder="Search..." className="w-full" aria-label="Search" />
          </form>
        </div>

        <div className="ml-auto flex items-center gap-2">
          <Popover>
            <PopoverTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                aria-label="Notifications"
                className="relative"
                onClick={handleNotificationClick}
              >
                <Bell className="size-4" aria-hidden />
                {unreadCount > 0 && (
                  <span className="absolute top-1 right-1 h-2 w-2 rounded-full bg-red-600" />
                )}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-80 p-0" align="end">
              <div className="p-4 border-b">
                <h4 className="font-semibold leading-none">Notifications</h4>
              </div>
              <ScrollArea className="h-[300px]">
                {notifications.length === 0 ? (
                  <div className="p-4 text-center text-sm text-muted-foreground">
                    No new notifications
                  </div>
                ) : (
                  <div className="flex flex-col">
                    {notifications.map((notification) => (
                      <div
                        key={notification.id}
                        className="p-4 border-b last:border-0 hover:bg-muted/50 transition-colors"
                      >
                        <p className="text-sm font-medium">{notification.message}</p>
                        <p className="text-xs text-muted-foreground mt-1">
                          {notification.timestamp.toLocaleTimeString()}
                        </p>
                      </div>
                    ))}
                  </div>
                )}
              </ScrollArea>
            </PopoverContent>
          </Popover>

          <ThemeToggle />
          <Button variant="default" size="default" aria-label="Notifications" onClick={handleLogout}>
            Logout
          </Button>
        </div>
      </div>
    </header>
  )
}

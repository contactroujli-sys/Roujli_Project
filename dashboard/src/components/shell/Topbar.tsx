import { Bell, Menu, Moon, Search, Sun, ChevronDown } from "lucide-react";
import { Link } from "@tanstack/react-router";
import { useTheme } from "@/components/theme";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useNotifications } from "@/lib/queries/notifications";
import { useAuth } from "@/lib/auth";

export function Topbar({ onMenu, onSearch }: { onMenu: () => void; onSearch: () => void }) {
  const { theme, toggle } = useTheme();
  const { data: notifications = [] } = useNotifications();
  const unread = notifications.filter((n: any) => !n.isRead).length;
  const { user, logout } = useAuth();
  const name = user
    ? `${user.firstName || ""} ${user.lastName || ""}`.trim() || user.email
    : "Admin User";
  const initials =
    user && (user.firstName || user.lastName)
      ? `${user.firstName?.[0] || ""}${user.lastName?.[0] || ""}`.toUpperCase()
      : "AD";

  return (
    <header className="sticky top-0 z-20 border-b border-border bg-background/80 backdrop-blur-xl">
      <div className="grid h-16 grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 px-4 sm:px-6 lg:px-8">
        <button
          onClick={onMenu}
          className="grid h-9 w-9 shrink-0 place-items-center rounded-xl border border-border lg:hidden"
          aria-label="Open navigation"
        >
          <Menu className="h-4 w-4" />
        </button>

        <div className="relative hidden min-w-0 md:block">
          <Search className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            readOnly
            onClick={onSearch}
            placeholder="Search businesses, users, requests…"
            className="h-10 w-full max-w-md cursor-pointer rounded-xl border border-border bg-card pl-10 pr-16 text-sm outline-hidden transition-shadow placeholder:text-muted-foreground focus:ring-2 focus:ring-ring/40"
          />
          <kbd className="pointer-events-none absolute right-3 top-1/2 hidden -translate-y-1/2 rounded-md border border-border px-1.5 py-0.5 text-[10px] text-muted-foreground lg:block">
            ⌘K
          </kbd>
        </div>
        <div className="md:hidden" />

        <div className="flex shrink-0 items-center gap-1.5 justify-self-end">
          <button
            onClick={toggle}
            aria-label="Toggle theme"
            className="grid h-9 w-9 place-items-center rounded-xl border border-border bg-card text-muted-foreground transition-colors hover:text-foreground"
          >
            {theme === "dark" ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                aria-label="Notifications"
                className="relative grid h-9 w-9 place-items-center rounded-xl border border-border bg-card text-muted-foreground transition-colors hover:text-foreground"
              >
                <Bell className="h-4 w-4" />
                {unread > 0 && (
                  <span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-danger" />
                )}
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-80 rounded-2xl p-2">
              <DropdownMenuLabel className="flex items-center justify-between">
                Notifications
                <span className="text-[11px] font-normal text-muted-foreground">
                  {unread} unread
                </span>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              {notifications.slice(0, 4).map((n: any) => (
                <DropdownMenuItem key={n.id} className="items-start gap-3 rounded-xl py-2.5">
                  <span
                    className={`mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full ${n.isRead ? "bg-muted-foreground" : "bg-gold"}`}
                  />
                  <span className="min-w-0">
                    <span className="block text-sm font-medium">
                      {n.type?.replace(/_/g, " ") || "Notification"}
                    </span>
                    <span className="block truncate text-xs text-muted-foreground">
                      {n.message}
                    </span>
                    <span className="block pt-0.5 text-[11px] text-muted-foreground">
                      {new Date(n.createdAt).toLocaleDateString()}
                    </span>
                  </span>
                </DropdownMenuItem>
              ))}
            </DropdownMenuContent>
          </DropdownMenu>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="flex items-center gap-2 rounded-xl border border-border bg-card py-1 pl-1 pr-2 transition-colors hover:bg-secondary">
                <span className="grid h-7 w-7 shrink-0 place-items-center rounded-lg bg-primary text-[11px] font-semibold text-primary-foreground">
                  {initials}
                </span>
                <span className="hidden min-w-0 text-left sm:block">
                  <span className="block truncate text-xs font-medium leading-tight">{name}</span>
                  <span className="block truncate text-[10px] leading-tight text-muted-foreground">
                    Super Admin
                  </span>
                </span>
                <ChevronDown className="hidden h-3.5 w-3.5 text-muted-foreground sm:block" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-52 rounded-2xl p-2">
              <DropdownMenuLabel>My account</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <Link to="/settings/profile">
                <DropdownMenuItem className="rounded-lg">Profile</DropdownMenuItem>
              </Link>
              <Link to="/settings/preferences">
                <DropdownMenuItem className="rounded-lg">Preferences</DropdownMenuItem>
              </Link>
              <Link to="/settings/team-access">
                <DropdownMenuItem className="rounded-lg">Team access</DropdownMenuItem>
              </Link>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="rounded-lg text-danger" onClick={logout}>
                Logout
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}

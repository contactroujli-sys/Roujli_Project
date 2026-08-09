import { Link, useRouterState } from "@tanstack/react-router";
import {
  LayoutDashboard,
  Users,
  Building2,
  LayoutGrid,
  Package,
  Wrench,
  Inbox,
  CreditCard,
  TrendingUp,
  Flag,
  Bell,
  Settings,
  LogOut,
  X,
  UserCog,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/lib/auth";

const groups: { label: string; items: { to: string; label: string; icon: typeof Users }[] }[] = [
  {
    label: "Overview",
    items: [
      { to: "/", label: "Dashboard", icon: LayoutDashboard },
      { to: "/growth", label: "Growth Analytics", icon: TrendingUp },
    ],
  },
  {
    label: "Manage",
    items: [
      { to: "/users", label: "Users", icon: Users },
      { to: "/businesses", label: "Businesses", icon: Building2 },
      { to: "/categories", label: "Categories", icon: LayoutGrid },
      { to: "/products", label: "Products", icon: Package },
      { to: "/services", label: "Services", icon: Wrench },
      { to: "/requests", label: "Requests", icon: Inbox },
      { to: "/subscriptions", label: "Subscriptions", icon: CreditCard },
    ],
  },
  {
    label: "System",
    items: [
      { to: "/reports", label: "Reports", icon: Flag },
      { to: "/notifications", label: "Notifications", icon: Bell },
      { to: "/settings", label: "Settings", icon: Settings },
      { to: "/settings/profile", label: "Admin Profile", icon: UserCog },
    ],
  },
];

export function Sidebar({ open, onClose }: { open: boolean; onClose: () => void }) {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { user, logout } = useAuth();

  return (
    <>
      {open && (
        <button
          aria-label="Close navigation"
          onClick={onClose}
          className="fixed inset-0 z-30 bg-foreground/30 backdrop-blur-xs lg:hidden"
        />
      )}
      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-40 flex w-[264px] flex-col border-r border-sidebar-border bg-sidebar transition-transform duration-300 lg:translate-x-0",
          open ? "translate-x-0" : "-translate-x-full",
        )}
      >
        <div className="flex h-16 shrink-0 items-center justify-between px-6">
          <Link to="/" className="flex min-w-0 items-center gap-2.5">
            <img
              src="/icon.png"
              alt="ROUJLI Logo"
              className="h-8 w-8 shrink-0 rounded-xl object-contain"
            />
            <span className="min-w-0">
              <span className="block truncate text-sm font-semibold tracking-tight">ROUJLI</span>
              <span className="block truncate text-[10px] uppercase tracking-[0.18em] text-muted-foreground">
                Growth Platform
              </span>
            </span>
          </Link>
          <button onClick={onClose} className="text-muted-foreground lg:hidden" aria-label="Close">
            <X className="h-4 w-4" />
          </button>
        </div>

        <nav className="scrollbar-slim flex-1 space-y-6 overflow-y-auto px-4 pb-4">
          {groups.map((group) => (
            <div key={group.label} className="space-y-1">
              <p className="px-3 pb-1 text-[10px] font-semibold uppercase tracking-[0.16em] text-muted-foreground">
                {group.label}
              </p>
              {group.items.map((item) => {
                const active = pathname === item.to;
                return (
                  <Link
                    key={item.to}
                    to={item.to}
                    onClick={onClose}
                    className={cn(
                      "group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors",
                      active
                        ? "bg-sidebar-primary font-medium text-sidebar-primary-foreground"
                        : "text-muted-foreground hover:bg-sidebar-accent hover:text-foreground",
                    )}
                  >
                    <item.icon className={cn("h-4 w-4 shrink-0", active && "text-gold")} />
                    <span className="truncate">{item.label}</span>
                  </Link>
                );
              })}
            </div>
          ))}
        </nav>

        <div className="border-t border-sidebar-border p-4">
          <div className="mb-3 rounded-2xl bg-gold-soft p-4">
            <p className="text-xs font-semibold truncate">
              {user?.firstName ? `${user.firstName} ${user.lastName || ""}` : "Admin User"}
            </p>
            <p className="mt-1 text-[11px] leading-relaxed text-muted-foreground truncate">
              {user?.email || "admin@roujli.com"}
            </p>
          </div>
          <button
            onClick={() => {
              logout();
              window.location.href = "/login";
            }}
            className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm text-muted-foreground transition-colors hover:bg-sidebar-accent hover:text-danger"
          >
            <LogOut className="h-4 w-4 shrink-0" />
            Logout
          </button>
        </div>
      </aside>
    </>
  );
}

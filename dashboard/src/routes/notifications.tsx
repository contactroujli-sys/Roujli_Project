import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, Panel } from "@/components/ui/page";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useNotifications } from "@/lib/queries";

export const Route = createFileRoute("/notifications")({
  head: () => ({
    meta: [
      { title: "Notifications — ROUJLI Admin" },
      {
        name: "description",
        content: "Platform alerts, moderation events and billing notifications for ROUJLI admins.",
      },
      { property: "og:title", content: "Notifications — ROUJLI Admin" },
      { property: "og:description", content: "Platform alerts and events for ROUJLI admins." },
    ],
  }),
  component: NotificationsPage,
});

const tone: Record<string, string> = {
  success: "bg-success",
  danger: "bg-danger",
  warning: "bg-warning",
  neutral: "bg-muted-foreground",
};

function getNotificationTone(type: string) {
  if (type.includes("REJECTED")) return "danger";
  if (type.includes("ACCEPTED")) return "success";
  if (type.includes("NEW")) return "warning";
  return "neutral";
}

function NotificationsPage() {
  const { data: notifications, isLoading } = useNotifications();

  if (isLoading) return <PageSkeleton />;

  return (
    <>
      <PageHeader
        title="Notifications"
        description="Everything that needs your attention, newest first."
        actions={
          <button className="h-9 rounded-xl border border-border px-3.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
            Mark all as read
          </button>
        }
      />
      <Panel bodyClassName="p-0">
        <ul className="divide-y divide-border">
          {(notifications || []).map((n: any) => (
            <li key={n.id} className={`flex gap-4 px-6 py-4 ${n.isRead ? "opacity-60" : ""}`}>
              <span
                className={`mt-2 h-2 w-2 shrink-0 rounded-full ${tone[getNotificationTone(n.type)]}`}
              />
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium">{n.type.replace(/_/g, " ")}</p>
                <p className="truncate text-xs text-muted-foreground">{n.message}</p>
              </div>
              <span className="shrink-0 text-xs text-muted-foreground">
                {new Date(n.createdAt).toLocaleDateString()}
              </span>
            </li>
          ))}
          {(!notifications || notifications.length === 0) && (
            <li className="px-6 py-8 text-center text-sm text-muted-foreground">
              No notifications
            </li>
          )}
        </ul>
      </Panel>
    </>
  );
}

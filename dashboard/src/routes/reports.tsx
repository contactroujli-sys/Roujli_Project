import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, StatusPill } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useReports, useUpdateReportStatus } from "@/lib/queries";

export const Route = createFileRoute("/reports")({
  head: () => ({
    meta: [
      { title: "Reports — ROUJLI Admin" },
      {
        name: "description",
        content: "Moderate user, business and content reports raised on the ROUJLI platform.",
      },
      { property: "og:title", content: "Reports — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Moderate user, business and content reports on ROUJLI.",
      },
    ],
  }),
  component: ReportsPage,
});

function ReportsPage() {
  const { data: reports, isLoading } = useReports();
  const updateMutation = useUpdateReportStatus();

  if (isLoading) return <PageSkeleton />;

  const columns: Column<any>[] = [
    {
      key: "subject",
      header: "Subject",
      cell: (r) => (
        <div className="min-w-0">
          <p className="truncate text-sm font-medium">{r.subject}</p>
          <p className="truncate text-xs text-muted-foreground">{r.id}</p>
        </div>
      ),
    },
    { key: "type", header: "Type", cell: (r) => <span className="text-sm">{r.type}</span> },
    {
      key: "reason",
      header: "Reason",
      cell: (r) => <span className="text-sm text-muted-foreground">{r.reason}</span>,
    },
    {
      key: "reporter",
      header: "Reported by",
      cell: (r) => (
        <span className="text-sm text-muted-foreground">{r.reporter?.email || r.reporterId}</span>
      ),
    },
    {
      key: "status",
      header: "Status",
      cell: (r) => <StatusPill status={r.status?.toLowerCase() || "pending"} />,
    },
    {
      key: "date",
      header: "Date",
      cell: (r) => (
        <span className="num text-sm text-muted-foreground">
          {new Date(r.createdAt).toLocaleDateString()}
        </span>
      ),
    },
    {
      key: "actions",
      header: "",
      cell: (r) => (
        <div className="flex items-center justify-end gap-2">
          {r.status === "PENDING" && (
            <>
              <button
                onClick={() => updateMutation.mutate({ id: r.id, status: "RESOLVED" })}
                disabled={updateMutation.isPending}
                className="rounded px-2 py-1 text-xs font-medium text-success hover:bg-success-soft"
              >
                Resolve
              </button>
              <button
                onClick={() => updateMutation.mutate({ id: r.id, status: "DISMISSED" })}
                disabled={updateMutation.isPending}
                className="rounded px-2 py-1 text-xs font-medium text-muted-foreground hover:bg-secondary"
              >
                Dismiss
              </button>
            </>
          )}
        </div>
      ),
    },
  ];

  const userReports = reports?.filter((r: any) => r.type === "USER").length || 0;
  const businessReports = reports?.filter((r: any) => r.type === "BUSINESS").length || 0;
  const contentReports = reports?.filter((r: any) => r.type === "CONTENT").length || 0;
  const pendingReports = reports?.filter((r: any) => r.status === "PENDING").length || 0;

  return (
    <>
      <PageHeader
        title="Reports"
        description="Moderation queue for user, business and content reports."
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="User Reports" value={userReports.toString()} delta="+0%" trend="up" />
        <StatCard
          label="Business Reports"
          value={businessReports.toString()}
          delta="-0%"
          trend="down"
        />
        <StatCard
          label="Content Reports"
          value={contentReports.toString()}
          delta="+0%"
          trend="up"
        />
        <StatCard
          label="Pending"
          value={pendingReports.toString()}
          delta="+0%"
          trend="up"
          hint="awaiting review"
        />
      </div>
      <DataTable
        rows={reports || []}
        columns={columns}
        searchKeys={["subject", "reason"]}
        filters={["Type", "Status"]}
      />
    </>
  );
}

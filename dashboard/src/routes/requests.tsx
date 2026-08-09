import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, StatusPill } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useRequests, useUpdateRequestStatus } from "@/lib/queries";

export const Route = createFileRoute("/requests")({
  head: () => ({
    meta: [
      { title: "Requests — ROUJLI Admin" },
      {
        name: "description",
        content: "Track customer service requests between customers and businesses on ROUJLI.",
      },
      { property: "og:title", content: "Requests — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Track customer service requests across ROUJLI businesses.",
      },
    ],
  }),
  component: RequestsPage,
});

function RequestsPage() {
  const { data: requests, isLoading } = useRequests();
  const updateMutation = useUpdateRequestStatus();

  if (isLoading) return <PageSkeleton />;

  const columns: Column<any>[] = [
    {
      key: "customer",
      header: "Customer",
      cell: (r) => (
        <div className="min-w-0">
          <p className="truncate text-sm font-medium">
            {r.user?.profile?.firstName} {r.user?.profile?.lastName}
          </p>
          <p className="truncate text-xs text-muted-foreground">{r.id}</p>
        </div>
      ),
    },
    {
      key: "business",
      header: "Business",
      cell: (r) => <span className="text-sm text-muted-foreground">{r.businessId}</span>,
    },
    {
      key: "service",
      header: "Service/Product",
      cell: (r) => <span className="text-sm">{r.service?.name || r.product?.name || r.type}</span>,
    },
    {
      key: "status",
      header: "Status",
      cell: (r) => <StatusPill status={r.status?.toLowerCase() || "pending"} />,
    },
    {
      key: "created",
      header: "Created",
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
                onClick={() => updateMutation.mutate({ id: r.id, status: "ACCEPTED" })}
                disabled={updateMutation.isPending}
                className="rounded px-2 py-1 text-xs font-medium text-success hover:bg-success-soft"
              >
                Accept
              </button>
              <button
                onClick={() => updateMutation.mutate({ id: r.id, status: "REJECTED" })}
                disabled={updateMutation.isPending}
                className="rounded px-2 py-1 text-xs font-medium text-danger hover:bg-danger-soft"
              >
                Reject
              </button>
            </>
          )}
        </div>
      ),
    },
  ];

  const totalRequests = requests?.length || 0;
  const pendingRequests = requests?.filter((r: any) => r.status === "PENDING").length || 0;
  const completedRequests = requests?.filter((r: any) => r.status === "ACCEPTED").length || 0;

  return (
    <>
      <PageHeader
        title="Requests"
        description="Every customer request routed through the platform."
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Total Requests"
          value={totalRequests.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard
          label="Completed"
          value={completedRequests.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard
          label="Pending"
          value={pendingRequests.toLocaleString()}
          delta="-0%"
          trend="down"
        />
        <StatCard label="Avg. response" value="-" delta="-0%" trend="down" hint="target under 4h" />
      </div>
      <DataTable
        rows={requests || []}
        columns={columns}
        searchKeys={["customer", "business", "service"]}
        filters={["Status"]}
      />
    </>
  );
}

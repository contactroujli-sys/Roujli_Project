import { createFileRoute } from "@tanstack/react-router";
import { Trash2 } from "lucide-react";
import { PageHeader, StatusPill, Avatar } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useServices, useDeleteService } from "@/lib/queries";

export const Route = createFileRoute("/services")({
  head: () => ({
    meta: [
      { title: "Services — ROUJLI Admin" },
      { name: "description", content: "Manage bookable services offered by businesses on ROUJLI." },
      { property: "og:title", content: "Services — ROUJLI Admin" },
      { property: "og:description", content: "Manage bookable services offered on ROUJLI." },
    ],
  }),
  component: ServicesPage,
});

function ServicesPage() {
  const { data: services, isLoading } = useServices();
  const deleteMutation = useDeleteService();

  if (isLoading) return <PageSkeleton />;

  const columns: Column<any>[] = [
    {
      key: "name",
      header: "Service",
      cell: (s) => (
        <div className="flex min-w-0 items-center gap-3">
          <Avatar name={s.name} />
          <div className="min-w-0">
            <p className="truncate text-sm font-medium">{s.name}</p>
            <p className="truncate text-xs text-muted-foreground">{s.id}</p>
          </div>
        </div>
      ),
    },
    {
      key: "business",
      header: "Business",
      cell: (s) => <span className="text-sm text-muted-foreground">{s.businessId}</span>,
    },
    {
      key: "category",
      header: "Category",
      cell: (s) => <span className="text-sm">{s.business?.category?.name || "-"}</span>,
    },
    {
      key: "price",
      header: "Price",
      cell: (s) => <span className="num text-sm font-medium">{s.price}</span>,
    },
    { key: "status", header: "Status", cell: (s) => <StatusPill status="active" /> },
    {
      key: "actions",
      header: "",
      cell: (s) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => {
              if (confirm("Delete service?")) deleteMutation.mutate(s.id);
            }}
            disabled={deleteMutation.isPending}
            className="rounded p-1.5 text-danger hover:bg-danger-soft"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      ),
    },
  ];

  const totalServices = services?.length || 0;

  return (
    <>
      <PageHeader
        title="Services"
        description="Bookable offerings and their availability across businesses."
        actions={
          <button className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
            Add service
          </button>
        }
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Total Services"
          value={totalServices.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard
          label="Bookable now"
          value={totalServices.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard label="Draft" value="0" delta="-0%" trend="down" />
        <StatCard label="Avg. booking value" value="-" delta="+0%" trend="up" />
      </div>
      <DataTable
        rows={services || []}
        columns={columns}
        searchKeys={["name"]}
        filters={["Status"]}
      />
    </>
  );
}

import { createFileRoute } from "@tanstack/react-router";
import { Trash2 } from "lucide-react";
import { PageHeader, StatusPill } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useCategories, useDeleteCategory } from "@/lib/queries";

export const Route = createFileRoute("/categories")({
  head: () => ({
    meta: [
      { title: "Categories — ROUJLI Admin" },
      {
        name: "description",
        content: "Organise the ROUJLI taxonomy of business, product and service categories.",
      },
      { property: "og:title", content: "Categories — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Organise ROUJLI business, product and service categories.",
      },
    ],
  }),
  component: CategoriesPage,
});

function CategoriesPage() {
  const { data: categories, isLoading } = useCategories();
  const deleteMutation = useDeleteCategory();

  if (isLoading) return <PageSkeleton />;

  const columns: Column<any>[] = [
    {
      key: "name",
      header: "Category",
      cell: (c) => (
        <div className="min-w-0">
          <p className="truncate text-sm font-medium">{c.name}</p>
          <p className="truncate text-xs text-muted-foreground">{c.id}</p>
        </div>
      ),
    },
    {
      key: "businesses",
      header: "Businesses",
      cell: (c) => (
        <span className="num text-sm">{c._count?.businesses?.toLocaleString() || "0"}</span>
      ),
    },
    { key: "products", header: "Products", cell: (c) => <span className="num text-sm">0</span> }, // No products count yet
    { key: "services", header: "Services", cell: (c) => <span className="num text-sm">0</span> }, // No services count yet
    { key: "status", header: "Status", cell: (c) => <StatusPill status="active" /> },
    {
      key: "actions",
      header: "",
      cell: (c) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => {
              if (confirm("Delete category?")) deleteMutation.mutate(c.id);
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

  const totalCategories = categories?.length || 0;

  return (
    <>
      <PageHeader
        title="Categories"
        description="The taxonomy powering discovery across the platform."
        actions={
          <button className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
            New category
          </button>
        }
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Categories" value={totalCategories.toString()} delta="+0" trend="up" />
        <StatCard label="Subcategories" value="0" delta="+0" trend="up" />
        <StatCard label="Uncategorised listings" value="0" delta="-0%" trend="down" />
        <StatCard label="Avg. per category" value="0" delta="+0%" trend="up" hint="businesses" />
      </div>
      <DataTable
        rows={categories || []}
        columns={columns}
        searchKeys={["name"]}
        filters={["Status"]}
      />
    </>
  );
}

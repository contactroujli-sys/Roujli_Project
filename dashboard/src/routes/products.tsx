import { createFileRoute } from "@tanstack/react-router";
import { Trash2 } from "lucide-react";
import { PageHeader, StatusPill, Avatar } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useProducts, useDeleteProduct } from "@/lib/queries";

export const Route = createFileRoute("/products")({
  head: () => ({
    meta: [
      { title: "Products — ROUJLI Admin" },
      {
        name: "description",
        content: "Moderate and manage every product listed by businesses on ROUJLI.",
      },
      { property: "og:title", content: "Products — ROUJLI Admin" },
      { property: "og:description", content: "Moderate and manage product catalogs on ROUJLI." },
    ],
  }),
  component: ProductsPage,
});

function ProductsPage() {
  const { data: products, isLoading } = useProducts();
  const deleteMutation = useDeleteProduct();

  if (isLoading) return <PageSkeleton />;

  const columns: Column<any>[] = [
    {
      key: "name",
      header: "Product",
      cell: (p) => (
        <div className="flex min-w-0 items-center gap-3">
          <Avatar name={p.name} />
          <div className="min-w-0">
            <p className="truncate text-sm font-medium">{p.name}</p>
            <p className="truncate text-xs text-muted-foreground">{p.id}</p>
          </div>
        </div>
      ),
    },
    {
      key: "business",
      header: "Business",
      cell: (p) => <span className="text-sm text-muted-foreground">{p.businessId}</span>,
    },
    {
      key: "category",
      header: "Category",
      cell: (p) => <span className="text-sm">{p.business?.category?.name || "-"}</span>,
    },
    {
      key: "price",
      header: "Price",
      cell: (p) => (
        <span className="num text-sm font-medium">
          {p.price} {p.currency}
        </span>
      ),
    },
    { key: "status", header: "Status", cell: (p) => <StatusPill status="active" /> }, // Default active
    {
      key: "actions",
      header: "",
      cell: (p) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => {
              if (confirm("Delete product?")) deleteMutation.mutate(p.id);
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

  const totalProducts = products?.length || 0;

  return (
    <>
      <PageHeader
        title="Products"
        description="Catalog items published by businesses across the platform."
        actions={
          <button className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
            Add product
          </button>
        }
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Total Products"
          value={totalProducts.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard label="Published" value={totalProducts.toLocaleString()} delta="+0%" trend="up" />
        <StatCard label="Awaiting review" value="0" delta="+0%" trend="up" />
        <StatCard label="Avg. price" value="-" delta="-0%" trend="down" />
      </div>
      <DataTable
        rows={products || []}
        columns={columns}
        searchKeys={["name"]}
        filters={["Status"]}
      />
    </>
  );
}

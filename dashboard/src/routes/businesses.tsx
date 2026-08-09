import { createFileRoute } from "@tanstack/react-router";
import { BadgeCheck, ShieldAlert, Trash2 } from "lucide-react";
import { PageHeader, StatusPill, PlanPill, ScoreBar, Avatar } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useBusinesses, useDeleteBusiness, useToggleBusinessVerification } from "@/lib/queries";

export const Route = createFileRoute("/businesses")({
  head: () => ({
    meta: [
      { title: "Businesses — ROUJLI Admin" },
      {
        name: "description",
        content: "Review, verify and manage every business listed on ROUJLI.",
      },
      { property: "og:title", content: "Businesses — ROUJLI Admin" },
      { property: "og:description", content: "Review, verify and manage businesses on ROUJLI." },
    ],
  }),
  component: BusinessesPage,
});

function BusinessesPage() {
  const { data: businesses, isLoading } = useBusinesses();
  const deleteMutation = useDeleteBusiness();
  const verifyMutation = useToggleBusinessVerification();

  if (isLoading) return <PageSkeleton />;

  const columns: Column<any>[] = [
    {
      key: "name",
      header: "Business",
      cell: (b) => {
        // Name is missing from simple listing in prisma unless it's in owner profile, using category as placeholder
        const name = b.category?.name || "Unknown Business";
        return (
          <div className="flex min-w-0 items-center gap-3">
            <Avatar name={name} />
            <div className="min-w-0">
              <p className="truncate text-sm font-medium">{name}</p>
              <p className="truncate text-xs text-muted-foreground">{b.id}</p>
            </div>
          </div>
        );
      },
    },
    {
      key: "owner",
      header: "Owner",
      cell: (b) => <span className="text-sm text-muted-foreground">{b.owner?.email}</span>,
    },
    {
      key: "category",
      header: "Category",
      cell: (b) => <span className="text-sm">{b.category?.name}</span>,
    },
    {
      key: "score",
      header: "Growth score",
      cell: (b) => <ScoreBar score={b.verified ? 85 : 45} />,
    },
    { key: "plan", header: "Subscription", cell: (b) => <PlanPill plan="Pro" /> }, // Hardcoded plan for now since it's not in the response yet
    {
      key: "verified",
      header: "Verification",
      cell: (b) =>
        b.verified ? (
          <span className="inline-flex items-center gap-1.5 text-xs font-medium text-success">
            <BadgeCheck className="h-4 w-4" /> Verified
          </span>
        ) : (
          <span className="inline-flex items-center gap-1.5 text-xs font-medium text-muted-foreground">
            <ShieldAlert className="h-4 w-4" /> Unverified
          </span>
        ),
    },
    { key: "status", header: "Status", cell: (b) => <StatusPill status="active" /> }, // Active by default
    {
      key: "actions",
      header: "",
      cell: (b) => (
        <div className="flex items-center gap-2">
          <button
            onClick={() => verifyMutation.mutate(b.id)}
            disabled={verifyMutation.isPending}
            className="rounded px-2 py-1 text-xs font-medium text-primary hover:bg-secondary"
          >
            {b.verified ? "Unverify" : "Verify"}
          </button>
          <button
            onClick={() => {
              if (confirm("Delete business?")) deleteMutation.mutate(b.id);
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

  const totalBusinesses = businesses?.length || 0;
  const verifiedCount = businesses?.filter((b: any) => b.verified).length || 0;

  return (
    <>
      <PageHeader
        title="Businesses"
        description="Directory of every registered business, with growth and verification state."
        actions={
          <button className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
            Add business
          </button>
        }
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Total Businesses"
          value={totalBusinesses.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard
          label="Active"
          value={totalBusinesses.toLocaleString()}
          delta="+0%"
          trend="up"
          hint="100% of total"
        />
        <StatCard
          label="Verified"
          value={verifiedCount.toLocaleString()}
          delta="+0%"
          trend="up"
          hint={`${totalBusinesses ? Math.round((verifiedCount / totalBusinesses) * 100) : 0}% of total`}
        />
        <StatCard
          label="Pending review"
          value={(totalBusinesses - verifiedCount).toLocaleString()}
          delta="+0%"
          trend="down"
          hint="needs action"
        />
      </div>
      <DataTable
        rows={businesses || []}
        columns={columns}
        searchKeys={["owner", "category"]}
        filters={["Category"]}
      />
    </>
  );
}

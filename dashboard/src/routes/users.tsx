import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, StatusPill, Avatar } from "@/components/ui/page";
import { DataTable, type Column } from "@/components/ui/data-table";
import { StatCard } from "@/components/ui/stat-card";
import { useUsers } from "@/lib/queries";
import { PageSkeleton } from "@/components/ui/loading-skeleton";

export const Route = createFileRoute("/users")({
  head: () => ({
    meta: [
      { title: "Users — ROUJLI Admin" },
      {
        name: "description",
        content: "Manage ROUJLI platform users, roles, access and account status.",
      },
      { property: "og:title", content: "Users — ROUJLI Admin" },
      { property: "og:description", content: "Manage ROUJLI users, roles and account status." },
    ],
  }),
  component: UsersPage,
});

const columns: Column<any>[] = [
  {
    key: "name",
    header: "User",
    cell: (u) => {
      const name = `${u.profile?.firstName || ""} ${u.profile?.lastName || ""}`.trim() || "Unknown";
      return (
        <div className="flex min-w-0 items-center gap-3">
          <Avatar name={name} />
          <div className="min-w-0">
            <p className="truncate text-sm font-medium">{name}</p>
            <p className="truncate text-xs text-muted-foreground">{u.id}</p>
          </div>
        </div>
      );
    },
  },
  {
    key: "email",
    header: "Email",
    cell: (u) => <span className="text-sm text-muted-foreground">{u.email}</span>,
  },
  {
    key: "phone",
    header: "Phone",
    cell: (u) => (
      <span className="num text-sm text-muted-foreground">{u.profile?.phone || "-"}</span>
    ),
  },
  { key: "role", header: "Role", cell: (u) => <span className="text-sm">{u.role}</span> },
  {
    key: "status",
    header: "Status",
    cell: (u) => <StatusPill status={u.isVerified ? "verified" : "pending"} />,
  },
  {
    key: "joined",
    header: "Registered",
    cell: (u) => (
      <span className="text-sm text-muted-foreground">
        {new Date(u.createdAt).toLocaleDateString()}
      </span>
    ),
  },
];

function UsersPage() {
  const { data: users, isLoading } = useUsers();

  if (isLoading) return <PageSkeleton />;

  const totalUsers = users?.length || 0;
  const verifiedUsers = users?.filter((u: any) => u.isVerified).length || 0;
  const businessOwners = users?.filter((u: any) => u.role === "BUSINESS").length || 0;

  return (
    <>
      <PageHeader
        title="Users"
        description="Every account on the platform, with roles and activity."
        actions={
          <button className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
            Invite user
          </button>
        }
      />
      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Total Users"
          value={totalUsers.toLocaleString()}
          delta="+0%"
          trend="up"
          hint="all roles"
        />
        <StatCard
          label="Verified"
          value={verifiedUsers.toLocaleString()}
          delta="+0%"
          trend="up"
          hint="verified emails"
        />
        <StatCard
          label="Business Owners"
          value={businessOwners.toLocaleString()}
          delta="+0%"
          trend="up"
        />
        <StatCard label="Suspended" value="0" delta="-0%" trend="down" />
      </div>
      <DataTable
        rows={users || []}
        columns={columns}
        searchKeys={["email", "role"]}
        filters={["Role"]}
      />
    </>
  );
}

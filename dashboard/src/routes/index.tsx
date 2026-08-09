import { createFileRoute } from "@tanstack/react-router";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { PageHeader, Panel, StatusPill, PlanPill, ScoreBar, Avatar } from "@/components/ui/page";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { useStats, useBusinesses, useUsers, useRequests, useAnalytics } from "@/lib/queries";
import { useReports } from "@/lib/queries/reports";
import { chartTooltip, axis, grid } from "@/components/charts/config";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Dashboard — ROUJLI Admin" },
      {
        name: "description",
        content:
          "Platform-wide KPIs, revenue, growth and activity for the ROUJLI business growth platform.",
      },
      { property: "og:title", content: "Dashboard — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Platform-wide KPIs, revenue, growth and activity for ROUJLI.",
      },
    ],
  }),
  component: Dashboard,
});

function Dashboard() {
  const { data: stats, isLoading: isStatsLoading } = useStats();
  const { data: businesses, isLoading: isBusinessesLoading } = useBusinesses();
  const { data: users, isLoading: isUsersLoading } = useUsers();
  const { data: requests, isLoading: isRequestsLoading } = useRequests();
  const { data: reports, isLoading: isReportsLoading } = useReports();
  const { data: analytics, isLoading: isAnalyticsLoading } = useAnalytics();

  if (
    isStatsLoading ||
    isBusinessesLoading ||
    isUsersLoading ||
    isRequestsLoading ||
    isReportsLoading ||
    isAnalyticsLoading
  ) {
    return <PageSkeleton />;
  }

  const kpis = [
    {
      label: "Total Users",
      value: stats?.totalUsers?.toLocaleString() || "0",
      delta: "+12.5%",
      trend: "up" as const,
    },
    {
      label: "Total Businesses",
      value: stats?.totalBusinesses?.toLocaleString() || "0",
      delta: "+8.2%",
      trend: "up" as const,
    },
    {
      label: "Active Subscriptions",
      value: stats?.activeSubscriptions?.toLocaleString() || "0",
      delta: "+15.3%",
      trend: "up" as const,
    },
    {
      label: "Pending Requests",
      value: stats?.pendingRequests?.toLocaleString() || "0",
      delta: "-2.4%",
      trend: "down" as const,
    },
  ];

  return (
    <>
      <PageHeader
        title="Dashboard"
        description="Platform performance across businesses, customers and revenue."
        actions={
          <>
            <button className="h-9 rounded-xl border border-border px-3.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
              Last 30 days
            </button>
            <button className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
              Export report
            </button>
          </>
        }
      />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {kpis.map((k) => (
          <StatCard key={k.label} {...k} />
        ))}
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 xl:grid-cols-3">
        <Panel
          title="Business Growth"
          subtitle="Average growth score vs benchmark"
          className="xl:col-span-2"
        >
          {!analytics?.growthSeries || analytics.growthSeries.length === 0 ? (
            <div className="flex h-[280px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={280}>
              <AreaChart data={analytics.growthSeries} margin={{ left: -18, right: 8, top: 8 }}>
                <defs>
                  <linearGradient id="growthFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--color-gold)" stopOpacity={0.35} />
                    <stop offset="100%" stopColor="var(--color-gold)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid {...grid} />
                <XAxis dataKey="month" {...axis} />
                <YAxis {...axis} />
                <Tooltip {...chartTooltip} />
                <Area
                  type="monotone"
                  dataKey="growth"
                  stroke="var(--color-gold)"
                  strokeWidth={2}
                  fill="url(#growthFill)"
                />
                <Line
                  type="monotone"
                  dataKey="benchmark"
                  stroke="var(--color-muted-foreground)"
                  strokeDasharray="4 4"
                  strokeWidth={1.5}
                  dot={false}
                />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Subscriptions" subtitle="Distribution by plan">
          {!analytics?.subscriptionSplit || analytics.subscriptionSplit.length === 0 ? (
            <div className="flex h-[200px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie
                  data={analytics.subscriptionSplit}
                  dataKey="value"
                  nameKey="name"
                  innerRadius={62}
                  outerRadius={88}
                  paddingAngle={3}
                  stroke="none"
                >
                  {analytics.subscriptionSplit.map((s: any) => (
                    <Cell key={s.name} fill={s.color} />
                  ))}
                </Pie>
                <Tooltip {...chartTooltip} />
              </PieChart>
            </ResponsiveContainer>
          )}
          <div className="mt-4 space-y-2.5">
            {analytics?.subscriptionSplit?.map((s: any) => (
              <div key={s.name} className="flex items-center justify-between text-xs">
                <span className="flex items-center gap-2">
                  <span className="h-2 w-2 rounded-full" style={{ background: s.color }} />
                  {s.name}
                </span>
                <span className="num font-medium">{s.value.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </Panel>

        <Panel title="Platform Revenue" subtitle="Monthly recurring + one-off">
          {!analytics?.revenueSeries || analytics.revenueSeries.length === 0 ? (
            <div className="flex h-[240px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={analytics.revenueSeries} margin={{ left: -14, right: 8, top: 8 }}>
                <CartesianGrid {...grid} />
                <XAxis dataKey="month" {...axis} />
                <YAxis {...axis} tickFormatter={(v: number) => `${Math.round(v / 1000)}k`} />
                <Tooltip {...chartTooltip} />
                <Bar dataKey="revenue" fill="var(--color-primary)" radius={[6, 6, 0, 0]} />
                <Bar dataKey="subscriptions" fill="var(--color-gold)" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="User Registration" subtitle="New accounts per month">
          {!analytics?.registrationSeries || analytics.registrationSeries.length === 0 ? (
            <div className="flex h-[240px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={240}>
              <LineChart
                data={analytics.registrationSeries}
                margin={{ left: -14, right: 8, top: 8 }}
              >
                <CartesianGrid {...grid} />
                <XAxis dataKey="month" {...axis} />
                <YAxis {...axis} />
                <Tooltip {...chartTooltip} />
                <Line
                  type="monotone"
                  dataKey="users"
                  stroke="var(--color-success)"
                  strokeWidth={2.5}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Active Businesses" subtitle="Active vs dormant">
          {!analytics?.activeBusinessSeries || analytics.activeBusinessSeries.length === 0 ? (
            <div className="flex h-[240px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={240}>
              <AreaChart
                data={analytics.activeBusinessSeries}
                margin={{ left: -14, right: 8, top: 8 }}
              >
                <defs>
                  <linearGradient id="activeFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--color-primary)" stopOpacity={0.28} />
                    <stop offset="100%" stopColor="var(--color-primary)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid {...grid} />
                <XAxis dataKey="month" {...axis} />
                <YAxis {...axis} />
                <Tooltip {...chartTooltip} />
                <Area
                  type="monotone"
                  dataKey="active"
                  stroke="var(--color-primary)"
                  strokeWidth={2}
                  fill="url(#activeFill)"
                />
                <Area
                  type="monotone"
                  dataKey="inactive"
                  stroke="var(--color-danger)"
                  strokeWidth={1.5}
                  fill="transparent"
                />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Requests" subtitle="This week">
          {!analytics?.requestSeries || analytics.requestSeries.length === 0 ? (
            <div className="flex h-[240px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={analytics.requestSeries} margin={{ left: -14, right: 8, top: 8 }}>
                <CartesianGrid {...grid} />
                <XAxis dataKey="day" {...axis} />
                <YAxis {...axis} />
                <Tooltip {...chartTooltip} />
                <Bar
                  dataKey="completed"
                  stackId="a"
                  fill="var(--color-primary)"
                  radius={[0, 0, 0, 0]}
                />
                <Bar
                  dataKey="pending"
                  stackId="a"
                  fill="var(--color-warning)"
                  radius={[6, 6, 0, 0]}
                />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Growth Score Distribution" subtitle="Businesses per score band">
          {!analytics?.scoreDistribution || analytics.scoreDistribution.length === 0 ? (
            <div className="flex h-[240px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart
                data={analytics.scoreDistribution}
                layout="vertical"
                margin={{ left: 4, right: 12 }}
              >
                <CartesianGrid {...grid} horizontal={false} />
                <XAxis type="number" {...axis} />
                <YAxis type="category" dataKey="band" width={54} {...axis} />
                <Tooltip {...chartTooltip} />
                <Bar dataKey="count" fill="var(--color-gold)" radius={[0, 6, 6, 0]} barSize={18} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Most Popular Categories" subtitle="By business count">
          {!analytics?.popularCategories || analytics.popularCategories.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <div className="space-y-4">
              {analytics.popularCategories.map((c: any) => (
                <div key={c.name}>
                  <div className="flex items-center justify-between text-xs">
                    <span className="truncate font-medium">{c.name}</span>
                    <span className="num text-muted-foreground">{c.value.toLocaleString()}</span>
                  </div>
                  <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-secondary">
                    <div
                      className="h-full rounded-full bg-primary"
                      style={{ width: `${(c.value / (stats?.totalBusinesses || 1)) * 100}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          )}
        </Panel>

        <Panel title="Top Cities" subtitle="Business concentration">
          {!analytics?.topCities || analytics.topCities.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <div className="space-y-3.5">
              {analytics.topCities.map((c: any, i: number) => (
                <div key={c.city} className="flex items-center gap-3">
                  <span className="num w-5 shrink-0 text-xs text-muted-foreground">0{i + 1}</span>
                  <span className="min-w-0 flex-1 truncate text-sm">{c.city}</span>
                  <span className="num shrink-0 text-xs text-muted-foreground">
                    {c.businesses.toLocaleString()}
                  </span>
                  <span className="num w-10 shrink-0 rounded-full bg-gold-soft px-2 py-0.5 text-center text-[11px] font-medium text-gold">
                    {c.share}%
                  </span>
                </div>
              ))}
            </div>
          )}
        </Panel>
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 xl:grid-cols-2">
        <Panel title="Recent Businesses" subtitle="Newest listings" bodyClassName="p-0">
          {!businesses || businesses.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {businesses.slice(0, 5).map((b: any) => (
                <li key={b.id} className="flex items-center gap-3 px-6 py-3.5">
                  <Avatar name={b.category?.name || "Business"} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{b.owner?.email || "Unknown"}</p>
                    <p className="truncate text-xs text-muted-foreground">
                      {b.category?.name || "No Category"}
                    </p>
                  </div>
                  <StatusPill status={b.verified ? "verified" : "unverified"} />
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel title="Recent Users" subtitle="Latest signups" bodyClassName="p-0">
          {!users || users.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {users.slice(0, 5).map((u: any) => (
                <li key={u.id} className="flex items-center gap-3 px-6 py-3.5">
                  <Avatar name={`${u.profile?.firstName || ""} ${u.profile?.lastName || ""}`} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{`${u.profile?.firstName || ""} ${u.profile?.lastName || ""}`}</p>
                    <p className="truncate text-xs text-muted-foreground">{u.email}</p>
                  </div>
                  <StatusPill status={u.isVerified ? "verified" : "pending"} />
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel title="Recent Requests" subtitle="Customer service requests" bodyClassName="p-0">
          {!requests || requests.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {requests.slice(0, 5).map((r: any) => (
                <li key={r.id} className="flex items-center gap-3 px-6 py-3.5">
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">
                      {r.service?.title || r.product?.name || "Request"}
                    </p>
                    <p className="truncate text-xs text-muted-foreground">
                      {r.user?.profile?.firstName} → {r.business?.name || r.businessId}
                    </p>
                  </div>
                  <StatusPill status={r.status?.toLowerCase() || "pending"} />
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel title="Recent Reports" subtitle="Moderation queue" bodyClassName="p-0">
          {!reports || reports.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {reports.slice(0, 5).map((r: any) => (
                <li key={r.id} className="flex items-center gap-3 px-6 py-3.5">
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{r.subject}</p>
                    <p className="truncate text-xs text-muted-foreground">
                      {r.type} · {r.reason}
                    </p>
                  </div>
                  <StatusPill status={r.status?.toLowerCase() || "pending"} />
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel
          title="Latest Payments"
          subtitle="Settled subscription charges"
          className="xl:col-span-2"
          bodyClassName="p-0"
        >
          <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
        </Panel>
      </div>

      <div className="mt-6">
        <Panel
          title="Growth Leaders"
          subtitle="Highest scoring businesses this month"
          bodyClassName="p-0"
        >
          {!businesses || businesses.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {businesses.slice(0, 4).map((b: any) => (
                <li key={b.id} className="flex items-center gap-4 px-6 py-3.5">
                  <Avatar name={b.owner?.email || "Unknown"} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{b.owner?.email || "Unknown"}</p>
                    <p className="truncate text-xs text-muted-foreground">
                      {b.category?.name || "No Category"}
                    </p>
                  </div>
                  <ScoreBar score={b.verified ? 90 : 50} />
                </li>
              ))}
            </ul>
          )}
        </Panel>
      </div>
    </>
  );
}

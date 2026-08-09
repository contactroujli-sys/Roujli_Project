import { createFileRoute } from "@tanstack/react-router";
import { Check } from "lucide-react";
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { PageHeader, Panel, PlanPill, StatusPill } from "@/components/ui/page";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { axis, grid, chartTooltip } from "@/components/charts/config";
import { useSubscriptionPlans, useUserSubscriptions, useAnalytics } from "@/lib/queries";

export const Route = createFileRoute("/subscriptions")({
  head: () => ({
    meta: [
      { title: "Subscriptions — ROUJLI Admin" },
      {
        name: "description",
        content: "Monitor ROUJLI subscription plans, revenue, renewals and expiring accounts.",
      },
      { property: "og:title", content: "Subscriptions — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Monitor ROUJLI plans, revenue, renewals and churn risk.",
      },
    ],
  }),
  component: SubscriptionsPage,
});

function SubscriptionsPage() {
  const { data: plans, isLoading: isPlansLoading } = useSubscriptionPlans();
  const { data: subscriptions, isLoading: isSubsLoading } = useUserSubscriptions();
  const { data: analytics, isLoading: isAnalyticsLoading } = useAnalytics();

  if (isPlansLoading || isSubsLoading || isAnalyticsLoading) return <PageSkeleton />;

  const activeSubscriptions = subscriptions?.filter((s: any) => s.status === "ACTIVE")?.length || 0;

  return (
    <>
      <PageHeader
        title="Subscriptions"
        description="Plan performance, renewals and revenue across the platform."
      />

      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Subscribers"
          value={activeSubscriptions.toLocaleString()}
          delta="+0%"
          trend="up"
          hint="paid plans"
        />
        <StatCard label="Revenue (MTD)" value="-" delta="+0%" trend="up" />
        <StatCard label="Renewals this month" value="-" delta="+0%" trend="up" />
        <StatCard
          label="Expiring in 7 days"
          value="-"
          delta="+0%"
          trend="up"
          hint="needs outreach"
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        {(plans || []).map((p: any) => (
          <div
            key={p.id}
            className={
              p.type === "PREMIUM"
                ? "card-surface relative overflow-hidden p-6 ring-1 ring-gold"
                : "card-surface p-6"
            }
          >
            <div className="flex items-center justify-between">
              <PlanPill plan={p.type} />
              <span className="num text-sm text-muted-foreground">
                {p._count?.subscriptions || 0} subs
              </span>
            </div>
            <p className="num mt-5 text-3xl font-semibold">
              DA {p.price}
              <span className="text-sm font-normal text-muted-foreground"> /mo</span>
            </p>
            <p className="mt-1 text-xs text-muted-foreground">
              Monthly revenue{" "}
              <span className="num font-medium text-foreground">
                DA {(p.price * (p._count?.subscriptions || 0)).toLocaleString()}
              </span>
            </p>
            <ul className="mt-5 space-y-2.5">
              <li className="flex items-center gap-2 text-sm text-muted-foreground">
                <Check className="h-4 w-4 shrink-0 text-gold" />
                Max products: {p.maxProducts}
              </li>
              <li className="flex items-center gap-2 text-sm text-muted-foreground">
                <Check className="h-4 w-4 shrink-0 text-gold" />
                Max services: {p.maxServices}
              </li>
              {p.verifiedBadge && (
                <li className="flex items-center gap-2 text-sm text-muted-foreground">
                  <Check className="h-4 w-4 shrink-0 text-gold" />
                  Verified Badge
                </li>
              )}
            </ul>
          </div>
        ))}
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 xl:grid-cols-3">
        <Panel title="Subscription Revenue" subtitle="Trailing 12 months" className="xl:col-span-2">
          {!analytics?.revenueSeries || analytics.revenueSeries.length === 0 ? (
            <div className="flex h-[280px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={280}>
              <AreaChart data={analytics.revenueSeries} margin={{ left: -12, right: 8, top: 8 }}>
                <defs>
                  <linearGradient id="subFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--color-gold)" stopOpacity={0.35} />
                    <stop offset="100%" stopColor="var(--color-gold)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid {...grid} />
                <XAxis dataKey="month" {...axis} />
                <YAxis {...axis} tickFormatter={(v: number) => `${Math.round(v / 1000)}k`} />
                <Tooltip {...chartTooltip} />
                <Area
                  type="monotone"
                  dataKey="subscriptions"
                  stroke="var(--color-gold)"
                  strokeWidth={2}
                  fill="url(#subFill)"
                />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Recent Subscriptions" subtitle="Latest activations" bodyClassName="p-0">
          <ul className="divide-y divide-border">
            {(subscriptions || []).slice(0, 6).map((s: any) => (
              <li key={s.id} className="flex items-center gap-3 px-6 py-3.5">
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{s.user?.email}</p>
                  <p className="truncate text-xs text-muted-foreground">
                    Started {new Date(s.startDate).toLocaleDateString()}
                  </p>
                </div>
                <PlanPill plan={s.plan?.type || "Free"} />
              </li>
            ))}
          </ul>
        </Panel>
      </div>

      <div className="mt-6">
        <Panel title="Recent Transactions" subtitle="Settled & failed" bodyClassName="p-0">
          {!subscriptions || subscriptions.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {subscriptions.slice(0, 5).map((s: any) => (
                <li key={s.id} className="flex items-center justify-between px-6 py-3.5">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium">{s.user?.email || "Unknown"}</p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(s.startDate).toLocaleDateString()}
                    </p>
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <span className="num text-sm font-medium">
                      DA {(plans?.find((p: any) => p.id === s.planId)?.price || 0).toLocaleString()}
                    </span>
                    <StatusPill status={s.status.toLowerCase()} />
                  </div>
                </li>
              ))}
            </ul>
          )}
        </Panel>
      </div>
    </>
  );
}

import { createFileRoute } from "@tanstack/react-router";
import { ArrowDownRight, ArrowUpRight, Sparkles } from "lucide-react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  PolarAngleAxis,
  PolarGrid,
  Radar,
  RadarChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { PageHeader, Panel, ScoreBar, Avatar } from "@/components/ui/page";
import { StatCard } from "@/components/ui/stat-card";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { axis, grid, chartTooltip } from "@/components/charts/config";
import { useBusinesses, useAnalytics } from "@/lib/queries";

export const Route = createFileRoute("/growth")({
  head: () => ({
    meta: [
      { title: "Growth Analytics — ROUJLI Admin" },
      {
        name: "description",
        content:
          "ROUJLI growth scores, trends, health signals, rankings and recommendations for every business.",
      },
      { property: "og:title", content: "Growth Analytics — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Growth scores, trends, health signals and recommendations across ROUJLI.",
      },
    ],
  }),
  component: GrowthPage,
});

const weekly = ["W28", "W29", "W30", "W31", "W32", "W33"].map((w, i) => ({
  week: w,
  score: 64 + i * 1.8,
}));

const monthly = ["Mar", "Apr", "May", "Jun", "Jul", "Aug"].map((m, i) => ({
  month: m,
  score: 61 + i * 2.3,
}));

function heatTone(v: number) {
  if (v > 80) return "bg-primary";
  if (v > 60) return "bg-gold";
  if (v > 40) return "bg-gold/60";
  if (v > 20) return "bg-gold/30";
  return "bg-secondary";
}

function GrowthPage() {
  const { data: businesses, isLoading: isBusinessesLoading } = useBusinesses();
  const { data: analytics, isLoading: isAnalyticsLoading } = useAnalytics();

  if (isBusinessesLoading || isAnalyticsLoading) return <PageSkeleton />;

  const bList = businesses || [];

  // Real computing
  const avgScore = bList.length
    ? (bList.reduce((acc: number, b: any) => acc + (b.growthScore || 0), 0) / bList.length).toFixed(
        1,
      )
    : "0.0";
  const avgGrowth = bList.length
    ? (
        bList.reduce((acc: number, b: any) => acc + (b.monthlyGrowth || 0), 0) / bList.length
      ).toFixed(1)
    : "0.0";
  const isUp = Number(avgGrowth) >= 0;

  const sortedByGrowth = [...bList].sort((a, b) => (b.monthlyGrowth || 0) - (a.monthlyGrowth || 0));
  const topGrowing = sortedByGrowth.slice(0, 5);
  const lowestPerforming = [...sortedByGrowth].reverse().slice(0, 5);

  const healthMetrics = [
    {
      label: "Profile completeness",
      value: bList.length
        ? Math.round(
            (bList.filter((b: any) => b.description && b.logo).length / bList.length) * 100,
          )
        : 0,
    },
    {
      label: "Verified businesses",
      value: bList.length
        ? Math.round((bList.filter((b: any) => b.verified).length / bList.length) * 100)
        : 0,
    },
    {
      label: "Active catalog items",
      value: bList.length
        ? Math.round(
            (bList.filter((b: any) => b.products?.length > 0 || b.services?.length > 0).length /
              bList.length) *
              100,
          )
        : 0,
    },
  ];

  return (
    <>
      <PageHeader
        title="Growth Analytics"
        description="The signature ROUJLI engine — how every business is actually performing."
        actions={
          <button className="inline-flex h-9 items-center gap-1.5 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90">
            <Sparkles className="h-3.5 w-3.5 text-gold" />
            Recalculate scores
          </button>
        }
      />

      <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
        <div className="card-surface flex flex-col justify-between p-6 xl:col-span-1">
          <div>
            <p className="text-xs font-medium text-muted-foreground">Platform Growth Score</p>
            <p className="num mt-4 text-6xl font-semibold leading-none">{avgScore}</p>
            <p
              className={`mt-3 inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-medium ${isUp ? "bg-success-soft text-success" : "bg-danger-soft text-danger"}`}
            >
              {isUp ? <ArrowUpRight className="h-3 w-3" /> : <ArrowDownRight className="h-3 w-3" />}
              {isUp ? "+" : ""}
              {avgGrowth} this month
            </p>
          </div>
          <div className="mt-6 h-2 overflow-hidden rounded-full bg-secondary">
            <div
              className="h-full rounded-full bg-linear-to-r from-gold to-primary"
              style={{ width: `${avgScore}%` }}
            />
          </div>
          <p className="mt-3 text-xs text-muted-foreground">
            Weighted from catalog depth, response time, reviews, retention and verification.
          </p>
        </div>

        <div className="card-surface p-6 xl:col-span-2">
          {!analytics?.growthSeries || analytics.growthSeries.length === 0 ? (
            <div className="flex h-[280px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={280}>
              <AreaChart data={analytics.growthSeries} margin={{ left: -18, right: 8, top: 8 }}>
                <defs>
                  <linearGradient id="growthFill2" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--color-primary)" stopOpacity={0.25} />
                    <stop offset="100%" stopColor="var(--color-primary)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid {...grid} />
                <XAxis dataKey="month" {...axis} />
                <YAxis {...axis} />
                <Tooltip {...chartTooltip} />
                <Area
                  type="monotone"
                  dataKey="growth"
                  stroke="var(--color-primary)"
                  strokeWidth={2}
                  fill="url(#growthFill2)"
                />
                <Area
                  type="monotone"
                  dataKey="benchmark"
                  stroke="var(--color-gold)"
                  strokeDasharray="4 4"
                  strokeWidth={1.5}
                  fill="transparent"
                />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Businesses improving" value="4,102" trend="up" delta="+7.9%" />
        <StatCard label="Businesses declining" value="612" trend="down" delta="-3.2%" />
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 xl:grid-cols-2">
        <Panel title="Top Growing Businesses" subtitle="Largest score gains" bodyClassName="p-0">
          {topGrowing.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {topGrowing.map((b: any, i) => (
                <li key={b.id} className="flex items-center gap-3 px-6 py-3.5">
                  <span className="num w-5 shrink-0 text-xs text-muted-foreground">0{i + 1}</span>
                  <Avatar name={b.owner?.email || "Unknown"} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{b.owner?.email || "Unknown"}</p>
                    <p className="truncate text-xs text-muted-foreground">
                      {b.category?.name || "No Category"}
                    </p>
                  </div>
                  <span
                    className={`num inline-flex shrink-0 items-center gap-0.5 rounded-full px-2 py-0.5 text-[11px] font-medium ${(b.monthlyGrowth || 0) >= 0 ? "bg-success-soft text-success" : "bg-danger-soft text-danger"}`}
                  >
                    {(b.monthlyGrowth || 0) >= 0 ? (
                      <ArrowUpRight className="h-3 w-3" />
                    ) : (
                      <ArrowDownRight className="h-3 w-3" />
                    )}
                    {b.monthlyGrowth || 0}
                  </span>
                  <ScoreBar score={b.growthScore || 0} />
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel title="Lowest Performing Businesses" subtitle="At risk of churn" bodyClassName="p-0">
          {lowestPerforming.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">No data available</div>
          ) : (
            <ul className="divide-y divide-border">
              {lowestPerforming.map((b: any, i) => (
                <li key={b.id} className="flex items-center gap-3 px-6 py-3.5">
                  <span className="num w-5 shrink-0 text-xs text-muted-foreground">0{i + 1}</span>
                  <Avatar name={b.owner?.email || "Unknown"} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{b.owner?.email || "Unknown"}</p>
                    <p className="truncate text-xs text-muted-foreground">
                      {b.category?.name || "No Category"}
                    </p>
                  </div>
                  <span
                    className={`num inline-flex shrink-0 items-center gap-0.5 rounded-full px-2 py-0.5 text-[11px] font-medium ${(b.monthlyGrowth || 0) >= 0 ? "bg-success-soft text-success" : "bg-danger-soft text-danger"}`}
                  >
                    {(b.monthlyGrowth || 0) >= 0 ? (
                      <ArrowUpRight className="h-3 w-3" />
                    ) : (
                      <ArrowDownRight className="h-3 w-3" />
                    )}
                    {b.monthlyGrowth || 0}
                  </span>
                  <ScoreBar score={b.growthScore || 0} />
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel title="Business Health" subtitle="Platform-wide signal strength">
          <ResponsiveContainer width="100%" height={280}>
            <RadarChart data={healthMetrics} outerRadius="72%">
              <PolarGrid stroke="var(--color-border)" />
              <PolarAngleAxis
                dataKey="label"
                tick={{ fill: "var(--color-muted-foreground)", fontSize: 11 }}
              />
              <Radar
                dataKey="value"
                stroke="var(--color-gold)"
                fill="var(--color-gold)"
                fillOpacity={0.28}
                strokeWidth={2}
              />
              <Tooltip {...chartTooltip} />
            </RadarChart>
          </ResponsiveContainer>
        </Panel>

        <Panel title="Growth Distribution" subtitle="Businesses per score band">
          {!analytics?.scoreDistribution || analytics.scoreDistribution.length === 0 ? (
            <div className="flex h-[280px] items-center justify-center text-sm text-muted-foreground">
              No data available
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={analytics.scoreDistribution} margin={{ left: -14, right: 8, top: 8 }}>
                <CartesianGrid {...grid} />
                <XAxis dataKey="band" {...axis} />
                <YAxis {...axis} />
                <Tooltip {...chartTooltip} />
                <Bar dataKey="count" fill="var(--color-primary)" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>

        <Panel title="Weekly Growth" subtitle="Rolling 6 weeks">
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={weekly} margin={{ left: -18, right: 8, top: 8 }}>
              <CartesianGrid {...grid} />
              <XAxis dataKey="week" {...axis} />
              <YAxis {...axis} domain={[55, 80]} />
              <Tooltip {...chartTooltip} />
              <Bar dataKey="score" fill="var(--color-gold)" radius={[6, 6, 0, 0]} barSize={26} />
            </BarChart>
          </ResponsiveContainer>
        </Panel>

        <Panel title="Monthly Growth" subtitle="Rolling 6 months">
          <ResponsiveContainer width="100%" height={200}>
            <AreaChart data={monthly} margin={{ left: -18, right: 8, top: 8 }}>
              <defs>
                <linearGradient id="monthlyFill" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="var(--color-success)" stopOpacity={0.3} />
                  <stop offset="100%" stopColor="var(--color-success)" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid {...grid} />
              <XAxis dataKey="month" {...axis} />
              <YAxis {...axis} domain={[55, 80]} />
              <Tooltip {...chartTooltip} />
              <Area
                type="monotone"
                dataKey="score"
                stroke="var(--color-success)"
                strokeWidth={2}
                fill="url(#monthlyFill)"
              />
            </AreaChart>
          </ResponsiveContainer>
        </Panel>
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 xl:grid-cols-3">
        <Panel
          title="Engagement Heatmap"
          subtitle="Active sessions per hour (Mock)"
          className="xl:col-span-2"
        >
          <div className="flex h-[200px] items-center justify-center text-sm text-muted-foreground">
            No data available
          </div>
        </Panel>

        <Panel title="AI Growth Insights" subtitle="Pattern analysis and recommendations">
          <ul className="divide-y divide-border">
            {[]?.map((r: any) => (
              <li key={r.id} className="flex gap-4 px-6 py-4">
                <span className="grid h-8 w-8 shrink-0 place-items-center rounded-xl bg-gold/10 text-gold">
                  {r.icon}
                </span>
                <div>
                  <p className="text-sm font-medium">{r.title}</p>
                  <p className="mt-1 pr-6 text-sm text-muted-foreground">{r.desc}</p>
                </div>
              </li>
            ))}
          </ul>
        </Panel>
      </div>

      <div className="mt-6 grid grid-cols-1 gap-4 xl:grid-cols-2">
        <Panel title="Business Ranking" subtitle="Leaderboard by growth score" bodyClassName="p-0">
          <ul className="divide-y divide-border">
            {(businesses || []).slice(0, 10).map((b: any, i: number) => (
              <li key={b.id} className="flex items-center gap-3 px-6 py-3.5">
                <span className="num w-5 shrink-0 text-xs text-muted-foreground">
                  {String(i + 1).padStart(2, "0")}
                </span>
                <Avatar name={b.owner?.email || "Unknown"} />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{b.owner?.email || "Unknown"}</p>
                  <p className="truncate text-xs text-muted-foreground">
                    {b.category?.name || "No Category"}
                  </p>
                </div>
                <ScoreBar score={b.growthScore || 0} />
              </li>
            ))}
          </ul>
        </Panel>

        <Panel title="Growth History" subtitle="Recent engine events" bodyClassName="p-0">
          <ol className="divide-y divide-border">
            {[
              {
                t: "Score model v2.4 deployed",
                d: "Response-time weight raised to 18%.",
                w: "07 Aug 2026",
              },
              {
                t: "Quarterly recalculation",
                d: "6,214 businesses re-scored in 4m 12s.",
                w: "01 Aug 2026",
              },
              {
                t: "Verification boost applied",
                d: "Verified businesses gained +3 baseline.",
                w: "24 Jul 2026",
              },
              {
                t: "Catalog freshness signal added",
                d: "New signal covering 30-day publishing.",
                w: "12 Jul 2026",
              },
              {
                t: "Score model v2.3 deployed",
                d: "Review-quality normalisation introduced.",
                w: "28 Jun 2026",
              },
            ].map((e) => (
              <li key={e.t} className="flex gap-4 px-6 py-4">
                <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-gold" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{e.t}</p>
                  <p className="truncate text-xs text-muted-foreground">{e.d}</p>
                </div>
                <span className="num shrink-0 text-xs text-muted-foreground">{e.w}</span>
              </li>
            ))}
          </ol>
        </Panel>
      </div>
    </>
  );
}

import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

export function PageHeader({
  title,
  description,
  actions,
}: {
  title: string;
  description: string;
  actions?: ReactNode;
}) {
  return (
    <div className="mb-8 grid grid-cols-[minmax(0,1fr)_auto] items-start gap-4 sm:flex sm:flex-wrap sm:items-center sm:justify-between">
      <div className="min-w-0">
        <h1 className="truncate text-2xl font-semibold tracking-tight sm:text-[28px]">{title}</h1>
        <p className="mt-1.5 text-sm text-muted-foreground">{description}</p>
      </div>
      {actions ? <div className="flex shrink-0 items-center gap-2">{actions}</div> : null}
    </div>
  );
}

export function Panel({
  title,
  subtitle,
  action,
  children,
  className,
  bodyClassName,
}: {
  title?: string;
  subtitle?: string;
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  bodyClassName?: string;
}) {
  return (
    <section className={cn("card-surface overflow-hidden", className)}>
      {(title || action) && (
        <div className="grid grid-cols-[minmax(0,1fr)_auto] items-center gap-3 border-b border-border px-5 py-4 sm:px-6">
          <div className="min-w-0">
            {title && <h2 className="truncate text-sm font-semibold tracking-tight">{title}</h2>}
            {subtitle && (
              <p className="mt-0.5 truncate text-xs text-muted-foreground">{subtitle}</p>
            )}
          </div>
          {action}
        </div>
      )}
      <div className={cn("p-5 sm:p-6", bodyClassName)}>{children}</div>
    </section>
  );
}

const tones: Record<string, string> = {
  active: "bg-success-soft text-success",
  completed: "bg-success-soft text-success",
  resolved: "bg-success-soft text-success",
  pending: "bg-warning-soft text-warning",
  draft: "bg-secondary text-muted-foreground",
  suspended: "bg-danger-soft text-danger",
  cancelled: "bg-danger-soft text-danger",
};

export function StatusPill({ status }: { status: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-medium capitalize",
        tones[status] ?? "bg-secondary text-muted-foreground",
      )}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-current" />
      {status}
    </span>
  );
}

export function PlanPill({ plan }: { plan: string }) {
  const map: Record<string, string> = {
    Premium: "bg-primary text-primary-foreground",
    Plus: "bg-gold-soft text-gold",
    Free: "bg-secondary text-muted-foreground",
  };
  return (
    <span className={cn("inline-flex rounded-full px-2.5 py-1 text-[11px] font-medium", map[plan])}>
      {plan}
    </span>
  );
}

export function ScoreBar({ score }: { score: number }) {
  const tone = score >= 75 ? "bg-success" : score >= 50 ? "bg-gold" : "bg-danger";
  return (
    <div className="flex min-w-0 items-center gap-2.5">
      <div className="h-1.5 w-16 shrink-0 overflow-hidden rounded-full bg-secondary">
        <div className={cn("h-full rounded-full", tone)} style={{ width: `${score}%` }} />
      </div>
      <span className="num text-xs font-medium">{score}</span>
    </div>
  );
}

export function Avatar({ name }: { name: string }) {
  const initials = name
    .split(" ")
    .map((p) => p[0])
    .slice(0, 2)
    .join("");
  return (
    <span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-secondary text-[11px] font-semibold text-foreground">
      {initials}
    </span>
  );
}

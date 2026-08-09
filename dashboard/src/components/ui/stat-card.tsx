import { ArrowDownRight, ArrowUpRight } from "lucide-react";
import { cn } from "@/lib/utils";

export function StatCard({
  label,
  value,
  delta,
  trend,
  hint,
}: {
  label: string;
  value: string;
  delta: string;
  trend: "up" | "down";
  hint?: string;
}) {
  const Icon = trend === "up" ? ArrowUpRight : ArrowDownRight;
  return (
    <div className="card-surface group p-5 transition-shadow hover:shadow-[var(--shadow-lift)]">
      <p className="truncate text-xs font-medium text-muted-foreground">{label}</p>
      <div className="mt-3 grid grid-cols-[minmax(0,1fr)_auto] items-end gap-2">
        <p className="num truncate text-[26px] font-semibold leading-none">{value}</p>
        <span
          className={cn(
            "inline-flex shrink-0 items-center gap-0.5 rounded-full px-2 py-0.5 text-[11px] font-medium",
            trend === "up" ? "bg-success-soft text-success" : "bg-danger-soft text-danger",
          )}
        >
          <Icon className="h-3 w-3" />
          {delta}
        </span>
      </div>
      {hint && <p className="mt-2 truncate text-[11px] text-muted-foreground">{hint}</p>}
    </div>
  );
}

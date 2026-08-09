import { useMemo, useState, type ReactNode } from "react";
import { ChevronLeft, ChevronRight, Filter, MoreHorizontal, Search, Download } from "lucide-react";
import { cn } from "@/lib/utils";

export type Column<T> = {
  key: string;
  header: string;
  className?: string;
  cell: (row: T) => ReactNode;
};

export function DataTable<T extends { id: string }>({
  rows,
  columns,
  searchKeys,
  filters,
  pageSize = 6,
}: {
  rows: T[];
  columns: Column<T>[];
  searchKeys: (keyof T)[];
  filters?: string[];
  pageSize?: number;
}) {
  const [query, setQuery] = useState("");
  const [page, setPage] = useState(0);
  const [selected, setSelected] = useState<string[]>([]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) =>
      searchKeys.some((k) =>
        String(r[k] ?? "")
          .toLowerCase()
          .includes(q),
      ),
    );
  }, [rows, query, searchKeys]);

  const pages = Math.max(1, Math.ceil(filtered.length / pageSize));
  const current = Math.min(page, pages - 1);
  const view = filtered.slice(current * pageSize, current * pageSize + pageSize);
  const allSelected = view.length > 0 && view.every((r) => selected.includes(r.id));

  return (
    <div className="card-surface overflow-hidden">
      <div className="grid gap-3 border-b border-border p-4 sm:flex sm:items-center sm:justify-between sm:px-6">
        <div className="relative min-w-0 sm:w-80">
          <Search className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              setPage(0);
            }}
            placeholder="Search…"
            className="h-10 w-full rounded-xl border border-border bg-background pl-10 pr-3 text-sm outline-hidden placeholder:text-muted-foreground focus:ring-2 focus:ring-ring/40"
          />
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {filters?.map((f) => (
            <button
              key={f}
              className="inline-flex h-9 items-center gap-1.5 rounded-xl border border-border px-3 text-xs font-medium text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
            >
              <Filter className="h-3.5 w-3.5" />
              {f}
            </button>
          ))}
          <button className="inline-flex h-9 items-center gap-1.5 rounded-xl border border-border px-3 text-xs font-medium text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
            <Download className="h-3.5 w-3.5" />
            Export
          </button>
        </div>
      </div>

      {selected.length > 0 && (
        <div className="flex flex-wrap items-center gap-3 border-b border-border bg-secondary/60 px-6 py-3 text-xs">
          <span className="font-medium">{selected.length} selected</span>
          <button className="rounded-lg px-2 py-1 hover:bg-card">Approve</button>
          <button className="rounded-lg px-2 py-1 hover:bg-card">Suspend</button>
          <button className="rounded-lg px-2 py-1 text-danger hover:bg-card">Delete</button>
          <button onClick={() => setSelected([])} className="ml-auto text-muted-foreground">
            Clear
          </button>
        </div>
      )}

      <div className="scrollbar-slim overflow-x-auto">
        <table className="w-full min-w-[820px] border-collapse text-sm">
          <thead>
            <tr className="border-b border-border text-left">
              <th className="w-10 px-6 py-3">
                <input
                  type="checkbox"
                  aria-label="Select all"
                  checked={allSelected}
                  onChange={(e) => setSelected(e.target.checked ? view.map((r) => r.id) : [])}
                  className="h-3.5 w-3.5 rounded-sm accent-[var(--color-primary)]"
                />
              </th>
              {columns.map((c) => (
                <th
                  key={c.key}
                  className={cn(
                    "px-4 py-3 text-[11px] font-semibold uppercase tracking-[0.08em] text-muted-foreground",
                    c.className,
                  )}
                >
                  {c.header}
                </th>
              ))}
              <th className="w-12 px-4 py-3" />
            </tr>
          </thead>
          <tbody>
            {view.map((row) => (
              <tr
                key={row.id}
                className="border-b border-border/70 transition-colors last:border-0 hover:bg-secondary/50"
              >
                <td className="px-6 py-3.5">
                  <input
                    type="checkbox"
                    aria-label={`Select ${row.id}`}
                    checked={selected.includes(row.id)}
                    onChange={(e) =>
                      setSelected((s) =>
                        e.target.checked ? [...s, row.id] : s.filter((i) => i !== row.id),
                      )
                    }
                    className="h-3.5 w-3.5 rounded-sm accent-[var(--color-primary)]"
                  />
                </td>
                {columns.map((c) => (
                  <td key={c.key} className={cn("px-4 py-3.5 align-middle", c.className)}>
                    {c.cell(row)}
                  </td>
                ))}
                <td className="px-4 py-3.5 text-right">
                  <button
                    aria-label="Row actions"
                    className="grid h-8 w-8 place-items-center rounded-lg text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
                  >
                    <MoreHorizontal className="h-4 w-4" />
                  </button>
                </td>
              </tr>
            ))}
            {view.length === 0 && (
              <tr>
                <td
                  colSpan={columns.length + 2}
                  className="px-6 py-12 text-center text-sm text-muted-foreground"
                >
                  No results found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="grid gap-3 border-t border-border px-6 py-4 sm:flex sm:items-center sm:justify-between">
        <p className="text-xs text-muted-foreground">
          Showing {view.length} of {filtered.length} records
        </p>
        <div className="flex items-center gap-1.5">
          <button
            onClick={() => setPage(Math.max(0, current - 1))}
            disabled={current === 0}
            className="grid h-8 w-8 place-items-center rounded-lg border border-border disabled:opacity-40"
            aria-label="Previous page"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
          {Array.from({ length: pages }, (_, i) => (
            <button
              key={i}
              onClick={() => setPage(i)}
              className={cn(
                "h-8 min-w-8 rounded-lg border px-2 text-xs font-medium transition-colors",
                i === current
                  ? "border-primary bg-primary text-primary-foreground"
                  : "border-border text-muted-foreground hover:bg-secondary",
              )}
            >
              {i + 1}
            </button>
          ))}
          <button
            onClick={() => setPage(Math.min(pages - 1, current + 1))}
            disabled={current >= pages - 1}
            className="grid h-8 w-8 place-items-center rounded-lg border border-border disabled:opacity-40"
            aria-label="Next page"
          >
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}

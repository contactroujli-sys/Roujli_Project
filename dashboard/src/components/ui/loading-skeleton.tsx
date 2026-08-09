export function StatCardSkeleton() {
  return (
    <div className="card-surface p-5">
      <div className="mb-4 h-4 w-24 animate-pulse rounded bg-secondary"></div>
      <div className="h-8 w-16 animate-pulse rounded bg-secondary"></div>
      <div className="mt-3 h-3 w-32 animate-pulse rounded bg-secondary"></div>
    </div>
  );
}

export function TableSkeleton() {
  return (
    <div className="card-surface overflow-hidden">
      <div className="border-b border-border p-4">
        <div className="h-9 w-64 animate-pulse rounded bg-secondary"></div>
      </div>
      <div className="divide-y divide-border">
        {[1, 2, 3, 4, 5].map((i) => (
          <div key={i} className="flex items-center gap-4 p-4">
            <div className="h-10 w-10 shrink-0 animate-pulse rounded-full bg-secondary"></div>
            <div className="flex-1 space-y-2">
              <div className="h-4 w-1/4 animate-pulse rounded bg-secondary"></div>
              <div className="h-3 w-1/3 animate-pulse rounded bg-secondary"></div>
            </div>
            <div className="h-6 w-16 animate-pulse rounded-full bg-secondary"></div>
          </div>
        ))}
      </div>
    </div>
  );
}

export function PageSkeleton() {
  return (
    <div className="space-y-6 p-6">
      <div className="mb-8 space-y-2">
        <div className="h-8 w-48 animate-pulse rounded bg-secondary"></div>
        <div className="h-4 w-96 animate-pulse rounded bg-secondary"></div>
      </div>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCardSkeleton />
        <StatCardSkeleton />
        <StatCardSkeleton />
        <StatCardSkeleton />
      </div>
      <TableSkeleton />
    </div>
  );
}

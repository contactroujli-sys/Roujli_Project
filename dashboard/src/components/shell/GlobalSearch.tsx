import * as React from "react";
import { Command } from "cmdk";
import { Search, User, Building2, Inbox } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { fetchApi } from "@/lib/api";
import { useNavigate } from "@tanstack/react-router";

export function useGlobalSearch(query: string) {
  return useQuery({
    queryKey: ["admin", "search", query],
    queryFn: () =>
      fetchApi(`/api/admin/search?q=${encodeURIComponent(query)}`).then((res) => res.data),
    enabled: query.length > 0,
  });
}

export function GlobalSearch({
  open,
  onOpenChange,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const [search, setSearch] = React.useState("");
  const { data, isLoading } = useGlobalSearch(search);
  const navigate = useNavigate();

  React.useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        onOpenChange(!open);
      }
    };
    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, [open, onOpenChange]);

  return (
    <div
      className={`fixed inset-0 z-50 flex items-start justify-center pt-[20vh] sm:pt-[10vh] ${open ? "block" : "hidden"}`}
    >
      <div
        className="fixed inset-0 bg-background/80 backdrop-blur-sm"
        onClick={() => onOpenChange(false)}
      />
      <div className="relative z-50 w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl overflow-hidden">
        <Command label="Global Command Menu" shouldFilter={false}>
          <div className="flex items-center border-b border-border px-4">
            <Search className="mr-2 h-4 w-4 shrink-0 text-muted-foreground" />
            <Command.Input
              value={search}
              onValueChange={setSearch}
              placeholder="Search users, businesses, requests..."
              className="flex h-12 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50"
            />
          </div>
          <Command.List className="max-h-[300px] overflow-y-auto overflow-x-hidden p-2">
            <Command.Empty className="py-6 text-center text-sm text-muted-foreground">
              {isLoading
                ? "Searching..."
                : search.length === 0
                  ? "Type to start searching..."
                  : "No results found."}
            </Command.Empty>

            {data?.users?.length > 0 && (
              <Command.Group
                heading="Users"
                className="px-2 py-1.5 text-xs font-medium text-muted-foreground"
              >
                {data.users.map((user: any) => (
                  <Command.Item
                    key={user.id}
                    onSelect={() => {
                      onOpenChange(false);
                      navigate({ to: `/users` });
                    }}
                    className="flex cursor-pointer items-center gap-2 rounded-lg px-2 py-2 text-sm text-foreground hover:bg-secondary"
                  >
                    <User className="h-4 w-4" />
                    <span>
                      {user.profile?.firstName} {user.profile?.lastName} ({user.email})
                    </span>
                  </Command.Item>
                ))}
              </Command.Group>
            )}

            {data?.businesses?.length > 0 && (
              <Command.Group
                heading="Businesses"
                className="px-2 py-1.5 text-xs font-medium text-muted-foreground"
              >
                {data.businesses.map((biz: any) => (
                  <Command.Item
                    key={biz.id}
                    onSelect={() => {
                      onOpenChange(false);
                      navigate({ to: `/businesses` });
                    }}
                    className="flex cursor-pointer items-center gap-2 rounded-lg px-2 py-2 text-sm text-foreground hover:bg-secondary"
                  >
                    <Building2 className="h-4 w-4" />
                    <span>{biz.name}</span>
                  </Command.Item>
                ))}
              </Command.Group>
            )}

            {data?.requests?.length > 0 && (
              <Command.Group
                heading="Requests"
                className="px-2 py-1.5 text-xs font-medium text-muted-foreground"
              >
                {data.requests.map((req: any) => (
                  <Command.Item
                    key={req.id}
                    onSelect={() => {
                      onOpenChange(false);
                      navigate({ to: `/requests` });
                    }}
                    className="flex cursor-pointer items-center gap-2 rounded-lg px-2 py-2 text-sm text-foreground hover:bg-secondary"
                  >
                    <Inbox className="h-4 w-4" />
                    <span>
                      {req.business?.name} - {req.status}
                    </span>
                  </Command.Item>
                ))}
              </Command.Group>
            )}
          </Command.List>
        </Command>
      </div>
    </div>
  );
}

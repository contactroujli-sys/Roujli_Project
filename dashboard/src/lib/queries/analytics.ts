import { useQuery } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useAnalytics() {
  return useQuery({
    queryKey: ["admin", "analytics"],
    queryFn: () => fetchApi("/api/admin/analytics").then((res) => res.data),
  });
}

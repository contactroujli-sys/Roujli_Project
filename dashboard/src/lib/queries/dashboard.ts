import { useQuery } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useStats() {
  return useQuery({
    queryKey: ["admin", "stats"],
    queryFn: () => fetchApi("/api/admin/stats").then((res) => res.data),
  });
}

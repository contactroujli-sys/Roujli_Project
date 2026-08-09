import { useQuery } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useNotifications() {
  return useQuery({
    queryKey: ["admin", "notifications"],
    queryFn: () => fetchApi("/api/admin/notifications").then((res) => res.data),
  });
}

import { useQuery } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useSubscriptionPlans() {
  return useQuery({
    queryKey: ["admin", "subscriptions", "plans"],
    queryFn: () => fetchApi("/api/admin/subscriptions").then((res) => res.data),
  });
}

export function useUserSubscriptions() {
  return useQuery({
    queryKey: ["admin", "subscriptions", "users"],
    queryFn: () => fetchApi("/api/admin/subscriptions/users").then((res) => res.data),
  });
}

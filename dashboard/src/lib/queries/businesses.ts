import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useBusinesses() {
  return useQuery({
    queryKey: ["admin", "businesses"],
    queryFn: () => fetchApi("/api/admin/businesses").then((res) => res.data),
  });
}

export function useDeleteBusiness() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => fetchApi(`/api/admin/businesses/${id}`, { method: "DELETE" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "businesses"] });
    },
  });
}

export function useToggleBusinessVerification() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => fetchApi(`/api/admin/businesses/${id}/verify`, { method: "PATCH" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "businesses"] });
    },
  });
}

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useServices() {
  return useQuery({
    queryKey: ["admin", "services"],
    queryFn: () => fetchApi("/api/admin/services").then((res) => res.data),
  });
}

export function useDeleteService() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => fetchApi(`/api/admin/services/${id}`, { method: "DELETE" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "services"] });
    },
  });
}

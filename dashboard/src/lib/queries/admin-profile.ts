import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchApi } from "../api";

export function useAdminProfile() {
  return useQuery({
    queryKey: ["admin", "profile"],
    queryFn: () => fetchApi("/api/admin/profile").then((res) => res.data),
  });
}

export function useUpdateAdminProfile() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: any) =>
      fetchApi("/api/admin/profile", {
        method: "PUT",
        body: JSON.stringify(data),
      }).then((res) => res.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "profile"] });
    },
  });
}

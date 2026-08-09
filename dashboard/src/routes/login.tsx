import { createFileRoute, useNavigate, redirect } from "@tanstack/react-router";
import { useState } from "react";
import { useAuth } from "@/lib/auth";
import { API_URL } from "@/lib/api";

export const Route = createFileRoute("/login")({
  beforeLoad: ({ context }) => {
    // @ts-ignore - the context is typed correctly in __root, but tsc might complain here
    if (context.auth?.isAuthenticated) {
      throw redirect({ to: "/" });
    }
  },
  head: () => ({
    meta: [{ title: "Login — ROUJLI Admin" }],
  }),
  component: LoginPage,
});

function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const response = await fetch(`${API_URL}/api/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to login");
      }

      if (data.data?.user?.role !== "ADMIN") {
        throw new Error("Access denied. Admin role required.");
      }

      login(data.data);
      navigate({ to: "/" });
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="card-surface w-full max-w-md p-8">
        <div className="mb-8 text-center">
          <h1 className="text-2xl font-bold text-foreground">ROUJLI Admin</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            Sign in to access the platform dashboard
          </p>
        </div>

        {error && (
          <div className="mb-6 rounded-lg bg-danger-soft p-3 text-sm font-medium text-danger">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <label className="block">
            <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
              Email address
            </span>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="h-10 w-full rounded-xl border border-border bg-background px-3.5 text-sm outline-hidden focus:ring-2 focus:ring-ring/40"
              required
            />
          </label>

          <label className="block">
            <span className="mb-1.5 block text-xs font-medium text-muted-foreground">Password</span>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="h-10 w-full rounded-xl border border-border bg-background px-3.5 text-sm outline-hidden focus:ring-2 focus:ring-ring/40"
              required
            />
          </label>

          <button
            type="submit"
            disabled={isLoading}
            className="mt-2 h-10 w-full rounded-xl bg-primary px-3.5 text-sm font-medium text-primary-foreground transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {isLoading ? "Signing in..." : "Sign in"}
          </button>
        </form>
      </div>
    </div>
  );
}

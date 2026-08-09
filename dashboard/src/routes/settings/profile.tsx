import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, Panel } from "@/components/ui/page";
import { useAdminProfile, useUpdateAdminProfile } from "@/lib/queries";
import { PageSkeleton } from "@/components/ui/loading-skeleton";
import { toast } from "sonner";

export const Route = createFileRoute("/settings/profile")({
  component: ProfilePage,
});

function Field({
  label,
  name,
  value,
  type = "text",
}: {
  label: string;
  name: string;
  value?: string;
  type?: string;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-xs font-medium text-muted-foreground">{label}</span>
      <input
        name={name}
        type={type}
        defaultValue={value}
        className="h-10 w-full rounded-xl border border-border bg-background px-3.5 text-sm outline-hidden focus:ring-2 focus:ring-ring/40"
      />
    </label>
  );
}

function ProfilePage() {
  const { data: profile, isLoading } = useAdminProfile();
  const updateMutation = useUpdateAdminProfile();

  if (isLoading) return <PageSkeleton />;

  const handleSave = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const data: any = {};
    if (fd.get("firstName")) data.firstName = fd.get("firstName");
    if (fd.get("lastName")) data.lastName = fd.get("lastName");
    if (fd.get("phone")) data.phone = fd.get("phone");
    if (fd.get("email")) data.email = fd.get("email");
    if (fd.get("password")) data.password = fd.get("password");

    updateMutation.mutate(data, {
      onSuccess: () => {
        toast.success("Profile updated successfully");
        if (data.password) {
          e.currentTarget.reset(); // Reset password field but keep others
        }
      },
      onError: () => toast.error("Failed to update profile"),
    });
  };

  return (
    <form onSubmit={handleSave}>
      <PageHeader
        title="Profile"
        description="Manage your personal account details."
        actions={
          <button
            type="submit"
            disabled={updateMutation.isPending}
            className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {updateMutation.isPending ? "Saving..." : "Save profile"}
          </button>
        }
      />
      <div className="max-w-2xl space-y-4">
        <Panel title="Personal Info" subtitle="Your basic contact details">
          <div className="grid grid-cols-2 gap-4">
            <Field label="First Name" name="firstName" value={profile?.profile?.firstName} />
            <Field label="Last Name" name="lastName" value={profile?.profile?.lastName} />
            <div className="col-span-2">
              <Field label="Phone" name="phone" value={profile?.profile?.phone} />
            </div>
          </div>
        </Panel>

        <Panel title="Account Credentials" subtitle="Update your email or password">
          <div className="space-y-4">
            <Field label="Email address" name="email" value={profile?.email} />
            <Field label="New password" name="password" type="password" />
            <p className="text-xs text-muted-foreground">
              Leave password blank if you do not wish to change it.
            </p>
          </div>
        </Panel>
      </div>
    </form>
  );
}

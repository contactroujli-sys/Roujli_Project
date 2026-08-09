import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, Panel, StatusPill } from "@/components/ui/page";
import { Switch } from "@/components/ui/switch";

import { toast } from "sonner";

export const Route = createFileRoute("/settings/")({
  head: () => ({
    meta: [
      { title: "Settings — ROUJLI Admin" },
      {
        name: "description",
        content: "Configure ROUJLI platform settings, email, security, roles, API access and logs.",
      },
      { property: "og:title", content: "Settings — ROUJLI Admin" },
      {
        property: "og:description",
        content: "Configure ROUJLI platform, security, roles and API settings.",
      },
    ],
  }),
  component: SettingsPage,
});

import { useAdminSettings, useSaveAdminSettings } from "@/lib/queries";
import { PageSkeleton } from "@/components/ui/loading-skeleton";

function Field({ label, name, value }: { label: string; name: string; value: string }) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-xs font-medium text-muted-foreground">{label}</span>
      <input
        name={name}
        defaultValue={value}
        className="h-10 w-full rounded-xl border border-border bg-background px-3.5 text-sm outline-hidden focus:ring-2 focus:ring-ring/40"
      />
    </label>
  );
}

function Toggle({
  label,
  name,
  hint,
  on = false,
}: {
  label: string;
  name: string;
  hint: string;
  on?: boolean;
}) {
  return (
    <div className="flex items-start justify-between gap-4 py-3">
      <div className="min-w-0">
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-muted-foreground">{hint}</p>
      </div>
      <Switch name={name} defaultChecked={on} className="shrink-0" />
    </div>
  );
}

const roles = [
  { name: "Super Admin", members: 3, perms: "Full access" },
  { name: "Moderator", members: 11, perms: "Reports, businesses, content" },
  { name: "Finance", members: 4, perms: "Subscriptions, payments" },
  { name: "Support", members: 18, perms: "Users, requests (read/write)" },
];

function SettingsPage() {
  const { data: settings, isLoading } = useAdminSettings();
  const saveMutation = useSaveAdminSettings();

  if (isLoading) return <PageSkeleton />;

  const handleSave = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const data = {
      platformName: fd.get("platformName"),
      supportEmail: fd.get("supportEmail"),
      defaultCurrency: fd.get("defaultCurrency"),
      defaultTimezone: fd.get("defaultTimezone"),
      senderName: fd.get("senderName"),
      senderAddress: fd.get("senderAddress"),
      welcomeEmail: fd.get("welcomeEmail") === "on",
      weeklyDigest: fd.get("weeklyDigest") === "on",
      renewalReminders: fd.get("renewalReminders") === "on",
      notifyNewBusiness: fd.get("notifyNewBusiness") === "on",
      notifyNewReports: fd.get("notifyNewReports") === "on",
      notifyFailedPayments: fd.get("notifyFailedPayments") === "on",
      notifyScoreAnomalies: fd.get("notifyScoreAnomalies") === "on",
      require2FA: fd.get("require2FA") === "on",
      sessionTimeout: fd.get("sessionTimeout") === "on",
      ipAllowlist: fd.get("ipAllowlist") === "on",
      auditActions: fd.get("auditActions") === "on",
      rateLimiting: fd.get("rateLimiting") === "on",
      sandboxMode: fd.get("sandboxMode") === "on",
    };

    saveMutation.mutate(data, {
      onSuccess: () => toast.success("Settings saved successfully"),
      onError: () => toast.error("Failed to save settings"),
    });
  };

  return (
    <form onSubmit={handleSave}>
      <PageHeader
        title="Settings"
        description="Platform configuration, access control and system diagnostics."
        actions={
          <button
            type="submit"
            disabled={saveMutation.isPending}
            className="h-9 rounded-xl bg-primary px-3.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {saveMutation.isPending ? "Saving..." : "Save changes"}
          </button>
        }
      />

      <div className="grid grid-cols-1 gap-4 xl:grid-cols-2">
        <Panel title="Platform Settings" subtitle="Core identity and defaults">
          <div className="space-y-4">
            <Field
              label="Platform name"
              name="platformName"
              value={settings?.platformName || "ROUJLI"}
            />
            <Field
              label="Support email"
              name="supportEmail"
              value={settings?.supportEmail || "support@roujli.com"}
            />
            <Field
              label="Default currency"
              name="defaultCurrency"
              value={settings?.defaultCurrency || "DZD (DA)"}
            />
            <Field
              label="Default timezone"
              name="defaultTimezone"
              value={settings?.defaultTimezone || "GMT+1"}
            />
          </div>
        </Panel>

        <Panel title="Email" subtitle="Transactional delivery">
          <div className="space-y-4">
            <Field
              label="Sender name"
              name="senderName"
              value={settings?.senderName || "ROUJLI Platform"}
            />
            <Field
              label="Sender address"
              name="senderAddress"
              value={settings?.senderAddress || "no-reply@roujli.com"}
            />
            <div className="divide-y divide-border">
              <Toggle
                label="Welcome email"
                name="welcomeEmail"
                hint="Sent to every new account."
                on={settings?.welcomeEmail}
              />
              <Toggle
                label="Weekly growth digest"
                name="weeklyDigest"
                hint="Score summary for business owners."
                on={settings?.weeklyDigest}
              />
              <Toggle
                label="Renewal reminders"
                name="renewalReminders"
                hint="7 and 2 days before expiry."
                on={settings?.renewalReminders}
              />
            </div>
          </div>
        </Panel>

        <Panel title="Notifications" subtitle="Admin alerting">
          <div className="divide-y divide-border">
            <Toggle
              label="New business signups"
              name="notifyNewBusiness"
              hint="Realtime in-app alert."
              on={settings?.notifyNewBusiness}
            />
            <Toggle
              label="New reports"
              name="notifyNewReports"
              hint="Notify moderators immediately."
              on={settings?.notifyNewReports}
            />
            <Toggle
              label="Failed payments"
              name="notifyFailedPayments"
              hint="Alert the finance role."
              on={settings?.notifyFailedPayments}
            />
            <Toggle
              label="Score anomalies"
              name="notifyScoreAnomalies"
              hint="Sudden drops above 15 points."
              on={settings?.notifyScoreAnomalies}
            />
          </div>
        </Panel>

        <Panel title="Security" subtitle="Authentication policy">
          <div className="divide-y divide-border">
            <Toggle
              label="Require 2FA for admins"
              name="require2FA"
              hint="TOTP enforced on all admin roles."
              on={settings?.require2FA}
            />
            <Toggle
              label="Session timeout"
              name="sessionTimeout"
              hint="Auto sign-out after 30 minutes idle."
              on={settings?.sessionTimeout}
            />
            <Toggle
              label="IP allowlist"
              name="ipAllowlist"
              hint="Restrict admin console to office ranges."
              on={settings?.ipAllowlist}
            />
            <Toggle
              label="Audit sensitive actions"
              name="auditActions"
              hint="Log deletions and role changes."
              on={settings?.auditActions}
            />
          </div>
        </Panel>

        <Panel title="Roles & Permissions" subtitle="Who can do what" bodyClassName="p-0">
          <ul className="divide-y divide-border">
            {roles.map((r) => (
              <li key={r.name} className="flex items-center gap-3 px-6 py-4">
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{r.name}</p>
                  <p className="truncate text-xs text-muted-foreground">{r.perms}</p>
                </div>
                <span className="num shrink-0 rounded-full bg-secondary px-2.5 py-1 text-[11px] text-muted-foreground">
                  {r.members} members
                </span>
              </li>
            ))}
          </ul>
        </Panel>

        <Panel title="API Settings" subtitle="Programmatic access">
          <div className="space-y-4">
            <Field label="Public key" name="publicKey" value="pk_live_roujli_9f2c41ae" />
            <Field
              label="Webhook endpoint"
              name="webhookEndpoint"
              value="https://api.roujli.com/hooks/platform"
            />
            <div className="divide-y divide-border">
              <Toggle
                label="Rate limiting"
                name="rateLimiting"
                hint="1,000 requests / minute per key."
                on={settings?.rateLimiting}
              />
              <Toggle
                label="Sandbox mode"
                name="sandboxMode"
                hint="Route all calls to test data."
                on={settings?.sandboxMode}
              />
            </div>
          </div>
        </Panel>

        <Panel
          title="System Logs"
          subtitle="Last 24 hours"
          className="xl:col-span-2"
          bodyClassName="p-0"
        >
          <ul className="divide-y divide-border">
            {[
              { m: "Growth engine recalculation completed", s: "resolved", t: "20:14" },
              { m: "Payment webhook retry succeeded (PM-5513)", s: "resolved", t: "18:02" },
              { m: "Elevated API latency on /businesses", s: "pending", t: "14:47" },
              { m: "Role change: Support → Moderator (U-9016)", s: "resolved", t: "11:20" },
              { m: "Nightly backup verified", s: "resolved", t: "03:00" },
            ].map((l) => (
              <li key={l.m} className="flex items-center gap-4 px-6 py-3.5">
                <span className="num shrink-0 text-xs text-muted-foreground">{l.t}</span>
                <p className="min-w-0 flex-1 truncate text-sm">{l.m}</p>
                <StatusPill status={l.s} />
              </li>
            ))}
          </ul>
        </Panel>
      </div>
    </form>
  );
}

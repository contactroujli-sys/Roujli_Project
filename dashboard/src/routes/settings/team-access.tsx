import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, Panel } from "@/components/ui/page";

export const Route = createFileRoute("/settings/team-access")({
  component: TeamAccessPage,
});

function TeamAccessPage() {
  return (
    <>
      <PageHeader title="Team Access" description="Manage roles and permissions for your team." />
      <Panel title="Team Members">
        <p className="text-sm text-muted-foreground">Team access management coming soon.</p>
      </Panel>
    </>
  );
}

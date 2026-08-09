import { createFileRoute } from "@tanstack/react-router";
import { PageHeader, Panel } from "@/components/ui/page";

export const Route = createFileRoute("/settings/preferences")({
  component: PreferencesPage,
});

function PreferencesPage() {
  return (
    <>
      <PageHeader title="Preferences" description="Customize your dashboard experience." />
      <Panel title="UI Preferences">
        <p className="text-sm text-muted-foreground">Preferences settings coming soon.</p>
      </Panel>
    </>
  );
}

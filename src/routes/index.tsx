import { createFileRoute } from "@tanstack/react-router";
import { EditCopyMain } from "@/components/resolve/EditCopyMain";
import { Toaster } from "@/components/ui/sonner";

export const Route = createFileRoute("/")({
  component: () => (
    <div className="min-h-screen bg-[#0A0A0A] text-[#E0E0E0] selection:bg-primary/30">
      <EditCopyMain />
      <Toaster position="bottom-right" richColors theme="dark" />
    </div>
  ),
  head: () => ({
    title: "EditCOPY - DaVinci Resolve Integration",
    meta: [
      { name: "description", content: "Professional clipboard to DaVinci Resolve timeline integration." },
      { property: "og:title", content: "EditCOPY" },
      { property: "og:description", content: "Copy images from clipboard directly to DaVinci Resolve timeline." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" }
    ]
  })
});

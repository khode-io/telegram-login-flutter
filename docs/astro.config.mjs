// @ts-check
import starlight from "@astrojs/starlight";
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "Telegram Login Flutter",
      description: "Flutter plugin for Telegram Login SDK",
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/khode-io/telegram-login-flutter",
        },
      ],
      sidebar: [
        {
          label: "Getting Started",
          items: [
            { label: "Overview", slug: "" },
            { label: "Installation", slug: "getting-started" },
          ],
        },
        {
          label: "Guides",
          items: [
            { label: "Configuration", slug: "configuration" },
            { label: "Usage", slug: "usage" },
            { label: "Error Handling", slug: "error-handling" },
          ],
        },
      ],
    }),
  ],
});

# Telegram Login Documentation

Documentation site for the Telegram Login Flutter plugin, built with [Starlight](https://starlight.astro.build/) and [Astro](https://astro.build).

## 🚀 Project Structure

```
.
├── public/               # Static assets
├── src/
│   ├── assets/          # Images and other assets
│   ├── content/         # Documentation content
│   │   └── docs/        # Markdown/MDX docs
│   └── content.config.ts
├── astro.config.mjs     # Astro configuration
├── package.json
└── tsconfig.json
```

## 🧞 Commands

| Command           | Action                                      |
| :---------------- | :------------------------------------------ |
| `npm install`     | Installs dependencies                       |
| `npm run dev`     | Starts local dev server at `localhost:4321` |
| `npm run build`   | Build production site to `./dist/`          |
| `npm run preview` | Preview build locally                       |

## 🌐 Deployment

The documentation is automatically deployed to **GitHub Pages** when changes are pushed to the `main` or `master` branch.

- **Live URL:** https://khode-io.github.io/telegram-login-flutter
- **Workflow:** [`.github/workflows/deploy-docs.yaml`](../.github/workflows/deploy-docs.yaml)

### Manual Deployment

To trigger a manual deployment, go to **Actions → Deploy Docs to GitHub Pages** and click **Run workflow**.

## 📝 Adding Documentation

1. Add `.md` or `.mdx` files to `src/content/docs/`
2. Each file becomes a route based on its filename
3. Update `astro.config.mjs` to add pages to the sidebar

## 📚 Resources

- [Starlight Docs](https://starlight.astro.build/)
- [Astro Docs](https://docs.astro.build)

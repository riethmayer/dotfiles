# Herdr plugin development

All new Herdr plugins in this directory must be written in strict TypeScript and use Effect v4 for application effects, concurrency, resource management, and error handling. Existing non-TypeScript plugins are grandfathered until they are deliberately migrated.

Each plugin owns its `package.json`, lockfile, tests, build output, and `herdr-plugin.toml`. Runtime dependencies belong in `dependencies`; build and test tools belong in `devDependencies`. `mise run herdr` must be able to install, build, and link every plugin idempotently.

# Learning more about Effect

This repository uses the Effect Typescript library.

Before writing any Effect code, first read `node_modules/effect/AGENTS.md`
**completely**, and follow the links in the file when required.

If you need to learn more about particular Effect apis and concepts that the
guide doesn't cover, search through the source code in `node_modules/effect/src`.

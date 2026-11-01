# AGENTS.md

Discourse theme component. It mixes topics carrying a tag into one category's
own topic list, and makes Doc Categories treat a topic listed in an index but
filed in another category as a doc topic.

## Before changing anything

- Read `README.md`. Its "What it does" and "Limits and caveats" sections are the spec.
- Two behaviors depend on internals of the official
  [discourse-doc-categories](https://github.com/discourse/discourse-doc-categories)
  plugin, and on how core merges preloaded topic lists. Both are explained in
  the README; neither is a supported API.
- `api.modifyClass` cannot touch `service:doc-category-sidebar`: the plugin
  looks it up in the first line of its own initializer, so it is already in
  the container cache. The sidebar patch therefore shadows the getter on the
  service instance. Do not "fix" it back to `modifyClass`.

## Tests

CI installs the Doc Categories plugin through `tests.requiredPlugins` in
`about.json` and runs the system specs, including the sidebar one.

```bash
discourse_theme rspec .
pnpm lint
```

Screenshots in `docs/screenshots/` come from `spec/system/screenshots_spec.rb` via
Actions → Screenshots.

Core's `set_navigation_menu` helper and its page objects are not loaded for
theme specs; set the site setting and use raw selectors instead.

## Conventions

- Everything in code in English. Translations live in `locales/`.
- Setting descriptions belong in `locales/*.yml` under
  `theme_metadata.settings`, never inline in `settings.yml`, or they cannot
  be translated.
- Commit prefixes: `FEATURE:`, `FIX:`, `DEV:`, `DOCS:`. Short subject, no body.

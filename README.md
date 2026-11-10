# Docs by Tag

**ENGLISH** | [ESPAÑOL](README.es.md)

Maintained by Criptonautas. Not affiliated with or endorsed by Discourse (Civilized Discourse Construction Kit, Inc.).

A Discourse theme component that mixes every topic carrying a given tag into
one category's own topic list, so tagged topics scattered across the forum
read as part of that category's documentation.

| Desktop | Mobile |
|---|---|
| ![Tagged topics mixed into a category, desktop](docs/screenshots/doc-tags-desktop.png) | ![Tagged topics mixed into a category, mobile](docs/screenshots/doc-tags-mobile.png) |

The [Doc Categories](https://github.com/discourse/discourse-doc-categories)
plugin builds documentation out of a category, which means it cannot gather
topics that live elsewhere. This component closes that gap: tag a topic
anywhere, and it appears in the documentation category alongside the topics
that natively belong there.

## Requirements

- Discourse 2026.7.2 or newer.
- Tagging enabled.
- The Doc Categories plugin, for the sidebar behavior described below. The
  merge itself works without it.

## Install

Admin → Customize → Themes → Install → From a git repository, with this
repository's clone URL. Then add the component to the themes that should use
it, and set `target_category`: the merge needs it. The docs sidebar behavior
doesn't, so it applies as soon as the component is on and Doc Categories has an index.

## Settings

| Setting | Default | Notes |
| --- | --- | --- |
| `tag_name` | `wiki` | Tag whose topics get mixed in. Only the first tag is used. |
| `target_category` | — | The category whose list gains those topics. Only the first category is used. Required for the merge. |
| `redirect_tag_page` | `false` | Send `/tag/<tag>` to the target category. |
| `hide_tag_hashtags` | `false` | **Site-wide:** a `#<tag>` hashtag renders nothing in posts. |
| `hide_disabled_tag_rows` | `false` | **Site-wide:** hide the rows core lists as not allowed in the composer's tag search. |

## What it does

### Mixes the tagged topics into the list

On the target category only, it fetches the tag's topic list for the current
tab and merges those topics into the category's own list. Rows render through
core's topic list, so they keep the usual avatars, reply counts, activity and
badges, and they follow the tab's own sort — Latest stays ordered by activity.

Topics already in the target category are skipped, so nothing appears twice,
and the category's pinned topics stay pinned. Source category badges are
turned back on, since the list no longer holds a single category, and merged
rows carry a `doc-categories-tags-topic` class for styling.

Results are cached per tag and tab for the session, so switching tabs does
not refetch; a page reload does. If the fetch fails, the native list is left
exactly as it was and no error is shown.

### Treats topics listed in a doc index as docs

Doc Categories decides its sidebar from the category a topic lives in, so a
topic that a documentation index links to but that is filed in another
category gets no sidebar, even though it is part of those docs. This component
makes membership follow the index instead: whichever category's index links to
a topic drives that topic's sidebar.

This part is deliberately tag-independent — it keys on the index, not on
`tag_name` — so it also helps documentation topics that have nothing to do
with the merge above. Previous/next navigation for the same case lives in
[discourse-course-progress-nautas](https://github.com/criptonautas/discourse-course-progress-nautas),
which resolves membership the same way.

### Removes the noise the tag leaves behind

The tag pill is hidden on the target category's list, where it only repeats what
the page already is. It stays visible everywhere else, and other tags are untouched.

Three more rules assume the tag is plumbing rather than something readers should
see or type. They are opinionated, so they're off by default:

- `redirect_tag_page`: `/tag/<tag>` redirects to the target category, since the
  category now holds everything carrying the tag. Tag editing and `/tags/c/...`
  intersections are left alone.
- `hide_tag_hashtags`: a `#<tag>` hashtag written into a post body renders nothing,
  **site-wide**, so the tag is applied through the tag selector instead. Other
  hashtags are untouched and the word stays in the raw markdown.
- `hide_disabled_tag_rows`: disabled rows are hidden in the composer's tag search,
  **site-wide**. When a category restricts which tags it allows, core lists the ones
  it does not allow as disabled rows explaining why; this hides that explanation.
  What is offered is still decided server-side.

## Limits and caveats

- The **Top** tab is approximate: merged order is by view count, which is not
  the ranking the server uses, and the period (`top/weekly` and so on) is not
  passed through.
- Merged topics appear a moment after the native list, once the fetch
  finishes, which reflows the list on a slow connection.
- Everything carrying the tag is fetched up front, up to 20 pages, while the
  category's own topics keep paginating on scroll.
- The sidebar behavior patches plugin internals that are not a public API. If
  Doc Categories changes them, the sidebar reverts to its own default and the
  component logs a warning naming itself; nothing else breaks. A system spec
  runs against the real plugin to catch that, and CI also runs weekly.
- The tag redirect is client side, because Discourse's Permalinks only fire
  for URLs that match nothing else, and `/tag/<tag>` matches the real tag
  route first. In-app clicks never render the tag page, but a direct hit
  loads it briefly before bouncing, and crawlers do not follow it. A 301 at
  your reverse proxy fixes that, as long as it matches only the HTML paths
  and leaves `/tag/<tag>/l/<filter>.json` alone — the component fetches that
  for its own data.
- The hidden disabled rows in the tag search are not covered by a test;
  exercising them needs a category with restricted tag groups driven through
  the composer. Everything else here is.

## Development

```bash
pnpm install
pnpm lint
```

System tests run against a real Discourse through the
[discourse_theme CLI](https://github.com/discourse/discourse_theme), which
installs the Doc Categories plugin from `tests.requiredPlugins`:

```bash
discourse_theme rspec .
```

CI runs against the latest Discourse and the Doc Categories plugin, and weekly.

## License

MIT. See [LICENSE](LICENSE).

Text of this README under [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).

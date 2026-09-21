# robots.txt corpus

The `robots.txt` of 267,053 domains from the Tranco top one million, fetched on 3 and 4 September 2026
and parsed under RFC 9309. SQLite. CC BY 4.0.

| | |
|---|---|
| Domains attempted | 267,053 |
| Domains that served a readable file | 168,207 |
| Distinct crawler names | 16,008 |
| Allow and Disallow rules with a path | 9,441,114 |

## Sample

Ranks 1 to 100,000 are complete. Ranks 100,001 to 1,000,000 are a seeded simple random sample. The frame is
Tranco list [`N2Q8W`](https://tranco-list.eu/list/N2Q8W), downloaded 29 August 2026.

| Tranco rank, `band` | Domains in Tranco | Attempted | Coverage | Weight for the top one million |
|---|---|---|---|---|
| 1-1000 | 1,000 | 1,000 | 100% | 1 |
| 1001-10000 | 9,000 | 9,000 | 100% | 1 |
| 10001-100000 | 90,000 | 90,000 | 100% | 1 |
| 100001-1000000 | 900,000 | 167,053 | 18.6% | 5.39 |
| All | 1,000,000 | 267,053 | 26.7% | |

The top 100,000 are 37.4% of the sample and 10% of the top one million. A share across the whole corpus is a
share of the sample. To estimate the top one million, apply the weight or report by `band`.

## Files

| File | Size | Tables |
|---|---|---|
| `robots-corpus-lite.db` | 95.1 MiB | `sites`, `agents`, `measures`, `findings`, `meta` |
| `robots-corpus.db` | 1,811.6 MiB | the same plus `rules` and `files`. Download from the [latest release](../../releases/latest) |

`robots-corpus-lite.db` has no indexes, to stay under GitHub's 100 MiB limit. To add them, run
`sqlite3 robots-corpus-lite.db < indexes.sql`. The file grows to about 220 MiB. Checksums are in
`SHA256SUMS.txt`.

## Which domains count

| `outcome` | Domains | What came back |
|---|---|---|
| `ok` | 161,216 | a robots.txt. Includes 386 HTML pages, marked by the `html_served_as_robots` measure |
| `ok-empty` | 6,991 | a file with no records, empty or comments only. 5 still parse to rules |
| `unreadable-network` | 61,021 | no response |
| `absent` | 20,863 | 404 or 410 |
| `unreadable-status` | 9,926 | another status: 8,811 4xx including 8,260 403, 1,101 5xx and 14 other |
| `unreadable-not-robots` | 7,036 | a response that is not a robots.txt |

`served_sites` is `ok` and `ok-empty`, 168,207 domains. Use it as the denominator. `agents`, `rules` and
`files` hold rows for these domains only.

Under RFC 9309 a 4xx means no restrictions and a 5xx means disallow everything.

## Tables

### `sites`

One row per domain attempted, 267,053.

| Column | Meaning |
|---|---|
| `domain`, `rank`, `band` | Tranco domain, rank and rank band |
| `outcome`, `status` | what came back as above and the HTTP status |
| `client` | the client that produced the row. See Collection |
| `reason` | why Node's fetch failed. NULL when it read the file |
| `is_website` | 1 if the domain answered. 0 if `reason` is `no-dns` or `no-http-service` |
| `measurable` | 1 for `ok`, `ok-empty` and `absent` |
| `cloudflare_managed` | the file carries `# BEGIN Cloudflare Managed content` |
| `content_signal` | the value of the first `Content-Signal:` line |
| `names_ai`, `ai_count` | whether the file names any of the 58 catalogued AI crawlers and how many |
| `turns_one_away` | names an AI crawler and denies at least one of them `/` |
| `blocks_any_live` | denies `/` to an AI crawler that searches or fetches for a user |
| `has_half_shut_door` | for one of 8 pairs from one operator, names the first and denies it `/` while the second can fetch `/`. The pairs include `gptbot` with `oai-searchbot` |
| `closed_by_default` \* | the `*` group denies `/` |
| `sensitive_pool` \* | sensitive probe paths an anonymous crawler cannot fetch |
| `sensitive_paths` \* | how many of those a named AI crawler can fetch |
| `exposes_sensitive` \* | `sensitive_paths` is above 0 |
| `template_id` | a hash of the file with the host removed. Files that share one are the same template |

\* Computed only for a file that names a catalogued AI crawler and has at least two distinct probe paths. 0
otherwise. So `closed_by_default = 0` does not mean the `*` group allows `/`: reddit.com and baidu.com deny it
and carry 0.

Outside `served_sites` the per-file columns are 0 or NULL. The exception is `absent`: those rows were analysed
from the body sent with the 404 or 410, so a few carry flags and most carry a `template_id`.

### `agents`

One row per crawler name written in a file: 1,278,293 rows from 74,195 files. `*` is not stored, so a
file that addresses only `*` has no rows. Join from `served_sites` with a LEFT JOIN.

| Column | Meaning |
|---|---|
| `domain` | the domain |
| `token` | the crawler name as written, lower-cased |
| `allowed_at_root` | 1 if the crawler may fetch `/` under RFC 9309 |
| `in_registry` | 1 for the 58 AI crawlers this study catalogued |
| `role`, `operator` | set for 88 known crawlers. NULL otherwise |
| `ai_shaped` | the name looks like an AI crawler, catalogued or not |
| `nonexistent` | the name matches no crawler that exists. `.schema agents` has the detail |
| `denial_inherited` | the denial of `/` reaches the crawler from an adjacent group. NULL when it is not denied. `.schema agents` has the detail |

### `measures`

One row per thing the study counted, 85 rows.

| Column | Meaning |
|---|---|
| `id` | joins `findings.measure_id` |
| `measure`, `label` | key and label |
| `reading` | `RFC 9309` or `Google` where the two parsers differ, `either reading` for one measure, NULL otherwise |
| `defect_class`, `class_meaning` | A or B is a defect. C or D is not. NULL for the 53 that are not classified |
| `files` | served files that meet it. Equals its rows in `findings` |

`ua_email` counts 512 files with an `@` in a crawler name. 491 of them hold an email address.

### `findings`

Which files meet which measure, 628,274 rows. `rank` joins `sites.rank`. `measure_id` joins `measures.id`.

### `rules`

`robots-corpus.db` only. One row per Allow or Disallow with a path, for each crawler named in its group, `*`
included: 9,441,114 rows.

| Column | Meaning |
|---|---|
| `domain` | the domain |
| `group_id` | position of the group in the file, from 0 |
| `agent` | crawler name, lower-cased |
| `directive` | `allow` or `disallow`, lower-case |
| `path` | the path as written, masked as below |

An empty `Disallow:` has no row. RFC 9309 reads it as allowing everything. Read it from `files.body`.

### `files`

`robots-corpus.db` only. The text of each served file, 168,207 rows.

| Column | Meaning |
|---|---|
| `rank` | joins `sites.rank` |
| `bytes` | size as served |
| `masked_values`, `masked_emails` | how many values and email addresses the masking replaced |
| `body` | the file as served, masked as below, in UTF-8 with NUL bytes stored as U+FFFD |

### `meta`

Collection dates, method, limits and headline counts, as key and value.

### Views

| View | Rows |
|---|---|
| `served_sites` | `sites` where `outcome` is `ok` or `ok-empty` |
| `findings_by_domain` | `findings` with domain, measure and label |
| `band_summary` | served files per band |
| `agent_summary` | one per crawler name, with sites naming it and how often it is denied `/` |
| `defect_files` | served files with a class A or B finding |
| `ai_role_split` | files that deny a catalogued AI crawler `/`, split by whether they deny training crawlers, search and user crawlers or both |

## Masking

| Replaced | With | In `files` | In `rules.path` |
|---|---|---|---|
| Email addresses, except on `User-agent` lines | `[email]` | 6,693 | 60 |
| Values that identify a person or a session: URL signatures, contact keys, API keys, tokens | `[masked]` | 61 | 28 |

Email addresses written as a `User-agent` value are kept: 95 distinct addresses in 119
distinct `agents.token` values and 491 files. They are personal data.

Count masking with `files.masked_emails` and `files.masked_values`. The text `[email]` also appears as the site
owner wrote it in 8 files, 3 of which also have addresses masked. Those
are the files where `[email]` occurs more often than `masked_emails`.

## Collection

1. Node's fetch requested `/robots.txt` from every domain.
2. For each domain it could not read, `reason` records why. When the server answered, `reason` comes from the
   status. Otherwise it comes from a DNS lookup and a request for the homepage.
3. Domains with no DNS or no HTTP service stopped there.
4. The rest were tried with curl over HTTP/1.1, first the apex and then the `www.` host.
5. Those curl could not read were tried in a headless Chrome.

| `client` | Rows |
|---|---|
| `node fetch` | 229,216 |
| `browser-failed` | 19,736 |
| `curl` | 16,590 |
| `browser` | 1,511 |

## Limits

One vantage point, one IP range, two days. robots.txt is advisory. A site can allow a crawler here and block it
at its CDN, so `allowed_at_root = 1` does not mean the crawler gets the content.

## Citation

> Robots.txt corpus, Pete Dainty, 2026. CC BY 4.0.

Ranks are from Tranco: Le Pochat et al., *Tranco: A Research-Oriented Top Sites Ranking Hardened Against
Manipulation*, NDSS 2019, <https://tranco-list.eu/>.

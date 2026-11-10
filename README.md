# tcgpriser-uptime

Checks [tcgpriser.se](https://tcgpriser.se) and its API from outside the server every five minutes,
and posts to #site-alerts on the tcgpriser.se Discord when the site goes down or comes back.

It runs here, on GitHub's runners, because an alert that lives on the server goes down with it. That
is what happened on 2026-11-09: the server lost its network for 35 hours and nothing said so.

- `check.sh` checks pages **by content** (titles, API JSON), not status codes, and adds a unique
  query string to every URL so Cloudflare's cache cannot answer for a dead origin.
- `.github/workflows/uptime.yml` runs it, alerts only on a change of state, and re-enables itself so
  GitHub's 60-day inactivity pause never stops the schedule.

Run it locally: `bash check.sh`. Secrets: `DISCORD_BOT_TOKEN`, `SITE_ALERTS_CHANNEL_ID`.

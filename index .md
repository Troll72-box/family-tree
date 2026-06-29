# 🌳 Family Tree

A self-hosted, AI-powered family tree. You interview relatives (or send them a link), the app parses their answers into people + relationships, and everyone who opens the URL sees the same growing tree — with a visual graph, insights, and a "how are these two related?" finder.

- **Free forever** — GitHub Pages (hosting) + Supabase free tier (database). No credit card, no server.
- **Shared** — data lives in one database; invite links feed straight into your tree.
- **AI-optional** — use a free Groq/Gemini key for accurate parsing, or the built-in rule parser with no key at all.

Files: `index.html` (the whole app), `schema.sql` (database setup), `README.md` (this).

---

## Setup (≈ 10 minutes, one time)

### 1. Create the database (Supabase)
1. Go to **supabase.com** → sign up (free, no card) → **New project**. Pick any name + password, wait ~2 min for it to spin up.
2. Left menu → **SQL Editor** → **New query** → paste the entire contents of `schema.sql` → **Run**. You should see "Success".
3. Left menu → **Settings → API**. Copy two things:
   - **Project URL** (looks like `https://abcd1234.supabase.co`)
   - **Project API keys → `anon` `public`** (a long string starting `eyJ…`)

> The anon key is *designed* to be public — it's safe to ship in the page. Access is controlled by the policies in `schema.sql`.

### 2. Put your details in the app
Open `index.html`, find the `CONFIG` block near the top of the `<script>` (around line 380), and fill it in:

```js
const CONFIG = {
  SUPABASE_URL:  'https://abcd1234.supabase.co',   // your Project URL
  SUPABASE_KEY:  'eyJhbGciOi...',                  // your anon public key
  TREE_NAME:     'Tiwari Family',                  // header label
  ROOT_PERSON:   'Satyam',                         // who is "you" (gold node)
};
```

### 3. Host it on GitHub Pages (free, permanent URL)
1. Create a new GitHub repo (e.g. `family-tree`). Upload `index.html` (the README/schema are optional to upload).
2. Repo → **Settings → Pages** → **Source: Deploy from a branch** → Branch **main** / **`/root`** → **Save**.
3. Wait ~1 minute. Your URL appears at the top: `https://<your-username>.github.io/family-tree/`.

That URL is your tree. Open it — you'll land on the dashboard.

---

## First run

1. Open your GitHub Pages URL.
2. **Settings tab** → pick an AI provider:
   - **Groq (free)** or **Gemini (free)** — grab a key at `console.groq.com` or `aistudio.google.com`, paste it, hit **Test**. Recommended.
   - **No AI · rules** — works immediately with zero key (less accurate; good for testing).
3. **Add person tab** → add **yourself** first (name = your `ROOT_PERSON`, relation = "self"), fill a few answers, **Parse → Add to tree**. Now you're the gold root and links to "you" will resolve.
4. Keep adding family, or send invite links (below).

> Want to explore before any setup? Open `index.html` and click **Try the demo first** — it loads a sample Tiwari tree using browser-local storage (no Supabase needed).

---

## Sending invite links (the shared part)

1. **Invite links tab** → label it ("For Uncle Ramesh") → **Generate** → **Copy** the link.
2. Send it (WhatsApp/Telegram/email). They open it on any phone, answer the questions, **Submit**. They need nothing — no login, no key.
3. Their submission appears in your **Responses tab** with a badge count. Click **Process → review → Add to tree**.
4. The tree updates in the shared database — anyone who reloads the URL sees the new people.

Each link is single-use and marks itself "Used" once submitted.

---

## How it works

- **People** are nodes, **relationships** are typed edges (`PARENT_OF`, `SPOUSE_OF`, …) — a graph, not a rigid chart, so it expands in any direction.
- On save, anyone already in the tree (same name) is **matched** instead of duplicated. The `INTERVIEWER` reference in answers maps to your `ROOT_PERSON`, so "X is my uncle" connects X to you.
- **Connections tab** runs a breadth-first search for the shortest path between two people, then (if AI is on) explains it in plain language.

---

## Notes & tweaks

- **Privacy:** the default policies allow public read/write (fine for a family project on an unguessable URL). To lock it down, add Supabase Auth and tighten the policies in `schema.sql` to `auth.role() = 'authenticated'`.
- **API keys:** the AI key you enter stays in *your* browser (localStorage) and is only used for your own parsing. Respondents never need one.
- **Costs:** Groq and Gemini free tiers comfortably cover personal use. GitHub Pages and Supabase free tiers are permanent.
- **Backup:** Supabase → Table Editor → export any table to CSV anytime.
- **Already use Firebase?** This is built on Supabase REST (no SDK, lighter for a static page), but the same pattern works on Firestore if you'd rather — swap the `api()` function.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Lands on "Almost ready" screen | `CONFIG.SUPABASE_URL` / `KEY` not filled in correctly. |
| DB status shows an error in Settings | Re-check URL/key; confirm `schema.sql` ran successfully. |
| Invite link says "isn't set up yet" | The deployed file doesn't have CONFIG filled — re-upload after editing. |
| Parse fails / invalid JSON | Switch provider in Settings, or use **No AI · rules**. |
| Person connects to nobody | Add yourself (`ROOT_PERSON`) first so `INTERVIEWER` links resolve. |

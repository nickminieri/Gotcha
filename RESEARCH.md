# Marketplace Research → Gotcha Roadmap

Findings from a multi-source review of top P2P / student marketplace apps
(OfferUp, Mercari, Facebook Marketplace, Depop, Poshmark, Vinted, and
college-specific apps: Swaply, Vezzy, iWantIt, Ole Miss). 24/25 claims verified
across 27 sources.

## Core insight
The validated differentiator for a campus marketplace is **student-only safety**:
gate access to verified students, layer identity/trust signals, keep
communication and meetups safe, and protect transactions. Growth is **per-campus
density**, not breadth.

## Implemented in this app
- **Student gating** — `.edu` email required at login; profile derived from it,
  granting a **Student Verified** badge.
- **Layered verification + permanent badge** (OfferUp TruYou pattern) — a
  simulated **Verify ID** upgrade granting an **ID Verified** badge; badges shown
  on profiles, seller pages, and seller cards.
- **In-app messaging that stays safe** — a persistent chat **safety banner**
  ("never share phone numbers, passwords, or payment info").
- **Reporting & blocking** — report (with reasons) and block from listings,
  seller profiles, and conversations; blocked sellers are hidden from the feed.
- **Designated safe meetup spots + in-chat scheduling** — curated campus spots
  (student union, library, campus PD, etc.) proposed as a meetup card in chat.
- **Offers** — in-chat "Make an Offer" with accept/decline, shown as an offer card.

## Deferred (needs a backend / third parties)
- **Robust student verification** — university SSO (Shibboleth/CAS/OAuth) or an
  enrollment API (e.g., SheerID). `.edu` alone is a weak signal (alumni keep
  addresses; fake `.edu` accounts exist).
- **Real ID + selfie verification** — e.g., Onfido (what TruYou uses).
- **Functional escrow / payments** — Stripe Connect delayed payout + conditional
  refund (true "escrow" is a marketing label; needs legal/compliance review).
- **Report escalation to university administration** — requires a real workflow
  and institutional agreement.
- **Push notifications** for messages/offers/reviews.

## Strategy note
Launch and saturate a single campus before expanding; treat each campus as a
separate market (marketplace network effects are per-market).

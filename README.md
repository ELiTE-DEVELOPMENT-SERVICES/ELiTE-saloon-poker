<p align="center">
  <img src="docs/logo.png" alt="Elite Development" width="360">
</p>

<h1 align="center">saloon-poker</h1>
<p align="center"><b>Server-authoritative saloon Blackjack for RedM</b></p>

<p align="center">
  <a href="#">[Live Demo Reel](https://elite-development-services.github.io/ELiTE-saloon-poker/)</a> ·
  <a href="#installation">Installation</a> ·
  <a href="#configuration">Configuration</a> ·
  <a href="#support">Support</a>
</p>

---

**saloon-poker** drops a fully playable Blackjack table into any saloon in your RedM world. Players walk up to a table, press **E**, place a bet, and play a classic hit/stand/double hand against an NPC dealer — all resolved on the server so results can't be tampered with client-side.

Built and maintained by **Elite Development**.

## Features

- 🎴 **Server-authoritative Blackjack** — the deck, deal, and payout all happen on the server; the client only ever sees what it's allowed to.
- 🤠 **NPC dealer peds** spawned automatically at every table you configure, playing a card-dealer idle scenario.
- 💰 **Configurable betting** — set your own min/max bet and blackjack payout multiplier (defaults to 3:2).
- 🔌 **Framework-agnostic** — ships with a standalone in-memory wallet so it works out of the box, with drop-in hooks for VORP or RSG money systems.
- 🃏 **Multi-deck shoe** — configurable number of 52-card decks shuffled per round.
- 📍 **Multiple tables** — add as many saloon locations as you want in one config array.
- 🎨 **Western-themed NUI** — a styled felt-table UI (see the demo reel below) built with plain HTML/CSS/JS, no frameworks required.

## Live Demo Reel

The `docs/` folder contains a standalone, self-playing demo (`index.html`) of the table UI — no RedM required to preview it. It's meant to be screen-recorded for showcase clips.

Once this repo is pushed to GitHub, turn on **GitHub Pages** (see [Publishing the demo](#publishing-the-demo-with-github-pages) below) and this link will go live for anyone to click and preview in a browser.

## Requirements

- A running RedM server (`cerulean` fxmanifest / `rdr3` build)
- No other resource dependencies — works standalone
- Optional: [VORP](https://github.com/VORP-CORE) or RSG Framework, if you want to hook into an existing economy instead of the built-in wallet

## Installation

1. Download or clone this repository.
2. Copy the `saloon-poker` folder into your server's `resources` directory.
3. Add the following to your `server.cfg`:
   ```
   ensure saloon-poker
   ```
4. Restart your server (or run `refresh` + `ensure saloon-poker` in the console).

## Configuration

All settings live in `config.lua`:

| Setting | Description | Default |
|---|---|---|
| `Config.Tables` | List of `{ coords, heading, label }` saloon table locations | Valentine & Rhodes saloons |
| `Config.DealerModel` | Ped hash used for the dealer NPC | `cs_dealer_01` |
| `Config.InteractionDistance` | Distance (units) at which the "Press E" prompt appears | `1.5` |
| `Config.MinBet` / `Config.MaxBet` | Betting limits | `5` / `500` |
| `Config.BlackjackPayout` | Payout multiplier on a natural blackjack | `1.5` (3:2) |
| `Config.DeckCount` | Number of 52-card decks shuffled into the shoe | `6` |
| `Config.Framework` | `'standalone'`, `'vorp'`, or `'rsg'` | `'standalone'` |

### Adding your own table locations

Edit the `Config.Tables` array with real coordinates from your map:

```lua
Config.Tables = {
    { coords = vector3(-273.9, 802.9, 118.8), heading = 160.0, label = "Valentine Saloon" },
    -- add more tables here
}
```

### Hooking up a framework economy

By default the script uses a simple in-memory wallet so it works immediately for testing. To connect it to VORP or RSG, open `server/main.lua` and fill in the `GetMoney`, `AddMoney`, and `RemoveMoney` functions with your framework's calls (commented examples are already included for VORP).

## How to Play

1. Walk up to a configured saloon table.
2. Press **E** when the prompt appears.
3. Enter a bet and click **Place Bet**.
4. **Hit**, **Stand**, or **Double** — standard Blackjack rules apply.
5. Dealer stands on 17. A natural blackjack pays 3:2 by default.

## Publishing the demo with GitHub Pages

Once you've uploaded this repo to GitHub:

1. Go to your repo's **Settings** tab.
2. In the left sidebar, click **Pages**.
3. Under "Build and deployment," set **Source** to `Deploy from a branch`.
4. Set **Branch** to `main` and the folder to `/docs`, then click **Save**.
5. After a minute, GitHub will give you a live link like `https://yourusername.github.io/saloon-poker/` — that's your playable demo reel, shareable anywhere.

## Support

Questions, bug reports, or feature requests — reach out on Discord: **[Elite Development](https://discord.com/users/1162977745400254575)**

> Note: that link opens a personal Discord profile, not a server invite. If you'd like people to be able to join a support server (rather than needing to already share a server with you or send a friend request), create a Discord server and use its `discord.gg/...` invite link instead — happy to help you swap it in.

## License

Released under the [MIT License](LICENSE) — free to use, modify, and redistribute, including in commercial servers, with attribution.

---

<p align="center">Made with 🤠 by Elite Development</p>

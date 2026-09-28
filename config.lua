Config = {}

Config.Locale = 'en'

-- Saloon table locations (coords for the dealer ped / interaction point)
Config.Tables = {
    { coords = vector3(-273.9, 802.9, 118.8), heading = 160.0, label = "Valentine Saloon" },
    { coords = vector3(2726.4, 1379.9, 45.0), heading = 45.0,  label = "Rhodes Saloon" },
}

Config.DealerModel = `cs_dealer_01` -- swap for a real RDR3 dealer/gambler ped hash
Config.InteractionDistance = 1.5

Config.MinBet = 5
Config.MaxBet = 500

Config.BlackjackPayout = 1.5 -- 3:2 payout on a natural blackjack
Config.DeckCount = 6         -- number of 52-card decks shuffled into the shoe

-- Hook these into your framework. 'standalone' keeps a simple in-memory wallet
-- so the script works out of the box for testing/showcasing.
Config.Framework = 'standalone' -- 'vorp', 'rsg', or 'standalone'

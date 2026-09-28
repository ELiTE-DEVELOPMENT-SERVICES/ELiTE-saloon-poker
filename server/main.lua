local Games = {}       -- [src] = { deck, playerHand, dealerHand, bet, state }
local PlayerMoney = {} -- standalone fallback wallet

local Suits = { 'hearts', 'diamonds', 'clubs', 'spades' }
local Ranks = { '2','3','4','5','6','7','8','9','10','J','Q','K','A' }

local function BuildShoe()
    local deck = {}
    for _ = 1, Config.DeckCount do
        for _, s in ipairs(Suits) do
            for _, r in ipairs(Ranks) do
                table.insert(deck, { suit = s, rank = r })
            end
        end
    end
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

local function HandTotal(hand)
    local total, aces = 0, 0
    for _, c in ipairs(hand) do
        if c.rank == 'A' then
            aces = aces + 1
            total = total + 11
        elseif c.rank == 'J' or c.rank == 'Q' or c.rank == 'K' then
            total = total + 10
        else
            total = total + tonumber(c.rank)
        end
    end
    while total > 21 and aces > 0 do
        total = total - 10
        aces = aces - 1
    end
    return total
end

-- ===== Money bridge: replace this block with your framework's money functions =====
local function GetMoney(src)
    if Config.Framework == 'standalone' then
        PlayerMoney[src] = PlayerMoney[src] or 500
        return PlayerMoney[src]
    end
    -- Example VORP:
    -- local Character = VorpCore.getUser(src).getUsedCharacter
    -- return Character.money
    return 0
end

local function AddMoney(src, amount)
    if Config.Framework == 'standalone' then
        PlayerMoney[src] = (PlayerMoney[src] or 500) + amount
        return
    end
    -- hook framework "add money" here
end

local function RemoveMoney(src, amount)
    if Config.Framework == 'standalone' then
        PlayerMoney[src] = math.max(0, (PlayerMoney[src] or 500) - amount)
        return
    end
    -- hook framework "remove money" here
end
-- ====================================================================================

local function SendState(src)
    local g = Games[src]
    if not g then return end
    TriggerClientEvent('saloon-poker:client:gameState', src, {
        playerHand   = g.playerHand,
        dealerHand   = g.state == 'playing' and { g.dealerHand[1], { hidden = true } } or g.dealerHand,
        playerTotal  = HandTotal(g.playerHand),
        dealerTotal  = g.state == 'playing' and nil or HandTotal(g.dealerHand),
        bet          = g.bet,
        state        = g.state,
    })
end

local function ResolveDealer(src)
    local g = Games[src]
    if not g then return end

    while HandTotal(g.dealerHand) < 17 do
        table.insert(g.dealerHand, table.remove(g.deck))
    end

    local playerTotal = HandTotal(g.playerHand)
    local dealerTotal = HandTotal(g.dealerHand)
    local playerBJ = playerTotal == 21 and #g.playerHand == 2
    local dealerBJ = dealerTotal == 21 and #g.dealerHand == 2

    local outcome, payout
    if playerBJ and not dealerBJ then
        outcome, payout = 'blackjack', g.bet + math.floor(g.bet * Config.BlackjackPayout)
    elseif dealerBJ and not playerBJ then
        outcome, payout = 'lose', 0
    elseif dealerTotal > 21 or playerTotal > dealerTotal then
        outcome, payout = 'win', g.bet * 2
    elseif playerTotal == dealerTotal then
        outcome, payout = 'push', g.bet
    else
        outcome, payout = 'lose', 0
    end

    if payout > 0 then AddMoney(src, payout) end

    g.state = 'finished'
    TriggerClientEvent('saloon-poker:client:result', src, {
        outcome = outcome, playerTotal = playerTotal, dealerTotal = dealerTotal, payout = payout,
    })
    TriggerClientEvent('saloon-poker:client:updateBalance', src, GetMoney(src))
    SendState(src)
end

RegisterNetEvent('saloon-poker:server:requestBalance', function()
    local src = source
    TriggerClientEvent('saloon-poker:client:updateBalance', src, GetMoney(src))
end)

RegisterNetEvent('saloon-poker:server:placeBet', function(amount)
    local src = source
    amount = tonumber(amount)
    if not amount or amount < Config.MinBet or amount > Config.MaxBet then
        TriggerClientEvent('saloon-poker:client:result', src, { outcome = 'error', message = 'Invalid bet amount' })
        return
    end
    if GetMoney(src) < amount then
        TriggerClientEvent('saloon-poker:client:result', src, { outcome = 'error', message = 'Not enough cash' })
        return
    end

    RemoveMoney(src, amount)

    local deck = BuildShoe()
    local playerHand = { table.remove(deck), table.remove(deck) }
    local dealerHand = { table.remove(deck), table.remove(deck) }

    Games[src] = { deck = deck, playerHand = playerHand, dealerHand = dealerHand, bet = amount, state = 'playing' }

    if HandTotal(playerHand) == 21 then
        ResolveDealer(src)
    else
        SendState(src)
    end
end)

RegisterNetEvent('saloon-poker:server:hit', function()
    local src = source
    local g = Games[src]
    if not g or g.state ~= 'playing' then return end

    table.insert(g.playerHand, table.remove(g.deck))
    local total = HandTotal(g.playerHand)

    if total > 21 then
        g.state = 'finished'
        TriggerClientEvent('saloon-poker:client:result', src, { outcome = 'bust', playerTotal = total })
        TriggerClientEvent('saloon-poker:client:updateBalance', src, GetMoney(src))
    end
    SendState(src)
end)

RegisterNetEvent('saloon-poker:server:double', function()
    local src = source
    local g = Games[src]
    if not g or g.state ~= 'playing' or #g.playerHand ~= 2 then return end
    if GetMoney(src) < g.bet then return end

    RemoveMoney(src, g.bet)
    g.bet = g.bet * 2
    table.insert(g.playerHand, table.remove(g.deck))

    local total = HandTotal(g.playerHand)
    if total > 21 then
        g.state = 'finished'
        TriggerClientEvent('saloon-poker:client:result', src, { outcome = 'bust', playerTotal = total })
        TriggerClientEvent('saloon-poker:client:updateBalance', src, GetMoney(src))
        SendState(src)
    else
        ResolveDealer(src)
    end
end)

RegisterNetEvent('saloon-poker:server:stand', function()
    local src = source
    local g = Games[src]
    if not g or g.state ~= 'playing' then return end
    ResolveDealer(src)
end)

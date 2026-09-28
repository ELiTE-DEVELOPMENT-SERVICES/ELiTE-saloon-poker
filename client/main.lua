local uiOpen = false
local dealerPeds = {}

local function CreateDealer(tableData)
    RequestModel(Config.DealerModel)
    local timeout = 0
    while not HasModelLoaded(Config.DealerModel) and timeout < 5000 do
        Wait(50)
        timeout = timeout + 50
    end
    if not HasModelLoaded(Config.DealerModel) then return end

    local ped = CreatePed(4, Config.DealerModel, tableData.coords.x, tableData.coords.y, tableData.coords.z - 1.0, tableData.heading, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_CARD_PLAYER_DEALER", 0, true)
    table.insert(dealerPeds, ped)
end

CreateThread(function()
    for _, t in ipairs(Config.Tables) do
        CreateDealer(t)
    end
end)

local function DrawTablePrompt(label)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(("Press ~INPUT_CONTEXT~ to play %s"):format(label))
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function OpenPokerUI()
    uiOpen = true
    SetNuiFocus(true, true)
    TriggerServerEvent('saloon-poker:server:requestBalance')
    SendNUIMessage({ action = 'open', minBet = Config.MinBet, maxBet = Config.MaxBet })
end

local function CloseUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, t in ipairs(Config.Tables) do
            local dist = #(coords - t.coords)
            if dist < 5.0 then
                sleep = 0
                if dist < Config.InteractionDistance then
                    DrawTablePrompt(t.label)
                    if IsControlJustPressed(0, 0xE10469E7) and not uiOpen then -- INPUT_CONTEXT
                        OpenPokerUI()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNUICallback('close', function(_, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('placeBet', function(data, cb)
    TriggerServerEvent('saloon-poker:server:placeBet', tonumber(data.amount))
    cb('ok')
end)

RegisterNUICallback('hit', function(_, cb)
    TriggerServerEvent('saloon-poker:server:hit')
    cb('ok')
end)

RegisterNUICallback('stand', function(_, cb)
    TriggerServerEvent('saloon-poker:server:stand')
    cb('ok')
end)

RegisterNUICallback('double', function(_, cb)
    TriggerServerEvent('saloon-poker:server:double')
    cb('ok')
end)

RegisterNetEvent('saloon-poker:client:updateBalance', function(amount)
    SendNUIMessage({ action = 'balance', amount = amount })
end)

RegisterNetEvent('saloon-poker:client:gameState', function(state)
    SendNUIMessage({ action = 'state', state = state })
end)

RegisterNetEvent('saloon-poker:client:result', function(result)
    SendNUIMessage({ action = 'result', result = result })
    local ped = PlayerPedId()
    if result.outcome == 'win' or result.outcome == 'blackjack' then
        PlayAmbientSpeech1(ped, "GENERIC_WIN_SMALL", "SPEECH_PARAMS_FORCE")
    elseif result.outcome == 'lose' or result.outcome == 'bust' then
        PlayAmbientSpeech1(ped, "GENERIC_CURSE_MED", "SPEECH_PARAMS_FORCE")
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, ped in ipairs(dealerPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)

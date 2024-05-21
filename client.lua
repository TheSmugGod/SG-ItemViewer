local isViewing = false
local modelRotation = 0.0
local modelCoords = vector3(0.0, 0.0, 0.0)
local height = 0.0 -- Initialize height
local model
local previousViewMode = nil




RegisterCommand('show3ditem', function(source, args)
    if not isViewing then
        isViewing = true
        previousViewMode = GetFollowPedCamViewMode()
        SetFollowPedCamViewMode(4) -- Force first-person view
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'display'
        })
        Citizen.CreateThread(function()

            
-- Initialize modelCoords with the player's position
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
local forwardVector = GetEntityForwardVector(playerPed)
local x, y, z = table.unpack(playerCoords + forwardVector * 2.0)
modelCoords = vector3(x, y, z)

            while isViewing do
                Citizen.Wait(0)
                Draw3DModel(args[1])
            end
        end)
    end
end, false)


RegisterNUICallback('move', function(data, cb)
    local step = 0.1 -- Step size for movement
    local direction = data.direction

    if direction == 'forward' then
        modelCoords = modelCoords + vector3(0.0, step, 0.0)
    elseif direction == 'backward' then
        modelCoords = modelCoords + vector3(0.0, -step, 0.0)
    elseif direction == 'left' then
        modelCoords = modelCoords + vector3(-step, 0.0, 0.0)
    elseif direction == 'right' then
        modelCoords = modelCoords + vector3(step, 0.0, 0.0)
    elseif direction == 'up' then
        height = height + step
    elseif direction == 'down' then
        height = height - step
    end

    SetEntityCoords(model, modelCoords.x, modelCoords.y, modelCoords.z + height)
    cb('ok')
end)


RegisterNUICallback('rotate', function(data, cb)
    modelRotation = data.rotation
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    CloseViewer()
    cb('ok')
end)

function Draw3DModel(modelnamed)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)

    if not model then
        local x, y, z = table.unpack(coords + forwardVector * 2.0)
        local modelHash = GetHashKey(modelnamed)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end

        model = CreateObject(modelHash, modelCoords.x, modelCoords.y, modelCoords.z, false, false, false)
        SetEntityAsMissionEntity(model, true, true)
        SetModelAsNoLongerNeeded(modelHash)
    end

    SetEntityCoords(model, modelCoords.x, modelCoords.y, modelCoords.z + height)
    SetEntityRotation(model, 0.0, 0.0, modelRotation, 2, true)
    SetEntityAlpha(model, 255, false)
    FreezeEntityPosition(model, true)
   -- DisplayText('~INPUT_SCRIPTED_FLY_UD~ - HEIGHT , ~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_DOWN~ ~INPUT_CELLPHONE_LEFT~ ~INPUT_CELLPHONE_RIGHT~ - MOVE , ~INPUT_ATTACK~ - ROTATE', false)
    -- Debug prints
    print("Model Coords: " .. modelCoords.x .. ", " .. modelCoords.y .. ", " .. modelCoords.z)
    print("Model Rotation: " .. modelRotation)
end


function CloseViewer()
    isViewing = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'hide'
    })
    if model then
        if DoesEntityExist(model) then
            print("Model exists, deleting model")
            DeleteObject(model)
            Citizen.Wait(100) -- Wait a short moment to ensure deletion
            if not DoesEntityExist(model) then
                print("Model successfully deleted")
            else
                print("Failed to delete model")
            end
        else
            print("Model does not exist")
        end
        model = nil
    end
    if previousViewMode then
        SetFollowPedCamViewMode(previousViewMode) -- Revert to previous view mode
        previousViewMode = nil
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if model then
            DeleteObject(model)
        end
        if previousViewMode then
            SetFollowPedCamViewMode(previousViewMode)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isViewing then
            if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 200) then -- Backspace or Escape key
                CloseViewer()
            end
        end
    end
end)

function DisplayText(text, bool)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, bool, -1)
end
peds = {}
ped_player = {}
blip = {}
marker = {}
marker_player = {}
timers = {}
function marker_join(player)
    if getElementType(player) ~= "player" then return  end
    if marker_player[source] ~= player then return  end

    setPedAnimation( peds[player])
    if isTimer(timers[player]) then 
        killTimer(timers[player])
        timers[player] = nil 
    end
end
function marker_exit(player)
    if getElementType(player) ~= "player" then return  end
    if marker_player[source] ~= player then return  end
    if isPedInVehicle(player) then return end
    local rx,ry,rz = getElementRotation(player)
    setElementRotation(peds[player],rx,ry,rz)
    setPedAnimation( peds[player], "ped", "WOMAN_runpanic")
    timers[player] = setTimer(setrot_timer,1000,0,peds[player],player)
end
function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end
function setrot_timer(ped,player)
    local ox,oy,oz = getElementPosition(player)
    local px,py,pz = getElementPosition(ped)
    local result = getDistanceBetweenPoints3D(ox,oy,oz,px,py,pz)
    local rx,ry,rz = getElementRotation(player)
    local prx,pry,prz = getElementRotation(ped)
    if result > 50 then 
        destroy_ped(player)
        return
    end
    local srx,sry,srz = findRotation3D(px,py,pz,ox,oy,oz)
    setElementRotation(ped,srx,sry,srz)
end
function ped_wasted()
    destroy_ped(ped_player[source])
end
function player_damage()
    setPedAnimation( peds[source], "ped", "cower")
end
function player_wasted()
    destroy_ped(source)
end
function player_quit()
    destroy_ped(source)
end
function destroy_ped(player)
    if isTimer(timers[player]) then 
        killTimer(timers[player])
        timers[player] = nil 
    end
    triggerClientEvent("sent_ped_meta",player,false,false)
    removeEventHandler("onMarkerHit",marker[player],marker_join)
    removeEventHandler("onMarkerLeave",marker[player],marker_exit)
    removeEventHandler("onPedWasted",peds[player],ped_wasted)
    removeEventHandler("onPlayerWasted",player,player_wasted)
    removeEventHandler("onPlayerDamage",player,player_damage)
    removeEventHandler("onPlayerQuit",player,player_quit)
    destroyElement(blip[player])
    destroyElement(marker[player])
    ped_player[peds[player]] = nil
    destroyElement(peds[player])
    marker[player] = nil
    blip[player] = nil
    peds[player] = nil
    marker_player[player] = false
end
function create_ped_command(player)
    if peds[player] then 
        destroy_ped(player)
    else
        local x,y,z = getElementPosition(player)
        local _,_,ozz = getElementRotation(player)
        local posVector = Vector3(x,y,z+1)
        local rotVector = Vector3(0,0,ozz)
        local pedMatrix = Matrix(posVector,rotVector)
        local pedPos = posVector+pedMatrix.right*0.5
        local ped = createPed(skin_id,pedPos,ozz)
        peds[player] = ped
        ped_player[ped] = player
        triggerClientEvent("sent_ped_meta",player,ped,true)
        blip[player] = createBlip(x, y, z, 21, 2, 255, 0, 0, 255, 0, 99999.0, player)
        marker[player] = createMarker(x, y, z, "cylinder", 4, 0, 0, 0,0, player)
        marker_player[marker[player]] = player
        attachElements(marker[player], ped)
        attachElements(blip[player], ped)
        addEventHandler("onMarkerHit",marker[player],marker_join)
        addEventHandler("onMarkerLeave",marker[player],marker_exit)
        addEventHandler("onPedWasted",ped,ped_wasted)
        addEventHandler("onPlayerWasted",player,player_wasted)
        addEventHandler("onPlayerDamage",player,player_damage)
        addEventHandler("onPlayerQuit",player,player_quit)
    end
end

addCommandHandler(command,create_ped_command)



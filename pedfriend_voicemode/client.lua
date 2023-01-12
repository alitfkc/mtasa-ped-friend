ped = false
text = ""
timer = false
sound = false
function create_ped_event(pedt,state)
    if state then 
        create_ped(pedt)
    else
        destroyped()
    end
end

function create_ped(pedt)
    ped = pedt
    setPedVoice(ped,"PED_TYPE_GEN","VOICE_GEN_WMOTR1")
    addEventHandler("onClientVehicleEnter",getRootElement(),vehicle_enter)
    addEventHandler("onClientVehicleExit",getRootElement(),vehicle_exit)
    addCommandHandler(talk_cmd,talk_ped)
end
function destroyped()
    ped = false
    removeEventHandler("onClientVehicleEnter",getRootElement(),vehicle_enter)
    removeEventHandler("onClientVehicleExit",getRootElement(),vehicle_exit)
    removeCommandHandler(talk_cmd,talk_ped)
end
addEvent("sent_ped_meta",true)
addEventHandler("sent_ped_meta",localPlayer,create_ped_event)

function talk_ped(cmd,...)
    local msg = string.lower(...)
    for k,v in pairs(messages) do 
        if string.lower(k) == msg then 
            if isTimer(timer) then 
                killTimer(timer)
            end
            timer = setTimer(function() text = "" render_openclose(false) end,5000,1)
            text = v
            if isElement(sound) then 
                stopSound(sound)
                sound = false 
            end
            sound = playSound("http://translate.google.com/translate_tts?tl="..voice_lang.."&q="..text.."&client=tw-ob", false)
            render_openclose(true)
            break 
        end
    end
end
local state = false
function render_openclose(new_state)
    if state and new_state == false then 
        state = false
        removeEventHandler("onClientRender",root,show_info_veh)
    elseif state == false and new_state == true then
        state = true
        addEventHandler("onClientRender",root,show_info_veh)
    end
end

function vehicle_enter(p) --enter_exit
    if p ~= localPlayer then return end
    local a= setPedEnterVehicle(ped,source,true)
    if isTimer(timer) then 
        killTimer(timer)
    end
    timer = setTimer(function() text = "" render_openclose(false)  end,5000,1)
    text = messages["car_join"]
    render_openclose(true)
end
function vehicle_exit(p) --enter_exit
    if p ~= localPlayer then return end
    local a= setPedExitVehicle(ped)
end
function show_info_veh()
    local cx, cy, cz = getCameraMatrix();
    local screenW,screenH=guiGetScreenSize()
    local x, y, z = getElementPosition( ped )
    z=z+0.8
    if isLineOfSightClear( cx, cy, cz, x, y, z, false, false, false, false, false, false, false, ped) then
        local dist = getDistanceBetweenPoints3D( cx, cy, cz, x, y, z )
        if dist <= 16 then
            local px, py = getScreenFromWorldPosition( x, y, z + 0.6, 0.06 )
            if px then
                dxDrawText(text, px, (py + screenW/38)+60, px, py, tocolor( 255, 255, 255, 255 ), 1.25, 'default-bold', 'center', 'center', false, false )
            end
        end
    end
end


addEventHandler('onClientResourceStart',resourceRoot,function () 
txd = engineLoadTXD( 'skin/skin.txd' ) 
engineImportTXD( txd, skin_id ) 
dff = engineLoadDFF('skin/skin.dff', skin_id) 
engineReplaceModel( dff, skin_id )
end)

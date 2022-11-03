scope CameraCommands initializer onInit

  private function OnPlayerChat takes nothing returns nothing
    local real zoomDistance = 0.0
    if CothUtilities_IsStringContains(GetEventPlayerChatString(), "-far", true) then
      call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, 2975, 0.5)
    elseif CothUtilities_IsStringContains(GetEventPlayerChatString(), "-medium", true) then
      call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, 2300, 0.5)
    elseif CothUtilities_IsStringContains(GetEventPlayerChatString(), "-close", true) then
      call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, 1650, 0.5)
    elseif CothUtilities_IsStringContains(GetEventPlayerChatString(), "-zoom ", true) then
      set zoomDistance = S2R( SubString( GetEventPlayerChatString(), /*
      */ CothUtilities_GetLastIndexOf( GetEventPlayerChatString(), "-zoom ", true ), /*
      */ CothUtilities_GetLastIndexOf( GetEventPlayerChatString(), "-zoom ", true ) + 4 ) )
      call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, zoomDistance, 0.5)
    endif
  endfunction

  private function onInit takes nothing returns nothing
    local playerEvents onPlayerChatEvent = playerEvents.create()
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-far", true)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-medium", true)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-close", true)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-zoom", false)
    call onPlayerChatEvent.addAction(function OnPlayerChat)
  endfunction
endscope
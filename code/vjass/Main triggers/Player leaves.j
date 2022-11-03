scope PlayerLeaves initializer onInit

  private function onLeave takes nothing returns nothing
    call ShareEverythingWithTeam(GetTriggerPlayer())
    call ForceRemovePlayer(alliancePlayers, GetTriggerPlayer())
    call ForceRemovePlayer(hordePlayers, GetTriggerPlayer())
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, /*
    */ CothUtilities_PlayerColorToColorTag(GetPlayerColor(GetTriggerPlayer())) + /*
    */ GetPlayerName(GetTriggerPlayer()) + /*
    */ " покинул игру")
  endfunction

  private function onInit takes nothing returns nothing
    local playerEvents onPlayerLeaveEvent = playerEvents.create()
    call onPlayerLeaveEvent.registerAnyPlayerEventLeave()
    call onPlayerLeaveEvent.addAction(function onLeave)
  endfunction
endscope

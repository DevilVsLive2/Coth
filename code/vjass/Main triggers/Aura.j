scope HordeAndAllianceAura initializer onInit

  globals
    private integer levelOfAura = 0
    private constant unit auraAlliance = CreateUnit(Player(0), 'n012', 0, 0, 0)
    private constant unit auraHorde = CreateUnit(Player(4), 'n013', 0, 0, 0)
  endglobals

  private function AuraUpgrade takes nothing returns nothing
    set levelOfAura = levelOfAura + 1
    if levelOfAura == 1 then
      call UnitRemoveAbility(auraAlliance, 'Apiv')
      call UnitRemoveAbility(auraHorde, 'Apiv')
    else
      call SetUnitAbilityLevel(auraAlliance, 'A0C8', levelOfAura)
      call SetUnitAbilityLevel(auraAlliance, 'A0C9', levelOfAura)
      call SetUnitAbilityLevel(auraHorde, 'A0CA', levelOfAura)
      call SetUnitAbilityLevel(auraHorde, 'A0CB', levelOfAura)
    endif
    if levelOfAura == 4 then
      call DestroyTimer(GetExpiredTimer())
    else
      call TimerStart(GetExpiredTimer(), 600, false, function AuraUpgrade)
    endif
  endfunction

  private function onInit takes nothing returns nothing
    call TimerStart(CreateTimer(), 900, false, function AuraUpgrade)
  endfunction
endscope
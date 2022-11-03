scope maxUpgrades initializer onInit

  globals
    //Исследования и улучшения
    constant integer maxArmorHumans = 'R00X'
    constant integer maxArmorHorde = 'R00T'
    constant integer maxArmorGnome = 'R003'
    constant integer maxDamageHumans = 'R00Y'
    constant integer maxDamageHorde = 'R00U'
    constant integer maxDamageGnome = 'R005'
    constant integer maxRangeDamage = 'R00Z'

    constant integer armor = 'R00B'
    constant integer armorGnome = 'R002'
    constant integer armorHorde = 'Roar'
    constant integer damage = 'R00G'
    constant integer damageGnome = 'R004'
    constant integer damageHorde = 'Rome'
    constant integer rangeDamage = 'R000'
  endglobals

  private function onResearch takes nothing returns nothing
    local integer research = GetResearched()
    if research == maxArmorHumans or research == maxArmorHorde or research == maxArmorGnome then
      call SetPlayerTechResearched(GetTriggerPlayer(), armor, 3)
      call SetPlayerTechResearched(GetTriggerPlayer(), armorGnome, 3)
      call SetPlayerTechResearched(GetTriggerPlayer(), armorHorde, 3)
    elseif research == maxDamageHumans or research == maxDamageGnome or research == maxDamageHorde then
      call SetPlayerTechResearched(GetTriggerPlayer(), damage, 3)
      call SetPlayerTechResearched(GetTriggerPlayer(), damageGnome, 3)
      call SetPlayerTechResearched(GetTriggerPlayer(), damageHorde, 3)
    elseif research == maxRangeDamage then
      call SetPlayerTechResearched(GetTriggerPlayer(), rangeDamage, 3)
    elseif research == armor or research == armorGnome or research == armorHorde then
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxArmorHumans, 0)
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxArmorGnome, 0)
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxArmorHorde, 0)
    elseif research == damage or research == damageGnome or research == damageHorde then
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxDamageHumans, 0)
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxDamageGnome, 0)
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxDamageHorde, 0)
    elseif research == rangeDamage then
      call SetPlayerTechMaxAllowed(GetTriggerPlayer(), maxRangeDamage, 0)
    endif
  endfunction

  private function onInit takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
    call TriggerAddAction(t, function onResearch)
  endfunction
endscope
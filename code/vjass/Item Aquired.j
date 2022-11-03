library itemAquired initializer onInit

  globals
    private hashtable ItemDataHashtable = InitHashtable()
    private integer countOfFreeSlots = 0
  endglobals

  private function GetItemIndexEx takes integer whichItemID, unit whichUnit returns integer
    local integer i = 0
    loop
      if GetItemTypeId(UnitItemInSlot(whichUnit, i)) == whichItemID and not LoadBoolean(ItemDataHashtable, GetHandleId(UnitItemInSlot(whichUnit, i)), 0) then
        return i
      endif
      set i = i + 1
      exitwhen i > 5
    endloop
    return -1
  endfunction

  private function UnitHasItemOfTypeEx takes integer whichItemID, unit whichUnit returns boolean
    return GetItemIndexEx(whichItemID, whichUnit) != -1
  endfunction

  private function IsItemBasic takes integer itemID returns boolean
    local integer i = 0
    loop
      if LoadInteger(ItemDataHashtable, itemID, i) != 0 then
        return false
      endif
      set i = i + 1
      exitwhen i > 5
    endloop
    return true
  endfunction

  private function GetItemPrice takes integer itemID, unit itemOwner returns integer
    local integer itemPrice = LoadInteger(ItemDataHashtable, itemID, 6)
    local integer i = 0
    local integer requiredItemID = 0

    if itemID == 0 then
      return 0
    endif
    
    if UnitHasItemOfTypeEx(itemID, itemOwner) then
      call SaveBoolean(ItemDataHashtable, GetHandleId(UnitItemInSlot(itemOwner, GetItemIndexEx(itemID, itemOwner))), 0, true)
      set countOfFreeSlots = countOfFreeSlots + 1
      return 0
    endif

    if IsItemBasic(itemID) then
      return itemPrice
    endif

    loop
      set requiredItemID = LoadInteger(ItemDataHashtable, itemID, i)
      set itemPrice = itemPrice + GetItemPrice(requiredItemID, itemOwner)
      set i = i + 1
      exitwhen ( i > 5 ) or ( requiredItemID == 0 )
    endloop
    
    return itemPrice
  endfunction

  private function GetHeroFreeSlots takes unit whichHero returns integer
    local integer i = 0
    local integer numberOfFreeSlots = 0
    loop
      if UnitItemInSlot(whichHero, i) == null then
        set numberOfFreeSlots = numberOfFreeSlots + 1
      endif
      set i = i + 1
      exitwhen i > 5
    endloop
    return numberOfFreeSlots
  endfunction

  private function IsItemHasTwoVariants takes integer itemID returns boolean
    return LoadInteger(ItemDataHashtable, itemID, 8) != 0
  endfunction

  private function UnitBuyItem takes nothing returns nothing
    local unit buyer = GetBuyingUnit()
    local integer soldItem = GetItemTypeId(GetSoldItem())
    local player buyerOwner = GetOwningPlayer(buyer)
    local integer i = 0
    local integer requiredItemID = 0
    local integer itemPrice = LoadInteger(ItemDataHashtable, soldItem, 6)
    local item addedItem = null
    local item it = null
    set countOfFreeSlots = 0
    if IsItemBasic(soldItem) then
      call SetItemPlayer(GetSoldItem(), buyerOwner, false)
      return
    endif
    loop
      set requiredItemID = LoadInteger(ItemDataHashtable, soldItem, i)
      set itemPrice = itemPrice + GetItemPrice(requiredItemID, buyer)
      set i = i + 1
      exitwhen ( i > 5 ) or ( requiredItemID == 0 ) 
    endloop
    set countOfFreeSlots = countOfFreeSlots + GetHeroFreeSlots(buyer)
    debug call BJDebugMsg("Item " GetItemName(GetSoldItem()) + " costs: " + I2S(itemPrice))
    debug call BJDebugMsg("Free slots: " + I2S(countOfFreeSlots))
    if countOfFreeSlots == 0 then
      call DisplayTimedTextToPlayer(buyerOwner, 0, 0, 15, "У вас заполнен инвентарь!")
      set i = 0
      loop
        call RemoveSavedBoolean(ItemDataHashtable, GetHandleId(UnitItemInSlot(buyer, i)), 0)
        set i = i + 1
        exitwhen i > 5
      endloop
      return
    endif
    if GetPlayerState(buyerOwner, PLAYER_STATE_RESOURCE_GOLD) >= itemPrice then
      call SetPlayerState(buyerOwner, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(buyerOwner, PLAYER_STATE_RESOURCE_GOLD) - itemPrice)
      set i = 0
      loop
        set it = UnitItemInSlot(buyer, i)
        if LoadBoolean(ItemDataHashtable, GetHandleId(it), 0) then
          call FlushChildHashtable(ItemDataHashtable, GetHandleId(it))
          call RemoveItem(it)
          set it = null
        endif
        set i = i + 1
        exitwhen i > 5
      endloop
      if IsItemHasTwoVariants(soldItem) then
        if IsUnitType(buyer, UNIT_TYPE_RANGED_ATTACKER) then
          set addedItem = UnitAddItemById(buyer, LoadInteger(ItemDataHashtable, soldItem, 8))
        else
          set addedItem = UnitAddItemById(buyer, LoadInteger(ItemDataHashtable, soldItem, 7))
        endif
      else
        set addedItem = UnitAddItemById(buyer, LoadInteger(ItemDataHashtable, soldItem, 7))
      endif
      call SetItemPlayer(addedItem, buyerOwner, false)
      set addedItem = null
      return
    endif
    set i = 0
    loop
      call RemoveSavedBoolean(ItemDataHashtable, GetHandleId(UnitItemInSlot(buyer, i)), 0)
      set i = i + 1
      exitwhen i > 5
    endloop
    call DisplayTimedTextToPlayer(buyerOwner, 0, 0, 15, "Вам не хватает " + I2S( itemPrice - GetPlayerState(buyerOwner, PLAYER_STATE_RESOURCE_GOLD) ) + " очков предметов.")
  endfunction

  private function CreateItemWithOneRequirements takes integer itemID, integer itemInInventory, integer itemPrice, integer itemFirstRequirement returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 6, itemPrice)
  endfunction

  private function CreateItemWithTwoRequirements takes integer itemID, integer itemInInventory, integer itemPrice, integer itemFirstRequirement, integer itemSecondRequirement returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 6, itemPrice)
  endfunction

  private function CreateItemWithThreeRequirements takes integer itemID, integer itemInInventory, integer itemPrice, integer itemFirstRequirement, integer itemSecondRequirement, integer itemThirdRequirement returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 6, itemPrice)
  endfunction

  private function CreateItemWithFourRequirements takes integer itemID, integer itemInInventory, integer itemPrice, integer itemFirstRequirement, integer itemSecondRequirement, integer itemThirdRequirement, integer itemFourthRequirement returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 3, itemFourthRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 1, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 2, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 3, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemInInventory, 6, itemPrice)
  endfunction

  private function CreateItemWithFiveRequirements takes integer itemID, integer itemInInventory, integer itemPrice, integer itemFirstRequirement, integer itemSecondRequirement, integer itemThirdRequirement, integer itemFourthRequirement, integer itemFivethRequirement returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 3, itemFourthRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 4, itemFivethRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 3, itemFourthRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 4, itemFivethRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 6, itemPrice)
  endfunction

  private function CreateItemWithSixRequirements takes integer itemID, integer itemInInventory, integer itemPrice, integer itemFirstRequirement, integer itemSecondRequirement, integer itemThirdRequirement, integer itemFourthRequirement, integer itemFivethRequirement, integer itemSixthRequirement returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemInInventory)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
    call SaveInteger(ItemDataHashtable, itemID, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 3, itemFourthRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 4, itemFivethRequirement)
    call SaveInteger(ItemDataHashtable, itemID, 5, itemSixthRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 0, itemFirstRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 1, itemSecondRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 2, itemThirdRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 3, itemFourthRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 4, itemFivethRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 5, itemSixthRequirement)
    call SaveInteger(ItemDataHashtable, itemInInventory, 6, itemPrice)
  endfunction

  private function CreateSimpleItem takes integer itemID, integer itemPrice returns nothing
    call SaveInteger(ItemDataHashtable, itemID, 7, itemID)
    call SaveInteger(ItemDataHashtable, itemID, 6, itemPrice)
  endfunction

  private function onInit takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM)
    call TriggerAddAction(t, function UnitBuyItem)
    call CreateSimpleItem(scimitar, 775)
    call CreateSimpleItem(falchion, 875)
    call CreateSimpleItem(hammer, 950)
    call CreateSimpleItem(clawsOfAttack, 325)
    call CreateSimpleItem(claymore, 1700)
    call CreateSimpleItem(mace, 925)
    call CreateSimpleItem(gauntletsOfOgre, 325)
    call CreateSimpleItem(bowOfQuelThalas, 1000)
    call CreateSimpleItem(greatSword, 2400)
    call CreateSimpleItem(halberd, 900)
    call CreateSimpleItem(axeOfWar, 1000)

    call CreateSimpleItem(ringOfProtection, 225)
    call CreateSimpleItem(spikedHelm, 820)
    call CreateSimpleItem(cloakOfEvasion, 650)
    call CreateSimpleItem(glovesOfAttackSpeed, 500)
    call CreateSimpleItem(woodenShield, 500)
    call CreateSimpleItem(battleHelm, 875)
    call CreateSimpleItem(robeOfTheMagi, 650)
    call CreateSimpleItem(elvenBoots, 350)
    call CreateSimpleItem(bronzeShield, 850)
    call CreateSimpleItem(chestPlate, 1000)
    call CreateSimpleItem(beltOfGiant, 650)

    call CreateSimpleItem(ringOfRegeneration, 390)
    call CreateSimpleItem(periartOfVitality, 475)
    call CreateSimpleItem(starWand, 325)
    call CreateSimpleItem(circletOfNobility, 175)
    call CreateSimpleItem(amuletOfHealth, 600)
    call CreateSimpleItem(sobiMask, 400)
    call CreateSimpleItem(pedantOfMana, 450)
    call CreateSimpleItem(medallionOfCourage, 1000)
    call CreateSimpleItem(cursedBones, 975)
    call CreateSimpleItem(enchantedSkull, 600)
    call CreateSimpleItem(mageStave, 1000)

    call CreateItemWithTwoRequirements(skullBladeShop, skullBladeInventory, 275,  mace, enchantedSkull)
    call CreateItemWithTwoRequirements(assasinsBladeShop, assasinsBladeInventory, 275, clawsOfAttack, circletOfNobility)
    call CreateItemWithTwoRequirements(repeaterCrossbowShop, repeaterCrossbowInventory, 275, clawsOfAttack, cloakOfEvasion)
    call CreateItemWithTwoRequirements(ogreMalletShop, ogreMalletInventory, 275, beltOfGiant, gauntletsOfOgre)
    call CreateItemWithTwoRequirements(argentSpearShop, argentSpearInventory, 275, halberd, scimitar)
    call CreateItemWithTwoRequirements(veteransBladeShop, veteransBladeInventory, 550, falchion, ringOfProtection)
    call CreateItemWithTwoRequirements(dwarvenAxeShop, dwarvenAxeInventory, 275, halberd, beltOfGiant)
    call CreateItemWithTwoRequirements(silverBladeShop, silverBladeInventory, 275, scimitar, falchion)

    call CreateItemWithTwoRequirements(gauntletsOfPowerShop, gauntletsOfPowerInventory, 275, glovesOfAttackSpeed, medallionOfCourage)
    call CreateItemWithTwoRequirements(runedGauntletsShop, runedGauntletsInventory, 275, gauntletsOfOgre, circletOfNobility)
    call CreateItemWithTwoRequirements(swiftShieldShop, swiftShieldInventory, 275, glovesOfAttackSpeed, woodenShield)
    call CreateItemWithTwoRequirements(slippersOfAgillityShop, slippersOfAgillityInventory, 275, cloakOfEvasion, elvenBoots)
    call CreateItemWithTwoRequirements(runedBracersShop, runedBracersInventory, 275, amuletOfHealth, ringOfProtection)
    call CreateItemWithTwoRequirements(helmOfEnergyShop, helmOfEnergyInventory, 275, battleHelm, pedantOfMana)
    call CreateItemWithTwoRequirements(platedBootsShop, platedBootsInventory, 275, elvenBoots, ringOfRegeneration)
    call CreateItemWithTwoRequirements(ringOfTitusShop, ringOfTitusInventory, 275, periartOfVitality, ringOfProtection)
    call CreateItemWithTwoRequirements(greatShieldShop, greatShieldInventory, 325, woodenShield, ringOfProtection)

    call CreateItemWithTwoRequirements(shamanClawsShop, shamanClawsInventory, 275, clawsOfAttack, sobiMask)
    call CreateItemWithTwoRequirements(mantleOfIntelligenceShop, mantleOfIntelligenceInventory, 275, starWand, circletOfNobility)
    call CreateItemWithTwoRequirements(khadgarGemShop, khadgarGemInventory, 275, amuletOfHealth, periartOfVitality)
    call CreateItemWithTwoRequirements(frozenShardShop, frozenShardInventory, 275, sobiMask, ringOfRegeneration)
    call CreateItemWithTwoRequirements(rodOfNecromancyShop, rodOfNecromancyInventory, 275, starWand, enchantedSkull)
    call CreateItemWithTwoRequirements(manaBladeShop, manaBladeInventory, 275, robeOfTheMagi, scimitar)
    call CreateItemWithTwoRequirements(crystallBallShop, crystallBallInventory, 275, robeOfTheMagi, enchantedSkull)

    call CreateItemWithTwoRequirements(corruptionEdgeShop, corruptionEdgeInventory, 600, claymore, skullBladeInventory)
    call CreateItemWithTwoRequirements(liberatorsBladeShop, liberatorsBladeInventory, 700, cursedBones, silverBladeInventory)
    call CreateItemWithThreeRequirements(bladesOfAgonyShop, bladesOfAgonyInventory, 730, claymore, glovesOfAttackSpeed, assasinsBladeInventory)
    call CreateItemWithTwoRequirements(fillingRifleShop, fillingRifleInventory, 700, argentSpearInventory, crystallBallInventory)
    call CreateItemWithTwoRequirements(thunderfuryShop, thunderfuryInventory, 850, greatSword, veteransBladeInventory)
    call CreateItemWithTwoRequirements(executionerCleaverShop, executionerCleaverInventory, 700, claymore, dwarvenAxeInventory)
    call CreateItemWithTwoRequirements(obsidianSpearShop, obsidianSpearInventory, 1075, mace, argentSpearInventory)
    call CreateItemWithTwoRequirements(venomstrikeShop, venomstrikeInventory, 1200, falchion, skullBladeInventory)
    call CreateItemWithTwoRequirements(bronzeSwordShop, bronzeSwordInventory, 675, greatSword, silverBladeInventory)
    call CreateItemWithThreeRequirements(sycophantShop, sycophantInventory, 700, hammer, cursedBones, skullBladeInventory)
    call CreateItemWithTwoRequirements(duelantsBladeShop, duelantsBladeInventory, 700, claymore, veteransBladeInventory)

    call CreateItemWithTwoRequirements(breastPlateOfTheLightbringerShop, breastPlateOfTheLightbringerInventory, 1200, chestPlate, runedBracersInventory)
    call CreateItemWithTwoRequirements(bronzeGreavesShop, bronzeGreavesInventory, 1035, bronzeShield, platedBootsInventory)
    call CreateItemWithTwoRequirements(grimWardShop, grimWardInventory, 730, cursedBones, swiftShieldInventory)
    call CreateItemWithThreeRequirements(steelShieldShop, steelShieldInventory, 850, battleHelm, periartOfVitality, greatShieldInventory)
    call CreateItemWithThreeRequirements(dragonscaleSheathShop, dragonscaleSheathInventory, 1030, spikedHelm, ringOfProtection, runedBracersInventory)
    call CreateItemWithTwoRequirements(soulSlippersShop, soulSlippersInventory, 620, frozenShardInventory, platedBootsInventory)
    call CreateItemWithTwoRequirements(bastionOfPurityShop, bastionOfPurityInventory, 900, bronzeShield, runedBracersInventory)
    call CreateItemWithThreeRequirements(ringOfShieldsWallShop, ringOfShieldsWallInventory, 925, circletOfNobility, medallionOfCourage, greatShieldInventory)
    call CreateItemWithThreeRequirements(stonepathChestguardShop, stonepathChestguardInventory, 650, battleHelm, chestPlate, ringOfTitusInventory)
    call CreateItemWithTwoRequirements(essenceOfAszuneShop, essenceOfAszuneInventory, 730, ringOfTitusInventory, khadgarGemInventory)
    call CreateItemWithThreeRequirements(glacialShieldShop, glacialShieldInventory, 730, ringOfProtection, bronzeShield, frozenShardInventory)

    call CreateItemWithTwoRequirements(arcaneWonderShop, arcaneWonderInventory, 600, helmOfEnergyInventory, khadgarGemInventory)
    call CreateItemWithTwoRequirements(battlehirstHelmShop, battlehirstHelmInventory, 730, spikedHelm, gauntletsOfPowerInventory)
    call CreateItemWithThreeRequirements(aegisGlovesShop, aegisGlovesInventory, 730, gauntletsOfOgre, starWand, gauntletsOfPowerInventory)
    call CreateItemWithThreeRequirements(wisdomCarverShop, wisdomCarverInventory, 975, falchion, robeOfTheMagi, shamanClawsInventory)
    call CreateItemWithThreeRequirements(starlightsShop, starlightsInventory, 600, robeOfTheMagi, beltOfGiant, slippersOfAgillityInventory)
    call CreateItemWithThreeRequirements(journeysEndShop, journeysEndInventory, 730, sobiMask, claymore, manaBladeInventory)

    call CreateItemWithThreeRequirements(windStaveShop, windStaveInventory, 730, mageStave, sobiMask, mantleOfIntelligenceInventory)
    call CreateItemWithThreeRequirements(deathEdgeShop, deathEdgeInventory, 730, mageStave, enchantedSkull, rodOfNecromancyInventory)
    call CreateItemWithThreeRequirements(radiantSaviorShop, radiantSaviorInventory, 1025, robeOfTheMagi, bronzeShield, mantleOfIntelligenceInventory)
    call CreateItemWithThreeRequirements(lightningStaveShop, lightningStaveInventory, 730, pedantOfMana, starWand, manaBladeInventory)
    call CreateItemWithTwoRequirements(urnShop, urnInventory, 730, medallionOfCourage, rodOfNecromancyInventory)
    call CreateItemWithThreeRequirements(wandOfTheWaywardShop, wandOfTheWaywardInventory, 730, mageStave, elvenBoots, crystallBallInventory)
    call CreateItemWithTwoRequirements(talismanOfTheWildShop, talismanOfTheWildInventory, 730, medallionOfCourage, rodOfNecromancyInventory)

    call CreateItemWithThreeRequirements(amaniThrowAxeShop, amaniThrowAxeInventory, 1250, clawsOfAttack, scimitar, repeaterCrossbowInventory)
    call CreateItemWithThreeRequirements(soulRingShop, soulRingInventory, 730, ringOfRegeneration, bowOfQuelThalas, shamanClawsInventory)
    call CreateItemWithThreeRequirements(fluteOfAccuranceShop, fluteOfAccuranceInventory, 1275, glovesOfAttackSpeed, cloakOfEvasion, repeaterCrossbowInventory)
    call CreateItemWithThreeRequirements(bloodmoonPlateShop, bloodmoonPlateInventory, 700, cloakOfEvasion, chestPlate, assasinsBladeInventory)
    call CreateItemWithThreeRequirements(windrunnerBowShop, windrunnerBowInventory, 625, bowOfQuelThalas, bowOfQuelThalas, slippersOfAgillityInventory)
    call CreateItemWithThreeRequirements(huntersRobeShop, huntersRobeInventory, 650, periartOfVitality, bowOfQuelThalas, swiftShieldInventory)

    call CreateItemWithTwoRequirements(royalHammerShop, royalHammerInventoryForMelee, 800, hammer, ogreMalletInventory)
    call SaveInteger(ItemDataHashtable, royalHammerShop, 8, royalHammerInventoryForRange)
    call CreateItemWithThreeRequirements(sunscaleHelmShop, sunscaleHelmInventory, 1030, battleHelm, beltOfGiant, runedGauntletsInventory)
    call CreateItemWithTwoRequirements(warsongDrumesShop, warsongDrumesInventory, 1250, axeOfWar, ogreMalletInventory)
    call CreateItemWithThreeRequirements(ogreskullShop, ogreskullInventory, 850, beltOfGiant, ringOfRegeneration, helmOfEnergyInventory)
    call CreateItemWithTwoRequirements(axeOfBlackrockShop, axeOfBlackrockInventory, 900, axeOfWar, dwarvenAxeInventory)
    call CreateItemWithThreeRequirements(demonbonesBulwarkShop, demonbonesBulwarkInventory, 825, chestPlate, axeOfWar, runedGauntletsInventory)
  endfunction
endlibrary

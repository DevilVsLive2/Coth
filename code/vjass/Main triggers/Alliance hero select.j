
scope AllianceHeroSelection initializer onInit
  private function onInit takes nothing returns nothing
    local trigger onHeroSelect = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(onHeroSelect, EVENT_PLAYER_UNIT_TRAIN_FINISH)
    call TriggerAddCondition(onHeroSelect, Filter(IsTrainedUnitTypeAHero))
  endfunction
endscope

/*
//! zinc
  library AllianceHeroSelection requires CothUtilities {

    function RedHeroSelect ()  -> nothing {
      SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function BlueHeroSelect ()  -> nothing {
      if (GetTrainedUnitType() == Khadgar) SetPlayerHandicapXP(GetTriggerPlayer(), 0.92);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function TealHeroSelect ()  -> nothing {
      unit trainedUnit = GetTrainedUnit();
      if (GetTrainedUnitType() == Derek) SetPlayerHandicapXP(GetTriggerPlayer(), 0.92);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(trainedUnit), trainedUnit, EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function PurpleHeroSelect ()  -> nothing {
      if (GetTrainedUnitType() == Rhonin) SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.92);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function OrangeHeroSelect ()  -> nothing {
      if (GetTrainedUnitType() == Brann || GetTrainedUnitType() == Gelbin) SetPlayerHandicap(GetTriggerPlayer(), 0.92);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function GreenHeroSelect ()  -> nothing {
      if (GetTrainedUnitType() == LorThermar) SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.92);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }
    
    function PinkHeroSelect ()  -> nothing {
      if (GetTrainedUnitType() == Arugal) SetPlayerHandicapXP(GetTriggerPlayer(), 0.92);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function GrayHeroSelect ()  -> nothing {
      if (GetTrainedUnitType() == AlonSUS) SetPlayerHandicapXP(GetTriggerPlayer(), 0.92);
      else SetPlayerHandicapXP(GetTriggerPlayer(), 0.99);
      TriggerRegisterUnitEvent(GetHeroTriggerOnDamage(GetTrainedUnit()), GetTrainedUnit(), EVENT_UNIT_DAMAGED);
      DestroyTrigger(GetTriggeringTrigger());
    }

    function AntiAbuseXPFilter ()  -> boolean {
      return IsUnitAlly(GetEnteringUnit(), Player(0)) && IsUnitType(GetEnteringUnit(), UNIT_TYPE_HERO);
    }

    function AntiAbuseXPAdd ()  -> nothing {
      SetPlayerHandicapXP(GetOwningPlayer(GetEnteringUnit()), 0);
    }

    function AntiAbuseXPRemove ()  -> nothing {
      SetPlayerHandicapXP(GetOwningPlayer(GetEnteringUnit()), 99);
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      rect BattleZone = Rect(3648, -15872, 7360, -12640);
      region BattleZoneRegion = CreateRegion();
      RegionAddRect(BattleZoneRegion, BattleZone);
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function RedHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(1), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function BlueHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(2), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function TealHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(3), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function PurpleHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(5), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function OrangeHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(6), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function GreenHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(7), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function PinkHeroSelect);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(8), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerAddCondition(t, Filter(function IsTrainedUnitAHero));
      TriggerAddAction(t, function GrayHeroSelect);

      t = CreateTrigger();
      TriggerRegisterEnterRegion(t, BattleZoneRegion, null);
      TriggerAddCondition(t,  Filter(function AntiAbuseXPFilter));
      t = CreateTrigger();
      TriggerRegisterLeaveRegion(t, BattleZoneRegion, null);
      TriggerAddCondition(t, Filter(function AntiAbuseXPFilter));
      TriggerAddAction(t, function AntiAbuseXPRemove);


    }
  }
//! endzinc
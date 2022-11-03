//! zinc
  library HeroSelection requires CothUtilities {
    public integer CountOfTrainedHeroes = 0;
    trigger HeroStart;
    trigger HeroCancel;
    
    function HeroLimit ()  -> nothing {
      if (! IsHeroUnitId(GetTrainedUnitType())) return;
      SetPlayerTechMaxAllowed(Player(9), GetTrainedUnitType(), 0);
      SetPlayerTechMaxAllowed(Player(10), GetTrainedUnitType(), 0);
      SetPlayerTechMaxAllowed(Player(11), GetTrainedUnitType(), 0);
    }

    function HeroUnlimit ()  -> nothing {
      if (! IsHeroUnitId(GetTrainedUnitType())) return;
      SetPlayerTechMaxAllowed(Player(9), GetTrainedUnitType(), 1);
      SetPlayerTechMaxAllowed(Player(10), GetTrainedUnitType(), 1);
      SetPlayerTechMaxAllowed(Player(11), GetTrainedUnitType(), 1);
    }

    function CountOfHeroes ()  -> nothing {
      CountOfTrainedHeroes += 1;
      if (CountOfTrainedHeroes >= 3) {
        DestroyTrigger(HeroCancel);
        DestroyTrigger(HeroStart);
        DestroyTrigger(GetTriggeringTrigger());
      }
    }

    private function onInit ()  -> nothing {
      trigger t;
      HeroStart = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(HeroStart, Player(9), EVENT_PLAYER_UNIT_TRAIN_START, null);
      TriggerRegisterPlayerUnitEvent(HeroStart, Player(10), EVENT_PLAYER_UNIT_TRAIN_START, null);
      TriggerRegisterPlayerUnitEvent(HeroStart, Player(11), EVENT_PLAYER_UNIT_TRAIN_START, null);
      TriggerAddAction(HeroStart, function HeroLimit);

      HeroCancel = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(HeroCancel, Player(9), EVENT_PLAYER_UNIT_TRAIN_CANCEL, null);
      TriggerRegisterPlayerUnitEvent(HeroCancel, Player(10), EVENT_PLAYER_UNIT_TRAIN_CANCEL, null);
      TriggerRegisterPlayerUnitEvent(HeroCancel, Player(11), EVENT_PLAYER_UNIT_TRAIN_CANCEL, null);
      TriggerAddAction(HeroCancel, function HeroUnlimit);

      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(9), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerRegisterPlayerUnitEvent(t, Player(10), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);
      TriggerRegisterPlayerUnitEvent(t, Player(11), EVENT_PLAYER_UNIT_TRAIN_FINISH, null);

      TriggerAddAction(t, function CountOfHeroes);
    }
  }
//! endzinc
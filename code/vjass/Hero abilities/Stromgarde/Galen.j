//! zinc
  library GalenAbils requires CothUtilities {

    function RejuvTeal ()  -> nothing {
      unit RejuvUnit = LoadUnitHandle(TimerData, GetHandleId(GetExpiredTimer()), 100);
      integer RejuvIteractionCount = LoadInteger(UnitAbilityData, GetHandleId(RejuvUnit), 102);
      effect RejuvEffectHeal;
      AddUnitLifePercent(RejuvUnit, RejuvIteractionCount + 4);
      if (RejuvIteractionCount == 12) {
        RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(RejuvUnit), 101);
        PauseTimer(GetExpiredTimer());
        DestroyEffect(RejuvEffectHeal);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(RejuvUnit), 101);
        RemoveSavedInteger(UnitAbilityData, GetHandleId(RejuvUnit), 102);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(RejuvUnit), 103);
        RemoveSavedHandle(TimerData, GetHandleId(GetExpiredTimer()), 100);
        DestroyTimer(GetExpiredTimer());
        RejuvUnit = null;
        RejuvEffectHeal = null;
        return;
      } else if (RejuvIteractionCount > 12) {
        DestroyTimer(GetExpiredTimer());
      }
      RejuvIteractionCount += 1;
      SaveInteger(UnitAbilityData, GetHandleId(RejuvUnit), 102, RejuvIteractionCount);
      RejuvUnit = null;
      RejuvEffectHeal = null;
    }

    function RejuvStop ()  -> nothing {
      effect RejuvEffectStart;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Galen) return;
      RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      DestroyEffect(RejuvEffectStart);
      RejuvEffectStart = null;
    }

    function RejuvEffectSpell ()  -> nothing {
      timer RejuvTimer;
      integer RejuvIteractionCount;
      effect RejuvEffectHeal;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Galen) return;
      RejuvTimer = CreateTimer();
      RejuvIteractionCount = 0;

      DestroyEffect( LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100) );
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);

      RejuvEffectHeal = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", GetTriggerUnit(), "overhead");

      SaveEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101, RejuvEffectHeal);
      SaveInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 102, RejuvIteractionCount);
      SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 103, RejuvTimer);

      SaveUnitHandle(TimerData, GetHandleId(RejuvTimer), 100, GetTriggerUnit());

      TimerStart(RejuvTimer, 2, true, function RejuvTeal);
      AddUnitLifePercent(GetTriggerUnit(), 4);
      RejuvTimer = null;
      RejuvEffectHeal = null;
    }

    function DisarmConditions () ->  boolean {
      return (IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit()))) && (!IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)) && (!IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL));
    }

    function DisarmDamage ()  -> nothing {
      UnitDamageTarget(GetTriggerUnit(), GetEnumUnit(), 65 + (GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()) * 65), true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
    }

    function UseAbility ()  -> nothing {
      effect RejuvEffectStart;
      effect RejuvEffectHeal;
      timer RejuvTimer;

      unit TriggerUnit = GetTriggerUnit();
      group DisarmGroup;
      if (GetUnitTypeId(GetTriggerUnit()) != Galen) return;
      
      //Омоложение
      if (GetSpellAbilityId() == 'AEsf') {
        //Жёлтый кружочек
        RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
        //Зелёный кружочек
        RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101);
        //Таймер хила
        RejuvTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 103);

        //Жёлтый кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
        //Зелёный кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101);
        //Число итеракций хила
        RemoveSavedInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 102);
        //Таймер хила
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 103);
        //Хендл юнита, сохранённый в таймере хила
        RemoveSavedHandle(TimerData, GetHandleId(RejuvTimer), 100);


        PauseTimer( RejuvTimer );
        DestroyTimer( RejuvTimer );
        DestroyEffect(RejuvEffectStart);
        DestroyEffect(RejuvEffectHeal);
        
        RejuvEffectStart = AddSpecialEffectTarget("RejuvTarget.mdx", GetTriggerUnit(), "overhead");
        SaveEffectHandle( UnitAbilityData, GetHandleId(GetTriggerUnit()), 100, RejuvEffectStart );
      }
      //Сверкающий Клинок
      if (GetSpellAbilityId() == 'A07I') {
        RemoveSavedInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 104);
        UnitRemoveAbility(GetTriggerUnit(), 'A06Z');
        UnitAddAbility(GetTriggerUnit(), 'A06Z');
        SetUnitAbilityLevel(GetTriggerUnit(), 'A06Z', GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()));
        SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), 'A06Z', false);
        PolledWait(10);
        UnitRemoveAbility(TriggerUnit, 'A06Z');
        UnitRemoveAbility(TriggerUnit, 'B01U');
      }
      //Обезоруживание
      if (GetSpellAbilityId() == 'A0DY') {
        DisarmGroup = CreateGroup();
        GroupEnumUnitsInRangeOfLoc(DisarmGroup, GetUnitLoc(GetSpellTargetUnit()), 180, Condition(function DisarmConditions));
        ForGroup(DisarmGroup, function DisarmDamage);
      }

      RejuvEffectStart = null;
      RejuvEffectHeal = null;
      RejuvTimer = null;
      DestroyGroup(DisarmGroup);
      DisarmGroup = null;
      TriggerUnit = null;
    }

    function GalenDamaged ()  -> nothing {
      effect RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      effect RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101);
      timer RejuvTimer;
      if (RejuvEffectStart != null) {
        DestroyEffect(RejuvEffectStart);
        //Жёлтый кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
        IssueImmediateOrder(GetTriggerUnit(), "stop");
      } else if (RejuvEffectHeal != null) {
        DestroyEffect(RejuvEffectHeal);
        RejuvTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 103);
        //Зелёный кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101);
        //Число итеракций хила
        RemoveSavedInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 102);
        //Таймер хила
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 103);
        //Хендл юнита, сохранённый в таймере хила
        RemoveSavedHandle(TimerData, GetHandleId(RejuvTimer), 100);
        PauseTimer(RejuvTimer);
        DestroyTimer(RejuvTimer);
      }
    }

    function IsAttackerGalen ()  -> boolean {
      return GetUnitTypeId(GetAttacker()) == Galen && IsUnitEnemy(GetTriggerUnit(), GetOwningPlayer(GetAttacker()));
    }

    function RemoveAdditionalAGI ()  -> nothing {
      unit GalenHero = LoadUnitHandle(TimerHashtable, GetHandleId(GetExpiredTimer()), 100);
      integer AdditionalAGI = LoadInteger(TimerHashtable, GetHandleId(GetExpiredTimer()), 100);
      ModifyHeroStat(bj_HEROSTAT_AGI, GalenHero, bj_MODIFYMETHOD_SUB, AdditionalAGI );
      SaveInteger(UnitAbilityData, GetHandleId(GalenHero), 105, LoadInteger(UnitAbilityData, GetHandleId(GalenHero), 105) - AdditionalAGI);
      GalenHero = null;
    }

    function GalenDamaging ()  -> nothing {
      integer CountOfAdditionalAGI;
      timer FuryTimer;
      integer CountOfAttacks;
      //Сверкающий Клинок
      if (UnitHasBuffBJ(GetAttacker(), 'B01U')) {
        CountOfAttacks = LoadInteger(UnitAbilityData, GetHandleId(GetAttacker()), 104);
        CountOfAttacks += 1;
        SaveInteger(UnitAbilityData, GetHandleId(GetAttacker()), 104, CountOfAttacks);
        if (CountOfAttacks >= 5) {
          UnitRemoveAbility(GetAttacker(), 'B01U');
          UnitRemoveAbility(GetAttacker(), 'A06Z');
          RemoveSavedInteger(UnitAbilityData, GetHandleId(GetAttacker()), 104);
        }
      }
      //Ярость
      CountOfAdditionalAGI = LoadInteger(UnitAbilityData, GetHandleId(GetAttacker()), 105);
      if (UnitHasBuffBJ(GetAttacker(), 'B023') && CountOfAdditionalAGI < (2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y')) * 10) {

        FuryTimer = CreateTimer();

        ModifyHeroStat(bj_HEROSTAT_AGI, GetAttacker(), bj_MODIFYMETHOD_ADD, 2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y'));
        SaveInteger(UnitAbilityData, GetHandleId(GetAttacker()), 105, CountOfAdditionalAGI + (2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y')) );
        SaveInteger(TimerHashtable, GetHandleId(FuryTimer), 100, 2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y'));
        SaveUnitHandle(TimerHashtable, GetHandleId(FuryTimer), 100, GetAttacker());
        TimerStart(FuryTimer, 5, false, function RemoveAdditionalAGI);
      }
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      TriggerAddAction(GalenOnDamage, function GalenDamaged);
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_EFFECT, null);
      TriggerAddAction(t, function UseAbility);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_FINISH, null);
      TriggerAddAction(t, function RejuvEffectSpell);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null);
      TriggerAddAction(t, function RejuvStop);
      t = CreateTrigger();
      TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED);
      TriggerAddCondition(t, Filter(function IsAttackerGalen));
      TriggerAddAction(t, function GalenDamaging);
    }
  }
//! endzinc
/*
//! zinc
  library GalenAbils requires CothUtilities {

    integer RejuvIteractionCount = 0;
    timer RejuvTimer = CreateTimer();
    effect RejuvEffectStart = null;
    effect RejuvEffectHeal = null;
    public trigger GalenOnDamage;
    integer CountOfAttacks = 0;

    function RejuvHeal ()  -> nothing {
      AddUnitLifePercent(LoadUnitHandle(RejuvHashtable, GetHandleId(GetExpiredTimer()), 0), RejuvIteractionCount + 4);
      if (RejuvIteractionCount == 12) {
        PauseTimer(GetExpiredTimer());
        DestroyTimer(GetExpiredTimer());
        DestroyEffect(RejuvEffectHeal);
        return;
      } else if (RejuvIteractionCount > 12) {
        //BJDebugMsg("С омоложением красного что-то пошло не так!");
        DestroyTimer(GetExpiredTimer());
      }
      RejuvIteractionCount += 1;
    }

    function RejuvStop ()  -> nothing {
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Galen) return;
      DestroyEffect(RejuvEffectStart);
    }

    function RejuvEffectSpell ()  -> nothing {
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Galen) return;
      RejuvTimer = CreateTimer();
      RejuvIteractionCount = 0;
      RejuvEffectHeal = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", GetTriggerUnit(), "overhead");
      SaveUnitHandle(RejuvHashtable, GetHandleId(RejuvTimer), 0, GetTriggerUnit());
      TimerStart(RejuvTimer, 2, true, function RejuvHeal);
      AddUnitLifePercent(GetTriggerUnit(), 4);
    }

    function DisarmConditions () ->  boolean {
      return (IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit()))) && (!IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE)) && (!IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL));
    }

    function DisarmDamage ()  -> nothing {
      UnitDamageTarget(GetTriggerUnit(), GetEnumUnit(), 65 + (GetUnitAbilityLevel(GetTriggerUnit(), 'A0DY') * 65), true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
    }

    function UseAbility ()  -> nothing {
      unit TriggerUnit;
      group DisarmGroup;
      if (GetUnitTypeId(GetTriggerUnit()) != Galen) return;
      TriggerUnit = GetTriggerUnit();
      
      //Омоложение
      if (GetSpellAbilityId() == 'AEsf') {
        DestroyEffect(RejuvEffectStart);
        DestroyEffect(RejuvEffectHeal);
        RemoveSavedHandle(RejuvHashtable, GetHandleId(RejuvTimer), 0);
        DestroyTimer(RejuvTimer);
        RejuvEffectStart = AddSpecialEffectTarget("RejuvTarget.mdx", GetTriggerUnit(), "overhead");
      }
      //Сверкающий Клинок
      if (GetSpellAbilityId() == 'A07I') {
        CountOfAttacks = 0;
        UnitRemoveAbility(GetTriggerUnit(), 'A06Z');
        UnitAddAbility(GetTriggerUnit(), 'A06Z');
        SetUnitAbilityLevel(GetTriggerUnit(), 'A06Z', GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()));
        SetPlayerAbilityAvailable(Player(0), 'A06Z', false);
        PolledWait(10);
        UnitRemoveAbility(TriggerUnit, 'A06Z');
        UnitRemoveAbility(TriggerUnit, 'B01U');
      }
      //Обезоруживание
      if (GetSpellAbilityId() == 'A0DY') {
        DisarmGroup = CreateGroup();
        GroupEnumUnitsInRangeOfLoc(DisarmGroup, GetUnitLoc(GetSpellTargetUnit()), 180, Condition(function DisarmConditions));
        ForGroup(DisarmGroup, function DisarmDamage);
      }

      DestroyGroup(DisarmGroup);
      DisarmGroup = null;
    }

    function GalenDamaged ()  -> nothing {
      if (RejuvEffectStart != null || RejuvEffectHeal != null) {
        DestroyEffect(RejuvEffectStart);
        DestroyEffect(RejuvEffectHeal);
        IssueImmediateOrder(GetTriggerUnit(), "stop");
      }
      RemoveSavedHandle(RejuvHashtable, GetHandleId(RejuvTimer), 0);
      DestroyTimer(RejuvTimer);
    }

    function IsAttackerGalen ()  -> boolean {
      return (GetUnitTypeId(GetAttacker()) == Galen);
    }

    function RemoveAdditionalAGI ()  -> nothing {
      unit GalenHero = LoadUnitHandle(TimerHashtable, GetHandleId(GetExpiredTimer()), 100);
      integer AdditionalAGI = LoadInteger(TimerHashtable, GetHandleId(GetExpiredTimer()), 100);
      ModifyHeroStat(bj_HEROSTAT_AGI, GalenHero, bj_MODIFYMETHOD_SUB, AdditionalAGI );
      SaveInteger(UnitInfoHashtable, GetHandleId(GalenHero), 100, LoadInteger(UnitInfoHashtable, GetHandleId(GalenHero), 100) - AdditionalAGI);
      GalenHero = null;
    }

    function GalenDamaging ()  -> nothing {
      integer CountOfAdditionalAGI;
      timer t;
      //Сверкающий Клинок
      if (UnitHasBuffBJ(GetAttacker(), 'B01U')) {
        CountOfAttacks += 1;
        if (CountOfAttacks >= 5) {
          UnitRemoveAbility(GetAttacker(), 'B01U');
          UnitRemoveAbility(GetAttacker(), 'A06Z');
        }
      }
      //Ярость
      CountOfAdditionalAGI = LoadInteger(UnitInfoHashtable, GetHandleId(GetAttacker()), 100);
      if (UnitHasBuffBJ(GetAttacker(), 'B023') && CountOfAdditionalAGI < (2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y')) * 10) {
        ModifyHeroStat(bj_HEROSTAT_AGI, GetAttacker(), bj_MODIFYMETHOD_ADD, 2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y'));
        SaveInteger(UnitInfoHashtable, GetHandleId(GetAttacker()), 100, CountOfAdditionalAGI + (2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y')) );
        t = CreateTimer();
        SaveInteger(TimerHashtable, GetHandleId(t), 100, 2 + GetUnitAbilityLevel(GetAttacker(), 'A06Y'));
        SaveUnitHandle(TimerHashtable, GetHandleId(t), 100, GetAttacker());
        TimerStart(t, 3.5, false, function RemoveAdditionalAGI);
      }
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_EFFECT, null);
      TriggerAddAction(t, function UseAbility);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_FINISH, null);
      TriggerAddAction(t, function RejuvEffectSpell);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null);
      TriggerAddAction(t, function RejuvStop);  
      GalenOnDamage = CreateTrigger();
      TriggerRegisterUnitEvent(GalenOnDamage, GalenUnit, EVENT_UNIT_DAMAGED);
      TriggerAddAction(GalenOnDamage, function GalenDamaged);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(4), EVENT_PLAYER_UNIT_ATTACKED, null);
      TriggerRegisterPlayerUnitEvent(t, Player(9), EVENT_PLAYER_UNIT_ATTACKED, null);
      TriggerRegisterPlayerUnitEvent(t, Player(10), EVENT_PLAYER_UNIT_ATTACKED, null);
      TriggerRegisterPlayerUnitEvent(t, Player(11), EVENT_PLAYER_UNIT_ATTACKED, null);
      TriggerRegisterPlayerUnitEvent(t, Player(12), EVENT_PLAYER_UNIT_ATTACKED, null);
      TriggerAddCondition(t, Condition(function IsAttackerGalen));
      TriggerAddAction(t, function GalenDamaging);
    }
  }
//! endzinc 
*/
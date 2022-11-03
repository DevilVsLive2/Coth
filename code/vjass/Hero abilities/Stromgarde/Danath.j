//! zinc
  library DanathAbils requires CothUtilities {

    function RejuvRed ()  -> nothing {
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
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Danath) return;
      RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      DestroyEffect(RejuvEffectStart);
      RejuvEffectStart = null;
    }

    function RejuvEffectSpell ()  -> nothing {
      timer RejuvTimer;
      integer RejuvIteractionCount;
      effect RejuvEffectHeal;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Danath) return;
      RejuvTimer = CreateTimer();
      RejuvIteractionCount = 0;

      DestroyEffect( LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100) );
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);

      RejuvEffectHeal = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", GetTriggerUnit(), "overhead");

      SaveEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101, RejuvEffectHeal);
      SaveInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 102, RejuvIteractionCount);
      SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 103, RejuvTimer);

      SaveUnitHandle(TimerData, GetHandleId(RejuvTimer), 100, GetTriggerUnit());

      TimerStart(RejuvTimer, 2, true, function RejuvRed);
      AddUnitLifePercent(GetTriggerUnit(), 4);
      RejuvTimer = null;
      RejuvEffectHeal = null;
    }

    function AttackOrder ()  -> nothing {
      unit DanathCaster = LoadUnitHandle(UnitAbilityData, GetHandleId(GetExpiredTimer()), 100);
      group DanathTauntTargetsUnfiltired = CreateGroup();
      group DanathTauntTargetsFiltered = CreateGroup();
      unit DanathTauntTarget;
      unit TempUnit;
      GroupEnumUnitsInRangeOfLoc(DanathTauntTargetsUnfiltired, GetUnitLoc(DanathCaster), 500, null);

      while (FirstOfGroup(DanathTauntTargetsUnfiltired) != null) {
        TempUnit = FirstOfGroup(DanathTauntTargetsUnfiltired);
        GroupRemoveUnit(DanathTauntTargetsUnfiltired, TempUnit);
        if
        (
          TempUnit != DanathCaster &&
          IsUnitEnemy(TempUnit, GetOwningPlayer(DanathCaster)) &&
          !IsUnitCastingAbil(TempUnit)
        )
        {
          GroupAddUnit(DanathTauntTargetsFiltered, TempUnit);
        }
      }
      while (FirstOfGroup(DanathTauntTargetsFiltered) != null) {
        DanathTauntTarget = FirstOfGroup(DanathTauntTargetsFiltered);
        GroupRemoveUnit(DanathTauntTargetsFiltered, DanathTauntTarget);
        IssueTargetOrder(DanathTauntTarget, "attack", DanathCaster);
      }

      DestroyGroup(DanathTauntTargetsUnfiltired);
      DanathTauntTargetsUnfiltired = null;
      DestroyGroup(DanathTauntTargetsFiltered);
      DanathTauntTargetsFiltered = null;
      DanathTauntTarget = null;
      TempUnit = null;
      DanathCaster = null;
    }

    function TauntStopTimer ()  -> nothing {
      timer Taunt = LoadTimerHandle(UnitAbilityData, GetHandleId(GetExpiredTimer()), 100);
      unit DanathCaster = LoadUnitHandle(UnitAbilityData, GetHandleId(Taunt), 100);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(DanathCaster), 104);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(DanathCaster), 105);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetExpiredTimer()), 100);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(Taunt), 100);
      DestroyTimer(Taunt);
      Taunt = null;
      DanathCaster = null;
      DestroyTimer(GetExpiredTimer());
    }

    function UseAbility ()  -> nothing {
      effect RejuvEffectStart;
      effect RejuvEffectHeal;
      timer RejuvTimer;

      timer TauntTimer;
      timer TauntStop;
      effect TauntEffect;
      if (GetUnitTypeId(GetTriggerUnit()) != Danath) return;
      
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

      //Удар Щитом
      if
      (
        GetSpellAbilityId() == 'AHtb' &&
        !UnitHasBuffBJ(GetSpellTargetUnit(), 'B01E') &&
        !UnitHasBuffBJ(GetSpellTargetUnit(), 'B03N')
      )
      {
        UnitDamageTarget(GetTriggerUnit(), GetSpellTargetUnit(), 43 * (GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId() + 15)), true, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS );
        UnitDamageTarget(GetTriggerUnit(), GetSpellTargetUnit(), 42 * (GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId() + 15)), true, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS );
      }

      //Боевой Клич
      if (GetSpellAbilityId() == 'A03G') {
        TauntTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 104);
        TauntStop = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(TauntStop), 100);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 104);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(TauntTimer), 100);
        DestroyTimer(TauntTimer);
        DestroyTimer(TauntStop);
        TauntStop = CreateTimer();
        TauntTimer = CreateTimer();
        SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 104, TauntTimer);
        SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105, TauntStop);
        SaveTimerHandle(UnitAbilityData, GetHandleId(TauntStop), 100, TauntTimer);
        SaveUnitHandle(UnitAbilityData, GetHandleId(TauntTimer), 100, GetTriggerUnit());
        TimerStart(TauntTimer, 0.01, true, function AttackOrder);
        TimerStart(TauntStop, 3, false, function TauntStopTimer);
        TauntEffect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Taunt\\TauntCaster.mdl", GetTriggerUnit(), "origin");
        DestroyEffect(TauntEffect);
        TauntEffect = null;
      }

      RejuvEffectStart = null;
      RejuvEffectHeal = null;
      RejuvTimer = null;
    }

    function DanathDamaged ()  -> nothing {
      effect RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 300);
      effect RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 301);
      timer RejuvTimer;
      if (RejuvEffectStart != null) {
        DestroyEffect(RejuvEffectStart);
        //Жёлтый кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 300);
        IssueImmediateOrder(GetTriggerUnit(), "stop");
      } else if (RejuvEffectHeal != null) {
        DestroyEffect(RejuvEffectHeal);
        RejuvTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 303);
        //Зелёный кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 301);
        //Число итеракций хила
        RemoveSavedInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 302);
        //Таймер хила
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 303);
        //Хендл юнита, сохранённый в таймере хила
        RemoveSavedHandle(TimerData, GetHandleId(RejuvTimer), 300);
        PauseTimer(RejuvTimer);
        DestroyTimer(RejuvTimer);
      }

    }

    function DanathLearnSkill ()  -> nothing {
      if (GetLearnedSkill() != 'A02Q') return;
      if (GetLearnedSkillLevel() == 1) UnitAddAbility(GetTriggerUnit(), 'A01U');
      if (GetLearnedSkillLevel() == 2) UnitAddAbility(GetTriggerUnit(), 'A02T');
      if (GetLearnedSkillLevel() == 3) UnitAddAbility(GetTriggerUnit(), 'A02R');
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      TriggerAddAction(DanathOnDamage, function DanathDamaged);
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_EFFECT, null);
      TriggerAddAction(t, function UseAbility);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_HERO_SKILL, null);
      TriggerAddAction(t, function DanathLearnSkill);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_FINISH, null);
      TriggerAddAction(t, function RejuvEffectSpell);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null);
      TriggerAddAction(t, function RejuvStop);
    }
  }
//! endzinc
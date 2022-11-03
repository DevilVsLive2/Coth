//! zinc
  library CurdranAbils requires CothUtilities {

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
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Curdran) return;
      RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      DestroyEffect(RejuvEffectStart);
      RejuvEffectStart = null;
    }

    function RejuvEffectSpell ()  -> nothing {
      timer RejuvTimer;
      integer RejuvIteractionCount;
      effect RejuvEffectHeal;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Curdran) return;
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

    function UseAbility ()  -> nothing {
      effect RejuvEffectStart;
      effect RejuvEffectHeal;
      timer RejuvTimer;

      unit StormHammer;
      unit Caster = GetTriggerUnit();
      location TargetLoc = GetSpellTargetLoc();
      unit Placeholder;
      group StormHammerUnfilteredGroup = CreateGroup();
      group StormHammerFilteredGroup = CreateGroup();
      unit TempUnit;
      unit StormHammerEffect;

      integer ModifierStrengthCurdran = 0;
      if
      (
        (GetUnitTypeId(GetTriggerUnit()) != Curdran) &&
        (GetUnitTypeId(GetTriggerUnit()) != CurdranMorphFirst) &&
        (GetUnitTypeId(GetTriggerUnit()) != CurdranMorphSecond) &&
        (GetUnitTypeId(GetTriggerUnit()) != CurdranMorphThird)
      ) return;
      
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

      //Штормовой молот
      if (GetSpellAbilityId() == 'A051') {
        //Молот, летяющий в точку каста
        StormHammer = CreateUnitAtLoc(GetTriggerPlayer(), 'h01G', GetUnitLoc(Caster), AngleBetweenPoints(GetUnitLoc(Caster), TargetLoc));
        IssuePointOrderLoc(StormHammer, "move", TargetLoc);
        PolledWait(DistanceBetweenPoints(GetUnitLoc(Caster), GetUnitLoc(StormHammer)) / 625);
        Placeholder = CreateUnitAtLoc(GetOwningPlayer(Caster), 'o008', TargetLoc, 0);
        UnitAddAbility(Placeholder, 'A05K');
        SetUnitAbilityLevel(Placeholder, 'A05K', GetUnitAbilityLevel(Caster, GetSpellAbilityId()));
        IssueImmediateOrder(Placeholder, "thunderclap");
        UnitApplyTimedLife(Placeholder, 'BTLF', 1);
        UnitApplyTimedLife(StormHammer, 'BTLF', 0.01);
        GroupEnumUnitsInRangeOfLoc(StormHammerUnfilteredGroup, TargetLoc, 210, null);
        while (FirstOfGroup(StormHammerUnfilteredGroup) != null) {
          TempUnit = FirstOfGroup(StormHammerUnfilteredGroup);
          if
          (
            IsUnitEnemy(TempUnit, GetOwningPlayer(Caster)) &&
            IsUnitType(TempUnit, UNIT_TYPE_GROUND)
          ) GroupAddUnit(StormHammerFilteredGroup, TempUnit);
          GroupRemoveUnit(StormHammerUnfilteredGroup, TempUnit);
        }
        while (FirstOfGroup(StormHammerFilteredGroup) != null) {
          TempUnit = FirstOfGroup(StormHammerFilteredGroup);
          StormHammerEffect = CreateUnitAtLoc(GetOwningPlayer(Caster), 'o00C', GetUnitLoc(TempUnit), 0);
          UnitApplyTimedLife(StormHammerEffect, 'BTLF', 0.01);
          GroupRemoveUnit(StormHammerFilteredGroup, TempUnit);
        }
      }
      //Скай'ри
      if (GetSpellAbilityId() == 'Arav') {
        if
        (
          GetUnitTypeId(Caster) == CurdranMorphFirst ||
          GetUnitTypeId(Caster) == CurdranMorphSecond ||
          GetUnitTypeId(Caster) == CurdranMorphThird
        )
        {
          ModifierStrengthCurdran = 16 - (GetUnitAbilityLevel(Caster, GetSpellAbilityId()) * 4);
          SaveInteger(UnitAbilityData, GetHandleId(Caster), 104, ModifierStrengthCurdran);
          ModifyHeroStat( CheckHeroMainAttribute(Caster), Caster, bj_MODIFYMETHOD_SUB, ModifierStrengthCurdran );
        } else
        {
          ModifyHeroStat( CheckHeroMainAttribute(Caster), Caster, bj_MODIFYMETHOD_ADD, LoadInteger(UnitAbilityData, GetHandleId(Caster), 104) );
        }
        UnitMakeAbilityPermanent(Caster, true, 'AEsf');
        UnitMakeAbilityPermanent(Caster, true, 'A05Y');
        SetUnitInvulnerable(Caster, true);
        TriggerSleepAction(0.01);
        SetUnitInvulnerable(Caster, false);
      }

      RejuvEffectStart = null;
      RejuvEffectHeal = null;
      RejuvTimer = null;

      StormHammer = null;
      Caster = null;
      RemoveLocation(TargetLoc);
      TargetLoc = null;
      DestroyGroup(StormHammerUnfilteredGroup);
      StormHammerUnfilteredGroup = null;
      DestroyGroup(StormHammerFilteredGroup);
      StormHammerFilteredGroup = null;
      TempUnit = null;
      StormHammerEffect = null;
      ModifierStrengthCurdran = 0;
    }

    function CurdranDamaged ()  -> nothing {
      effect RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      effect RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 101);
      timer RejuvTimer;
      timer ThunderShieldCD = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105);
      unit Placeholder;
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

      //Громовой Щит
      if
      (
        GetUnitAbilityLevel(GetTriggerUnit(), 'A05L') > 0 &&
        TimerGetRemaining(ThunderShieldCD) <= 0.1 &&
        IsUnitEnemy(GetEventDamageSource(), GetOwningPlayer(GetTriggerUnit()))
      )
      {
        PauseTimer(ThunderShieldCD);
        DestroyTimer(ThunderShieldCD);
        ThunderShieldCD = CreateTimer();
        SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105, ThunderShieldCD);
        TimerStart(ThunderShieldCD, 30 - (6 * GetUnitAbilityLevel(GetTriggerUnit(), 'A05L')), false, null);
        Placeholder = CreateUnitAtLoc(GetOwningPlayer(GetTriggerUnit()), 'o008', GetUnitLoc(GetTriggerUnit()), 0);
        UnitApplyTimedLife(Placeholder, 'BTLF', 3);
        UnitAddAbility(Placeholder, 'AOcl');
        IssueTargetOrder(Placeholder, "chainlightning", GetEventDamageSource());
      }

      ThunderShieldCD = null;
      Placeholder = null;
      RejuvTimer = null;
      RejuvEffectStart = null;
      RejuvEffectHeal = null;
    }

    function CurdranLearnSkill ()  -> nothing {
      timer ThunderShieldTimer;
      real ThunderShieldTimerRemaining;
      if (GetLearnedSkill() != 'A05L') return;
      ThunderShieldTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105);
      if ( ThunderShieldTimer == null ) return;
      ThunderShieldTimerRemaining = TimerGetRemaining(ThunderShieldTimer);
      if ( ThunderShieldTimerRemaining - 7 < 0 ) return;
      DestroyTimer(ThunderShieldTimer);
      ThunderShieldTimer = CreateTimer();
      TimerStart(ThunderShieldTimer, ThunderShieldTimerRemaining - 6, false, null );
      SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 105, ThunderShieldTimer);
      ThunderShieldTimer = null;
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      TriggerAddAction(CurdranOnDamage, function CurdranDamaged);
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_EFFECT, null);
      TriggerAddAction(t, function UseAbility);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_HERO_SKILL, null);
      TriggerAddAction(t, function CurdranLearnSkill);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_FINISH, null);
      TriggerAddAction(t, function RejuvEffectSpell);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null);
      TriggerAddAction(t, function RejuvStop);
    }
  }
//! endzinc
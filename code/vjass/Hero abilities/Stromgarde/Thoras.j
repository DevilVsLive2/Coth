//! zinc
  library ThorasAbils requires CothUtilities {

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
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Thoras) return;
      RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 100);
      DestroyEffect(RejuvEffectStart);
      RejuvEffectStart = null;
    }

    function RejuvEffectSpell ()  -> nothing {
      timer RejuvTimer;
      integer RejuvIteractionCount;
      effect RejuvEffectHeal;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Thoras) return;
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

    function HeroicStrikeFilter ()  -> boolean {
      return
      (
        IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) &&
        !IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) &&
        IsUnitType(GetFilterUnit(), UNIT_TYPE_GROUND) &&
        IsUnitAliveBJ(GetFilterUnit())
      );
    }

    function HeroicStrikeDamage ()  -> nothing {
      UnitDamageTarget(GetTriggerUnit(), GetEnumUnit(), 75 + (GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()) * 50), true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
    }

    function UseAbility ()  -> nothing {
      effect RejuvEffectStart;
      effect RejuvEffectHeal;
      timer RejuvTimer;

      group HeroicStrikeGroup;
      unit Caster = GetTriggerUnit();
      unit Target = GetSpellTargetUnit();
      real AdditionalHeroStat;
      effect e;
      unit Placeholder;
      if (GetUnitTypeId(GetTriggerUnit()) != Thoras) return;
      
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
      //Героический Удар
      if (GetSpellAbilityId() == 'ANab') {
        HeroicStrikeGroup = CreateGroup();
        GroupEnumUnitsInRangeOfLoc(HeroicStrikeGroup, GetUnitLoc(GetSpellTargetUnit()), 270, Filter(function HeroicStrikeFilter));
        ForGroup(HeroicStrikeGroup, function HeroicStrikeDamage);
        DestroyGroup(HeroicStrikeGroup);
        HeroicStrikeGroup = null;
      }
      //Мощь Богов
      if (GetSpellAbilityId() == 'Aroa') {
        UnitAddAbility(GetTriggerUnit(), 'A0C7');
        UnitAddAbility(GetTriggerUnit(), 'A08A');
        SetUnitAbilityLevel(GetTriggerUnit(), 'A08A', GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()));
        PolledWait(10);
        UnitRemoveAbility(Caster, 'A0C7');
        UnitRemoveAbility(Caster, 'A08A');
      }

      //Божественная Сила
      if (GetSpellAbilityId() == 'A0E4') {
        AdditionalHeroStat = GetHeroStatBJ(CheckHeroMainAttribute(Target), Target, true);
        if (Target == Caster) AdditionalHeroStat *= 0.75;
        else AdditionalHeroStat *= 0.25;
        ModifyHeroStat(CheckHeroMainAttribute(Target), Target, bj_MODIFYMETHOD_ADD, R2I(AdditionalHeroStat));
        PlaySoundOnUnitBJ(gg_snd_RestorationPotion, 100, Target);
        e = AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl", Target, "origin");
        DestroyEffect(e);
        e = null;
        //Юнит, дающий ауру-пустышку, для иконки баффа 
        Placeholder = CreateUnit(GetOwningPlayer(Target), 'o008', 0, 0, 0);
        UnitAddAbility(Placeholder, 'A0E6');
        UnitApplyTimedLife(Placeholder, 'BTLF', 12.5);
        Placeholder = null;
        PolledWait(15);
        ModifyHeroStat(CheckHeroMainAttribute(Target), Target, bj_MODIFYMETHOD_SUB, R2I(AdditionalHeroStat));
      }

      RejuvEffectStart = null;
      RejuvEffectHeal = null;
      RejuvTimer = null;
    }

    function ThorasDamaged ()  -> nothing {
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

    function ThorasLearnSkill ()  -> nothing {
      if (GetLearnedSkill() != 'AIsr') return;
      UnitAddAbility(GetTriggerUnit(), 'A005');
      SetUnitAbilityLevel(GetTriggerUnit(), 'A005', GetLearnedSkillLevel());
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      TriggerAddAction(ThorasOnDamage, function ThorasDamaged);
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_EFFECT, null);
      TriggerAddAction(t, function UseAbility);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_HERO_SKILL, null);
      TriggerAddAction(t, function ThorasLearnSkill);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_FINISH, null);
      TriggerAddAction(t, function RejuvEffectSpell);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(0), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null);
      TriggerAddAction(t, function RejuvStop);
    }
  }
//! endzinc
//! zinc
  library LlaneAbils requires CothUtilities {

    function RejuvBlue ()  -> nothing {
      unit RejuvUnit = LoadUnitHandle(TimerData, GetHandleId(GetExpiredTimer()), 200);
      integer RejuvIteractionCount = LoadInteger(UnitAbilityData, GetHandleId(RejuvUnit), 202);
      effect RejuvEffectHeal;
      AddUnitLifePercent(RejuvUnit, RejuvIteractionCount + 4);
      if (RejuvIteractionCount == 12) {
        RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(RejuvUnit), 201);
        PauseTimer(GetExpiredTimer());
        DestroyEffect(RejuvEffectHeal);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(RejuvUnit), 201);
        RemoveSavedInteger(UnitAbilityData, GetHandleId(RejuvUnit), 202);
        RemoveSavedHandle(UnitAbilityData, GetHandleId(RejuvUnit), 203);
        RemoveSavedHandle(TimerData, GetHandleId(GetExpiredTimer()), 200);
        DestroyTimer(GetExpiredTimer());
        RejuvUnit = null;
        RejuvEffectHeal = null;
        return;
      } else if (RejuvIteractionCount > 12) {
        DestroyTimer(GetExpiredTimer());
      }
      RejuvIteractionCount += 1;
      SaveInteger(UnitAbilityData, GetHandleId(RejuvUnit), 202, RejuvIteractionCount);
      RejuvUnit = null;
      RejuvEffectHeal = null;
    }

    function RejuvStop ()  -> nothing {
      effect RejuvEffectStart;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Llane) return;
      RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);
      DestroyEffect(RejuvEffectStart);
      RejuvEffectStart = null;
    }

    function RejuvEffectSpell ()  -> nothing {
      timer RejuvTimer;
      integer RejuvIteractionCount;
      effect RejuvEffectHeal;
      if (GetSpellAbilityId() != 'AEsf' || GetUnitTypeId(GetTriggerUnit()) != Llane) return;
      RejuvTimer = CreateTimer();
      RejuvIteractionCount = 0;

      DestroyEffect( LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200) );
      RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);

      RejuvEffectHeal = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Tranquility\\TranquilityTarget.mdl", GetTriggerUnit(), "overhead");

      SaveEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 201, RejuvEffectHeal);
      SaveInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 202, RejuvIteractionCount);
      SaveTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 203, RejuvTimer);

      SaveUnitHandle(TimerData, GetHandleId(RejuvTimer), 200, GetTriggerUnit());

      TimerStart(RejuvTimer, 2, true, function RejuvBlue);
      AddUnitLifePercent(GetTriggerUnit(), 4);
      RejuvTimer = null;
      RejuvEffectHeal = null;
    }

    function UseAbility ()  -> nothing {
      effect RejuvEffectStart;
      effect RejuvEffectHeal;
      timer RejuvTimer;

      unit Caster = GetTriggerUnit();
      unit AegwynnNecklackeCaster;

      unit HammerBuff;
      if (GetUnitTypeId(GetTriggerUnit()) != Llane) return;
      
      //Омоложение
      if (GetSpellAbilityId() == 'AEsf') {
        //Жёлтый кружочек
        RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);
        //Зелёный кружочек
        RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 201);
        //Таймер хила
        RejuvTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 203);

        //Жёлтый кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);
        //Зелёный кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 201);
        //Число итеракций хила
        RemoveSavedInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 202);
        //Таймер хила
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 203);
        //Хендл юнита, сохранённый в таймере хила
        RemoveSavedHandle(TimerData, GetHandleId(RejuvTimer), 200);


        PauseTimer( RejuvTimer );
        DestroyTimer( RejuvTimer );
        DestroyEffect(RejuvEffectStart);
        DestroyEffect(RejuvEffectHeal);
        
        RejuvEffectStart = AddSpecialEffectTarget("RejuvTarget.mdx", GetTriggerUnit(), "overhead");
        SaveEffectHandle( UnitAbilityData, GetHandleId(GetTriggerUnit()), 200, RejuvEffectStart );
      }
      //Убийца Орков
      if (GetSpellAbilityId() == 'A048') {
        if (IsUnitType(GetSpellTargetUnit(), UNIT_TYPE_UNDEAD)) {
          UnitDamageTarget(GetTriggerUnit(), GetSpellTargetUnit(), 200 + (GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()) * 75), true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
        } else {
          UnitDamageTarget(GetTriggerUnit(), GetSpellTargetUnit(), (GetUnitAbilityLevel(GetTriggerUnit(), GetSpellAbilityId()) * 75), true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
        }
      }
      //Ожерелье Аэгвинн
      if (GetSpellAbilityId() == 'A06E') {
        SetUnitVertexColorBJ(Caster, 100, 100, 40, 0);
        AegwynnNecklackeCaster = CreateUnitAtLoc(GetOwningPlayer(Caster), 'o008', GetUnitLoc(Caster), 0);
        UnitAddAbility(AegwynnNecklackeCaster, 'Aams');
        IssueTargetOrder(AegwynnNecklackeCaster, "antimagicshell", Caster);
        UnitApplyTimedLife(AegwynnNecklackeCaster, 'BTLF', 3);
        PolledWait( 2 * (GetUnitAbilityLevel(Caster, 'A06E')) );
        //Удаляем иммун к магии
        UnitRemoveAbility(Caster, 'Bams');
        UnitRemoveAbility(Caster, 'Bam2');
        SetUnitVertexColorBJ(Caster, 100, 100, 100, 0);
      }
      //Львиный Молот Азерота
      if (GetSpellAbilityId() == 'A05N') {
        //Юнит, дающий бафф львиного молота
        HammerBuff = CreateUnitAtLoc(GetOwningPlayer(Caster), 'o008', GetUnitLoc(Caster), 0);
        UnitAddAbility(HammerBuff, 'A0AI');
        UnitApplyTimedLife(HammerBuff, 'BTLF', 28);
        //Добавляем невидимый сплеш
        UnitAddAbility(Caster, 'Aspb');
        SetUnitAbilityLevel(Caster, 'Aspb', GetUnitAbilityLevel(Caster, GetSpellAbilityId()));
        SetPlayerAbilityAvailable(GetOwningPlayer(Caster), 'Aspb', false);
        //Доп урон
        if (GetUnitAbilityLevel(Caster, GetSpellAbilityId()) == 1) UnitAddAbility(Caster, 'A095');
        if (GetUnitAbilityLevel(Caster, GetSpellAbilityId()) == 2) UnitAddAbility(Caster, 'A096');
        if (GetUnitAbilityLevel(Caster, GetSpellAbilityId()) == 3) UnitAddAbility(Caster, 'A094');
        PolledWait(30);
        UnitRemoveAbility(Caster, 'Aspb');
        UnitRemoveAbility(Caster, 'A094');
        UnitRemoveAbility(Caster, 'A095');
        UnitRemoveAbility(Caster, 'A096');
      }

      RejuvEffectStart = null;
      RejuvEffectHeal = null;
      RejuvTimer = null;
    }

    function LlaneDamaged ()  -> nothing {
      effect RejuvEffectStart = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);
      effect RejuvEffectHeal = LoadEffectHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 201);
      timer RejuvTimer;
      if (RejuvEffectStart != null) {
        DestroyEffect(RejuvEffectStart);
        //Жёлтый кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 200);
        IssueImmediateOrder(GetTriggerUnit(), "stop");
      } else if (RejuvEffectHeal != null) {
        DestroyEffect(RejuvEffectHeal);
        RejuvTimer = LoadTimerHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 203);
        //Зелёный кружочек
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 201);
        //Число итеракций хила
        RemoveSavedInteger(UnitAbilityData, GetHandleId(GetTriggerUnit()), 202);
        //Таймер хила
        RemoveSavedHandle(UnitAbilityData, GetHandleId(GetTriggerUnit()), 203);
        //Хендл юнита, сохранённый в таймере хила
        RemoveSavedHandle(TimerData, GetHandleId(RejuvTimer), 200);
        PauseTimer(RejuvTimer);
        DestroyTimer(RejuvTimer);
      }

    }

    function LlaneLearnSkill ()  -> nothing {
      if (GetLearnedSkill() != 'AUts') return;
      if (GetLearnedSkillLevel() == 1) UnitAddAbility(GetTriggerUnit(), 'Arll');
      if (GetLearnedSkillLevel() == 2) UnitAddAbility(GetTriggerUnit(), 'A03A');
      if (GetLearnedSkillLevel() == 3) UnitAddAbility(GetTriggerUnit(), 'A03B');
      if (GetLearnedSkillLevel() == 3) UnitAddAbility(GetTriggerUnit(), 'A03C');
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      TriggerAddAction(LlaneOnDamage, function LlaneDamaged);
      TriggerRegisterPlayerUnitEvent(t, Player(1), EVENT_PLAYER_UNIT_SPELL_EFFECT, null);
      TriggerAddAction(t, function UseAbility);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(1), EVENT_PLAYER_HERO_SKILL, null);
      TriggerAddAction(t, function LlaneLearnSkill);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(1), EVENT_PLAYER_UNIT_SPELL_FINISH, null);
      TriggerAddAction(t, function RejuvEffectSpell);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(1), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null);
      TriggerAddAction(t, function RejuvStop);
    }
  }
//! endzinc
//! zinc
  library GlacialShield {
    timer GlacialTimer[11];
    hashtable GlacialHashtable = InitHashtable();

    function IsAbillityAGlacial ()  -> boolean {
      return (GetSpellAbilityId() == 'AIhb');
    }

    function RemoveAncient ()  -> nothing {
      UnitRemoveType(LoadUnitHandle(GlacialHashtable, 0, GetHandleId(GetExpiredTimer())), UNIT_TYPE_ANCIENT);
      PauseTimer(GetExpiredTimer());
      DestroyTimer(GetExpiredTimer());
    }

    function GlacialUsed ()  -> nothing {
      unit GlacialTarget = GetSpellTargetUnit();
      unit u = CreateUnit(GetOwningPlayer(GlacialTarget), 'o008', GetUnitX(GlacialTarget), GetUnitY(GlacialTarget), 0);
      UnitAddType(GetSpellAbilityUnit(), UNIT_TYPE_ANCIENT);
      UnitAddAbility(u, 'Aams');
      IssueTargetOrder(u, "antimagicshell", GlacialTarget);
      UnitApplyTimedLife(u, 'BTLF', 1);
      PauseTimer(GlacialTimer[GetPlayerId(GetOwningPlayer(GlacialTarget))]);
      DestroyTimer(GlacialTimer[GetPlayerId(GetOwningPlayer(GlacialTarget))]);
      GlacialTimer[GetPlayerId(GetOwningPlayer(GlacialTarget))] = CreateTimer();
      TimerStart(GlacialTimer[GetPlayerId(GetOwningPlayer(GlacialTarget))], 8, false, function RemoveAncient);
      SaveUnitHandle(GlacialHashtable, 0, GetHandleId(GlacialTimer[GetPlayerId(GetOwningPlayer(GlacialTarget))]), GlacialTarget);
      GlacialTarget = null;
      u = null;
    }

    function onInit ()  -> nothing {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, Condition(function IsAbillityAGlacial));
        TriggerAddAction(t, function GlacialUsed);
    }
  }
//! endzinc
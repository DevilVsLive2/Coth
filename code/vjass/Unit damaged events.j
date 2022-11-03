//! zinc
  library UnitDamaged requires CothUtilities {

    hashtable UnitDataHashtable = InitHashtable();
    public hashtable TimerHashtable = InitHashtable();
    constant integer HASHTABLE_IS_UNIT_STAN_ON_COOLDOWN = 1;
    constant integer HASHTABLE_UNIT_REMOVE_AMAIN_DEBUFF = 2;
    constant integer HASHTABLE_UNIT_REMOVE_BLACKROCKS_AXE_DEBUFF = 3;
    constant integer HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF = 4;
    constant integer HASHTABLE_CORRUPTION_AURA = 5;
    boolean IsGaronaUsedAbillity = false;
    unit CorruptionAuraUnit[11];
    integer udg_CarveDamage = 0;
    unit PrevTarget;
    public {
      constant integer GLACIAL_BUFF = 'Bams';
      constant integer ABILITY_STUN = 'ACbh';
      constant integer AMANI_DEBUFF = 'A06D';
      constant integer BLACKROCK_DEBUFF = 'A0GM';
      constant integer CORRUPTION_DEBUFF = 'A0GN';
    }

    function RemoveCooldownBash ()  -> nothing {
      SaveBoolean(UnitDataHashtable, GetHandleId(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), 0)), HASHTABLE_IS_UNIT_STAN_ON_COOLDOWN, false);
    }

    function AmaniRemove ()  -> nothing {
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_AMAIN_DEBUFF), AMANI_DEBUFF);
      SaveTimerHandle(TimerHashtable, GetHandleId(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_AMAIN_DEBUFF)), 0, null);
    }

    function BlackrockRemove ()  -> nothing {
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_BLACKROCKS_AXE_DEBUFF), BLACKROCK_DEBUFF);
      SaveTimerHandle(TimerHashtable, GetHandleId(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_BLACKROCKS_AXE_DEBUFF)), 1, null);
    }

    function CorruptionEdgeRemove ()  -> nothing {
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF), 'A0GW');
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF), 'A0GO');
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF), 'A0GX');
      RemoveUnit(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_CORRUPTION_AURA));
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF), 'B04L');
      UnitRemoveAbility(LoadUnitHandle(UnitDataHashtable, GetHandleId(GetExpiredTimer()), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF), 'B04M');

    }

    public function SetCorruptionEdgeLevels (unit CorruptionEdgeTarget, unit CorruptionEdgeAura)  -> nothing {
      real HeroArmor;
      string HeroArmorStr;
      if (UnitHasItemOfTypeBJ(CorruptionEdgeTarget, Stonepath_Chestguard_Inventory)) {
        HeroArmor = GetHeroArmor(CorruptionEdgeTarget) * 1.25;
        HeroArmor = HeroArmor * 0.4;
      } else {
        HeroArmor = GetHeroArmor(CorruptionEdgeTarget) * 0.4;
      }
      if (IsUnitDeadBJ(CorruptionEdgeTarget)) return;
      HeroArmorStr = R2SW(HeroArmor, 2, 2);
      if (HeroArmor >= 100) {
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GP', S2I(SubString(HeroArmorStr, 0, 1)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GN', S2I(SubString(HeroArmorStr, 1, 2)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GO', S2I(SubString(HeroArmorStr, 2, 3)) + 1);

          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GS', S2I(SubString(HeroArmorStr, 4, 5)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GY', S2I(SubString(HeroArmorStr, 5, 6)) + 1);
      } else if (HeroArmor >= 10) {
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GP', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GN', S2I(SubString(HeroArmorStr, 0, 1)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GO', S2I(SubString(HeroArmorStr, 1, 2)) + 1);

          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GS', S2I(SubString(HeroArmorStr, 3, 4)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GY', S2I(SubString(HeroArmorStr, 4, 5)) + 1);
      } else if (HeroArmor >= 1) {
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GP', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GN', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GO', S2I(SubString(HeroArmorStr, 0, 1)) + 1);

          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GS', S2I(SubString(HeroArmorStr, 2, 3)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GY', S2I(SubString(HeroArmorStr, 3, 4)) + 1);
      } else if (HeroArmor >= 0.1) {
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GP', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GN', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GO', 1);

          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GS', S2I(SubString(HeroArmorStr, 1, 2)) + 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GY', S2I(SubString(HeroArmorStr, 2, 3)) + 1);
      } else if (HeroArmor >= 0.01) {
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GP', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GN', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GO', 1);

          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GS', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GY', S2I(SubString(HeroArmorStr, 1, 2)) + 1);
      } else {
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GP', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GN', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GO', 1);

          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GS', 1);
          SetUnitAbilityLevel(CorruptionEdgeAura, 'A0GY', 1);
      }
  }

    function UnitOnDamage ()  -> nothing {
      unit Damager = GetAttacker();
      unit Target = GetTriggerUnit();
      timer BashCooldownTimer;
      unit Placeholder;
      boolean IsApplyStun = false;
      real Damage = GetEventDamage();
      boolean IsTargetAllyDamager = IsUnitAlly(Target, GetOwningPlayer(Damager) );
      boolean WisdomDamageTarget = false;
      real Mana;
      real AmaniTimerSeconds = 3;
      real BlackrockTimerSeconds = 3;
      real CorruptionEdgeTimerSeconds = 3;
      timer TempTimer;
      timer AmaniThrowAxeTimer;
      timer BlackrockChampionsAxeTimer;
      timer CorruptionEdgeTimer;
      trigger TriggeringTrg = GetTriggeringTrigger();
      integer UnitArmor;
      real UnitFloatArmor;
      unit TempUnit;
      location TempLoc;
      location TempLocSecond;
      texttag GaronaDamage;
      if (IsUnitInGroup(Damager, udg_StopGroup)) return;
      //Стан
      if (udg_Sandbox == 11) IsTargetAllyDamager = false;
      if
      (
        (UnitHasItemOfTypeBJ(Damager, Royal_Hammer_Inventory_Melee) ||
        UnitHasItemOfTypeBJ(Damager, Royal_Hammer_Inventory_Range) ||
        (GetUnitAbilityLevel(Damager, ABILITY_STUN) > 0))
        && !IsTargetAllyDamager
      )
      {
        if (UnitHasItemOfTypeBJ(Damager, Royal_Hammer_Inventory_Melee)) {
          if (GetRandomInt(1, 100) <= 16 ) IsApplyStun = true;
        }
        if (UnitHasItemOfTypeBJ(Damager, Royal_Hammer_Inventory_Range)) {
          if (GetRandomInt(1, 100) <= 8 ) IsApplyStun = true;
        }
        if (GetUnitAbilityLevel(Damager, 'ACbh') > 0) {
          if (GetRandomInt(1, 100) <= 10 ) IsApplyStun = true;
        }

        if (IsHeroUnitId(GetUnitTypeId(Target))) 
        {
          if ( LoadBoolean(UnitDataHashtable, GetHandleId(Damager), HASHTABLE_IS_UNIT_STAN_ON_COOLDOWN) == false && IsApplyStun)
          {
            SaveBoolean(UnitDataHashtable, GetHandleId(Damager), HASHTABLE_IS_UNIT_STAN_ON_COOLDOWN, true);
            BashCooldownTimer = CreateTimer();
            TimerStart(BashCooldownTimer, 3.5, false, function RemoveCooldownBash);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(BashCooldownTimer), 0, Damager);
            UnitRemoveAbility(Target, GLACIAL_BUFF);
            Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 0);
            UnitAddAbility(Placeholder, 'ANfb');
            DisableTrigger(TriggeringTrg);
            IssueTargetOrder(Placeholder, "firebolt", Target);
            EnableTrigger(TriggeringTrg);
            UnitApplyTimedLife(Placeholder, 'BTLF', 1);
          }
        } else if (IsApplyStun)
        {
          Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 0);
          UnitAddAbility(Placeholder, 'ANfb');
          DisableTrigger(TriggeringTrg);
          IssueTargetOrder(Placeholder, "firebolt", Target);
          UnitApplyTimedLife(Placeholder, 'BTLF', 1);
          EnableTrigger(TriggeringTrg);
        }
      }

      //Разрушитель разума
      if (UnitHasItemOfTypeBJ(Damager, Wisdom_Carver_Inventory) && !IsTargetAllyDamager)
      {
        if (IsHeroRange(Damager)) {
          Mana = GetHeroInt(Target, true) * 0.25;
        } else {
          Mana = GetHeroInt(Target, true) * 0.5;
        }
        UnitRemoveMana(Target, Mana);
        UnitAddMana(Damager, Mana);

        if (GetRandomInt(1, 100) <= 40) WisdomDamageTarget = true;
        
        if (WisdomDamageTarget) {
          DisableTrigger(TriggeringTrg);
          UnitDamageTarget(Damager, Target, Mana, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
          EnableTrigger(TriggeringTrg);
        }
      }
      //Топор Амани
      if (UnitHasItemOfTypeBJ(Damager, Amani_Throw_Axe_Inventory) && !IsTargetAllyDamager) {
        if (IsHeroUnitId(GetUnitTypeId(Target))) {
          UnitAddAbility(Target, AMANI_DEBUFF); //Добавление абилки на -7 армора
          TempTimer = LoadTimerHandle(TimerHashtable, GetHandleId(Target), 0);
          //Смотрим, имеется ли у нас уже дебафф на юните
          if (TempTimer != null) {
            //Если имеется - мы перезапускаем таймер, что убирает дебаф
            PauseTimer(TempTimer);
            DestroyTimer(TempTimer);
            TempTimer = CreateTimer();
            TimerStart(TempTimer, AmaniTimerSeconds, false, function AmaniRemove);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(TempTimer), HASHTABLE_UNIT_REMOVE_AMAIN_DEBUFF, Target);
            SaveTimerHandle(TimerHashtable, GetHandleId(Target), 0, TempTimer);
          } else {
            AmaniThrowAxeTimer = CreateTimer();
            TimerStart(AmaniThrowAxeTimer, AmaniTimerSeconds, false, function AmaniRemove);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(AmaniThrowAxeTimer), HASHTABLE_UNIT_REMOVE_AMAIN_DEBUFF, Target);
            SaveTimerHandle(TimerHashtable, GetHandleId(Target), 0, AmaniThrowAxeTimer);
          }
        }
      }

      //Топор блэкрока

      if (UnitHasItemOfTypeBJ(Damager, Blackrock_Champions_Axe_Inventory) && !IsTargetAllyDamager) {
        if (IsHeroUnitId(GetUnitTypeId(Target))) {
          UnitAddAbility(Target, BLACKROCK_DEBUFF); //Добавление абилки на -7 армора
          TempTimer = LoadTimerHandle(TimerHashtable, GetHandleId(Target), 1);
          //Смотрим, имеется ли у нас уже дебафф на юните
          if (TempTimer != null) {
            //Если имеется - мы перезапускаем таймер, что убирает дебаф
            PauseTimer(TempTimer);
            DestroyTimer(TempTimer);
            TempTimer = CreateTimer();
            TimerStart(TempTimer, BlackrockTimerSeconds, false, function BlackrockRemove);
            //Сохраняем в хендл таймера юнита, что бы когда он кончается знать, на ком дебафф
            SaveUnitHandle(UnitDataHashtable, GetHandleId(TempTimer), HASHTABLE_UNIT_REMOVE_BLACKROCKS_AXE_DEBUFF, Target);
            //Сохраняем в хендл юнита таймер, что бы мы могли в этом триггере проверить, идёт ли таймер для этого
            SaveTimerHandle(TimerHashtable, GetHandleId(Target), 1, TempTimer);
          } else {
            BlackrockChampionsAxeTimer = CreateTimer();
            TimerStart(BlackrockChampionsAxeTimer, BlackrockTimerSeconds, false, function BlackrockRemove);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(BlackrockChampionsAxeTimer), HASHTABLE_UNIT_REMOVE_BLACKROCKS_AXE_DEBUFF, Target);
            SaveTimerHandle(TimerHashtable, GetHandleId(Target), 1, BlackrockChampionsAxeTimer);
          }
        }
      }

      //Меч Рока
      if (UnitHasItemOfTypeBJ(Damager, Corruption_Edge_Inventory) && !IsTargetAllyDamager) {
        if (IsHeroUnitId(GetUnitTypeId(Target))) {
          RemoveUnit(CorruptionAuraUnit[GetPlayerId(GetOwningPlayer(Target))]);
          Placeholder = CreateUnit(GetOwningPlayer(Target), 'o008', 0, 0, 0);
          CorruptionAuraUnit[GetPlayerId(GetOwningPlayer(Target))] = Placeholder;
          //Добавление аур, снижающие защиту меньше 1
          UnitAddAbility(Placeholder, 'A0GS');
          UnitAddAbility(Placeholder, 'A0GY');
          //Добавление абилок, снижающих защиту
          UnitAddAbility(Target, 'A0GO');
          UnitAddAbility(Target, 'A0GW');
          UnitAddAbility(Target, 'A0GX');
          TempTimer = LoadTimerHandle(TimerHashtable, GetHandleId(Target), 2);
          //Смотрим, имеется ли у нас уже дебафф на юните
          if (TempTimer != null) {
            //Если имеется - мы перезапускаем таймер, что убирает дебаф
            PauseTimer(TempTimer);
            DestroyTimer(TempTimer);
            TempTimer = CreateTimer();
            TimerStart(TempTimer, CorruptionEdgeTimerSeconds, false, function CorruptionEdgeRemove);
            //Сохраняем в хендл таймера юнита, что бы когда он кончается знать, на ком дебафф
            SaveUnitHandle(UnitDataHashtable, GetHandleId(TempTimer), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF, Target);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(TempTimer), HASHTABLE_CORRUPTION_AURA, Placeholder);
            //Сохраняем в хендл юнита таймер, что бы мы могли в этом триггере проверить, идёт ли таймер для этого
            SaveTimerHandle(TimerHashtable, GetHandleId(Target), 2, TempTimer);
          } else {
            CorruptionEdgeTimer = CreateTimer();
            TimerStart(CorruptionEdgeTimer, CorruptionEdgeTimerSeconds, false, function CorruptionEdgeRemove);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(CorruptionEdgeTimer), HASHTABLE_UNIT_REMOVE_CORRUPTION_EDGE_DEBUFF, Target);
            SaveUnitHandle(UnitDataHashtable, GetHandleId(CorruptionEdgeTimer), HASHTABLE_CORRUPTION_AURA, Placeholder);
            SaveTimerHandle(TimerHashtable, GetHandleId(Target), 2, CorruptionEdgeTimer);
          }
          SetCorruptionEdgeLevels(Target, Placeholder);
        }
      }

      if (UnitHasItemOfTypeBJ(Damager, Thunderfury_Inventory) && !IsTargetAllyDamager) {
        Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 270);
        UnitAddAbility(Placeholder, 'A0BY');
        IssueTargetOrder(Placeholder, "slow", Target);
        UnitApplyTimedLife(Placeholder, 'BTLF', 1);
        if (GetRandomInt(1, 100) <= 40) {
          UnitAddAbility(Placeholder, 'ACcl');
          DisableTrigger(TriggeringTrg);
          IssueTargetOrder(Placeholder, "chainlightning", Target);
          EnableTrigger(TriggeringTrg);
        }
      }

      if (UnitHasItemOfTypeBJ(Damager, Obsidian_Spear_Inventory) && !IsTargetAllyDamager) {
        if (GetRandomInt(1, 100) <= 18) {
          if (!IsUnitType(Target, UNIT_TYPE_HERO) && !IsUnitType(Target, UNIT_TYPE_ANCIENT) && !IsUnitType(Target, UNIT_TYPE_STRUCTURE)) {
            Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 270);
            DisableTrigger(TriggeringTrg);
            UnitDamageTarget(Placeholder, Target, 50000, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
            EnableTrigger(TriggeringTrg);
            UnitApplyTimedLife(Placeholder, 'BTLF', 1);
          }
        }
      }

      if (UnitHasItemOfTypeBJ(Damager, Argent_Spear_Inventory) && !IsTargetAllyDamager) {
        if (GetRandomInt(1, 100) <= 8) {
          if (!IsUnitType(Target, UNIT_TYPE_HERO) && !IsUnitType(Target, UNIT_TYPE_ANCIENT) && !IsUnitType(Target, UNIT_TYPE_STRUCTURE)) {
            Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 270);
            DisableTrigger(TriggeringTrg);
            UnitDamageTarget(Placeholder, Target, 50000, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
            EnableTrigger(TriggeringTrg);
            UnitApplyTimedLife(Placeholder, 'BTLF', 1);
          }
        }
      }

      //Кара Бутера
      if (GetUnitAbilityLevel(Damager, 'A03L') > 0 && !IsTargetAllyDamager) {
        if (GetUnitAbilityLevel(Target, 'BEsh') > 0) {
          if (GetRandomInt(1, 100) <= (GetUnitAbilityLevel(Damager, 'A03L') * 5 + 5) * 2) {
            Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 270);
            UnitAddAbility(Placeholder, 'ACbh');
            UnitApplyTimedLife(Placeholder, 'BTLF', 1);
            if (IsUnitType(Target, UNIT_TYPE_HERO) || GetUnitTypeId(Target) == 'nogr' || GetUnitTypeId(Target) == 'nsqa' || GetUnitTypeId(Target) == 'nahy') {
              SetUnitAbilityLevel(Placeholder, 'ACbh', 1);
            } else {
              SetUnitAbilityLevel(Placeholder, 'ACbh', 2);
            }
            DisableTrigger(TriggeringTrg);
            IssueTargetOrder(Placeholder, "thunderbolt", Target);
            EnableTrigger(TriggeringTrg);
          }
        } else {
          if (GetRandomInt(1, 100) <= GetUnitAbilityLevel(Damager, 'A03L') * 5 + 5) {
            Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 270);
            UnitAddAbility(Placeholder, 'ACbh');
            UnitApplyTimedLife(Placeholder, 'BTLF', 1);
            if (IsUnitType(Target, UNIT_TYPE_HERO) || GetUnitTypeId(Target) == 'nogr' || GetUnitTypeId(Target) == 'nsqa' || GetUnitTypeId(Target) == 'nahy') {
              SetUnitAbilityLevel(Placeholder, 'ACbh', 1);
            } else {
              SetUnitAbilityLevel(Placeholder, 'ACbh', 2);
            }
            DisableTrigger(TriggeringTrg);
            IssueTargetOrder(Placeholder, "thunderbolt", Target); 
            EnableTrigger(TriggeringTrg);
          }
        }
      }

      //Вражеская Слабость Темара
      if (GetUnitAbilityLevel(Damager, 'A09E') > 0 && !IsTargetAllyDamager) {
        if (
          !IsUnitType(Target, UNIT_TYPE_STRUCTURE) &&
          !IsUnitType(Target, UNIT_TYPE_MECHANICAL) &&
          GetUnitAbilityLevel(Target, 'B01E') < 1 &&
          GetUnitAbilityLevel(Target, 'B03N') < 1 &&
          GetUnitState(Target, UNIT_STATE_LIFE) < ( 125 + I2R(GetUnitAbilityLevel(Damager, 'A09E') * 125) ) &&
          GetUnitTypeId(Target) != 'ohwd' &&
          GetUnitTypeId(Target) != 'oswy'
        ) {
          Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 270);
          UnitApplyTimedLife(Placeholder, 'BTLF', 1);
          DisableTrigger(TriggeringTrg);
          UnitDamageTarget(Placeholder, Target, 9000, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
          EnableTrigger(TriggeringTrg);
        }
      }

      if (GetUnitAbilityLevel(Damager, 'A0CJ') > 0 && !IsTargetAllyDamager) {
        DisableTrigger(TriggeringTrg);
        UnitDamageTarget(Damager, Target, GetUnitState(Target, UNIT_STATE_MANA) * 0.02, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
        EnableTrigger(TriggeringTrg);
        UnitRemoveMana(Target, GetUnitState(Target, UNIT_STATE_MANA) * 0.02);
      }

      if ( (GetUnitTypeId(Damager) == 'O001' || GetUnitTypeId(Damager) == 'O000' || GetUnitTypeId(Damager) == 'O00N') && !IsTargetAllyDamager ) {
        TriggerSleepAction(0.05);
        if (IsGaronaUsedAbillity == false) {
          if ( !UnitHasBuffBJ(Target, 'BHds') && !UnitHasBuffBJ(Target, 'B03N') && !UnitHasBuffBJ(Target, 'BIsv') ) {
            DisableTrigger(TriggeringTrg);
            UnitDamageTarget(Damager, Target, Damage * ( 1 + (GetUnitAbilityLevel(Damager, 'A09D')) ), true, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS);
            UnitDamageTarget(Damager, Target, Damage * ( 1 + (GetUnitAbilityLevel(Damager, 'A09D')) ), true, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
            EnableTrigger(TriggeringTrg);
            GaronaDamage = CreateTextTagLocBJ( I2S( R2I (Damage * ( 2 + (GetUnitAbilityLevel(Damager, 'A09D')) )) ) + "!", GetUnitLoc(Target), 0, 10, 100, 0.00, 0.00, 0);
            SetTextTagPermanentBJ(GaronaDamage, false);
            SetTextTagVelocityBJ(GaronaDamage, 15.00, 90);
            SetTextTagLifespanBJ(GaronaDamage, 3.00);
            SetTextTagFadepointBJ(GaronaDamage, 1.00);
          }

          if (IsUnitOwnedByPlayer(Damager, Player(9))) {
            UnitAddAbility(Damager, 'A0DH');
            UnitRemoveAbility(Damager, 'A0DH');
          } else if (IsUnitOwnedByPlayer(Damager, Player(10))) {
            UnitAddAbility(Damager, 'A029');
            UnitRemoveAbility(Damager, 'A029');
          } else {
            UnitAddAbility(Damager, 'A0DG');
            UnitRemoveAbility(Damager, 'A0DG');
          }

          SetPlayerAbilityAvailableBJ(true, 'Afod', GetOwningPlayer(Damager));
          SetPlayerAbilityAvailableBJ(true, 'A099', GetOwningPlayer(Damager));
          SetPlayerAbilityAvailableBJ(true, 'AOwk', GetOwningPlayer(Damager));
          SetPlayerAbilityAvailableBJ(false, 'ANwk', GetOwningPlayer(Damager));
        }
      }

      if (Damager == GromUnit && !IsTargetAllyDamager) {
        udg_SliceandDiceOff = 1;
      }

      if (Damager == TichondriusUnit && GetUnitState(Damager, UNIT_STATE_MANA) >= 12 && udg_DarkTouchOn == 1 && !IsTargetAllyDamager) {
        udg_DarkTouchOff = 1;
      }

      if (Damager == ZulJinUnit && !IsTargetAllyDamager ) {
        Placeholder = CreateUnit(GetOwningPlayer(Damager), 'o008', GetUnitX(Target), GetUnitY(Target), 0);
        UnitAddAbility(Placeholder, 'ACcr');
        IssueTargetOrder(Placeholder, "cripple", Target);
        UnitApplyTimedLife(Placeholder, 'BTLF', 1);
        if (PrevTarget == Target) {
          udg_CarveDamage += 4 * GetUnitAbilityLevel(Damager, 'AIad');
        } else {
          udg_CarveDamage = 4 * GetUnitAbilityLevel(Damager, 'AIad');
        }
        DisableTrigger(TriggeringTrg);
        UnitDamageTarget(Damager, Target, udg_CarveDamage, true, true, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS);
        EnableTrigger(TriggeringTrg);
      }

      PrevTarget = Target;


      BashCooldownTimer = null;
      Placeholder = null;
      TempTimer = null;
      AmaniThrowAxeTimer = null;
      BlackrockChampionsAxeTimer = null;
      CorruptionEdgeTimer = null;
      TriggeringTrg = null;
      TempUnit = null;
      TempLoc = null;
      TempLocSecond = null;
      GaronaDamage = null;

    }

    function EventUnitDeath ()  -> nothing {
      if (GetKillingUnit() == GaronaUnit && IsUnitEnemy(GetDyingUnit(), GetOwningPlayer(GetKillingUnit())) && IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO)) {
        SetUnitPositionLoc(gg_unit_osw3_0435, GetUnitLoc(GetDyingUnit()));
        SetUnitAbilityLevelSwapped('A0BA', gg_unit_osw3_0435, GetUnitAbilityLevelSwapped('A099', GaronaUnit));
        IssueImmediateOrder(gg_unit_osw3_0435, "thunderclap");
        PlaySoundOnUnitBJ(gg_snd_FanOfKnives, 100, GaronaUnit);
      }
    }

    function IsUnitGarona ()  -> boolean {
      return (GetUnitTypeId(GetTriggerUnit()) == 'O001' || GetUnitTypeId(GetTriggerUnit()) == 'O000' || GetUnitTypeId(GetTriggerUnit()) == 'O00N');
    }

    function DisableGaronaTriggeringUltToAbility ()  -> nothing {
      IsGaronaUsedAbillity = true;
      TriggerSleepAction(0.1);
      IsGaronaUsedAbillity = false;
    }

    function onInit ()  -> nothing {
      trigger t = CreateTrigger();
      return;
      TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED);
      TriggerAddAction(t, function UnitOnDamage);
      t = CreateTrigger();
      TriggerRegisterPlayerUnitEvent(t, Player(9), EVENT_PLAYER_UNIT_SPELL_EFFECT, Condition(function IsUnitGarona));
      TriggerAddAction(t, function DisableGaronaTriggeringUltToAbility);
    }
  }
//! endzinc
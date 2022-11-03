//* requires CothUtilities library
scope Sandbox initializer onInit
  
  globals
    public player sandboxPlayer

    private hashtable addNewUnitData = InitHashtable()

    private constant integer MAX_HERO_SLOTS = 12
    private constant integer MAX_PLAYERS = 16
  endglobals

  private function SandboxInit takes nothing returns nothing
    local quest commandDescriptionHeading = CreateQuest()
    local questitem commandDescriptionBody = QuestCreateItem(commandDescriptionHeading)
    local string array commands
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 45, "Включен режим песочницы.|n Вам доступны следующие команды:")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-refresh")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-addunit")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-editunit")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-editplayer")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-enemy")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-ally")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "-solo")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 50, "Подробнее об этих командах вы можете прочитать в F9.")
    call QuestSetTitle(commandDescriptionHeading, "Команды песочницы.")
    call QuestItemSetDescription(commandDescriptionBody, "Описание команд песочницы.")
    set commands[0] = "|cffd88232-refresh:|r Сбрасывает перезарядку всех способностей, а так же восстанавливает всем войскам здоровье и ману. |nМожно добавлять аргументы: onlyability - сбрасывает только перезарядку всех способностей, |nonlyhp - восстанавливает всем только здоровье, |nonlymp - восстанавливает всем только ману, |nonlystats - восстанавливает всем здоровье и ману. |nУказать можно только 1 аргумент.|n"
    set commands[1] = "|cffd88232-addunit:|r Добавляет любого воина на карту. Так же позволяет добавлять и героев.|n"
    set commands[2] = "|cffd88232-editunit:|r Изменяет параметры любого воина или героя, а именно: включая урон, защиту, здоровье и так далее. Позволяет так же обнулить все добавленные изменения и восстановить полностью здоровье и/или ману.|n"
    set commands[3] = "|cffd88232-editplayer:|r Позволяет менять ресурсы и состояния игрока, такие как сделать его врагом для определенного игрока или группы игроков, и тому подобное.|n"
    set commands[4] = "|cffd88232-enemy:|r Делает альянс и орду врагами.|n"
    set commands[5] = "|cffd88232-ally:|r Делает альянс и орду союзниками.|n"
    set commands[6] = "|cffd88232-solo:|r Делает орду и альянс врагами, однако вы являетесь союзником и для орды и для альянса, а так же можете управлять ими."
    call QuestSetDescription(commandDescriptionHeading, commands[0] + commands[1] + commands[2] + commands[3] + commands[4] + commands[5] + commands[6])
    call QuestSetIconPath(commandDescriptionHeading, "Sandbox\\Icons\\CommandsDescriptionQuestIcon.blp")
  endfunction

  private function Refresh takes nothing returns nothing
    local group allUnits = CreateGroup()
    local unit u = null
    call GroupEnumUnitsInRect(allUnits, GetWorldBounds(), null)
    if CothUtilities_IsStringContains(GetEventPlayerChatString(), "onlyability", false) or CothUtilities_IsStringContains(GetEventPlayerChatString(), "щтднфишдшен", false) then
      loop
        set u = FirstOfGroup(allUnits)
        call UnitResetCooldown(u)
        call GroupRemoveUnit(allUnits, u)
        exitwhen FirstOfGroup(allUnits) == null
      endloop
    elseif CothUtilities_IsStringContains(GetEventPlayerChatString(), "onlyhp", false) or CothUtilities_IsStringContains(GetEventPlayerChatString(), "щтднрз", false) then
      loop
        set u = FirstOfGroup(allUnits)
        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        call GroupRemoveUnit(allUnits, u)
        exitwhen FirstOfGroup(allUnits) == null
      endloop
    elseif CothUtilities_IsStringContains(GetEventPlayerChatString(), "onlymp", false) or CothUtilities_IsStringContains(GetEventPlayerChatString(), "щтдньз", false) then
      loop
        set u = FirstOfGroup(allUnits)
        call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))
        call GroupRemoveUnit(allUnits, u)
        exitwhen FirstOfGroup(allUnits) == null
      endloop
    elseif CothUtilities_IsStringContains(GetEventPlayerChatString(), "onlystats", false) or CothUtilities_IsStringContains(GetEventPlayerChatString(), "щтдныефеы", false) then
      loop
        set u = FirstOfGroup(allUnits)
        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))
        call GroupRemoveUnit(allUnits, u)
        exitwhen FirstOfGroup(allUnits) == null
      endloop
    else
      loop
        set u = FirstOfGroup(allUnits)
        call UnitResetCooldown(u)
        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))
        call GroupRemoveUnit(allUnits, u)
        exitwhen FirstOfGroup(allUnits) == null
      endloop
    endif
    call DestroyGroup(allUnits)
    set allUnits = null
    set u = null
  endfunction

  
  struct AddNewUnitUtils

    dialog selectTypeOfUnit
    dialog selectPlayer
    dialog selectHeroType

    //Выбор, добавить героя или юнита
    button unitTypeHero
    button unitTypeUnit

    //Список кнопок, где ты выбираешь героя какого игрока создать?
    button array ownerOfHero[MAX_PLAYERS]
    //Список кнопок, где ты выбираешь юнита какого игрока создать?
    button array addUnitsOfPlayer[MAX_PLAYERS]

    //Кнопки героев фракций
    button array stromgardeHeroes[MAX_HERO_SLOTS]
    button array azerothHeroes[MAX_HERO_SLOTS]
    button array kulTirasHeroes[MAX_HERO_SLOTS]
    button array dalaranHeroes[MAX_HERO_SLOTS]
    button array demonHeroes[MAX_HERO_SLOTS]
    button array gnomeHeroes[MAX_HERO_SLOTS]
    button array elfHeroes[MAX_HERO_SLOTS]
    button array gilneasHeroes[MAX_HERO_SLOTS]
    button array lordaeronHeroes[MAX_HERO_SLOTS]
    button array hordeStrengthHeroes[MAX_HERO_SLOTS]
    button array hordeAgilityHeroes[MAX_HERO_SLOTS]
    button array hordeIntelligenceHeroes[MAX_HERO_SLOTS]

    //Список, каких героев добавить
    button array addHeroTypes[12]
    //Список, каких юнитов добавить
    button array addUnitTypes[400]
    //Кнопка следующего списка
    button nextList
    //Кнопка следующего игрока
    button nextPlayer
    //Кнопка предыдущего списка
    button previousList
    //Кнопка предыдущего игрока
    button previousPlayer
    
    method createAStromgardeHeroButtonList takes nothing returns nothing
      set this.stromgardeHeroes[0] = DialogAddButton(this.selectHeroType, "Торас", '1')
      set this.stromgardeHeroes[1] = DialogAddButton(this.selectHeroType, "Гален", '1')
      set this.stromgardeHeroes[2] = DialogAddButton(this.selectHeroType, "Данат", '1')
      set this.stromgardeHeroes[3] = DialogAddButton(this.selectHeroType, "Курдран", '1')
    endmethod

    method createAnAzerothHeroButtonList takes nothing returns nothing
      set this.azerothHeroes[0] = DialogAddButton(this.selectHeroType, "Андуин", '1')
      set this.azerothHeroes[1] = DialogAddButton(this.selectHeroType, "Кадгар", '1')
      set this.azerothHeroes[2] = DialogAddButton(this.selectHeroType, "Ллейн", '1')
      set this.azerothHeroes[3] = DialogAddButton(this.selectHeroType, "Мара", '1')
    endmethod

    method createAKulTirasHeroButtonList takes nothing returns nothing
      set this.kulTirasHeroes[0] = DialogAddButton(this.selectHeroType, "Даэлин", '1')
      set this.kulTirasHeroes[1] = DialogAddButton(this.selectHeroType, "Дюк", '1')
      set this.kulTirasHeroes[2] = DialogAddButton(this.selectHeroType, "Дерек", '1')
      set this.kulTirasHeroes[3] = DialogAddButton(this.selectHeroType, "Мишан", '1')
    endmethod

    method createADalaranHeroButtonList takes nothing returns nothing
      set this.dalaranHeroes[0] = DialogAddButton(this.selectHeroType, "Антонидас", '1')
      set this.dalaranHeroes[1] = DialogAddButton(this.selectHeroType, "Ронин", '1')
      set this.dalaranHeroes[2] = DialogAddButton(this.selectHeroType, "Кель'Тас", '1')
      set this.dalaranHeroes[3] = DialogAddButton(this.selectHeroType, "Аэгвинн", '1')
    endmethod

    method createADemonHeroButtonList takes nothing returns nothing
      set this.demonHeroes[0] = DialogAddButton(this.selectHeroType, "Архимонд", '1')
      set this.demonHeroes[1] = DialogAddButton(this.selectHeroType, "Кил'Джеден", '1')
      set this.demonHeroes[2] = DialogAddButton(this.selectHeroType, "Маннорот", '1')
      set this.demonHeroes[3] = DialogAddButton(this.selectHeroType, "Тихондриус", '1')
      set this.demonHeroes[4] = DialogAddButton(this.selectHeroType, "Медив", '1')
      set this.demonHeroes[5] = DialogAddButton(this.selectHeroType, "Азгалор", '1')
    endmethod

    method createAGnomeHeroButtonList takes nothing returns nothing
      set this.gnomeHeroes[0] = DialogAddButton(this.selectHeroType, "Магни", '1')
      set this.gnomeHeroes[1] = DialogAddButton(this.selectHeroType, "Бранн", '1')
      set this.gnomeHeroes[2] = DialogAddButton(this.selectHeroType, "Гелбин", '1')
      set this.gnomeHeroes[3] = DialogAddButton(this.selectHeroType, "Мурадин", '1')
    endmethod

    method createAnElfHeroButtonList takes nothing returns nothing
      set this.elfHeroes[0] = DialogAddButton(this.selectHeroType, "Анастериан", '1')
      set this.elfHeroes[1] = DialogAddButton(this.selectHeroType, "Аллерия", '1')
      set this.elfHeroes[2] = DialogAddButton(this.selectHeroType, "Лор'Темар", '1')
      set this.elfHeroes[3] = DialogAddButton(this.selectHeroType, "Сильванна", '1')
    endmethod

    method createAGilneasHeroButtonList takes nothing returns nothing
      set this.gilneasHeroes[0] = DialogAddButton(this.selectHeroType, "Генн", '1')
      set this.gilneasHeroes[1] = DialogAddButton(this.selectHeroType, "Аругал", '1')
      set this.gilneasHeroes[2] = DialogAddButton(this.selectHeroType, "Гевинрад", '1')
      set this.gilneasHeroes[3] = DialogAddButton(this.selectHeroType, "Дариус", '1')
    endmethod

    method createALordaeronHeroButtonList takes nothing returns nothing
      set this.lordaeronHeroes[0] = DialogAddButton(this.selectHeroType, "Утер", '1')
      set this.lordaeronHeroes[1] = DialogAddButton(this.selectHeroType, "Тирион", '1')
      set this.lordaeronHeroes[2] = DialogAddButton(this.selectHeroType, "Алонсий", '1')
      set this.lordaeronHeroes[3] = DialogAddButton(this.selectHeroType, "Имба", '1')
    endmethod

    method createAHordeStrengthHeroButtonList takes nothing returns nothing
      set this.hordeStrengthHeroes[0] = DialogAddButton(this.selectHeroType, "Блекхенд", '1')
      set this.hordeStrengthHeroes[1] = DialogAddButton(this.selectHeroType, "Оргрим", '1')
      set this.hordeStrengthHeroes[2] = DialogAddButton(this.selectHeroType, "Каргат", '1')
      set this.hordeStrengthHeroes[3] = DialogAddButton(this.selectHeroType, "Дентарг", '1')
      set this.hordeStrengthHeroes[4] = DialogAddButton(this.selectHeroType, "Ренд", '1')
    endmethod

    method createAHordeAgilityHeroButtonList takes nothing returns nothing
      set this.hordeAgilityHeroes[0] = DialogAddButton(this.selectHeroType, "Киллрог", '1')
      set this.hordeAgilityHeroes[1] = DialogAddButton(this.selectHeroType, "Гром", '1')
      set this.hordeAgilityHeroes[2] = DialogAddButton(this.selectHeroType, "Зул'Джин", '1')
      set this.hordeAgilityHeroes[3] = DialogAddButton(this.selectHeroType, "Гарона", '1')
      set this.hordeAgilityHeroes[4] = DialogAddButton(this.selectHeroType, "Мейм", '1')
      set this.hordeAgilityHeroes[5] = DialogAddButton(this.selectHeroType, "Гризельда", '1')
    endmethod

    method createAHordeIntelligenceHeroButtonList takes nothing returns nothing
      set this.hordeIntelligenceHeroes[0] = DialogAddButton(this.selectHeroType, "Гулдан", '1')
      set this.hordeIntelligenceHeroes[1] = DialogAddButton(this.selectHeroType, "Нер'Зул", '1')
      set this.hordeIntelligenceHeroes[2] = DialogAddButton(this.selectHeroType, "Терон", '1')
      set this.hordeIntelligenceHeroes[3] = DialogAddButton(this.selectHeroType, "Чо'Галл", '1')
      set this.hordeIntelligenceHeroes[4] = DialogAddButton(this.selectHeroType, "Фенрис", '1')
      set this.hordeIntelligenceHeroes[5] = DialogAddButton(this.selectHeroType, "Ратсо", '1')
      set this.hordeIntelligenceHeroes[6] = DialogAddButton(this.selectHeroType, "Зулухед", '1')
    endmethod

    method createDialogOfSelectHeroType takes nothing returns dialog
      set this.selectHeroType = DialogCreate()
      return this.selectHeroType
    endmethod

    method createButtonsForSelectPlayer takes nothing returns nothing
      set this.ownerOfHero[0] = DialogAddButton(this.selectPlayer, "Герои Стромгарда", '1')
      set this.ownerOfHero[1] = DialogAddButton(this.selectPlayer, "Герои Азерота", '2')
      set this.ownerOfHero[2] = DialogAddButton(this.selectPlayer, "Герои Кул'Тираса", '3')
      set this.ownerOfHero[3] = DialogAddButton(this.selectPlayer, "Герои Даларана", '4')
      set this.ownerOfHero[4] = DialogAddButton(this.selectPlayer, "Герои Демонов", '5')
      set this.ownerOfHero[5] = DialogAddButton(this.selectPlayer, "Герои Гномов", '6')
      set this.ownerOfHero[6] = DialogAddButton(this.selectPlayer, "Герои Эльфов", '7')
      set this.ownerOfHero[7] = DialogAddButton(this.selectPlayer, "Герои Гилнеаса", '8')
      set this.ownerOfHero[8] = DialogAddButton(this.selectPlayer, "Герои Лордерона", '9')
      set this.ownerOfHero[9] = DialogAddButton(this.selectPlayer, "Герои Силы у Орды", '000A')
      set this.ownerOfHero[10] = DialogAddButton(this.selectPlayer, "Герои Ловкости у Орды", '000B')
      set this.ownerOfHero[11] = DialogAddButton(this.selectPlayer, "Герои Интеллекта у Орды", '000C')
    endmethod

    method createDialogOfSelectPlayer takes nothing returns dialog
      set this.selectPlayer = DialogCreate()
      return this.selectPlayer
    endmethod
    

    method createChoiceHeroOrUnit takes nothing returns nothing
      set this.selectTypeOfUnit = DialogCreate()
      set this.unitTypeHero = DialogAddButton(this.selectTypeOfUnit, "Создать героя", '1')
      set this.unitTypeUnit = DialogAddButton(this.selectTypeOfUnit, "Создать воина", '2')
    endmethod

    static method create takes nothing returns thistype
      local thistype this = allocate()
      return this
    endmethod
    
  endstruct

  private function CreateHero takes nothing returns nothing
    local AddNewUnitUtils addNewHero = LoadInteger(addNewUnitData, GetHandleId(GetTriggeringTrigger()), 0)
    call FlushChildHashtable(addNewUnitData, GetHandleId(GetTriggeringTrigger()))
    call DestroyTrigger(GetTriggeringTrigger())
    if GetClickedButton() == addNewHero.stromgardeHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), thorasId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.stromgardeHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), galenId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.stromgardeHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), danathId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.stromgardeHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), curdranId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.azerothHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), anduinId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.azerothHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), khadgarId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.azerothHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), llaneId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.azerothHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), maraId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.kulTirasHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), daelinId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.kulTirasHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), dukeId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.kulTirasHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), derekId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.kulTirasHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), mishanId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.dalaranHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), antonidasId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.dalaranHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), rhoninId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.dalaranHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), kaelThasId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.dalaranHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), aegwynnId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.demonHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), archimondeId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.demonHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), killJaedenId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.demonHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), mannorothId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.demonHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), tichondriusId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.demonHeroes[4] then
      call CreateUnit(GetTriggerPlayer(), medivhId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.demonHeroes[5] then
      call CreateUnit(GetTriggerPlayer(), azgalorId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gnomeHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), magniId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gnomeHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), brannId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gnomeHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), gelbinId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gnomeHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), muradinId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.elfHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), anasterianId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.elfHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), alleriaId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.elfHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), lorThemarId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.elfHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), sylvanasId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gilneasHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), gennId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gilneasHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), arugalId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gilneasHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), gavinradId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.gilneasHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), dariusId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.lordaeronHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), utherId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.lordaeronHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), tirionId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.lordaeronHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), alonsusId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.lordaeronHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), tyralionId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeStrengthHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), blackhandId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeStrengthHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), orgrimId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeStrengthHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), kargathId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeStrengthHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), dentargId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeStrengthHeroes[4] then
      call CreateUnit(GetTriggerPlayer(), rendId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeAgilityHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), killrogId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeAgilityHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), gromId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeAgilityHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), zulJinId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeAgilityHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), garonaId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeAgilityHeroes[4] then
      call CreateUnit(GetTriggerPlayer(), maimId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeAgilityHeroes[5] then
      call CreateUnit(GetTriggerPlayer(), griseldaId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[0] then
      call CreateUnit(GetTriggerPlayer(), guldanId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[1] then
      call CreateUnit(GetTriggerPlayer(), nerzhulId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[2] then
      call CreateUnit(GetTriggerPlayer(), teronId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[3] then
      call CreateUnit(GetTriggerPlayer(), choGallId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[4] then
      call CreateUnit(GetTriggerPlayer(), fenrisId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[5] then
      call CreateUnit(GetTriggerPlayer(), ratsoId, 0, 0, 0)
    elseif GetClickedButton() == addNewHero.hordeIntelligenceHeroes[6] then
      call CreateUnit(GetTriggerPlayer(), zuluhedId, 0, 0, 0)
    endif
  endfunction
  
  private function SelectHero takes nothing returns nothing
    local button clickedButton = GetClickedButton()
    local AddNewUnitUtils addNewHero = LoadInteger(addNewUnitData, GetHandleId(GetTriggeringTrigger()), 0)
    local trigger onHeroSelected = CreateTrigger()
    call FlushChildHashtable(addNewUnitData, GetHandleId(GetTriggeringTrigger()))
    call DestroyTrigger(GetTriggeringTrigger())
    call addNewHero.createDialogOfSelectHeroType()
    //Герои фракции 0 (Стромгард)
    if clickedButton == addNewHero.ownerOfHero[0] then
      call addNewHero.createAStromgardeHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[1] then
      call addNewHero.createAnAzerothHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[2] then
      call addNewHero.createAKulTirasHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[3] then
      call addNewHero.createADalaranHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[4] then
      call addNewHero.createADemonHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[5] then
      call addNewHero.createAGnomeHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[6] then
      call addNewHero.createAnElfHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[7] then
      call addNewHero.createAGilneasHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[8] then
      call addNewHero.createALordaeronHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[9] then
      call addNewHero.createAHordeStrengthHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[10] then
      call addNewHero.createAHordeAgilityHeroButtonList()
    elseif clickedButton == addNewHero.ownerOfHero[11] then
      call addNewHero.createAHordeIntelligenceHeroButtonList()
    endif

    call DialogDisplay(GetTriggerPlayer(), addNewHero.selectHeroType, true)
    call SaveInteger(addNewUnitData, GetHandleId(onHeroSelected), 0, addNewHero)
    call TriggerRegisterDialogEvent(onHeroSelected, addNewHero.selectHeroType)
    call TriggerAddAction(onHeroSelected, function CreateHero)
  endfunction

  private function SelectPlayerOwnerOfHero takes nothing returns nothing
    local AddNewUnitUtils addNewUnit = AddNewUnitUtils.create()
    local trigger onDialogButtonClick = CreateTrigger()
    call DestroyTrigger(GetTriggeringTrigger())
    call addNewUnit.createDialogOfSelectPlayer()
    call addNewUnit.createButtonsForSelectPlayer()
    call DialogDisplay(GetTriggerPlayer(), addNewUnit.selectPlayer, true)
    call TriggerRegisterDialogEvent(onDialogButtonClick, addNewUnit.selectPlayer)
    call TriggerAddAction(onDialogButtonClick, function SelectHero)
    call SaveInteger(addNewUnitData, GetHandleId(onDialogButtonClick), 0, addNewUnit)
    set onDialogButtonClick = null
  endfunction

  private function SelectPlayerOwnerOfUnit takes nothing returns nothing

  endfunction

  private function AddNewUnit takes nothing returns nothing
    local AddNewUnitUtils addNewUnit = AddNewUnitUtils.create()
    local trigger onDialogButtonClick = CreateTrigger()
    call addNewUnit.createChoiceHeroOrUnit()
    call DialogDisplay(GetTriggerPlayer(), addNewUnit.selectTypeOfUnit, true)
    call TriggerRegisterDialogButtonEvent(onDialogButtonClick, addNewUnit.unitTypeHero)
    call TriggerAddAction(onDialogButtonClick, function SelectPlayerOwnerOfHero)
    set onDialogButtonClick = CreateTrigger()
    call TriggerRegisterDialogButtonEvent(onDialogButtonClick, addNewUnit.unitTypeUnit)
    call TriggerAddAction(onDialogButtonClick, function SelectPlayerOwnerOfUnit)
    set onDialogButtonClick = null
  endfunction

  private function EditUnit takes nothing returns nothing

  endfunction

  private function EditPlayer takes nothing returns nothing

  endfunction

  private function EditAllyState takes nothing returns nothing
    local integer commandEnemyIndex = CothUtilities_IndexOf(GetEventPlayerChatString(), "-enemy", false)
    local integer commandAllyIndex = CothUtilities_IndexOf(GetEventPlayerChatString(), "-ally", false)
    local integer commandSoloIndex = CothUtilities_IndexOf(GetEventPlayerChatString(), "-solo", false)
    local player p = null
    if commandEnemyIndex == -1 then
      set commandEnemyIndex = CothUtilities_IndexOf(GetEventPlayerChatString(), "-утуьн", false)
    endif
    if commandAllyIndex == -1 then
      set commandAllyIndex = CothUtilities_IndexOf(GetEventPlayerChatString(), "-фддн", false)
    endif
    if commandSoloIndex == -1 then
      set commandSoloIndex = CothUtilities_IndexOf(GetEventPlayerChatString(), "-ыщдщ", false)
    endif
    if (commandEnemyIndex < commandAllyIndex and commandEnemyIndex < commandSoloIndex) and commandEnemyIndex != -1 then //первая команда, что ввели это -enemy
      call SetForceAllianceStateBJ(alliancePlayers, hordePlayers, bj_ALLIANCE_UNALLIED)
      call SetForceAllianceStateBJ(hordePlayers, alliancePlayers, bj_ALLIANCE_UNALLIED)
    elseif (commandAllyIndex < commandEnemyIndex and commandAllyIndex < commandSoloIndex) and commandAllyIndex != -1 then //первая команда, что ввели это -ally
      call SetForceAllianceStateBJ(alliancePlayers, hordePlayers, bj_ALLIANCE_ALLIED_ADVUNITS)
      call SetForceAllianceStateBJ(hordePlayers, alliancePlayers, bj_ALLIANCE_ALLIED_ADVUNITS)
    elseif (commandSoloIndex < commandEnemyIndex and commandSoloIndex < commandAllyIndex) and commandSoloIndex != -1 then //первая команда, что ввели это -solo
      call SetForceAllianceStateBJ(alliancePlayers, hordePlayers, bj_ALLIANCE_UNALLIED)
      call SetForceAllianceStateBJ(hordePlayers, alliancePlayers, bj_ALLIANCE_UNALLIED)

      call SetForceAllianceStateBJ(alliancePlayers, bj_FORCE_PLAYER[GetPlayerId(GetTriggerPlayer())], bj_ALLIANCE_ALLIED_ADVUNITS)
      call SetForceAllianceStateBJ(hordePlayers, bj_FORCE_PLAYER[GetPlayerId(GetTriggerPlayer())], bj_ALLIANCE_ALLIED_ADVUNITS)
    endif
  endfunction
  
  public function GetSandboxPlayer takes nothing returns player
    local integer i = 0
    loop  
      if (IsPlayerSlotState(Player(i), PLAYER_SLOT_STATE_PLAYING)) and (GetPlayerController(Player(i)) == MAP_CONTROL_USER) then
        return Player(i)
      endif
      set i = i + 1
      exitwhen i == bj_MAX_PLAYERS
    endloop
    return null
  endfunction

  private function onInit takes nothing returns nothing
    local playerEvents onPlayerChatEvent = playerEvents.create()
    if not CothUtilities_IsLocalGame() then
      call onPlayerChatEvent.destroyEx()
      return
    endif
    set sandboxPlayer = GetSandboxPlayer()
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-refresh", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-рефреш", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-куакуыр", false)
    call onPlayerChatEvent.addAction(function Refresh)
    call onPlayerChatEvent.destroy()
    set onPlayerChatEvent = playerEvents.create()
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-addunit", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-фввгтше", false)
    call onPlayerChatEvent.addAction(function AddNewUnit)
    call onPlayerChatEvent.destroy()
    set onPlayerChatEvent = playerEvents.create()
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-editunit", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-увшегтше", false)
    call onPlayerChatEvent.addAction(function EditUnit)
    call onPlayerChatEvent.destroy()
    set onPlayerChatEvent = playerEvents.create()
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-editplayer", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-увшездфнук", false)
    call onPlayerChatEvent.addAction(function EditPlayer)
    call onPlayerChatEvent.destroy()
    set onPlayerChatEvent = playerEvents.create()
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-enemy", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-утуьн", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-ally", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-фддн", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-solo", false)
    call onPlayerChatEvent.registerAnyPlayerChatEvent("-ыщдщ", false)
    call onPlayerChatEvent.addAction(function EditAllyState)
    call onPlayerChatEvent.destroy()
    call TimerStart(CreateTimer(), 0, false, function SandboxInit )
  endfunction
endscope
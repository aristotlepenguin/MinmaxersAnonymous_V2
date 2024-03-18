local mod = MMAMod

if EID then
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_ABSTINENCE, "#When touching an item pedestal, the pedestal turns into a Chastity Card. Using the card grants the item.#If multiple cards have been created, the most recent item is dispensed first.#You can take a shop or devil deal in this way without paying its price; the price will be deducted when you use the card.", "Abstinence", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS, "#When moving down to a new floor, randomly open red room doors equal to the number of non-cleared rooms on the previous floor.#Unexplored rooms include red rooms opened using this item's effect.#The ??? and Home floors are skipped. The floor after ??? will use the unexplored rooms of Womb II.", "Dad's Sneakers", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET, "#When touching a pickup, if your capacity for that pickup is full, the amount will overflow into another pickup count. #Order of pickups is: Coins->Bombs/Keys->Red Hearts->Soul Hearts->Charges->Small stat increases", "Rain Bucket", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS, "#A random item icon will appear on the bottom right of the screen. Acquiring that item gives a large number of coins, a substantial all stats up, and four angel items.#If you do not find the item, this item has no effect.", "Isaac's Hopes and Dreams", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK, "#0.3 Tears Up#Items now have a chance to become glitched. The probability increases the lower your floor.", "Memory Leak", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES, "#On use, creates a large, screen-wiping tear blast for 15 seconds.#Gain additional streams of tears based on the Tears stat, and tears also fire in random directions based on the Luck stat.#If you crash the game while the beam is firing, the user gains 2x damage and loses the item upon returning to the game.", "Overclocked Sinuses", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_HYPERFIXATION, "After taking this item, the next card, pill or rune you take will lock all future cards/pills/runes to be only that one type for the rest of the run.", "Hyperfixation", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE, "Isaac has a chance to fire heavy tears that scale with Luck.#Heavy tears cause non-boss enemies to fall through the ground, creating a pit and sending the enemy to a random room on the next floor.", "Mom's Scale", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE, "Gain an extra life. Each time a room is cleared, all stats are reduced by a small amount.#After revival, your stats are restored, and increased further based on how long you survived.", "Job's Curse", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_D_SQRT, "Rerolls all items in the room. However, it uses a very particular formula to calculate this.#The formula is: Final item number = (<Number of bombs> * <old item number>^2 + <number of coins> * <old item number> + seconds on the timer + 109)/9 % <total number of items(732 in Repentance), plus modded ones>.#If the final item number is not a natural number, it will reroll into The Poop.", "D-Sqrt(-1)", "en_us")
    
    EID:addCard(mod.MMATypes.CARD_CHASTITY, "Use this card to gain one of the item pedestals you touched while holding Abstinence. The last item pedestal you touched is the first item out.", "Chastity Card", "en_us")
    local chasteHud = Sprite()
    chasteHud:Load("gfx/cards_1_chastity.anm2", true)
    EID:addIcon("Card" .. tostring(mod.MMATypes.CARD_CHASTITY), "HUDSmall", 0, 16, 16, 6, 6, chasteHud)

    EID:addBirthright(mod.MMATypes.CHARACTER_EPAPHRAS, "Reduces limits for coins, bombs and keys to 45. If coin limits for Maxie are set to 99, Birthright sets them to 65.", "Maxie", "en_us")
    
    if REPENTOGON then
        EID:addBirthright(mod.MMATypes.CHARACTER_EPAPHRAS_B, "Red rooms opened when descending floors now have a 20% chance to be special rooms, up from 10%", "Minnie", "en_us")
    else
        EID:addBirthright(mod.MMATypes.CHARACTER_EPAPHRAS_B, "3 more red rooms are opened when descending floors, in addition to ignored rooms.", "Minnie", "en_us")
    end


    EID:addCollectible(mod.MMATypes.COLLECTIBLE_ABSTINENCE, "#При прикосновении к пьедесталу с предметом он превращается в карту целомудрия. Использование карты дает предмет.#Если было создано несколько карт, первым выдается самый последний предмет.#Вы можете таким образом заключить сделку в магазине или с дьяволом, не платя за нее.", "Воздержание", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS, "##При переходе на новый этаж случайным образом открываются двери красных комнат, равные количеству непройденных комнат на предыдущем этаже.#Неисследованные комнаты на этажах, включаются в красные комнаты, открытые с использованием эффекта этого предмета.#Этажи как ??? и Дом пропускаются. Этаже после ??? будет использовать неизведанные комнаты Утробы II", "Папины кроссовки", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET, "#Если вместимость ведра для этого пикапа заполнена, то при повтрном прикосновении к пикапу, вместимость ведра переполнится и перейдет в другой счетчик пикапов. # Иерархия получения: Монеты->Бомбы/Ключи->Красные сердца->Сердца души->Заряды->Небольшое увеличение характеристик.", "Дождевое ведро", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS, "#В правом нижнем углу экрана появится значок случайного предмета. Если вы заполучите его, то в награду вам дадут большое количество монет, существенное улучшение всех характеристик и четыре предмета ангела.#Если вы не нашли этот предмет, то предмет не имеет никакого эффекта.", "Надежды и мечты Исаака", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK, "#+0.3 к скорострельности#Теперь у предметов есть шанс превратиться в гличнутый предмет. Чем ниже ваш этаж, вероятность увеличивается.", "Утечка памяти", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES, "#При использовании создает большой поток слез, \"протирающий экран\", на 15 секунд.#Получите дополнительные потоки слез если увеличете харрактеристику скорострельности, также слезы выпускаются в случайных направлениях зависящих от удачи.#Если у вас крашится игра, то игрок получает двукратный урон и теряет предмет при возвращении в игру.", "Разогнанные синусы", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_HYPERFIXATION, "После подбора этого предмета, следующая использованная: карта, пилюля или руна, запомнит их. Все карты/пилюли/руны которые вы встретие будут такого же эффекта как от первого использования, до конца забега.", "Гиперфиксация", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE, "У Исаака есть шанс выпустить тяжелые слезы, которые масштабируются в зависимости от Удачи. #Тяжелые слезы заставляют врагов, проваливаться под землю, создавая яму и отправляя врага в случайную комнату на следующем этаже. (не влияет на боссов)", "Мамины весы", "ru")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE, "Вы получаете доп. жизнь. Каждый раз, когда комната зачищаеться, все характеристики немного уменьшаются.#После возрождения ваши характеристики восстанавливаются и увеличиваются в зависимости от того, как много вы зачистили комнат.", "Проклятие Иова", "ru")
    
    EID:addCard(mod.MMATypes.CARD_CHASTITY, "Используя эту карту, вы получите один из пьедесталов с предметом, к которым вы прикоснулись, пока держали в руках эту карту. Последний пьедестал предмета, которого вы коснулись, является первым предметом.", "Карта целомудрия", "ru")
    local chasteHud = Sprite()
    chasteHud:Load("gfx/cards_1_chastity.anm2", true)
    EID:addIcon("Card" .. tostring(mod.MMATypes.CARD_CHASTITY), "HUDSmall", 0, 16, 16, 6, 6, chasteHud)

    EID:addBirthright(mod.MMATypes.CHARACTER_EPAPHRAS, "Уменьшает лимит на монеты, бомбы и ключи до 45. Если лимит монет для \"Макси\" установлен на 99, право первородства устанавливает их на 65.", "Maxie", "ru")
    
    if REPENTOGON then
        EID:addBirthright(mod.MMATypes.CHARACTER_EPAPHRAS_B, "Красные комнаты, открывающиеся при спуске по этажам, теперь имеют 20% шанс оказаться особыми комнатами вместо 10%.", "Minnie", "ru")
    else
        EID:addBirthright(mod.MMATypes.CHARACTER_EPAPHRAS_B, "На каждом этаже открываются еще 3 красные комнаты, помимо игнорируемых комнат.", "Minnie", "ru")
    end
end
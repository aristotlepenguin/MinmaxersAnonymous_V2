local mod = MMAMod

if EID then
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_ABSTINENCE, "#When touching an item pedestal, the pedestal turns into a Chastity Card. Using the card grants the item.#If multiple cards have been created, the most recent item is dispensed first.#You can take a shop or devil deal in this way without paying its price; the price will be deducted when you use the card.", "Abstinence", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS, "#When moving down to a new floor, randomly open red room doors equal to the number of non-cleared rooms on the previous floor.#Unexplored rooms include red rooms opened using this item's effect.#The ??? and Home floors are skipped. The floor after ??? will use the unexplored rooms of Womb II.", "Dad's Sneakers", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET, "#When touching a pickup, if your capacity for that pickup is full, the amount will overflow into another pickup count. #Order of pickups is: Coins->Bombs/Keys->Red Hearts->Soul Hearts->Charges->Small stat increases", "Rain Bucket", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS, "#A random item icon will appear on the bottom right of the screen. Acquiring that item gives a large number of coins, a substantial all stats up, and four angel items.#If you do not find the item, this item has no effect.", "Isaac's Hopes and Dreams", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK, "#0.3 Tears Up#Items now have a chance to become glitched. The probability increases the lower your floor.", "Memory Leak", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES, "#On use, creates a large, screen-wiping tear blast for 15 seconds.#Gain additional streams of tears based on the Tears stat, and tears also fire in random directions based on the Luck stat.#If you crash the game while the beam is firing, all players gain 2x damage and lose the item upon returning to the game.", "Overclocked Sinuses", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_HYPERFIXATION, "After taking this item, the next card, pill or rune you take will lock all future cards/pills/runes to be only that one type for the rest of the run.", "Hyperfixation", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE, "Isaac has a chance to fire heavy tears that scale with Luck.#Heavy tears cause non-boss enemies to fall through the ground, creating a pit and sending the enemy to a random room on the next floor.", "Mom's Scale", "en_us")
    EID:addCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE, "Gain an extra life. Each time a room is cleared, all stats are reduced by a small amount.#After revival, your stats are restored, and increased further based on how long you survived.", "Job's Curse", "en_us")
    
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
end
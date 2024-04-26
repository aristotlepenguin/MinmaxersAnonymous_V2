return function(mod)

    local function GI(i) return Isaac.GetItemIdByName(i)>0 and Isaac.GetItemIdByName(i) or Isaac.GetTrinketIdByName(i) end

	local Collectible = {
		[GI("Rain Bucket")]={ru={"Дождевое ведро","Лови плюшки!"},},
		[GI("Abstinence")]={ru={"Воздержание","Ты ещё не готов"},},
		[GI("Memory Leak")]={ru={"Утечка памяти","Скорострельность + ощущение утечки"},},
		[GI("Hyperfixation")]={ru={"Гиперфиксация","Ты так одержим c этой штукой!"},},
		[GI("Isaac's Hopes and Dreams")]={ru={"Надежды и мечты Исаака","Да верно…"},},
		[GI("Dad's Sneakers")]={ru={"Папины кроссовки","He оглядывайся назад"},},
		[GI("Overclocked Sinuses")]={ru={"Разогнанные синусы","Однократное огроничение удаления времени"},},
		[GI("Job's Curse")]={ru={"Проклятие Иова","Bce характеристики понижены + вы чувствуете себя испытанным"},},
		[GI("D-Sqrt(-1)")]={ru={"D-Квадрат(-1)","Переверните свою головную боль"},},
		[GI("Mom's Scale")]={ru={"Мамины весы","Тяжелые слезы"},}
	}

	local Cards={
        ['Chastity Card']={ru={"Карта целомудрия","Карта целомудрия"},}
        --['']={ru={"",""},},
        }

	local ModTranslate = {
		['Collectibles'] = Collectible,
		--['Trinkets'] = Trinket,
		['Cards'] = Cards,
		--['Pills'] = Pills,
	}
	ItemTranslate.AddModTranslation("MinmaxersAnonymous_V2", ModTranslate, {ru = true})
end
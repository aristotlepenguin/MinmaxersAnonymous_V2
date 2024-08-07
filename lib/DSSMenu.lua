return function(mod)

local DSSModName = "Dead Sea Scrolls (MinmaxersAnonymous)"
    
local DSSCoreVersion = 6
    
local MenuProvider = {}
    
function MenuProvider.SaveSaveData()
    mod:savePersistentData()
end
    
function MenuProvider.GetPaletteSetting()
    return mod.GetMenuSaveData().MenuPalette
end
    
function MenuProvider.SavePaletteSetting(var)
    mod.GetMenuSaveData().MenuPalette = var
end
    
function MenuProvider.GetGamepadToggleSetting()
    return mod.GetMenuSaveData().GamepadToggle
end
    
function MenuProvider.SaveGamepadToggleSetting(var)
    mod.GetMenuSaveData().GamepadToggle = var
end
    
function MenuProvider.GetMenuKeybindSetting()
    return mod.GetMenuSaveData().MenuKeybind
end
    
function MenuProvider.SaveMenuKeybindSetting(var)
    mod.GetMenuSaveData().MenuKeybind = var
end
    
function MenuProvider.GetMenuHintSetting()
    return mod.GetMenuSaveData().MenuHint
end
    
function MenuProvider.SaveMenuHintSetting(var)
    mod.GetMenuSaveData().MenuHint = var
end
    
function MenuProvider.GetMenuBuzzerSetting()
    return mod.GetMenuSaveData().MenuBuzzer
end
    
function MenuProvider.SaveMenuBuzzerSetting(var)
    mod.GetMenuSaveData().MenuBuzzer = var
end
    
function MenuProvider.GetMenusNotified()
    return mod.GetMenuSaveData().MenusNotified
end
    
function MenuProvider.SaveMenusNotified(var)
    mod.GetMenuSaveData().MenusNotified = var
end
    
function MenuProvider.GetMenusPoppedUp()
    return mod.GetMenuSaveData().MenusPoppedUp
end
    
function MenuProvider.SaveMenusPoppedUp(var)
    mod.GetMenuSaveData().MenusPoppedUp = var
end
    
local DSSInitializerFunction = include("lib.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local strings = {
    Title = {
        en = "minmaxers",
        --es = "minmaxers",
    },
    resume_game = {
        en = "resume game",
        --ru = "вернуться в игру",
    },
    settings = {
        en = "settings",
        --ru = "настройки",
    },
    yes = {
        en = "yes",
        --ru = "да",
    },
    no = {
        en = "no",
        --ru = "нет",
    },
    enable = {
        en = "enable",
        --ru = "включен",
    },
    disable = {
        en = "disabled",
       -- ru = "выключен",
    },
    startTooltip = {
        en = dssmod.menuOpenToolTip,
       -- ru = { strset = { 'переключение', 'меню', '', 'клавиатура:', '[c] или [f1]', '', 'контроллер:', 'нажатие', 'на стик' }, fsize = 2 }
    },
    maxie_bs_mode1 = {
        en = "maxie",
        --ru = "режим рюкзака",
    },
    maxie_bs_mode2 = {
        en = "boss rush/hush",
        --ru = "спелеолога",
    },
    mbs_var1 = {
		en = "no timer",
		--ru = "взрывать особые",
	},
	mbs_var2 = {
		en = "keep timer",
		--ru = "бомбы в руки",
	},

    maxie_pocket = {
        en = "pocket limits"
    },
    pocket1 = {
        en = "65"
    },
    pocket2 = {
        en = "99"
    },

    job_curse = {
        en = "job's curse"
    },
    job_stat_payout = {
        en = "stat payout"
    },
    job_1 = {
        en = "1/4"
    },
    job_2 = {
        en = "1/2"
    },
    job_3 = {
        en = "1"
    },
    hopes_dreams = {
        en = "hopes and dreams"
    },
    hopes_dream_pool = {
        en = "item select"
    },
    hopes_1 = {
        en = "unobtained items only"
    },
    hopes_2 = {
        en = "all items"
    },
    sa_score = {
        en = "road to one million"
    },
    sa_score_2 = {
        en = "score goal"
    },
    sa_score_1m = {
        en = "1 million"
    },
    sa_score_10m = {
        en = "10 million"
    },
    sa_score_100m = {
        en = "100 million"
    },
    sa_score_1b = {
        en = "1 billion"
    },
    itemswitch_rd = {
        en = "item switch"
    },
    itemswitch_on = {
        en = "on"
    },
    itemswitch_off = {
        en = "off"
    },
    itemswitch_hopes_dreams = {
        en = "hopes and dreams"
    },
    itemswitch_rain_bucket = {
        en = "rain bucket"
    },
    itemswitch_dads_sneakers = {
        en = "dad's sneakers"
    },
    itemswitch_d_sqrt = {
        en = "d-sqrt(-1)"
    },
    itemswitch_jobs_curse = {
        en = "job's curse"
    },
    itemswitch_hyperfixation = {
        en = "hyperfixation"
    },
    itemswitch_overclocked = {
        en = "overclocked sinuses"
    },
    itemswitch_memory_leak = {
        en = "memory leak"
    },
    itemswitch_moms_scale = {
        en = "mom's scale"
    },
    itemswitch_abstinence = {
        en = "abstinence"
    },
}
local function GetStr(str)
    return strings[str] and (strings[str][Options.Language] or strings[str].en) or str
end


local mainDirectory = {
    main = {
        title = GetStr("Title"),
        format = {
        Panels = {
            {
                Panel = dssmod.panels.main,
                Offset = Vector(-42, 10),
                Color = 1
            },
            {
                Panel = dssmod.panels.tooltip,
                Offset = Vector(130, -2),
                Color = 1
            }
        }
        },
            
        buttons = {
            {str = GetStr('resume_game'), action = 'resume'},
                {str = '', nosel = true, fsize = 3},
                {str = GetStr('maxie_bs_mode1'), nosel = true, fsize = 3},
                {
                    str = GetStr('maxie_bs_mode2'),
                    choices = {GetStr('mbs_var1'),GetStr('mbs_var2')}, 
                    variable = 'MaxieBossRush',
                    setting = 1,
                    load = function()
                        return MMAMod.MenuData.MaxieBossRush or 1
                    end,
                    store = function(var)
                        MMAMod.MenuData.MaxieBossRush = var
                    end,
                },
                {
                    str = GetStr('maxie_pocket'),
                    choices = {GetStr('pocket1'),GetStr('pocket2')}, 
                    variable = 'MaxiePocketLimits',
                    setting = 1,
                    load = function()
                        return MMAMod.MenuData.MaxiePocketLimits or 1
                    end,
                    store = function(var)
                        MMAMod.MenuData.MaxiePocketLimits = var
                    end,
                },
                {str = '', nosel = true, fsize = 3},
                {str = GetStr('job_curse'), nosel = true, fsize = 3},
                {
                    str = GetStr('job_stat_payout'),
                    choices = {GetStr('job_1'),GetStr('job_2'),GetStr('job_3')}, 
                    variable = 'JobStatPayout',
                    setting = 1,
                    load = function()
                        return MMAMod.MenuData.JobStatPayout or 1
                    end,
                    store = function(var)
                        MMAMod.MenuData.JobStatPayout = var
                    end,
                    
                },
                {str = '', nosel = true, fsize = 3},
                {str = GetStr('hopes_dreams'), nosel = true, fsize = 3},
                {
                    str = GetStr('hopes_dream_pool'),
                    choices = {GetStr('hopes_1'),GetStr('hopes_2')}, 
                    variable = 'HopesItemSelect',
                    setting = 1,
                    load = function()
                        return MMAMod.MenuData.HopesItemSelect or 1
                    end,
                    store = function(var)
                        MMAMod.MenuData.HopesItemSelect = var
                    end,
                    
                },
                {str = GetStr(''), nosel = true, fsize = 3},
                {str = GetStr('sa_score'), nosel = true, fsize = 3},
                {
                    str = GetStr('sa_score_2'),
                    choices = {GetStr('sa_score_1m'), GetStr('sa_score_10m'), GetStr('sa_score_100m'), GetStr('sa_score_1b')},
                    variable = 'ScoreAssaultScore',
                    setting = 1,
                    load = function()
                        return MMAMod.MenuData.ScoreAssaultScore or 1
                    end,
                    store = function(var)
                        MMAMod.MenuData.ScoreAssaultScore = var
                    end,
                },
                {str = 'item switch', dest = 'item_switch'},
                },
                tooltip = GetStr("startTooltip")
                },
        item_switch ={
            title = GetStr("itemswitch_rd"),
            format = {
                Panels = {
                    {
                        Panel = dssmod.panels.main,
                        Offset = Vector(-42, 10),
                        Color = 1
                    },
                    {
                        Panel = dssmod.panels.tooltip,
                        Offset = Vector(130, -2),
                        Color = 1
                    }
                }
                },
                buttons = {
                    {str = GetStr('item switch'), nosel = true, fsize = 3},
                    {
                        str = GetStr('itemswitch_rain_bucket'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'RainBucketItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_RAIN_BUCKET)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_RAIN_BUCKET)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_dads_sneakers'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'DadSneakersItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_hopes_dreams'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'HopesItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_hyperfixation'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'HyperfixItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_HYPERFIXATION)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_HYPERFIXATION)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_d_sqrt'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'DSqrtItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_D_SQRT)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_D_SQRT)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_jobs_curse'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'JobItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_JOBS_CURSE)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_JOBS_CURSE)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_memory_leak'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'MemoryLeakItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_MEMORY_LEAK)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_MEMORY_LEAK)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_abstinence'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'AbstinenceItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_ABSTINENCE)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_ABSTINENCE)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_overclocked'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'OverclockItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)] = var
                        end,
                    },
                    {
                        str = GetStr('itemswitch_moms_scale'),
                        choices = {GetStr('itemswitch_on'),GetStr('itemswitch_off')},
                        variable = 'MomScaleItemSwitch',
                        setting = 1,
                        load = function()
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            return MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_MOMS_SCALE)] or 1
                        end,
                        store = function(var)
                            if not MMAMod.MenuData.ItemSwitch then
                                MMAMod.MenuData.ItemSwitch = {}
                            end
                            MMAMod.MenuData.ItemSwitch[tostring(MMAMod.MMATypes.COLLECTIBLE_MOMS_SCALE)] = var
                        end,
                    },
            },
            tooltip = GetStr("startTooltip")
        },



        minmaxers = {
            title = GetStr('settings'),
            buttons = {
                dssmod.gamepadToggleButton,
                dssmod.menuKeybindButton,
            }
        }
    }
        
    local Minmaxersdirectorykey = {
        Item = mainDirectory.main,
        Main = 'main',
        Idle = false,
        MaskAlpha = 1,
        Settings = {},
        SettingsChanged = false,
        Path = {},
    }
    
    DeadSeaScrollsMenu.AddMenu("minmaxers", {
        Run = dssmod.runMenu, 
        Open = dssmod.openMenu,
        Close = dssmod.closeMenu,
        Directory = mainDirectory,
        DirectoryKey = Minmaxersdirectorykey
    })
    end
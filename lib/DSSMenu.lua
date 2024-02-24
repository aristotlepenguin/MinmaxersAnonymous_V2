return function(mod)

local DSSModName = "Dead Sea Scrolls (MinmaxersAnonymous)"
    
local DSSCoreVersion = 6
    
local MenuProvider = {}
    
function MenuProvider.SaveSaveData()
    mod.StoreSaveData()
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
}
local function GetStr(str)
    return strings[str] and (strings[str][Options.Language] or strings[str].en) or str
end


MMAMod.DSSdirectory = {
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
        Item = MMAMod.DSSdirectory.main,
        Main = 'main',
        Idle = false,
        MaskAlpha = 1,
        Settings = {},
        SettingsChanged = false,
        Path = {},
    }
    
    DeadSeaScrollsMenu.AddMenu("minmaxers", {
        Run = dssmod.runMenu, Open = dssmod.openMenu,
        Close = dssmod.closeMenu, Directory = MMAMod.DSSdirectory,
        DirectoryKey = Minmaxersdirectorykey,
        UseSubMenu = true,
    })
    end
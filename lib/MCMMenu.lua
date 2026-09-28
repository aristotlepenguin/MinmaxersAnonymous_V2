local json = require('json')

return function(mod)

    --In case we reload the mod you dont want multiple tabs to show up in the menu 
    ModConfigMenu.RemoveCategory("MinmaxersAnonymous")
    ModConfigMenu.UpdateCategory("MinmaxersAnonymous", {
        Name = "MinmaxersAnonymous",
        Info = "Min-Max your settings!"
    })

    --Load settings and set some defaults
    if not mod.MenuData then
        if mod:HasData() then
            mod.MenuData = json.decode(mod:LoadData()).MenuData or {}
        else
            mod.MenuData = {}
        end
    end

    --Set some defaults
    if mod.MenuData.MaxieBossRush == nil then mod.MenuData.MaxieBossRush = 1 end
    if mod.MenuData.MaxiePocketLimits == nil then mod.MenuData.MaxiePocketLimits = 1 end
    if mod.MenuData.JobStatPayout == nil then mod.MenuData.JobStatPayout = 1 end
    if mod.MenuData.HopesItemSelect == nil then mod.MenuData.HopesItemSelect = 1 end
    if mod.MenuData.ScoreAssaultScore == nil then mod.MenuData.ScoreAssaultScore = 1 end

    if mod.MenuData.ItemSwitch == nil then mod.MenuData.ItemSwitch = {} end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HYPERFIXATION)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HYPERFIXATION)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_D_SQRT)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_D_SQRT)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_ABSTINENCE)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_ABSTINENCE)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)] = 1 end
    if mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)] == nil then mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)] = 1 end



    ModConfigMenu.AddText("MinmaxersAnonymous", nil, "Maxie")

    --Maxie Boss Rush--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.MaxieBossRush end,
        
        Display = function() 
            local choices = {[1] = "No Timer", [2] = "Keep Timer"}
            return "Boss Rush/Hush: " .. (choices[mod.MenuData.MaxieBossRush])
            end,
    
        OnChange = function(new)
            mod.MenuData.MaxieBossRush = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Allow boss rush and hush to always show up while playing Maxie" }
    })

    --Maxie's Pockets--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

    Type = ModConfigMenu.OptionType.NUMBER,

    Default = 1,

    CurrentSetting = function() return mod.MenuData.MaxiePocketLimits end,
    
    Display = function() 
        local choices = {[1] = "65", [2] = "99"}
        return "Pocket Limits: " .. (choices[mod.MenuData.MaxiePocketLimits])
        end,

    OnChange = function(new)
        mod.MenuData.MaxiePocketLimits = new
        mod.saveData()
    end,

    Minimum = 1,

    Maximum = 2,

    Info = { "Determines how many pickups Maxie can hold" }
    })

    ModConfigMenu.AddSpace("MinmaxersAnonymous", nil)

    --Jobs Curse--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, { 

        Type = ModConfigMenu.OptionType.NUMBER,
     
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.JobStatPayout end,
    
        Display = function() 
            local choices = {[1] = "1/4", [2] = "1/2", [3] = "1"}
            return "Job's Curse Payout: " .. (choices[mod.MenuData.JobStatPayout])
            end,
    
        OnChange = function(new)
            mod.MenuData.JobStatPayout = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 3,
    
        Info = { "Change the amount of stats you get from Job's Curse" }
    })

    ModConfigMenu.AddSpace("MinmaxersAnonymous", nil)
    ModConfigMenu.AddText("MinmaxersAnonymous", nil, "Hopes and Dreams")

    --Hopes Item Select--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.HopesItemSelect end,
        
        Display = function() 
            local choices = {[1] = "Unobtained Only", [2] = "All Items"}
            return "Item Select: " .. (choices[mod.MenuData.HopesItemSelect])
            end,
    
        OnChange = function(new)
            mod.MenuData.HopesItemSelect = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Change what kind of item can be chosen as the goal for Hopes and Dreams" }
    })

    ModConfigMenu.AddSpace("MinmaxersAnonymous", nil)
    ModConfigMenu.AddText("MinmaxersAnonymous", nil, "Road to One Million")

    --Score Assault--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ScoreAssaultScore end,
        
        Display = function() 
            local choices = {[1] = "1 Million", [2] = "10 Million", [3] = "100 Million", [4] = "1 Billion"}
            return "Score Goal: " .. (choices[mod.MenuData.ScoreAssaultScore])
            end,
    
        OnChange = function(new)
            mod.MenuData.ScoreAssaultScore = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 4,
    
        Info = { "placeholder text" }
    })


    -------------------------ITEM SWITCHES-------------------------

    ModConfigMenu.AddSpace("MinmaxersAnonymous", nil)
    ModConfigMenu.AddText("MinmaxersAnonymous", nil, "Item Switch")
    

    --Rain Bucket--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Rain Bucket: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Rain Bucket appears" }
    })

    --Dad's Sneakers--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Dad's Sneakers: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Dad's Sneakers appear" }
    })

    --Hopes and Dreams--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Hopes and Dreams: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Hopes and Dreams appears" }
    })

    --Hyperfixation--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HYPERFIXATION)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Hyperfixation: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HYPERFIXATION)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_HYPERFIXATION)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Hyperfixation appears" }
    })

    --D Sqrt--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 2,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_D_SQRT)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "D SQRT(-1): " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_D_SQRT)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_D_SQRT)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = {  "Toggle whether D Sqrt [-1] appears"  }
    })

    --Job's Curse--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Job's Curse: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Job's Curse appears" }
    })

    --Memory Leak--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Memory Leak: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Memory Leak appears" }
    })

    --Abstinence--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_ABSTINENCE)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Abstinence: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_ABSTINENCE)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_ABSTINENCE)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Abstinance appears" }
    })

    --Overclocked Sinuses--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Overclocked Sinuses: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Overclocked Sinuses appears" }
    })

    --Mom's Scale--
    ModConfigMenu.AddSetting("MinmaxersAnonymous", nil, {

        Type = ModConfigMenu.OptionType.NUMBER,
    
        Default = 1,
    
        CurrentSetting = function() return mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)] end,
        
        Display = function() 
            local choices = {[1] = "On", [2] = "Off"}
            return "Mom's Scale: " .. (choices[mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)]])
            end,
    
        OnChange = function(new)
            mod.MenuData.ItemSwitch[tostring(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)] = new
            mod.saveData()
        end,
    
        Minimum = 1,
    
        Maximum = 2,
    
        Info = { "Toggle whether Mom's Scale appears" }
    })
end

--AaronRuinsLives
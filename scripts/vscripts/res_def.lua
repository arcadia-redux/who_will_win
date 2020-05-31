if ParticleRes == nil then
    ParticleRes = {}
    ParticleRes.TP_START = "particles/items2_fx/teleport_start.vpcf"
    ParticleRes.TP_END = "particles/items2_fx/teleport_end.vpcf"
    ParticleRes.OPEN_ROLL_PANEL = "particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7_ribbon_bright.vpcf"
    ParticleRes.SELL_HERO = "particles/items2_fx/hand_of_midas.vpcf"
    ParticleRes.REFRESH_HERO = "particles/items2_fx/refresher.vpcf"
    ParticleRes.RETRIEVE_ITEM = "particles/items2_fx/butterfly_active.vpcf"
    ParticleRes.LEVEL_UP = "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf"
    ParticleRes.HERO_MOVE_DROP = "particles/units/heroes/hero_rubick/rubick_telekinesis_marker.vpcf"
    ParticleRes.HERO_MOVE_LIFT = "particles/units/heroes/hero_rubick/rubick_telekinesis.vpcf"
    ParticleRes.HERO_MOVE_LAND = "particles/units/heroes/hero_rubick/rubick_telekinesis_land.vpcf"
    ParticleRes.HERO_REMOVE = "particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf"
    ParticleRes.HERO_CREATE = "particles/items_fx/aegis_respawn_aegis_starfall.vpcf"
    ParticleRes.HERO_RESPAWN = "particles/items_fx/aegis_respawn_spotlight.vpcf"
    ParticleRes.CONTROL_HERO = "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_explosion_alliance_trail.vpcf"
end

if SoundRes == nil then
    SoundRes = {}
    SoundRes.TP_START = "Portal.Hero_Disappear"
    SoundRes.TP_START_LOOP = "Portal.Loop_Disappear"
    SoundRes.TP_END = "Portal.Hero_Appear"
    SoundRes.TP_END_LOOP = "Portal.Loop_Appear"
    SoundRes.OPEN_ROLL_PANEL = "frostivus_ui_select"
    SoundRes.RETRIEVE_ITEM = "DOTA_Item.Hand_Of_Midas"
    SoundRes.RETRIEVE_ITEM_REVERSE = "DOTA_Item.PhaseBoots.Activate"
    SoundRes.LEVEL_UP = "Hero_Omniknight.GuardianAngel"
    SoundRes.HERO_MOVE_CASTER = "Hero_Rubick.Telekinesis.Cast"
    SoundRes.HERO_MOVE_TARGET = "Hero_Rubick.Telekinesis.Target"
    SoundRes.HERO_MOVE_LAND = "Hero_Rubick.Telekinesis.Target.Land"
    SoundRes.HERO_REMOVE = "Hero_Lion.Hex.Fishstick"
    SoundRes.HERO_REFRESH = "DOTA_Item.Refresher.Activate"
    SoundRes.TIME_TICK = "General.CastFail_AbilityInCooldown"
    SoundRes.COIN_BIG = "General.CoinsBig"
    SoundRes.STAGE_PREPARE = "Loot_Drop_Stinger_Legendary"
    SoundRes.STAGE_PREFIGHT = "GameStart.RadiantAncient"
    SoundRes.RAD_VICTORY = "DDW.RadVictory"
    SoundRes.DIRE_VICTORY = "DDW.DireVictory"
    SoundRes.BATTLE_DRAW = "DDW.BattleDraw"
    SoundRes.GAME_OVER = "dsadowski_01.stinger.dire_win"
    SoundRes.READY_FOR_FIGHT = "DDW.SetReady"
    SoundRes.CONTROL_HERO = "DOTA_Item.Mango.Activate"
end

if PreloadSounds == nil then
    PreloadSounds = {"soundevents/game_sounds_heroes/game_sounds_lion.vsndevts",
        "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts",
        "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts",
        "soundevents/ddw.vsndevts",
        "soundevents/music/dsadowski_01/soundevents_stingers.vsndevts",
    }
end

if PreloadModels == nil then
    PreloadModels = {
        "models/courier/huntling/huntling.vmdl",
        "models/courier/huntling/huntling_flying.vmdl",
        "models/items/courier/captain_bamboo/captain_bamboo.vmdl",
        "models/items/courier/captain_bamboo/captain_bamboo_flying.vmdl",
        "models/items/courier/nexon_turtle_15_red/nexon_turtle_15_red.vmdl",
        "models/items/courier/nexon_turtle_15_red/nexon_turtle_15_red_flying.vmdl",
        "models/items/courier/onibi_lvl_05/onibi_lvl_05.vmdl",
        "models/items/courier/onibi_lvl_05/onibi_lvl_05_flying.vmdl",
        "models/items/courier/onibi_lvl_21/onibi_lvl_21.vmdl",
        "models/items/courier/onibi_lvl_21/onibi_lvl_21_flying.vmdl",
        "models/courier/baby_rosh/babyroshan_ti9.vmdl",
        "models/courier/baby_rosh/babyroshan_ti9_flying.vmdl",
        "models/courier/baby_rosh/babyroshan.vmdl",
        "models/courier/baby_rosh/babyroshan_flying.vmdl",
        "models/courier/donkey_ti7/donkey_ti7.vmdl",
        "models/courier/donkey_ti7/donkey_ti7_flying.vmdl",
        "models/items/courier/duskie/duskie.vmdl",
        "models/items/courier/duskie/duskie_flying.vmdl",
        "models/items/courier/courier_mvp_redkita/courier_mvp_redkita.vmdl",
        "models/items/courier/courier_mvp_redkita/courier_mvp_redkita_flying.vmdl",
        "models/items/courier/nian_courier/nian_courier.vmdl",
        "models/items/courier/nian_courier/nian_courier_flying.vmdl",
        "models/items/courier/shibe_dog_cat/shibe_dog_cat.vmdl",
        "models/items/courier/shibe_dog_cat/shibe_dog_cat_flying.vmdl",
        "models/items/courier/baekho/baekho.vmdl",
        "models/items/courier/baekho/baekho_flying.vmdl",
        "models/heroes/dark_willow/dark_willow.vmdl",
        "models/items/dark_willow/the_naughty_witch_from_dark_woods_belt/the_naughty_witch_from_dark_woods_belt.vmdl",
        "models/items/dark_willow/the_naughty_witch_from_dark_woods_off_hand/the_naughty_witch_from_dark_woods_off_hand.vmdl",
        "models/items/dark_willow/the_naughty_witch_from_dark_woods_back/the_naughty_witch_from_dark_woods_back.vmdl",
        "models/items/dark_willow/the_naughty_witch_from_dark_woods_armor/the_naughty_witch_from_dark_woods_armor.vmdl",
        "models/items/dark_willow/the_naughty_witch_from_dark_woods_head/the_naughty_witch_from_dark_woods_head.vmdl",
        "models/items/courier/hermit_crab/hermit_crab_lotus.vmdl",
        "models/items/courier/hermit_crab/hermit_crab_lotus_flying.vmdl",
        "models/items/rubick/rubick_arcana/rubick_arcana_base.vmdl",
        "models/heroes/rubick/rubick_head.vmdl",
        "models/items/rubick/rubick_arcana/rubick_arcana_back.vmdl",
        "models/items/rubick/rubick_ti8_immortal_shoulders/rubick_ti8_immortal_shoulders.vmdl",
        "models/items/rubick/embrace_force_blue_weapon/embrace_force_blue_weapon.vmdl",
        "models/heroes/crystal_maiden/crystal_maiden_arcana.vmdl",
        "models/heroes/crystal_maiden/crystal_maiden_arcana_back.vmdl",
        "models/items/crystal_maiden/cm_ti9_immortal_weapon/cm_ti9_immortal_weapon.vmdl",
        "models/items/crystal_maiden/immortal_shoulders/cm_immortal_shoulders.vmdl",
        "models/items/crystal_maiden/cowl_of_ice/cowl_of_ice.vmdl",
        "models/items/crystal_maiden/np_arms/np_arms.vmdl",
    }
end

if PreloadParticles == nil then
    PreloadParticles = {
        "particles/items2_fx/teleport_start.vpcf",
        "particles/items2_fx/teleport_end.vpcf",
        "particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7_ribbon_bright.vpcf",
        "particles/items2_fx/hand_of_midas.vpcf",
        "particles/items2_fx/refresher.vpcf",
        "particles/items2_fx/butterfly_active.vpcf",
        "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf",
        "particles/units/heroes/hero_rubick/rubick_telekinesis_marker.vpcf",
        "particles/units/heroes/hero_rubick/rubick_telekinesis.vpcf",
        "particles/units/heroes/hero_rubick/rubick_telekinesis_land.vpcf",
        "particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf",
        "particles/items_fx/aegis_respawn_aegis_starfall.vpcf",
        "particles/items_fx/aegis_respawn_spotlight.vpcf",
        "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_explosion_alliance_trail.vpcf",
        "particles/econ/courier/courier_huntling_gold/courier_huntling_gold_ambient.vpcf",
        "particles/econ/courier/courier_huntling_gold/courier_huntling_gold_ambient_flying.vpcf",
        "particles/econ/courier/courier_hyeonmu_ambient/courier_hyeonmu_ambient_blue.vpcf",
        "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf",
        "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf",
        "particles/econ/courier/courier_nian/courier_nian_ambient.vpcf",
        "particles/econ/courier/courier_hwytty/courier_hwytty_ambient.vpcf",
        "particles/econ/courier/courier_onibi/courier_onibi_blue_lvl5_ambient.vpcf",
        "particles/econ/courier/courier_onibi/courier_onibi_black_lvl21_ambient.vpcf",
        "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_steam.vpcf",
        "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf",
        "particles/econ/courier/courier_shagbark/courier_shagbark_ambient.vpcf",
        "particles/econ/courier/courier_shibe/courier_shibe_ambient.vpcf",
        "particles/econ/courier/courier_shibe/courier_shibe_ambient_flying.vpcf",
        "particles/econ/courier/courier_baekho/courier_baekho_ambient.vpcf",
        "particles/units/heroes/hero_dark_willow/dark_willow_lantern_ambient.vpcf",
        "particles/econ/courier/courier_hermit_crab/hermit_crab_lotus_ambient.vpcf",
        "particles/econ/items/rubick/rubick_arcana/rubick_arc_ambient_default.vpcf",
        "particles/econ/items/rubick/rubick_arcana/rubick_arc_shoulders_ambient.vpcf",
        "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf",
        "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying.vpcf",
        "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_golden_staff_ambient.vpcf",
        "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_body_ambient.vpcf",
        "particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/crystal_maiden_cowl_ambient.vpcf",
        "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_ambient.vpcf",
    }
end

AllHeroNames = {
    "ancient_apparition", "antimage", "axe", "bane", "beastmaster", "bloodseeker", "chen", "crystal_maiden",
    "dazzle", "dragon_knight", "doom_bringer", "earthshaker", "enchantress",
    "enigma", "faceless_void", "furion", "juggernaut", "kunkka", "leshrac", "lich", "life_stealer", "lina",
    "lion", "mirana", "morphling", "necrolyte", "nevermore", "night_stalker", "omniknight", "puck", "pudge",
    "pugna", "rattletrap", "razor", "riki", "sand_king", "shadow_shaman", "slardar", "sniper", "spectre",
    "storm_spirit", "sven", "tidehunter", "tinker", "tiny", "venomancer", "viper", "weaver",
    "windrunner", "witch_doctor", "zuus", "broodmother", "skeleton_king", "queenofpain", "huskar", "jakiro",
    "batrider", "warlock", "alchemist", "death_prophet", "ursa", "bounty_hunter", "spirit_breaker",
    "obsidian_destroyer", "shadow_demon", "lycan", "brewmaster", "treant", "ogre_magi", 
    "lone_druid", "phantom_assassin", "gyrocopter", "rubick", "luna", "disruptor",
    "templar_assassin", "naga_siren", "nyx_assassin", "keeper_of_the_light", "phoenix",
    "magnataur", "centaur", "shredder", "medusa", "troll_warlord", "tusk", "bristleback", "skywrath_mage",
    "abaddon", "earth_spirit", "ember_spirit", "legion_commander", "terrorblade",
    "techies", "oracle", "winter_wyvern", "arc_warden", "abyssal_underlord", "grimstroke", "mars", "undying", 
    "invoker", "clinkz", "elder_titan", "pangolier", "slark", "dark_willow", "dark_seer", "phantom_lancer", "monkey_king",
    "void_spirit", "snapfire", "silencer", "visage", "vengefulspirit", "drow_ranger", "chaos_knight", "wisp", "meepo"
}

HeroNameLocalize = {
    {name = "ancient_apparition", english = "Ancient Apparition", schinese = "远古冰魂"},
    {name = "antimage", english = "Anti-Mage", schinese = "敌法师"},
    {name = "axe", english = "Axe", schinese = "斧王"},
    {name = "bane", english = "Bane", schinese = "祸乱之源"},
    {name = "beastmaster", english = "Beastmaster", schinese = "兽王"},
    {name = "bloodseeker", english = "Bloodseeker", schinese = "血魔"},
    {name = "chen", english = "Chen", schinese = "陈"},
    {name = "crystal_maiden", english = "Crystal Maiden", schinese = "水晶室女"},
    {name = "dazzle", english = "Dazzle", schinese = "戴泽"},
    {name = "dragon_knight", english = "Dragon Knight", schinese = "龙骑士"},
    {name = "doom_bringer", english = "Doom", schinese = "末日使者"},
    {name = "earthshaker", english = "Earthshaker", schinese = "撼地者"},
    {name = "enchantress", english = "Enchantress", schinese = "魅惑魔女"},
    {name = "enigma", english = "Enigma", schinese = "谜团"},
    {name = "faceless_void", english = "Faceless Void", schinese = "虚空假面"},
    {name = "furion", english = "Nature's Prophet", schinese = "先知"},
    {name = "juggernaut", english = "Juggernaut", schinese = "主宰"},
    {name = "kunkka", english = "Kunkka", schinese = "昆卡"},
    {name = "leshrac", english = "Leshrac", schinese = "拉席克"},
    {name = "lich", english = "Lich", schinese = "巫妖"},
    {name = "life_stealer", english = "Lifestealer", schinese = "噬魂鬼"},
    {name = "lina", english = "Lina", schinese = "莉娜"},
    {name = "lion", english = "Lion", schinese = "莱恩"},
    {name = "mirana", english = "Mirana", schinese = "米拉娜"},
    {name = "morphling", english = "Morphling", schinese = "变体精灵"},
    {name = "necrolyte", english = "Necrophos", schinese = "瘟疫法师"},
    {name = "nevermore", english = "Shadow Fiend", schinese = "影魔"},
    {name = "night_stalker", english = "Night Stalker", schinese = "暗夜魔王"},
    {name = "omniknight", english = "Omniknight", schinese = "全能骑士"},
    {name = "puck", english = "Puck", schinese = "帕克"},
    {name = "pudge", english = "Pudge", schinese = "帕吉"},
    {name = "pugna", english = "Pugna", schinese = "帕格纳"},
    {name = "rattletrap", english = "Clockwerk", schinese = "发条技师"},
    {name = "razor", english = "Razor", schinese = "剃刀"},
    {name = "riki", english = "Riki", schinese = "力丸"},
    {name = "sand_king", english = "Sand King", schinese = "沙王"},
    {name = "shadow_shaman", english = "Shadow Shaman", schinese = "暗影萨满"},
    {name = "slardar", english = "Slardar", schinese = "斯拉达"},
    {name = "sniper", english = "Sniper", schinese = "狙击手"},
    {name = "spectre", english = "Spectre", schinese = "幽鬼"},
    {name = "storm_spirit", english = "Storm Spirit", schinese = "风暴之灵"},
    {name = "sven", english = "Sven", schinese = "斯温"},
    {name = "tidehunter", english = "Tidehunter", schinese = "潮汐猎人"},
    {name = "tinker", english = "Tinker", schinese = "修补匠"},
    {name = "tiny", english = "Tiny", schinese = "小小"},
    {name = "venomancer", english = "Venomancer", schinese = "剧毒术士"},
    {name = "viper", english = "Viper", schinese = "冥界亚龙"},
    {name = "weaver", english = "Weaver", schinese = "编织者"},
    {name = "windrunner", english = "Windranger", schinese = "风行者"},
    {name = "witch_doctor", english = "Witch Doctor", schinese = "巫医"},
    {name = "zuus", english = "Zeus", schinese = "宙斯"},
    {name = "broodmother", english = "Broodmother", schinese = "育母蜘蛛"},
    {name = "skeleton_king", english = "Wraith King", schinese = "冥魂大帝"},
    {name = "queenofpain", english = "Queen of Pain", schinese = "痛苦女王"},
    {name = "huskar", english = "Huskar", schinese = "哈斯卡"},
    {name = "jakiro", english = "Jakiro", schinese = "杰奇洛"},
    {name = "batrider", english = "Batrider", schinese = "蝙蝠骑士"},
    {name = "warlock", english = "Warlock", schinese = "术士"},
    {name = "alchemist", english = "Alchemist", schinese = "炼金术士"},
    {name = "death_prophet", english = "Death Prophet", schinese = "死亡先知"},
    {name = "ursa", english = "Ursa", schinese = "熊战士"},
    {name = "bounty_hunter", english = "Bounty Hunter", schinese = "赏金猎人"},
    {name = "spirit_breaker", english = "Spirit Breaker", schinese = "裂魂人"},
    {name = "obsidian_destroyer", english = "Outworld Devourer", schinese = "殁境神蚀者"},
    {name = "shadow_demon", english = "Shadow Demon", schinese = "暗影恶魔"},
    {name = "lycan", english = "Lycan", schinese = "狼人"},
    {name = "brewmaster", english = "Brewmaster", schinese = "酒仙"},
    {name = "treant", english = "Treant Protector", schinese = "树精卫士"},
    {name = "ogre_magi", english = "Ogre Magi", schinese = "食人魔魔法师"},
    {name = "lone_druid", english = "Lone Druid", schinese = "德鲁伊"},
    {name = "phantom_assassin", english = "Phantom Assassin", schinese = "幻影刺客"},
    {name = "gyrocopter", english = "Gyrocopter", schinese = "矮人直升机"},
    {name = "rubick", english = "Rubick", schinese = "拉比克"},
    {name = "luna", english = "Luna", schinese = "露娜"},
    {name = "disruptor", english = "Disruptor", schinese = "干扰者"},
    {name = "templar_assassin", english = "Templar Assassin", schinese = "圣堂刺客"},
    {name = "naga_siren", english = "Naga Siren", schinese = "娜迦海妖"},
    {name = "nyx_assassin", english = "Nyx Assassin", schinese = "司夜刺客"},
    {name = "keeper_of_the_light", english = "Keeper of the Light", schinese = "光之守卫"},
    {name = "phoenix", english = "Phoenix", schinese = "凤凰"},
    {name = "magnataur", english = "Magnus", schinese = "马格纳斯"},
    {name = "centaur", english = "Centaur Warrunner", schinese = "半人马战行者"},
    {name = "shredder", english = "Timbersaw", schinese = "伐木机"},
    {name = "medusa", english = "Medusa", schinese = "美杜莎"},
    {name = "troll_warlord", english = "Troll Warlord", schinese = "巨魔战将"},
    {name = "tusk", english = "Tusk", schinese = "巨牙海民"},
    {name = "bristleback", english = "Bristleback", schinese = "钢背兽"},
    {name = "skywrath_mage", english = "Skywrath Mage", schinese = "天怒法师"},
    {name = "abaddon", english = "Abaddon", schinese = "亚巴顿"},
    {name = "earth_spirit", english = "Earth Spirit", schinese = "大地之灵"},
    {name = "ember_spirit", english = "Ember Spirit", schinese = "灰烬之灵"},
    {name = "legion_commander", english = "Legion Commander", schinese = "军团指挥官"},
    {name = "terrorblade", english = "Terrorblade", schinese = "恐怖利刃"},
    {name = "techies", english = "Techies", schinese = "工程师"},
    {name = "oracle", english = "Oracle", schinese = "神谕者"},
    {name = "winter_wyvern", english = "Winter Wyvern", schinese = "寒冬飞龙"},
    {name = "arc_warden", english = "Arc Warden", schinese = "天穹守望者"},
    {name = "abyssal_underlord", english = "Underlord", schinese = "孽主"},
    {name = "grimstroke", english = "Grimstroke", schinese = "天涯墨客"},
    {name = "mars", english = "Mars", schinese = "玛尔斯"},
    {name = "undying", english = "Undying", schinese = "不朽尸王"},
    {name = "invoker", english = "Invoker", schinese = "祈求者"},
    {name = "clinkz", english = "Clinkz", schinese = "克林克兹"},
    {name = "elder_titan", english = "Elder Titan", schinese = "上古巨神"},
    {name = "pangolier", english = "Pangolier", schinese = "石鳞剑士"},
    {name = "slark", english = "Slark", schinese = "斯拉克"},
    {name = "dark_willow", english = "Dark Willow", schinese = "邪影芳灵"},
    {name = "dark_seer", english = "Dark Seer", schinese = "黑暗贤者"},
    {name = "phantom_lancer", english = "Phantom Lancer", schinese = "幻影长矛手"},
    {name = "monkey_king", english = "Monkey King", schinese = "齐天大圣"},
    {name = "void_spirit", english = "Void Spirit", schinese = "虚无之灵"},
    {name = "snapfire", english = "Snapfire", schinese = "电炎绝手"},
    {name = "silencer", english = "Silencer", schinese = "沉默术士"},
    {name = "visage", english = "Visage", schinese = "维萨吉"},
    {name = "vengefulspirit", english = "Vengeful Spirit", schinese = "复仇之魂"},
    {name = "drow_ranger", english = "Drow Ranger", schinese = "卓尔游侠"},
    {name = "chaos_knight", english = "Drow Ranger", schinese = "混沌骑士"},
    {name = "wisp", english = "Io", schinese = "艾欧"},
    {name = "meepo", english = "Meepo", schinese = "米波"},
}

BannedHeros = {}

HeroNamePrefix = "npc_dota_hero_"

XpPerLevelTable = {
    0, 5000, 10000, 15000, 20000,
    25000, 30000, 35000, 40000, 45000,
    50000, 55000, 60000, 65000, 70000,
    75000, 80000, 85000, 90000, 95000,
    100000, 105000, 110000, 115000, 120000,
    125000, 130000, 135000, 140000, 145000
}
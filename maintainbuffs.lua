------------------------------------------------------------------
-- This script will maintain any castable buffs you have active --
-- that you are capable of extending yourself, when you have a  --
-- reasonable amount of mana. It will only extend buffs that    --
-- you already have active, so it won't have weird issues with  --
-- Accordion Thief buffs, and you can stop maintaining a buff   --
-- by shrugging it off.                                         --
------------------------------------------------------------------


-- If you have less than this percentage of your max mp left, no more buffs will be autocast
local mppercentcutoff = 1 - 0.11
-- Won't bother extending buffs to last longer than this
local maxturns = 1011
-- Will only attempt to buff this many times per page, just in case an infinite loop happens somehow, and to generally reduce lag.
local maxloops = 11

------------------------------------------------------------------
-- END OF CONFIGURATION, END USER SHOULD NOT MODIFY BEYOND HERE --
--       UNLESS THEY INTEND TO MODIFY CORE FUNCTIONALITY        --
------------------------------------------------------------------

local buffs = {
  ---[===[ STANDARD CLASSES
  ---[=[ Seal Clubber
  "Seal Clubbing Frenzy",                   -- +2 Muscle
  "Blubbered Up",                           -- +5 Moxie
  "Scowl of the Auk",                       -- +10 Weapon Damage. Facial expression.
  "Rage of the Reindeer",                   -- +10% Muscle, +10 Weapon Damage
  "Musk of the Moose",                      -- Increases combat frequency.
  "Pride of the Puffin",                    -- +10 Monster Level
  "Snarl of the Timberwolf",                -- +10 Spooky Damage. Facial expression.
  "A Few Extra Pounds",                     -- +5xLevel HP, up to +55. Crimbo '09 skill.
  --]=]
  ---[=[ Turtle Tamer
  "Patience of the Tortoise",               -- +1 Muscle, +3 HP
  "Stiff Upper Lip",                        -- 10 Damage Reduction. Facial expression.
  "Ghostly Shell",                          -- +80 Damage Absorption
  "Tenacity of the Snapper",                -- +8 Weapon Damage
  "Empathy",                                -- +5 Familiar Weight
  "Spiky Shell",                            -- Damages attacking Monsters
  "Reptilian Fortitude",                    -- +30 HP
  "Astral Shell",                           -- +80 Damage Absorption, Slight resistance to all elements (+1)
  "Boon of the War Snapper",                -- Your melee attacks restore some HP
  "Boon of She-Who-Was",                    -- +20 Weapon Damage, Your melee attacks deal Spooky Damage
  "Boon of the Storm Tortoise",             -- Your melee attacks restore some MP
  "Patient Smile",                          -- +1 Muscle Substat per fight. Facial expression.
  "Jingle Jangle Jingle",                   -- Familiar will act more often in combat. Crimbo '09 skill.
  "Curiosity of Br'er Tarrypin",            -- +1 Familiar Experience per combat. Travelling Trader skill.
  --]=]
  ---[=[ Pastamancer
  "Pasta Oneness",                          -- +2 Mysticality
  "Arched Eyebrow of the Archmage",         -- +10 Spell Damage. Facial expression.
  "Springy Fusilli",                        -- +40% Combat Initiative
  "Shield of the Pastalord",                -- 30% Reduced physical damage taken (10% for non-Pastamancers)
  "Leash of Linguini",                      -- +5 Familiar Weight
  "Wizard Squint",                          -- +10% Spell Critical Chance. Facial expression.
  --]=]
  ---[=[ Sauceror
  "Saucemastery",                           -- +1 Mysticality, +3 HP
  "Icy Glare",                              -- +10 Cold Damage, +10 Damage with Cold spells. Facial expression.
  "Elemental Saucesphere",                  -- So-So Resistance to all elements (+2)
  "Jalapeño Saucesphere",                   -- 3 Damage Reduction, Lightly damages attacking Monsters
  "Antibiotic Saucesphere",                 -- Regenerate 4-5 HP per Adventure
  "Wry Smile",                              -- +1 Mysticality Substat per fight. Facial expression.
  "Sauce Monocle",                          -- +15% Spell Critical Chance (+5% for non-Sauceror)
  --]=]
  ---[=[ Disco Bandit
  "Disco State of Mind",                    -- +2 Moxie
  "Disco Smirk",                            -- +10 Moxie. Facial expression.
  "Disco Fever",                            -- +10% Moxie, +10 Ranged Damage
  "Smooth Movements",                       -- Decreases combat frequency.
  "Disco Leer",                             -- +10% Meat from Monsters. Facial expression.
  --]=]
  ---[=[ Accordion Thief
  "Mariachi Mood",                          -- +1 Moxie, +3 HP
  "The Moxious Madrigal",                   -- +10 Moxie. Song.
  "Magical Mojomuscular Melody",            -- +10 Mysticality, +20 MP. Song.
  "Cletus's Canticle of Celerity",          -- +20% Combat Initiative. Song.
  "Power Ballad of the Arrowsmith",         -- +10 Muscle, +20 HP. Song.
  "Polka of Plenty",                        -- +50% Meat from Monsters. Song.
  "Jackasses' Symphony of Destruction",     -- +12 Weapon and Spell Damage. Song.
  "Fat Leon's Phat Loot Lyric",             -- +20% Items from Monsters. Song.
  "Brawnee's Anthem of Absorption",         -- floor(level^1.2) Damage Reduction. Song.
  "Suspicious Gaze",                        -- +20% Combat Initiative. Facial expression.
  "Psalm of Pointiness",                    -- Delevels and Damages attacking Monsters. Song.
  "Stevedave's Shanty of Superiority",      -- +10% to All Attributes. Song.
  "Aloysius' Antiphon of Aptitude",         -- +1 of each Substat per fight. Song.
  "The Sonata of Sneakiness",               -- Decreases combat frequency. Song.
  "Carlweather's Cantata of Confrontation", -- Increases combat frequency. Song.
  "Knowing Smile",                          -- +1 Moxie Substat per fight. Facial expression.
  "Ur-Kel's Aria of Annoyance",             -- +2*level ML. Song.
  "Dirge of Dreadfulness",                  -- +12 Spooky Damage, +12 Damage with Spooky spells. Song.
  "Cringle's Curative Carol",               -- Regenerate 5-10 HP per Adventure. Crimbo '09 skill. Song.
  --]=]
  --]===]
  -- Challenge path specific classes coming eventually, probably.
}

-- Most buffs are created by a skill with the same name,
-- but sometimes the skills are different instead, just
-- to inconvenience you! Or something.
local buffskillnames = {
  ["Blubbered Up"] = "Blubber Up",
  ["Empathy"] = "Empathy of the Newt",
  ["Boon of the War Snapper"] = "Spirit Boon",
  ["Boon of She-Who-Was"] = "Spirit Boon",
  ["Boon of the Storm Tortoise"] = "Spirit Boon",
  ["Jingle Jangle Jingle"] = "Jingle Bells",
  ["Pasta Oneness"] = "Manicotti Meditation",
  ["Saucemastery"] = "Sauce Contemplation",
  ["Disco State of Mind"] = "Disco Aerobics",
  ["Smooth Movements"] = "Smooth Movement",
  ["Mariachi Mood"] = "Moxie of the Mariachi",
  ["Magical Mojomuscular Melody"] = "The Magical Mojomuscular Melody",
  ["Power Ballad of the Arrowsmith"] = "The Power Ballad of the Arrowsmith",
  ["Polka of Plenty"] = "The Polka of Plenty",
  ["Psalm of Pointiness"] = "The Psalm of Pointiness",
}

local function buffmaintenanceautomator()
  --print("BUFF MAINTENANCE")
  local currloops = 0
  while mp() / maxmp() > mppercentcutoff do
    currloops = currloops + 1
    if currloops > maxloops then
      break
    end
    local leastturnsleft = maxturns
    local bufftocast
    for i,v in ipairs(buffs) do
      local skillname = buffskillnames[v] or v
      if have_skill(skillname) then
        local turnsleft = buffturns(v)
        if turnsleft > 0 and turnsleft < leastturnsleft then
          leastturnsleft = turnsleft
          bufftocast = skillname
        end
      end
    end
    if bufftocast then
      cast_skill(bufftocast)
    else
      break
    end
  end
end

add_automator("all pages", buffmaintenanceautomator)

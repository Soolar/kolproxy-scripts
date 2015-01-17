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
  -- +2 Muscle
  "Seal Clubbing Frenzy",
  -- +5 Moxie
  "Blubbered Up",
  -- +10 Weapon Damage. Facial expression.
  "Scowl of the Auk",
  -- +10% Muscle, +10 Weapon Damage
  "Rage of the Reindeer",
  -- Increases combat frequency.
  "Musk of the Moose",
  -- +10 Monster Level
  "Pride of the Puffin",
  -- +10 Spooky Damage. Facial expression.
  "Snarl of the Timberwolf",
  -- +5xLevel HP, up to +55. Crimbo '09 skill.
  "A Few Extra Pounds",
  --]=]

  ---[=[ Turtle Tamer
  -- +1 Muscle, +3 HP
  "Patience of the Tortoise",
  -- 10 Damage Reduction. Facial expression.
  "Stiff Upper Lip",
  -- +80 Damage Absorption
  "Ghostly Shell",
  -- +8 Weapon Damage
  "Tenacity of the Snapper",
  -- +5 Familiar Weight
  "Empathy",
  -- Damages attacking Monsters
  "Spiky Shell",
  -- +30 HP
  "Reptilian Fortitude",
  -- +80 Damage Absorption, Slight resistance to all elements (+1)
  "Astral Shell",
  -- Your melee attacks restore some HP
  "Boon of the War Snapper",
  -- +20 Weapon Damage, Your melee attacks deal Spooky Damage
  "Boon of She-Who-Was",
  -- Your melee attacks restore some MP
  "Boon of the Storm Tortoise",
  -- +1 Muscle Substat per fight. Facial expression.
  "Patient Smile",
  -- Familiar will act more often in combat. Crimbo '09 skill.
  "Jingle Jangle Jingle",
  -- +1 Familiar Experience per combat. Travelling Trader skill.
  "Curiosity of Br'er Tarrypin",
  --]=]

  ---[=[ Pastamancer
  -- +2 Mysticality
  "Pasta Oneness",
  -- +10 Spell Damage. Facial expression.
  "Arched Eyebrow of the Archmage",
  -- +40% Combat Initiative
  "Springy Fusilli",
  -- 30% Reduced physical damage taken (10% for non-Pastamancers)
  "Shield of the Pastalord",
  -- +5 Familiar Weight
  "Leash of Linguini",
  -- +10% Spell Critical Chance. Facial expression.
  "Wizard Squint",
  --]=]

  ---[=[ Sauceror
  -- +1 Mysticality, +3 HP
  "Saucemastery",
  -- +10 Cold Damage, +10 Damage with Cold spells. Facial expression.
  "Icy Glare",
  -- So-So Resistance to all elements (+2)
  "Elemental Saucesphere",
  -- 3 Damage Reduction, Lightly damages attacking Monsters
  "Jalapeño Saucesphere",
  -- Regenerate 4-5 HP per Adventure
  "Antibiotic Saucesphere",
  -- +1 Mysticality Substat per fight. Facial expression.
  "Wry Smile",
  -- +15% Spell Critical Chance (+5% for non-Sauceror)
  "Sauce Monocle",
  --]=]

  ---[=[ Disco Bandit
  -- +2 Moxie
  "Disco State of Mind",
  -- +10 Moxie. Facial expression.
  "Disco Smirk",
  -- +10% Moxie, +10 Ranged Damage
  "Disco Fever",
  -- Decreases combat frequency.
  "Smooth Movements",
  -- +10% Meat from Monsters. Facial expression.
  "Disco Leer",
  --]=]

  ---[=[ Accordion Thief
  -- +1 Moxie, +3 HP
  "Mariachi Mood",
  -- +10 Moxie. Song.
  "The Moxious Madrigal",
  -- +10 Mysticality, +20 MP. Song.
  "Magical Mojomuscular Melody",
  -- +20% Combat Initiative. Song.
  "Cletus's Canticle of Celerity",
  -- +10 Muscle, +20 HP. Song.
  "Power Ballad of the Arrowsmith",
  -- +50% Meat from Monsters. Song.
  "Polka of Plenty",
  -- +12 Weapon and Spell Damage. Song.
  "Jackasses' Symphony of Destruction",
  -- +20% Items from Monsters. Song.
  "Fat Leon's Phat Loot Lyric",
  -- floor(level^1.2) Damage Reduction. Song.
  "Brawnee's Anthem of Absorption",
  -- +20% Combat Initiative. Facial expression.
  "Suspicious Gaze",
  -- Delevels and Damages attacking Monsters. Song.
  "Psalm of Pointiness",
  -- +10% to All Attributes. Song.
  "Stevedave's Shanty of Superiority",
  -- +1 of each Substat per fight. Song.
  "Aloysius' Antiphon of Aptitude",
  -- Decreases combat frequency. Song.
  "The Sonata of Sneakiness",
  -- Increases combat frequency. Song.
  "Carlweather's Cantata of Confrontation",
  -- +1 Moxie Substat per fight. Facial expression.
  "Knowing Smile",
  -- +2*level ML. Song.
  "Ur-Kel's Aria of Annoyance",
  -- +12 Spooky Damage, +12 Damage with Spooky spells. Song.
  "Dirge of Dreadfulness",
  -- Regenerate 5-10 HP per Adventure. Crimbo '09 skill. Song.
  "Cringle's Curative Carol",
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

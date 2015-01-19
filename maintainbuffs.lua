------------------------------------------------------------------
-- This script will maintain any castable buffs you have active --
-- that you are capable of extending yourself, when you have a  --
-- reasonable amount of mana. It will only extend buffs that    --
-- you already have active, so it won't have weird issues with  --
-- Accordion Thief buffs, and you can stop maintaining a buff   --
-- by shrugging it off.                                         --
------------------------------------------------------------------

-- If you have less than this percentage of your max mp left, no more buffs will be autocast
local mppercentcutoff = 0.75
-- Won't bother extending buffs to last longer than this
local maxturns = 1011
-- Will only attempt to buff this many times per page, just in case an infinite loop happens somehow, and to generally reduce lag.
local maxloops = 11

------------------------------------------------------------------
-- END OF CONFIGURATION, END USER SHOULD NOT MODIFY BEYOND HERE --
--       UNLESS THEY INTEND TO MODIFY CORE FUNCTIONALITY        --
------------------------------------------------------------------

local function buff(effectname, mpcost, skillname)
  skillname = skillname or effectname
  return { effectname = effectname, mpcost = mpcost, skillname = skillname }
end

local buffs = {
  ---[===[ STANDARD CLASSES
  ---[=[ Seal Clubber
  -- +2 Muscle
  buff("Seal Clubbing Frenzy", 1),
  -- +5 Moxie
  buff("Blubbered Up", 7, "Blubber Up"),
  -- +10 Weapon Damage. Facial expression.
  buff("Scowl of the Auk", 10),
  -- +10% Muscle, +10 Weapon Damage
  buff("Rage of the Reindeer", 10),
  -- Increases combat frequency.
  buff("Musk of the Moose", 10),
  -- +10 Monster Level
  buff("Pride of the Puffin", 30),
  -- +10 Spooky Damage. Facial expression.
  buff("Snarl of the Timberwolf", 10),
  -- +5xLevel HP, up to +55. Crimbo '09 skill.
  buff("A Few Extra Pounds", 10, "Holiday Weight Gain"),
  --]=]

  ---[=[ Turtle Tamer
  -- +1 Muscle, +3 HP
  buff("Patience of the Tortoise", 1),
  -- 10 Damage Reduction. Facial expression.
  buff("Stiff Upper Lip", 10),
  -- +80 Damage Absorption
  buff("Ghostly Shell", 6),
  -- +8 Weapon Damage
  buff("Tenacity of the Snapper", 8),
  -- +5 Familiar Weight
  buff("Empathy", 15, "Empathy of the Newt"),
  -- Damages attacking Monsters
  buff("Spiky Shell", 8),
  -- +30 HP
  buff("Reptilian Fortitude", 10),
  -- +80 Damage Absorption, Slight resistance to all elements (+1)
  buff("Astral Shell", 10),
  -- Your melee attacks restore some HP
  buff("Boon of the War Snapper", 30, "Spirit Boon"),
  -- +20 Weapon Damage, Your melee attacks deal Spooky Damage
  buff("Boon of She-Who-Was", 30, "Spirit Boon"),
  -- Your melee attacks restore some MP
  buff("Boon of the Storm Tortoise", 30, "Spirit Boon"),
  -- +1 Muscle Substat per fight. Facial expression.
  buff("Patient Smile", 10),
  -- Familiar will act more often in combat. Crimbo '09 skill.
  buff("Jingle Jangle Jingle", 5),
  -- +1 Familiar Experience per combat. Travelling Trader skill.
  buff("Curiosity of Br'er Tarrypin", 10),
  --]=]

  ---[=[ Pastamancer
  -- +2 Mysticality
  buff("Pasta Oneness", 1, "Manicotti Meditation"),
  -- +10 Spell Damage. Facial expression.
  buff("Arched Eyebrow of the Archmage", 10),
  -- +40% Combat Initiative
  buff("Springy Fusilli", 10),
  -- 30% Reduced physical damage taken (10% for non-Pastamancers)
  buff("Shield of the Pastalord", 20),
  buff("Flimsy Shield of the Pastalord", 20, "Shield of the Pastalord"),
  -- +5 Familiar Weight
  buff("Leash of Linguini", 12),
  -- +10% Spell Critical Chance. Facial expression.
  buff("Wizard Squint", 10),
  --]=]

  ---[=[ Sauceror
  -- +1 Mysticality, +3 HP
  buff("Saucemastery", 1, "Sauce Contemplation"),
  -- +10 Cold Damage, +10 Damage with Cold spells. Facial expression.
  buff("Icy Glare", 10),
  -- So-So Resistance to all elements (+2)
  buff("Elemental Saucesphere", 10),
  -- 3 Damage Reduction, Lightly damages attacking Monsters
  buff("Jalape&ntilde;o Saucesphere", 5),
  -- Regenerate 4-5 HP per Adventure
  buff("Antibiotic Saucesphere", 15),
  -- +1 Mysticality Substat per fight. Facial expression.
  buff("Wry Smile", 10),
  -- +15% Spell Critical Chance (+5% for non-Sauceror)
  buff("Sauce Monocle", 20),
  -- So-So Cold and Sleaze Resistance (+2), Deals light Spooky damage to attackers.
  buff("Scarysauce", 10),
  --]=]

  ---[=[ Disco Bandit
  -- +2 Moxie
  buff("Disco State of Mind", 1, "Disco Aerobics"),
  -- +10 Moxie. Facial expression.
  buff("Disco Smirk", 10),
  -- +10% Moxie, +10 Ranged Damage
  buff("Disco Fever", 10),
  -- Decreases combat frequency.
  buff("Smooth Movements", 10, "Smooth Movement"),
  -- +10% Meat from Monsters. Facial expression.
  buff("Disco Leer", 10),
  --]=]

  ---[=[ Accordion Thief
  -- +1 Moxie, +3 HP
  buff("Mariachi Mood", 1, "Moxie of the Mariachi"),
  -- +10 Moxie. Song.
  buff("The Moxious Madrigal", 2),
  -- +10 Mysticality, +20 MP. Song.
  buff("Magical Mojomuscular Melody", 3, "The Magical Mojomuscular Melody"),
  -- +20% Combat Initiative. Song.
  buff("Cletus's Canticle of Celerity", 4),
  -- +10 Muscle, +20 HP. Song.
  buff("Power Ballad of the Arrowsmith", 5, "The Power Ballad of the Arrowsmith"),
  -- +50% Meat from Monsters. Song.
  buff("Polka of Plenty", 7, "The Polka of Plenty"),
  -- +12 Weapon and Spell Damage. Song.
  buff("Jackasses' Symphony of Destruction", 9),
  -- +20% Items from Monsters. Song.
  buff("Fat Leon's Phat Loot Lyric", 11),
  -- floor(level^1.2) Damage Reduction. Song.
  buff("Brawnee's Anthem of Absorption", 13),
  -- +20% Combat Initiative. Facial expression.
  buff("Suspicious Gaze", 10),
  -- Delevels and Damages attacking Monsters. Song.
  buff("Psalm of Pointiness", 15, "The Psalm of Pointiness"),
  -- +10% to All Attributes. Song.
  buff("Stevedave's Shanty of Superiority", 30),
  -- +1 of each Substat per fight. Song.
  buff("Aloysius' Antiphon of Aptitude", 40),
  -- Decreases combat frequency. Song.
  buff("The Sonata of Sneakiness", 20),
  -- Increases combat frequency. Song.
  buff("Carlweather's Cantata of Confrontation", 20),
  -- +1 Moxie Substat per fight. Facial expression.
  buff("Knowing Smile", 10),
  -- +2*level ML. Song.
  buff("Ur-Kel's Aria of Annoyance", 30),
  -- +12 Spooky Damage, +12 Damage with Spooky spells. Song.
  buff("Dirge of Dreadfulness", 9),
  -- Regenerate 5-10 HP per Adventure. Crimbo '09 skill. Song.
  buff("Cringle's Curative Carol", 5),
  --]=]
  --]===]
  -- Challenge path specific classes coming eventually, probably.
}

local function buffmaintenanceautomator()
  --print("BUFF MAINTENANCE")

  local minmp = maxmp() * mppercentcutoff

  -- Trim out the buffs that aren't going to actually be maintained,
  -- to avoid looping over all of them pointlessly.
  local buffs_to_maintain = {}
  for i,v in ipairs(buffs) do
    if buffturns(v.effectname) > 0 and have_skill(v.skillname) and maxmp() - v.mpcost >= minmp then
      buffs_to_maintain[#buffs_to_maintain + 1] = v
    end
  end

  for loop = 1, maxloops do
    local leastturnsleft = maxturns
    local bufftocast
    for i,v in ipairs(buffs_to_maintain) do
      local turnsleft = buffturns(v.effectname)
      if turnsleft < leastturnsleft then
        leastturnsleft = turnsleft
        if mp() - v.mpcost >= minmp then
          bufftocast = v.skillname
        else
          bufftocast = nil
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

--add_automator("all pages", buffmaintenanceautomator)
add_automator("won fight", buffmaintenanceautomator)
add_automator("use item", buffmaintenanceautomator)
add_automator("/choice.php", buffmaintenanceautomator)
add_automator("/adventure.php", buffmaintenanceautomator)

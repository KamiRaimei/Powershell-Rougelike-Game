# Powershell Rougelike Game

# Game State Variables goes here. 
$global:Player = $null
$global:GameRunning = $true
$global:CurrentFloor = 1
$global:MonstersDefeated = 0
$global:BossesDefeated = 0

# Typewriter effect function - Testing. 
function Write-Typewriter {
    param(
        [string]$Text,
        [int]$Delay = 1,
        [string]$Color = "White"
    )
    
    $chars = $Text.ToCharArray()
    foreach ($char in $chars) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds 0.1
    }
    Write-Host ""  # Page break, dont remove
}

# Quick text function for less important messages
function Write-Quick {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    
    $chars = $Text.ToCharArray()
    foreach ($char in $chars) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds 0.2
    }
    Write-Host "" #page break
}

function Show-WelcomeScreen {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "         POWERSHELL RPG ADVENTURE" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Welcome to the dungeon crawler!" -ForegroundColor White
    Write-Host "Defeat monsters, collect artifacts, and descend deeper!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Controls:" -ForegroundColor Yellow
    Write-Host "  - Use number keys to select options" -ForegroundColor Gray
    Write-Host "  - Press any key to skip text animations" -ForegroundColor Gray
    Write-Host "  - Manage your health and mana carefully" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key to begin your adventure..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Class Definitions
$ClassDefinitions = @{
    Warrior = @{
        Health = 30
        Mana = 10
        Attack = 8
        Defense = 6
        Speed = 4
        Description = "A strong melee fighter with high health and attack"
        Ascensions = @("Paladin", "Barbarian", "Gladiator", "Warlord")
    }
    Mage = @{
        Health = 18
        Mana = 35
        Attack = 5
        Defense = 3
        Speed = 6
        Description = "A spellcaster with powerful magic but low defense"
        Ascensions = @("Archmage", "Elementalist", "Necromancer", "Chronomancer")
    }
    Rogue = @{
        Health = 22
        Mana = 15
        Attack = 7
        Defense = 4
        Speed = 8
        Description = "A agile character with high speed and critical hits"
        Ascensions = @("Assassin", "Shadowdancer", "Ninja", "Spymaster")
    }
    Cleric = @{
        Health = 25
        Mana = 30
        Attack = 5
        Defense = 5
        Speed = 4
        Description = "A holy warrior with healing and defensive abilities"
        Ascensions = @("Templar", "Inquisitor", "Oracle", "Saint")
    }
}

# Ascension Class Bonuses
$AscensionBonuses = @{
    # Warrior Ascensions
    Paladin = @{ Health = 15; Mana = 10; Attack = 3; Defense = 5; Speed = 1 }
    Barbarian = @{ Health = 25; Mana = 5; Attack = 6; Defense = 2; Speed = 3 }
    Gladiator = @{ Health = 20; Mana = 8; Attack = 5; Defense = 3; Speed = 4 }
    Warlord = @{ Health = 18; Mana = 12; Attack = 4; Defense = 4; Speed = 2 }
    
    # Mage Ascensions
    Archmage = @{ Health = 10; Mana = 20; Attack = 4; Defense = 2; Speed = 3 }
    Elementalist = @{ Health = 12; Mana = 18; Attack = 5; Defense = 3; Speed = 4 }
    Necromancer = @{ Health = 15; Mana = 15; Attack = 6; Defense = 4; Speed = 2 }
    Chronomancer = @{ Health = 8; Mana = 25; Attack = 3; Defense = 1; Speed = 6 }
    
    # Rogue Ascensions
    Assassin = @{ Health = 15; Mana = 12; Attack = 8; Defense = 2; Speed = 6 }
    Shadowdancer = @{ Health = 18; Mana = 15; Attack = 6; Defense = 3; Speed = 8 }
    Ninja = @{ Health = 20; Mana = 10; Attack = 7; Defense = 4; Speed = 7 }
    Spymaster = @{ Health = 16; Mana = 18; Attack = 5; Defense = 5; Speed = 5 }
    
    # Cleric Ascensions
    Templar = @{ Health = 20; Mana = 15; Attack = 4; Defense = 6; Speed = 2 }
    Inquisitor = @{ Health = 18; Mana = 12; Attack = 6; Defense = 4; Speed = 4 }
    Oracle = @{ Health = 15; Mana = 20; Attack = 3; Defense = 3; Speed = 5 }
    Saint = @{ Health = 25; Mana = 18; Attack = 2; Defense = 7; Speed = 1 }
}

# Spell Definitions
# Spell Definitions (simplified without script blocks)
$ClassSpells = @{
    "Mage" = @(
        @{ 
            Name = "Fireball"; 
            Description = "Hurl a ball of fire at your enemy";
            BaseDamage = 15;
            DamagePerLevel = 2;
            DamagePerAttack = 0.5;
            ManaCost = 12;
            Element = "Fire";
            Type = "Damage"
        },
        @{ 
            Name = "Ice Shard"; 
            Description = "Launch sharp shards of ice";
            BaseDamage = 12;
            DamagePerLevel = 1.5;
            DamagePerAttack = 0.3;
            ManaCost = 10;
            Element = "Ice";
            Type = "Damage";
            Effect = "Slow"
        },
        @{ 
            Name = "Lightning Bolt"; 
            Description = "Strike with a bolt of lightning";
            BaseDamage = 18;
            DamagePerLevel = 2.5;
            DamagePerAttack = 0.4;
            ManaCost = 15;
            Element = "Lightning";
            Type = "Damage";
            Effect = "Stun"
        },
        @{ 
            Name = "Minor Heal"; 
            Description = "Basic healing magic";
            BaseHeal = 10;
            HealPerLevel = 1;
            ManaCost = 8;
            Type = "Heal"
        }
    )
    "Cleric" = @(
        @{ 
            Name = "Holy Light"; 
            Description = "Channel divine light to smite enemies";
            BaseDamage = 8;
            DamagePerLevel = 1;
            DamagePerAttack = 0.2;
            ManaCost = 6;
            Element = "Holy";
            Type = "Damage"
        },
        @{ 
            Name = "Divine Strike"; 
            Description = "Empowered strike with holy energy";
            BaseDamage = 10;
            DamagePerLevel = 1.2;
            DamagePerAttack = 0.25;
            ManaCost = 8;
            Element = "Holy";
            Type = "Damage"
        },
        @{ 
            Name = "Purifying Flame"; 
            Description = "Cleansing flames that burn impurities";
            BaseDamage = 6;
            DamagePerLevel = 0.8;
            DamagePerAttack = 0.15;
            ManaCost = 5;
            Element = "Fire";
            Type = "Damage"
        },
        @{ 
            Name = "Greater Heal"; 
            Description = "Powerful divine healing";
            BaseHeal = 25;
            HealPerLevel = 3;
            HealPerMaxHealth = 0.1;
            ManaCost = 12;
            Type = "Heal"
        }
    )
}

# Elemental weaknesses/resistances - 1.x = xx% damage.
$ElementalEffects = @{
    "Fire" = @{ 
        Description = "burns intensely"; 
        BonusDamage = 1.2 
    }
    "Ice" = @{ 
        Description = "freezes the target"; 
        BonusDamage = 1.1;
        Effect = "Reduces enemy speed by 2 for next turn"
    }
    "Lightning" = @{ 
        Description = "electrocutes the target"; 
        BonusDamage = 1.3;
        Effect = "10% chance to stun enemy"
    }
    "Holy" = @{ 
        Description = "purifies with divine energy"; 
        BonusDamage = 1.15;
        Effect = "Extra effective against undead"
    }
}

# Monster Definitions - New tier based array
$MonsterTypes = @(
    # Tier 1: Early game monsters
    @{ Name = "Goblin"; Health = 12; Attack = 4; Defense = 2; XP = 10; Gold = 5; Tier = 1 },
    @{ Name = "Skeleton"; Health = 15; Attack = 5; Defense = 3; XP = 15; Gold = 8; Tier = 1 },
    @{ Name = "Vampire Bat"; Health = 16; Attack = 6; Defense = 1; XP = 18; Gold = 10; Tier = 1 },
    @{ Name = "Bandit"; Health = 20; Attack = 5; Defense = 2; XP = 18; Gold = 10; Tier = 1 },
    @{ Name = "Giant Spider"; Health = 14; Attack = 5; Defense = 2; XP = 12; Gold = 6; Tier = 1 },

    # Tier 2: Early-mid game monsters
    @{ Name = "Orc"; Health = 20; Attack = 6; Defense = 4; XP = 20; Gold = 12; Tier = 2 },
    @{ Name = "Dark Mage"; Health = 18; Attack = 7; Defense = 2; XP = 25; Gold = 15; Tier = 2 },
    @{ Name = "Frost Elemental"; Health = 22; Attack = 8; Defense = 3; XP = 30; Gold = 18; Tier = 2 },
    @{ Name = "Demon Hound"; Health = 28; Attack = 8; Defense = 3; XP = 30; Gold = 18; Tier = 2 },
    
    # Tier 3: Mid game monsters
    @{ Name = "Troll"; Health = 30; Attack = 8; Defense = 5; XP = 35; Gold = 20; Tier = 3 },
    @{ Name = "Dragon Whelp"; Health = 25; Attack = 9; Defense = 4; XP = 40; Gold = 25; Tier = 3 },
    @{ Name = "Stone Golem"; Health = 35; Attack = 7; Defense = 8; XP = 45; Gold = 22; Tier = 3 },
    
    # Tier 4: Late-mid game monsters
    @{ Name = "Lich"; Health = 28; Attack = 10; Defense = 4; XP = 50; Gold = 30; Tier = 4 },
    @{ Name = "Behemoth"; Health = 45; Attack = 12; Defense = 6; XP = 65; Gold = 40; Tier = 4 },
    @{ Name = "High Orc"; Health = 59; Attack = 15; Defense = 6; XP = 65; Gold = 20; Tier = 4 },
    @{ Name = "Orc Priestest"; Health = 120; Attack = 15; Defense = 6; XP = 65; Gold = 40; Tier = 4 },
    @{ Name = "Lich Wench"; Health = 30; Attack = 10; Defense = 5; XP = 65; Gold = 25; Tier = 4 },
    
    # Tier 5: Late game monsters
    @{ Name = "Chaos Demon"; Health = 38; Attack = 14; Defense = 5; XP = 75; Gold = 50; Tier = 5 },
    @{ Name = "Nightmare"; Health = 38; Attack = 16; Defense = 5; XP = 85; Gold = 60; Tier = 5 },
    @{ Name = "High Lich Priest"; Health = 38; Attack = 12; Defense = 9; XP = 75; Gold = 50; Tier = 5 },
    @{ Name = "Orc Lord"; Health = 50; Attack = 18; Defense = 6; XP = 75; Gold = 90; Tier = 5 }
)

# Boss Definitions - Need more variant
$BossTypes = @(
    @{ Name = "Ancient Dragon"; BaseHealth = 50; BaseAttack = 15; BaseDefense = 8; XP = 200; Gold = 100 },
    @{ Name = "Titan Lord"; BaseHealth = 60; BaseAttack = 12; BaseDefense = 12; XP = 180; Gold = 120 },
    @{ Name = "Archlich"; BaseHealth = 40; BaseAttack = 18; BaseDefense = 6; XP = 220; Gold = 90 },
    @{ Name = "Chaos God"; BaseHealth = 55; BaseAttack = 16; BaseDefense = 10; XP = 250; Gold = 150 },
    @{ Name = "Death Eater"; BaseHealth = 50; BaseAttack = 4; BaseDefense = 20; XP = 350; Gold = 150 },
    @{ Name = "World Eater"; BaseHealth = 70; BaseAttack = 10; BaseDefense = 14; XP = 380; Gold = 200 }
)

# Add more boss special abilities.
$BossAbilities = @(
    @{ 
        Name = "Dark Blast"; 
        Description = "unleashes a wave of dark energy";
        DamageMultiplier = 1.8;
        Effect = "lifedrain"  # Heals boss for portion of damage
    },
    @{ 
        Name = "Soul Drain"; 
        Description = "drains your life force";
        DamageMultiplier = 1.5;
        Effect = "lifedrain"  # Heals boss for portion of damage
    },
    @{ 
        Name = "Shadow Strike"; 
        Description = "strikes from the shadows";
        DamageMultiplier = 2.0;
        Effect = "critical"   # Higher chance to crit
    },
    @{ 
        Name = "Necrotic Touch"; 
        Description = "saps your strength with necrotic energy";
        DamageMultiplier = 1.3;
        Effect = "debuff"     # Reduces player stats
    },
    @{ 
        Name = "Abyssal Scream"; 
        Description = "lets out a terrifying scream from the abyss";
        DamageMultiplier = 1.6;
        Effect = "stun"       # May skip player's next turn
    },
    @{ 
        Name = "Blood Ritual"; 
        Description = "performs a dark blood ritual";
        DamageMultiplier = 1.4;
        Effect = "sacrifice"  # Damages both but heals boss more
    },
    @{ 
        Name = "Void Slash"; 
        Description = "attacks with a blade of pure void";
        DamageMultiplier = 1.7;
        Effect = "armorbreak" # Reduces player defense
    },
    @{ 
        Name = "Cursed Blight"; 
        Description = "curses you with ancient blight";
        DamageMultiplier = 1.2;
        Effect = "dot"        # Damage over time
    }
)

# Artifact System
$global:PlayerArtifacts = @()
$global:MaxArtifacts = 5  # Maximum artifacts player can carry

# Low Tier Artifacts - dropped from normal monsters (low chance)
$LowTierArtifacts = @(
    @{ Name = "Rusty Amulet"; Description = "An old, tarnished amulet"; Stats = @{ Health = 5; Attack = 1 } },
    @{ Name = "Cracked Ring"; Description = "A ring with a hairline fracture"; Stats = @{ Defense = 2; Mana = 3 } },
    @{ Name = "Faded Cloak"; Description = "A cloak that has seen better days"; Stats = @{ Speed = 1; Health = 3 } },
    @{ Name = "Chipped Blade"; Description = "A blade with several notches"; Stats = @{ Attack = 2; CriticalChance = 2 } },
    @{ Name = "Weathered Shield"; Description = "A shield bearing many scars"; Stats = @{ Defense = 3; Health = 2 } },
    @{ Name = "Dull Crystal"; Description = "A crystal that barely glows"; Stats = @{ Mana = 5; CriticalMultiplier = 0.1 } },
    @{ Name = "Ancient Bone"; Description = "A bone inscribed with faint runes"; Stats = @{ Attack = 1; Defense = 1; Health = 2 } },
    @{ Name = "Tarnished Locket"; Description = "A locket that holds a faded picture"; Stats = @{ Health = 4; Mana = 2; Speed = 1 } },
    @{ Name = "Fractured Orb"; Description = "An orb that hums with weak energy"; Stats = @{ Mana = 4; CriticalChance = 1 } },
    @{ Name = "Worn Bracers"; Description = "Bracers that fit perfectly"; Stats = @{ Defense = 2; Speed = 1; Attack = 1 } }
)

# High Tier Artifacts - dropped from bosses (even lower chance)
$HighTierArtifacts = @(
    @{ Name = "Amulet of the Void"; Description = "An amulet that drinks the light around it"; Stats = @{ Health = 15; Attack = 3; CriticalChance = 5 } },
    @{ Name = "Ring of Eternal Night"; Description = "A ring that feels unnaturally cold"; Stats = @{ Defense = 5; Mana = 10; CriticalMultiplier = 0.5 } },
    @{ Name = "Cloak of Shadows"; Description = "A cloak that seems to blend with darkness"; Stats = @{ Speed = 3; Health = 10; CriticalChance = 3 } },
    @{ Name = "Blade of the Abyss"; Description = "A blade that whispers promises of power"; Stats = @{ Attack = 5; CriticalChance = 7; CriticalMultiplier = 0.3 } },
    @{ Name = "Shield of the Titan"; Description = "A shield that feels impossibly heavy"; Stats = @{ Defense = 8; Health = 12; Speed = -1 } },
    @{ Name = "Crystal of Infinite Potential"; Description = "A crystal that contains swirling galaxies"; Stats = @{ Mana = 15; CriticalMultiplier = 0.7; Attack = 2 } },
    @{ Name = "Bone of the First Lich"; Description = "A bone that pulses with necrotic energy"; Stats = @{ Attack = 4; Defense = 3; Health = 8; Mana = 5 } },
    @{ Name = "Locket of Lost Souls"; Description = "A locket that occasionally whispers"; Stats = @{ Health = 12; Mana = 8; Speed = 2; CriticalChance = 2 } },
    @{ Name = "Orb of Cosmic Truth"; Description = "An orb that shows impossible geometries"; Stats = @{ Mana = 12; CriticalChance = 4; CriticalMultiplier = 0.4; Defense = 2 } },
    @{ Name = "Bracers of Divine Wrath"; Description = "Bracers that glow with holy fire"; Stats = @{ Defense = 4; Speed = 2; Attack = 3; CriticalChance = 3 } },
    @{ Name = "Crown of the Fallen King"; Description = "A crown that weighs heavy with regret"; Stats = @{ Health = 20; Mana = 10; Attack = 2; Defense = 2 } },
    @{ Name = "Scepter of Unmaking"; Description = "A scepter that warps reality around it"; Stats = @{ Attack = 6; CriticalMultiplier = 0.6; Mana = 8; Speed = 1 } }
)

#Main game function goes here

function Show-Title {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "         POWERSHELL RPG ADVENTURE" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

function New-Player {
    Show-Title
    Write-Typewriter "CHARACTER CREATION" -Color Green -Delay 40
    Write-Host ""
    Write-Typewriter "It's dark, damp garderobe where your body lies, a voice called out to ask your name." -Color Yellow -Delay 30    
    Write-Typewriter "You've awaken without a memory, but you remembered your name." -Color Yellow -Delay 30    
    $name = Read-Host "My name is"
    
    Write-Host "`nChoose your class:" -ForegroundColor Yellow
    $i = 1
    foreach ($class in $ClassDefinitions.Keys) {
        Write-Host "$i. $class - $($ClassDefinitions[$class].Description)" -ForegroundColor White
        $i++
    }
    
    do {
        $choice = Read-Host "`nSelect class (1-4)"
    } while ($choice -notin @('1','2','3','4'))
    
    $classes = @($ClassDefinitions.Keys)
    $selectedClass = $classes[[int]$choice - 1]
    $global:PlayerArtifacts = @()
   $global:Player = @{
    Name = $name
    Class = $selectedClass
    Level = 1
    Experience = 0
    ExperienceToNextLevel = 100
    Health = $ClassDefinitions[$selectedClass].Health
    MaxHealth = $ClassDefinitions[$selectedClass].Health
    Mana = $ClassDefinitions[$selectedClass].Mana
    MaxMana = $ClassDefinitions[$selectedClass].Mana
    Attack = $ClassDefinitions[$selectedClass].Attack
    Defense = $ClassDefinitions[$selectedClass].Defense
    Speed = $ClassDefinitions[$selectedClass].Speed
    Gold = 50
    Ascension = $null
    AscensionsAvailable = $ClassDefinitions[$selectedClass].Ascensions
    CriticalChance = 10  # Base 10% critical chance
    CriticalMultiplier = 2.0  # 2x damage for critical hits
} 
    Write-Host "`nCharacter created successfully!" -ForegroundColor Green
    
    Write-Typewriter "You made your way out, a town, underground, you heard a calling," -Color Yellow -Delay 30
    Write-Typewriter "Make your mark they said, clear up the underground dungeon, earn Gold and Fame" -Color Yellow -Delay 30    
    Show-PlayerStats
    Write-Typewriter "A goal was set, you took the first steps and march forth.." -Color Yellow -Delay 30    
    Write-Host "`nPress any key to begin your adventure..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-PlayerStats {
    Write-Host "`n=== CHARACTER STATS ===" -ForegroundColor Cyan
    Write-Host "Name: $($global:Player.Name)" -ForegroundColor White
    Write-Host "Class: $($global:Player.Class)" -ForegroundColor White
    if ($global:Player.Ascension) {
        Write-Host "Ascension: $($global:Player.Ascension)" -ForegroundColor Magenta
    }
    Write-Host "Level: $($global:Player.Level)" -ForegroundColor Yellow
    Write-Host "XP: $($global:Player.Experience)/$($global:Player.ExperienceToNextLevel)" -ForegroundColor Green
    Write-Host "Health: $($global:Player.Health)/$($global:Player.MaxHealth)" -ForegroundColor Red
    Write-Host "Mana: $($global:Player.Mana)/$($global:Player.MaxMana)" -ForegroundColor Blue
    Write-Host "Attack: $($global:Player.Attack)" -ForegroundColor DarkRed
    Write-Host "Defense: $($global:Player.Defense)" -ForegroundColor DarkGreen
    Write-Host "Speed: $($global:Player.Speed)" -ForegroundColor DarkYellow
    Write-Host "Critical Chance: $($global:Player.CriticalChance)%" -ForegroundColor Cyan
    Write-Host "Critical Multiplier: $($global:Player.CriticalMultiplier)x" -ForegroundColor Cyan
    Write-Host "Gold: $($global:Player.Gold)" -ForegroundColor Yellow
}

function Show-GameOverScreen {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor DarkRed
    Write-Host "               GAME OVER" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor DarkRed
    Write-Host ""
    
    Write-Host "You feel numb from the wound. You felt cold as your soul consumed by the Dark Lord" -ForegroundColor Gray
    Write-Host "Your journey ends here.." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Final Stats:" -ForegroundColor Yellow
    Write-Host "  Reached Floor: $global:CurrentFloor" -ForegroundColor White
    Write-Host "  Monsters Defeated: $global:MonstersDefeated" -ForegroundColor White
    Write-Host "  Bosses Defeated: $global:BossesDefeated" -ForegroundColor White
    Write-Host "  Artifacts Collected: $($global:PlayerArtifacts.Count)" -ForegroundColor White
    Write-Host "  Final Level: $($global:Player.Level)" -ForegroundColor White
    
    if ($global:Player.Ascension) {
        Write-Host "  Ascension: $($global:Player.Ascension)" -ForegroundColor Magenta
    }
    Write-Host ""
    
    # Show achievements based on performance
    if ($global:CurrentFloor -ge 10) {
        Write-Host "🏆 Deep Explorer: Reached floor 10 or higher!" -ForegroundColor Cyan
    }
    if ($global:BossesDefeated -ge 5) {
        Write-Host "🏆 Boss Slayer: Defeated 5 or more bosses!" -ForegroundColor Yellow
    }
    if ($global:Player.Level -ge 10) {
        Write-Host "🏆 Veteran Adventurer: Reached level 10 or higher!" -ForegroundColor Green
    }
    if ($global:PlayerArtifacts.Count -ge 3) {
        Write-Host "🏆 Artifact Collector: Found 3 or more artifacts!" -ForegroundColor Magenta
    }
    
    Write-Host ""
    Write-Host "What would you like to do?" -ForegroundColor Yellow
    Write-Host "1. Start New Game" -ForegroundColor Green
    Write-Host "2. Exit Game" -ForegroundColor Red
    Write-Host ""
    
    do {
        $choice = Read-Host "Select option (1-2)"
    } while ($choice -notin @('1','2'))
    
    switch ($choice) {
        '1' {
            # Reset game state and start over
            Initialize-GameState
            Start-Game
        }
        '2' {
            Write-Host "`nThanks for playing!" -ForegroundColor Green
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit
        }
    }
}

function Initialize-GameState {
    $global:Player = $null
    $global:GameRunning = $true
    $global:CurrentFloor = 1
    $global:MonstersDefeated = 0
    $global:BossesDefeated = 0
    $global:PlayerArtifacts = @()
}

function Show-Spells {
    if ($global:Player.Class -ne "Mage" -and $global:Player.Class -ne "Cleric") {
        Write-Host "Your class doesn't use spells." -ForegroundColor Gray
        return
    }
    
    Write-Host "`n=== YOUR SPELLS ===" -ForegroundColor Cyan
    $spells = $ClassSpells[$global:Player.Class]
    
    foreach ($spell in $spells) {
        if ($spell.Type -eq "Damage") {
            # Calculate damage using the new structure
            $estimatedDamage = [Math]::Round($spell.BaseDamage + ($global:Player.Level * $spell.DamagePerLevel) + ($global:Player.Attack * $spell.DamagePerAttack))
            
            Write-Host "$($spell.Name): $($spell.Description)" -ForegroundColor White
            Write-Host "  Damage: ~$estimatedDamage | Mana Cost: $($spell.ManaCost)" -ForegroundColor Gray
            if ($spell.Element) {
                Write-Host "  Element: $($spell.Element)" -ForegroundColor Yellow
            }
        } else {
            # Calculate heal using the new structure
            if ($spell.HealPerMaxHealth) {
                $estimatedHeal = [Math]::Round($spell.BaseHeal + ($global:Player.Level * $spell.HealPerLevel) + ($global:Player.MaxHealth * $spell.HealPerMaxHealth))
            } else {
                $estimatedHeal = [Math]::Round($spell.BaseHeal + ($global:Player.Level * $spell.HealPerLevel))
            }
            
            Write-Host "$($spell.Name): $($spell.Description)" -ForegroundColor White
            Write-Host "  Heal: ~$estimatedHeal | Mana Cost: $($spell.ManaCost)" -ForegroundColor Gray
        }
        if ($spell.Effect) {
            Write-Host "  Effect: $($spell.Effect)" -ForegroundColor Cyan
        }
        Write-Host ""
    }
}

function Get-RandomMonster {
    # Boss spawn logic: higher chance on boss floors (every 3 floors), lower chance on other floors
    $isBossFloor = $global:CurrentFloor % 3 -eq 0
    
    # Calculate boss chance - higher on boss floors, lower on regular floors
    if ($isBossFloor) {
        $bossChance = 30  # 30% chance on boss floors (every 3 floors)
    } else {
        # Gradually increasing chance on non-boss floors based on floor level
        $baseChance = 0.5   # Base 0.5% chance on normal floors
        $floorBonus = [Math]::Min($global:CurrentFloor * 0.05, 0.1)  # +0.05% per floor, max +0.1% to prevent early death
        $bossChance = $baseChance + $floorBonus
    }
    
    $isBoss = (Get-Random -Maximum 100) -lt $bossChance

    if ($isBoss) {
        $boss = $BossTypes[(Get-Random -Maximum $BossTypes.Count)].Clone()
        
        # Scale boss stats based on player level and stats (balance as needed)
		$scaleFactor = 1 + ($global:Player.Level * 0.05) + ($global:Player.Attack * 0.05) + ($global:CurrentFloor * 0.1) + ($global:Player.ExperienceToNextLevel * 0.00005)
		$boss.Health = [Math]::Round($boss.BaseHealth * $scaleFactor)
		$boss.Attack = [Math]::Round($boss.BaseAttack * $scaleFactor)
		$boss.Defense = [Math]::Round($boss.BaseDefense * $scaleFactor)
		$boss.XP = [Math]::Round($boss.XP * $scaleFactor)
		$boss.Gold = [Math]::Round($boss.Gold * $scaleFactor)
		$boss.CriticalChance = 10
		$boss.CriticalMultiplier = 1.8
       
		# Add special boss abilities with random modifieders.
        	$boss.IsBoss = $true
		$randomAbility = $BossAbilities | Get-Random
		$boss.SpecialAbility = $randomAbility.Name
		$boss.SpecialDescription = $randomAbility.Description
		$boss.SpecialMultiplier = $randomAbility.DamageMultiplier
		$boss.SpecialEffect = $randomAbility.Effect
        
        Write-Typewriter "`n*** BOSS ENCOUNTER! ***" -ForegroundColor Red -Delay 50
        return $boss
    } else {
	    # Automatic tier-based monster selection
	    $currentTier = [Math]::Min([Math]::Ceiling($global:CurrentFloor / 3), 5)
	    
	    # Get all monsters in the current tier and one tier below (for variety)
	    $availableTiers = @($currentTier)
	    if ($currentTier -gt 1) {
		$availableTiers += ($currentTier - 1)
	    }
	    
	    # Filter monsters by available tiers
	    $availableMonsters = $MonsterTypes | Where-Object { $_.Tier -in $availableTiers }
	    
	    # If we have monsters available, select one randomly
	    if ($availableMonsters.Count -gt 0) {
		$selectedMonster = $availableMonsters | Get-Random
		$baseMonster = $selectedMonster.Clone()
	    } else {
		# Fallback: select any monster (shouldn't happen with proper tier setup)
		$baseMonster = ($MonsterTypes | Get-Random).Clone()
	    }
	    
	    # Scale monster stats based on floor level
	    $scaleFactor = 1 + ($global:CurrentFloor * 0.15) + ($global:Player.Level * 0.2)
	    $baseMonster.Health = [Math]::Round($baseMonster.Health * $scaleFactor)
	    $baseMonster.Attack = [Math]::Round($baseMonster.Attack * $scaleFactor)
	    $baseMonster.Defense = [Math]::Round($baseMonster.Defense * $scaleFactor)
	    $baseMonster.XP = [Math]::Round($baseMonster.XP * $scaleFactor)
	    $baseMonster.Gold = [Math]::Round($baseMonster.Gold * $scaleFactor)
	    $baseMonster.CriticalChance = 5
	    $baseMonster.CriticalMultiplier = 1.5
	    
	    return $baseMonster
	}
}

function Get-RandomArtifact {
    param([string]$Tier)
    
    if ($Tier -eq "Low") {
        $artifact = $LowTierArtifacts | Get-Random
    } else {
        $artifact = $HighTierArtifacts | Get-Random
    }
    
    return @{
        Name = $artifact.Name
        Description = $artifact.Description
        Tier = $Tier
        Stats = $artifact.Stats
    }
}

function Apply-ArtifactStats {
    param($Artifact)
    
    foreach ($stat in $Artifact.Stats.Keys) {
        switch ($stat) {
            "Health" { 
                $global:Player.MaxHealth += $Artifact.Stats[$stat]
                $global:Player.Health += $Artifact.Stats[$stat]  # Also heal the bonus
            }
            "Mana" { 
                $global:Player.MaxMana += $Artifact.Stats[$stat]
                $global:Player.Mana += $Artifact.Stats[$stat]
            }
            "Attack" { $global:Player.Attack += $Artifact.Stats[$stat] }
            "Defense" { $global:Player.Defense += $Artifact.Stats[$stat] }
            "Speed" { $global:Player.Speed += $Artifact.Stats[$stat] }
            "CriticalChance" { $global:Player.CriticalChance += $Artifact.Stats[$stat] }
            "CriticalMultiplier" { $global:Player.CriticalMultiplier += $Artifact.Stats[$stat] }
        }
    }
}

function Show-ArtifactStats {
    param($Artifact)
    
    Write-Host "Artifact Bonuses:" -ForegroundColor Cyan
    foreach ($stat in $Artifact.Stats.Keys) {
        $value = $Artifact.Stats[$stat]
        $color = if ($value -gt 0) { "Green" } else { "Red" }
        $symbol = if ($value -gt 0) { "+" } else { "" }
        
        switch ($stat) {
            "Health" { Write-Host "  $symbol$value Health" -ForegroundColor $color }
            "Mana" { Write-Host "  $symbol$value Mana" -ForegroundColor $color }
            "Attack" { Write-Host "  $symbol$value Attack" -ForegroundColor $color }
            "Defense" { Write-Host "  $symbol$value Defense" -ForegroundColor $color }
            "Speed" { Write-Host "  $symbol$value Speed" -ForegroundColor $color }
            "CriticalChance" { Write-Host "  $symbol$value% Critical Chance" -ForegroundColor $color }
            "CriticalMultiplier" { Write-Host "  $symbol$value Critical Multiplier" -ForegroundColor $color }
        }
    }
}

function Start-Combat {
    $monster = Get-RandomMonster
    $monsterHealth = $monster.Health
    
    Write-Host "`nA wild $($monster.Name) appears!" -ForegroundColor Red
    Write-Host "Monster HP: $monsterHealth | Attack: $($monster.Attack) | Defense: $($monster.Defense)" -ForegroundColor DarkRed
    
    $playerTurn = $global:Player.Speed -ge (Get-Random -Minimum 1 -Maximum 10)

    while ($monsterHealth -gt 0 -and $global:Player.Health -gt 0) {
	if ($playerTurn) {
	    Write-Host "`n=== YOUR TURN ===" -ForegroundColor Green
	    Write-Host "1. Attack"
	    
	    # Show spells for Mage and Cleric
	    if ($global:Player.Class -eq "Mage" -or $global:Player.Class -eq "Cleric") {
		$spells = $ClassSpells[$global:Player.Class]
		for ($i = 0; $i -lt $spells.Count; $i++) {
		    $spell = $spells[$i]
		    $spellNumber = $i + 2
		    
		    if ($spell.Type -eq "Damage") {
			# Calculate damage using the new simplified structure
			$estimatedDamage = [Math]::Round($spell.BaseDamage + ($global:Player.Level * $spell.DamagePerLevel) + ($global:Player.Attack * $spell.DamagePerAttack))
			Write-Host "$spellNumber. $($spell.Name) - $($spell.Description) (Mana: $($spell.ManaCost), Damage: ~$estimatedDamage)"
		    } else {
			# Calculate heal using the new simplified structure
			if ($spell.HealPerMaxHealth) {
			    $estimatedHeal = [Math]::Round($spell.BaseHeal + ($global:Player.Level * $spell.HealPerLevel) + ($global:Player.MaxHealth * $spell.HealPerMaxHealth))
			} else {
			    $estimatedHeal = [Math]::Round($spell.BaseHeal + ($global:Player.Level * $spell.HealPerLevel))
			}
			Write-Host "$spellNumber. $($spell.Name) - $($spell.Description) (Mana: $($spell.ManaCost), Heal: ~$estimatedHeal)"
		    }
		}
	    } else {
		# Special ability for non-spellcasters
		Write-Host "2. Special Ability" -ForegroundColor White
	    }
	    
	    # Standardized options for all classes
	    Write-Host "6. Use Potion (5 gold)" -ForegroundColor White
	    Write-Host "7. Flee" -ForegroundColor White
	    
	    $choice = Read-Host "Choose action"
	    # Validate input based on class
		if ($global:Player.Class -eq "Mage" -or $global:Player.Class -eq "Cleric") {
		    $validChoices = @('1','2','3','4','5','6','7')
		} else {
		    $validChoices = @('1','2','6','7')
		}

		if ($choice -notin $validChoices) {
		    Write-Host "Invalid choice! Please select a valid option." -ForegroundColor Red
		    continue
		}
		switch ($choice) {
		    '1' {
			# Regular attack for all classes
			$baseDamage = [Math]::Max(1, $global:Player.Attack - $monster.Defense + (Get-Random -Minimum -2 -Maximum 3))
			
			# Critical hit check
			$isCritical = (Get-Random -Maximum 100) -lt $global:Player.CriticalChance
			if ($isCritical) {
			    $damage = [Math]::Round($baseDamage * $global:Player.CriticalMultiplier)
			    Write-Typewriter "CRITICAL HIT! You attack the $($monster.Name) for $damage damage!" -Color Cyan -Delay 20
			} else {
			    $damage = $baseDamage
			    Write-Quick "You attack the $($monster.Name) for $damage damage!" -Color Yellow
			}
			$monsterHealth -= $damage
		    }
		    
		    # Spells for Mage and Cleric (options 2-5)
		    {($_ -ge '2' -and $_ -le '5') -and ($global:Player.Class -eq "Mage" -or $global:Player.Class -eq "Cleric")} {
			$spellIndex = [int]$choice - 2
			$spells = $ClassSpells[$global:Player.Class]
			
			if ($spellIndex -lt $spells.Count) {
			    $selectedSpell = $spells[$spellIndex]
			    
			    if ($global:Player.Mana -ge $selectedSpell.ManaCost) {
				$global:Player.Mana -= $selectedSpell.ManaCost
				
				if ($selectedSpell.Type -eq "Damage") {
				    # Calculate spell damage
				    $baseSpellDamage = [Math]::Round($selectedSpell.BaseDamage + ($global:Player.Level * $selectedSpell.DamagePerLevel) + ($global:Player.Attack * $selectedSpell.DamagePerAttack))
				    
				    # Apply elemental bonus if applicable
				    $elementalBonus = 1.0
				    $elementDescription = ""
				    if ($selectedSpell.Element -and $ElementalEffects.ContainsKey($selectedSpell.Element)) {
					$elementalBonus = $ElementalEffects[$selectedSpell.Element].BonusDamage
					$elementDescription = $ElementalEffects[$selectedSpell.Element].Description
				    }
				    
				    $spellDamage = [Math]::Round($baseSpellDamage * $elementalBonus)
				    
				    # Critical hit check for spells
				    $isCritical = (Get-Random -Maximum 100) -lt ($global:Player.CriticalChance + 5)
				    if ($isCritical) {
					$spellDamage = [Math]::Round($spellDamage * $global:Player.CriticalMultiplier)
					if ($elementDescription) {
					    Write-Typewriter "CRITICAL HIT! You cast $($selectedSpell.Name) and it $elementDescription for $spellDamage damage!" -Color Cyan -Delay 20
					} else {
					    Write-Typewriter "CRITICAL HIT! You cast $($selectedSpell.Name) for $spellDamage damage!" -Color Cyan -Delay 20
					}
				    } else {
					if ($elementDescription) {
					    Write-Typewriter "You cast $($selectedSpell.Name) and it $elementDescription for $spellDamage damage!" -Color Magenta -Delay 20
					} else {
					    Write-Typewriter "You cast $($selectedSpell.Name) for $spellDamage damage!" -Color Magenta -Delay 20
					}
				    }
				    
				    # Apply spell effects
				    if ($selectedSpell.Effect -eq "Slow") {
					Write-Host "The $($monster.Name) is slowed!" -ForegroundColor Blue
				    } elseif ($selectedSpell.Effect -eq "Stun" -and (Get-Random -Maximum 100) -lt 10) {
					$playerTurn = $true
					Write-Host "The $($monster.Name) is stunned and loses its turn!" -ForegroundColor Yellow
				    }
				    
				    $monsterHealth -= $spellDamage
				    
				} elseif ($selectedSpell.Type -eq "Heal") {
				    # Calculate heal
				    if ($selectedSpell.HealPerMaxHealth) {
					$healAmount = [Math]::Round($selectedSpell.BaseHeal + ($global:Player.Level * $selectedSpell.HealPerLevel) + ($global:Player.MaxHealth * $selectedSpell.HealPerMaxHealth))
				    } else {
					$healAmount = [Math]::Round($selectedSpell.BaseHeal + ($global:Player.Level * $selectedSpell.HealPerLevel))
				    }
				    
				    $oldHealth = $global:Player.Health
				    $global:Player.Health = [Math]::Min($global:Player.MaxHealth, $global:Player.Health + $healAmount)
				    $actualHeal = $global:Player.Health - $oldHealth
				    
				    Write-Typewriter "You cast $($selectedSpell.Name) and heal $actualHeal health!" -Color Green -Delay 20
				    Write-Host "Current HP: $($global:Player.Health)/$($global:Player.MaxHealth)" -ForegroundColor Green
				}
			    } else {
				Write-Host "Not enough mana! You need $($selectedSpell.ManaCost) mana." -ForegroundColor Red
				continue
			    }
			} else {
			    Write-Host "Invalid spell selection!" -ForegroundColor Red
			    continue
			}
		    }
		    
		    # Special ability for non-spellcasters (option 2)
		    {$_ -eq '2' -and $global:Player.Class -ne "Mage" -and $global:Player.Class -ne "Cleric"} {
			if ($global:Player.Mana -ge 5) {
			    $global:Player.Mana -= 5
			    $specialDamage = $global:Player.Attack + (Get-Random -Minimum 2 -Maximum 6)
			    $monsterHealth -= $specialDamage
			    Write-Host "You use a special ability for $specialDamage damage!" -ForegroundColor Magenta
			} else {
			    Write-Host "Not enough mana!" -ForegroundColor Red
			    continue
			}
		    }
		    
		    # Potion for all classes (option 6)
		    '6' {
			if ($global:Player.Gold -ge 5) {
			    $global:Player.Gold -= 5
			    
			    # Scaled healing
			    $baseHeal = 20
			    $levelBonus = $global:Player.Level * 3
			    $healthPercentage = $global:Player.MaxHealth * 0.15
			    $heal = $baseHeal + $levelBonus + [Math]::Round($healthPercentage)
			    
			    $oldHealth = $global:Player.Health
			    $global:Player.Health = [Math]::Min($global:Player.MaxHealth, $global:Player.Health + $heal)
			    $actualHeal = $global:Player.Health - $oldHealth
			    
			    Write-Host "You use a potion and heal $actualHeal health!" -ForegroundColor Green
			    Write-Host "Current HP: $($global:Player.Health)/$($global:Player.MaxHealth)" -ForegroundColor Green
			} else {
			    Write-Host "Not enough gold!" -ForegroundColor Red
			    continue
			}
		    }
		    
		    # Flee for all classes (option 7)
		    '7' {
			if ((Get-Random -Maximum 100) -lt 40) {
			    Write-Host "You successfully fled from combat!" -ForegroundColor Green
			    Write-Host "Press any key to continue..." -ForegroundColor Gray
			    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			    return $false
			} else {
			    Write-Host "Failed to flee!" -ForegroundColor Red
			}
		    }
		    default {
			Write-Host "Invalid choice!" -ForegroundColor Red
			continue
		    }
		}

	       } else {
	    Write-Typewriter "`n=== MONSTER'S TURN ===" -ForegroundColor Red
	    
		# Boss special attacks
		if ($monster.IsBoss -and (Get-Random -Maximum 100) -lt 25) {
    $baseDamage = [Math]::Max(2, ($monster.Attack * $monster.SpecialMultiplier) - $global:Player.Defense)
    
    # Apply special effects based on ability type
    $effectMessage = ""
    $additionalDamage = 0
    
    switch ($monster.SpecialEffect) {
        "lifedrain" {
            $healAmount = [Math]::Round($baseDamage * 0.25)  # Reduced from 0.5
            $monsterHealth += $healAmount
            $monsterHealth = [Math]::Min($monster.Health, $monsterHealth)
            $effectMessage = " and drains $healAmount health from you!"
        }
        "critical" {
            # Double critical chance for these abilities
            $isCritical = (Get-Random -Maximum 100) -lt ($monster.CriticalChance * 1.5)  # Reduced from 2.0
            if ($isCritical) {
                $baseDamage = [Math]::Round($baseDamage * $monster.CriticalMultiplier)
                $effectMessage = " with enhanced critical strike!"
            }
        }
        "debuff" {
            # Reduce player attack temporarily
            $attackReduction = 1  # Reduced from 2
            $global:Player.Attack = [Math]::Max(1, $global:Player.Attack - $attackReduction)
            $effectMessage = " reducing your attack power by $attackReduction!"
        }
        "stun" {
            # Chance to stun player (skip next turn)
            if ((Get-Random -Maximum 100) -lt 30) {  # Reduced from 40
                $playerTurn = $false
                $effectMessage = " stunning you and making you lose your next turn!"
            } else {
                $effectMessage = " but you resist the stun!"
            }
        }
        "sacrifice" {
            # Boss takes some damage but gains more - subject to rebalancing.
            $bossSelfDamage = [Math]::Round($baseDamage * 0.5)
            $monsterHealth -= $bossSelfDamage
            $healAmount = [Math]::Round($baseDamage * 0.3)
            $monsterHealth += $healAmount
            $monsterHealth = [Math]::Min($monster.Health, $monsterHealth)
            $effectMessage = " sacrificing $bossSelfDamage health but gaining $healAmount!"
        }
        "armorbreak" {
            # Reduce player defense
            $defenseReduction = 2  # Reduced from 2
            $global:Player.Defense = [Math]::Max(0, $global:Player.Defense - $defenseReduction)
            $effectMessage = " breaking your armor and reducing defense by $defenseReduction!"
        }
        "dot" {
            # Apply damage over time
            $additionalDamage = [Math]::Round($baseDamage * 0.2)  # Reduced from 0.3
            $effectMessage = " applying a damage over time effect for $additionalDamage additional damage!"
        }
        default {
            $effectMessage = "!"
        }
    }
    
	    # Critical hit check for boss special
	    $isCritical = (Get-Random -Maximum 100) -lt $monster.CriticalChance
	    if ($isCritical -and $monster.SpecialEffect -ne "critical") {
		$specialDamage = [Math]::Round($baseDamage * $monster.CriticalMultiplier)
		Write-Typewriter "CRITICAL HIT! The $($monster.Name) $($monster.SpecialDescription) for $specialDamage damage$effectMessage" -Color DarkRed -Delay 20
	    } else {
		$specialDamage = $baseDamage
		Write-Typewriter "The $($monster.Name) $($monster.SpecialDescription) for $specialDamage damage$effectMessage" -Color Red -Delay 20
	    }
	    
	    # Apply damage - ONLY ONCE
	    $global:Player.Health -= $specialDamage
	    if ($additionalDamage -gt 0) {
		$global:Player.Health -= $additionalDamage
	    }
		} else {
		$baseDamage = [Math]::Max(1, $monster.Attack - $global:Player.Defense + (Get-Random -Minimum -1 -Maximum 2))
		
		# Critical hit check for normal monster attack
		$isCritical = (Get-Random -Maximum 100) -lt $monster.CriticalChance
		if ($isCritical) {
		    $damage = [Math]::Round($baseDamage * $monster.CriticalMultiplier)
		    Write-Typewriter "CRITICAL HIT! The $($monster.Name) attacks you for $damage damage!" -ForegroundColor DarkRed
		} else {
		    $damage = $baseDamage
		    Write-Host "The $($monster.Name) attacks you for $damage damage!" -ForegroundColor Red
		}
		$global:Player.Health -= $damage
	    }

		}
		# Show combat status
		Write-Typewriter "`nYour HP: $($global:Player.Health)/$($global:Player.MaxHealth)" -ForegroundColor Green
		Write-Typewriter "$($monster.Name) HP: $monsterHealth/$($monster.Health)" -ForegroundColor Red
		
		$playerTurn = !$playerTurn
	    }
	    
	    if ($global:Player.Health -le 0) {
		    Write-Host "`n==========================================" -ForegroundColor DarkRed
		    Write-Host "          YOU HAVE BEEN DEFEATED" -ForegroundColor Red
		    Write-Host "==========================================" -ForegroundColor DarkRed
		    Write-Host ""
		    Write-Host "As your vision fades, you feel the cold embrace of death..." -ForegroundColor Gray
		    Write-Host ""
		        Write-Host ""   
		    # Different death messages based on progress
		    if ($global:CurrentFloor -le 3) {
			Write-Host "Your adventure ends before it truly began..." -ForegroundColor Gray
		    } elseif ($global:CurrentFloor -le 7) {
			Write-Host "You fought bravely, but the dungeon proved too formidable..." -ForegroundColor Gray
		    } elseif ($global:CurrentFloor -le 12) {
			Write-Host "A valiant effort, but even heroes must fall..." -ForegroundColor Gray
		    } else {
			Write-Host "You ventured deeper than most, but even legends must end..." -ForegroundColor Gray
		    }
		    
		    Write-Host ""
		    Write-Host "Press any key to face your fate..." -ForegroundColor Gray
		    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		    return $false
		    } else {
			Write-Host "`nYou defeated the $($monster.Name)!" -ForegroundColor Green
			$goldEarned = $monster.Gold
			$xpEarned = $monster.XP
			$global:Player.Gold += $goldEarned
			$global:Player.Experience += $xpEarned
			$global:MonstersDefeated++

			if ($monster.IsBoss) {
			    $global:BossesDefeated++
			    Write-Host "*** BOSS DEFEATED! ***" -ForegroundColor Magenta
			}

			Write-Host "Earned $xpEarned XP and $goldEarned gold!" -ForegroundColor Yellow

			# Check for level up after combat victory
			Level-Up

			# Check for artifact drops
			if ($victory) {
			    # Check for low tier artifact from normal monsters (2% chance)
			    if (!$monster.IsBoss -and (Get-Random -Maximum 100) -lt 2) {
				$newArtifact = Get-RandomArtifact -Tier "Low"
				if ($global:PlayerArtifacts.Count -lt $global:MaxArtifacts) {
				    $global:PlayerArtifacts += $newArtifact
				    Apply-ArtifactStats -Artifact $newArtifact
				    Write-Typewriter "*** You found a rare artifact: $($newArtifact.Name) ***" -Color Yellow -Delay 40
				    Write-Host "$($newArtifact.Description)" -ForegroundColor Gray
				    Show-ArtifactStats -Artifact $newArtifact
				} else {
				    Write-Host "You found an artifact but your inventory is full!" -ForegroundColor Yellow
				}
			    }
			    
			# Check for high tier artifact from bosses (5% chance)
			    if ($monster.IsBoss -and (Get-Random -Maximum 100) -lt 5) {
				$newArtifact = Get-RandomArtifact -Tier "High"
				if ($global:PlayerArtifacts.Count -lt $global:MaxArtifacts) {
				    $global:PlayerArtifacts += $newArtifact
				    Apply-ArtifactStats -Artifact $newArtifact
				    Write-Typewriter "*** The boss dropped a legendary artifact: $($newArtifact.Name) ***" -Color Magenta -Delay 50
				    Write-Host "$($newArtifact.Description)" -ForegroundColor Gray
				    Show-ArtifactStats -Artifact $newArtifact
				} else {
				    Write-Host "The boss dropped an artifact but your inventory is full!" -ForegroundColor Yellow
				}
			    }
			}

			Write-Host "Press any key to continue..." -ForegroundColor Gray
			$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			return $true	   
			}
			# Reset any temporary stat changes after combat
				if ($global:Player.Attack -lt ($ClassDefinitions[$global:Player.Class].Attack + ($global:Player.Level * 2))) {
				# Reset to base + level progression (simplified calculation)
				$global:Player.Attack = $ClassDefinitions[$global:Player.Class].Attack + ($global:Player.Level * 2)
				if ($global:Player.Ascension) {
				    $global:Player.Attack += $AscensionBonuses[$global:Player.Ascension].Attack
				}
			    }
			    
			    if ($global:Player.Defense -lt ($ClassDefinitions[$global:Player.Class].Defense + ($global:Player.Level * 1))) {
				# Reset to base + level progression
				$global:Player.Defense = $ClassDefinitions[$global:Player.Class].Defense + ($global:Player.Level * 1)
				if ($global:Player.Ascension) {
				    $global:Player.Defense += $AscensionBonuses[$global:Player.Ascension].Defense
					}
				}

}

function Show-Artifacts {
    Write-Host "`n=== YOUR ARTIFACTS ===" -ForegroundColor Cyan
    Write-Host "Carrying: $($global:PlayerArtifacts.Count)/$global:MaxArtifacts" -ForegroundColor White
    
    if ($global:PlayerArtifacts.Count -eq 0) {
        Write-Host "You haven't found any artifacts yet." -ForegroundColor Gray
        Write-Host "Defeat monsters and bosses to find rare artifacts!" -ForegroundColor Gray
        return
    }
    
    $totalBonuses = @{}
    
    for ($i = 0; $i -lt $global:PlayerArtifacts.Count; $i++) {
        $artifact = $global:PlayerArtifacts[$i]
        $tierColor = if ($artifact.Tier -eq "High") { "Magenta" } else { "Yellow" }
        
        Write-Host "`n$($i + 1). $($artifact.Name) [$($artifact.Tier) Tier]" -ForegroundColor $tierColor
        Write-Host "   $($artifact.Description)" -ForegroundColor Gray
        
        # Show individual artifact stats
        foreach ($stat in $artifact.Stats.Keys) {
            $value = $artifact.Stats[$stat]
            $color = if ($value -gt 0) { "Green" } else { "Red" }
            $symbol = if ($value -gt 0) { "+" } else { "" }
            
            switch ($stat) {
                "Health" { Write-Host "   $symbol$value Health" -ForegroundColor $color }
                "Mana" { Write-Host "   $symbol$value Mana" -ForegroundColor $color }
                "Attack" { Write-Host "   $symbol$value Attack" -ForegroundColor $color }
                "Defense" { Write-Host "   $symbol$value Defense" -ForegroundColor $color }
                "Speed" { Write-Host "   $symbol$value Speed" -ForegroundColor $color }
                "CriticalChance" { Write-Host "   $symbol$value% Critical Chance" -ForegroundColor $color }
                "CriticalMultiplier" { Write-Host "   $symbol$value Critical Multiplier" -ForegroundColor $color }
            }
            
            # Accumulate total bonuses
            if ($totalBonuses.ContainsKey($stat)) {
                $totalBonuses[$stat] += $value
            } else {
                $totalBonuses[$stat] = $value
            }
        }
    }
    
    # Show total bonuses
    if ($totalBonuses.Count -gt 0) {
        Write-Host "`n=== TOTAL ARTIFACT BONUSES ===" -ForegroundColor Cyan
        foreach ($stat in $totalBonuses.Keys) {
            $value = $totalBonuses[$stat]
            $color = if ($value -gt 0) { "Green" } else { "Red" }
            $symbol = if ($value -gt 0) { "+" } else { "" }
            
            switch ($stat) {
                "Health" { Write-Host "$symbol$value Health" -ForegroundColor $color }
                "Mana" { Write-Host "$symbol$value Mana" -ForegroundColor $color }
                "Attack" { Write-Host "$symbol$value Attack" -ForegroundColor $color }
                "Defense" { Write-Host "$symbol$value Defense" -ForegroundColor $color }
                "Speed" { Write-Host "$symbol$value Speed" -ForegroundColor $color }
                "CriticalChance" { Write-Host "$symbol$value% Critical Chance" -ForegroundColor $color }
                "CriticalMultiplier" { Write-Host "$symbol$value Critical Multiplier" -ForegroundColor $color }
            }
        }
    }
    
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

#Level Up function
function Level-Up {
    while ($global:Player.Experience -ge $global:Player.ExperienceToNextLevel) {
        $global:Player.Level++
        $global:Player.Experience -= $global:Player.ExperienceToNextLevel
        $global:Player.ExperienceToNextLevel = [Math]::Round($global:Player.ExperienceToNextLevel * 1.5)
        
        # Stat increases
        $healthIncrease = 5 + (Get-Random -Minimum 1 -Maximum 4)
        $attackIncrease = 1 + (Get-Random -Minimum 0 -Maximum 2)
        $defenseIncrease = 1 + (Get-Random -Minimum 0 -Maximum 2)
        $manaIncrease = 5 + (Get-Random -Minimum 2 -Maximum 5)
        
        $global:Player.MaxHealth += $healthIncrease
        $global:Player.Health = $global:Player.MaxHealth
        $global:Player.Attack += $attackIncrease
        $global:Player.Defense += $defenseIncrease
        $global:Player.MaxMana += $manaIncrease
        $global:Player.Mana = $global:Player.MaxMana
        if ((Get-Random -Maximum 100) -lt 30) {  # 30% chance per level up
	$global:Player.CriticalChance += 1
	Write-Host "Critical Chance +1%" -ForegroundColor Cyan
	}
        Write-Host "`n*** LEVEL UP! You are now level $($global:Player.Level) ***" -ForegroundColor Yellow
        Write-Host "Health +$healthIncrease, Attack +$attackIncrease, Defense +$defenseIncrease, Mana +$manaIncrease" -ForegroundColor Green
        
        # Check for ascension at level 5
        if ($global:Player.Level -eq 5 -and !$global:Player.Ascension) {
            Start-Ascension
        }
        
        # Full heal on level up
        $global:Player.Health = $global:Player.MaxHealth
        $global:Player.Mana = $global:Player.MaxMana
    }
}

function Start-Ascension {
    Write-Typewriter "`n*** ASCENSION AVAILABLE! ***" -ForegroundColor Magenta
    Write-Typewriter "Choose your ascension path:" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $global:Player.AscensionsAvailable.Count; $i++) {
        $ascension = $global:Player.AscensionsAvailable[$i]
        Write-Typewriter "$($i + 1). $ascension" -ForegroundColor White
        Write-Typewriter "   Bonus: +$($AscensionBonuses[$ascension].Health) HP, +$($AscensionBonuses[$ascension].Mana) Mana, +$($AscensionBonuses[$ascension].Attack) Attack, +$($AscensionBonuses[$ascension].Defense) Defense, +$($AscensionBonuses[$ascension].Speed) Speed" -ForegroundColor Gray
    }
    
    do {
        $choice = Read-Host "`nSelect ascension (1-4)"
    } while ($choice -notin @('1','2','3','4'))
    
    $selectedAscension = $global:Player.AscensionsAvailable[[int]$choice - 1]
    $global:Player.Ascension = $selectedAscension
    
    # Apply ascension bonuses
    $global:Player.MaxHealth += $AscensionBonuses[$selectedAscension].Health
    $global:Player.Health = $global:Player.MaxHealth
    $global:Player.MaxMana += $AscensionBonuses[$selectedAscension].Mana
    $global:Player.Mana = $global:Player.MaxMana
    $global:Player.Attack += $AscensionBonuses[$selectedAscension].Attack
    $global:Player.Defense += $AscensionBonuses[$selectedAscension].Defense
    $global:Player.Speed += $AscensionBonuses[$selectedAscension].Speed
    
    Write-Typewriter "`nYou have ascended to $selectedAscension!" -ForegroundColor Magenta
    Write-Typewriter "All stats improved!" -ForegroundColor Green
}

function Show-GameMenu {
    Write-Host "`n=== FLOOR $global:CurrentFloor ===" -ForegroundColor Cyan
    Write-Host "Monsters Defeated: $global:MonstersDefeated" -ForegroundColor White
    Write-Host "Artifacts Found: $($global:PlayerArtifacts.Count)/$global:MaxArtifacts" -ForegroundColor Yellow
    Write-Host "`nWhat would you like to do?" -ForegroundColor Yellow
    Write-Host "1. Explore (Fight monsters)"
    Write-Host "2. Rest (Heal for 10 gold)"
    Write-Host "3. View Stats"
    Write-Host "4. View Spells"
    Write-Host "5. Visit Shop"
    Write-Host "6. Show Artifacts"
    Write-Host "7. Descend to next floor"
    Write-Host "0. Quit Game"
}

function Show-ExitScreen {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "          EXITING GAME" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Your current progress:" -ForegroundColor White
    Write-Host "  Current Floor: $global:CurrentFloor" -ForegroundColor Gray
    Write-Host "  Monsters Defeated: $global:MonstersDefeated" -ForegroundColor Gray
    Write-Host "  Bosses Defeated: $global:BossesDefeated" -ForegroundColor Gray
    Write-Host "  Artifacts Collected: $($global:PlayerArtifacts.Count)" -ForegroundColor Gray
    Write-Host "  Current Level: $($global:Player.Level)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Are you sure you want to exit?" -ForegroundColor Yellow
    Write-Host "1. Continue Playing" -ForegroundColor Green
    Write-Host "2. Exit Game" -ForegroundColor Red
    Write-Host ""
    
    do {
        $choice = Read-Host "Select option (1-2)"
    } while ($choice -notin @('1','2'))
    
    switch ($choice) {
        '1' {
            Write-Host "Continuing your adventure..." -ForegroundColor Green
            return $true
        }
        '2' {
            Write-Host "`nThanks for playing! Your adventure awaits another day." -ForegroundColor Green
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit
        }
    }
}

# Shop Inventory and logic - TODO Make the Item balance to prevent over leveled bruteforce

function Visit-Shop {
    Write-Host "`n=== WELCOME TO THE SHOP ===" -ForegroundColor Yellow
    Write-Host "Your gold: $($global:Player.Gold)" -ForegroundColor Yellow
    
    $shopItems = @(
        @{ Name = "Health Potion"; Cost = 15; Description = "Restore 25 HP" },
        @{ Name = "Mana Potion"; Cost = 12; Description = "Restore 20 Mana" },
        @{ Name = "Attack Boost"; Cost = 50; Description = "Permanently +2 Attack" },
        @{ Name = "Defense Boost"; Cost = 50; Description = "Permanently +2 Defense" },
	@{ Name = "Mana Boost"; Cost = 50; Description = "Permanently +5 Mana" },
        @{ Name = "Critical Charm"; Cost = 95; Description = "Permanently +5% Critical Chance" },
        @{ Name = "Keen Edge"; Cost = 180; Description = "Permanently +0.5 Critical Multiplier" }
    )
    
    for ($i = 0; $i -lt $shopItems.Count; $i++) {
        Write-Host "$($i + 1). $($shopItems[$i].Name) - $($shopItems[$i].Cost) gold" -ForegroundColor White
        Write-Host "   $($shopItems[$i].Description)" -ForegroundColor Gray
    }
    Write-Host "8. Sell Artifact (50 gold)" -ForegroundColor White
    Write-Host "   Get rid of an unwanted artifact" -ForegroundColor Gray
    Write-Host "0. Leave Shop" -ForegroundColor Gray
    
    do {
        $choice = Read-Host "`nSelect item to purchase"
    } while ($choice -notin @('0','1','2','3','4','5','6','7','8'))
    
    if ($choice -eq '0') { return }
    
    $selectedItem = $shopItems[[int]$choice - 1]
    
    if ($global:Player.Gold -ge $selectedItem.Cost) {
        $global:Player.Gold -= $selectedItem.Cost
        
        switch ($choice) {
            '1' {
                $global:Player.Health = [Math]::Min($global:Player.MaxHealth, $global:Player.Health + 25)
                Write-Host "Health restored! Current HP: $($global:Player.Health)" -ForegroundColor Green
            }
            '2' {
                $global:Player.Mana = [Math]::Min($global:Player.MaxMana, $global:Player.Mana + 20)
                Write-Host "Mana restored! Current Mana: $($global:Player.Mana)" -ForegroundColor Blue
            }
            '3' {
                $global:Player.Attack += 2
                Write-Host "Attack permanently increased by 2!" -ForegroundColor Red
            }
            '4' {
                $global:Player.Defense += 2
                Write-Host "Defense permanently increased by 2!" -ForegroundColor Green
            }
            '5' {
                $global:Player.MaxMana += 5
                Write-Host "Maximum Mana permanently increased by 5!" -ForegroundColor Green
            }
            '6' {
                $global:Player.CriticalChance += 5
                Write-Host "Critical chance increased by 5%! Current: $($global:Player.CriticalChance)%" -ForegroundColor Cyan
            }
            '7' {
                $global:Player.CriticalMultiplier += 0.5
                Write-Host "Critical multiplier increased by 0.5! Current: $($global:Player.CriticalMultiplier)x" -ForegroundColor Cyan
            }
	    '8' {
		if ($global:PlayerArtifacts.Count -eq 0) {
		    Write-Host "You have no artifacts to sell!" -ForegroundColor Red
		    return
		}
		
		Write-Host "`nSelect artifact to sell:" -ForegroundColor Yellow
		for ($i = 0; $i -lt $global:PlayerArtifacts.Count; $i++) {
		    $artifact = $global:PlayerArtifacts[$i]
		    Write-Host "$($i + 1). $($artifact.Name) - $($artifact.Description)" -ForegroundColor White
		}
		Write-Host "0. Cancel" -ForegroundColor Gray
		
		$sellChoice = Read-Host "`nSelect artifact"
		if ($sellChoice -eq '0') { return }
		
		$artifactIndex = [int]$sellChoice - 1
		if ($artifactIndex -ge 0 -and $artifactIndex -lt $global:PlayerArtifacts.Count) {
		    $soldArtifact = $global:PlayerArtifacts[$artifactIndex]
		    
		    # Remove artifact bonuses
		    foreach ($stat in $soldArtifact.Stats.Keys) {
			switch ($stat) {
			    "Health" { 
				$global:Player.MaxHealth -= $soldArtifact.Stats[$stat]
				$global:Player.Health = [Math]::Min($global:Player.Health, $global:Player.MaxHealth)
			    }
			    "Mana" { 
				$global:Player.MaxMana -= $soldArtifact.Stats[$stat]
				$global:Player.Mana = [Math]::Min($global:Player.Mana, $global:Player.MaxMana)
			    }
			    "Attack" { $global:Player.Attack -= $soldArtifact.Stats[$stat] }
			    "Defense" { $global:Player.Defense -= $soldArtifact.Stats[$stat] }
			    "Speed" { $global:Player.Speed -= $soldArtifact.Stats[$stat] }
			    "CriticalChance" { $global:Player.CriticalChance -= $soldArtifact.Stats[$stat] }
			    "CriticalMultiplier" { $global:Player.CriticalMultiplier -= $soldArtifact.Stats[$stat] }
			}
		    }
		    
		    $global:PlayerArtifacts.RemoveAt($artifactIndex)
		    $global:Player.Gold += 50
		    Write-Host "Sold $($soldArtifact.Name) for 50 gold!" -ForegroundColor Yellow
		}
	    }
        }
    } else {
        Write-Host "Not enough gold!" -ForegroundColor Red
    }
}

function Start-Game {
    Show-WelcomeScreen
    New-Player
    
    while ($global:GameRunning -and $global:Player.Health -gt 0) {
        Show-Title
        Show-PlayerStats
        Show-GameMenu
        
        $choice = Read-Host "`nSelect action"
        
        switch ($choice) {
            '1' {
                $victory = Start-Combat
                if ($victory) {
                    Level-Up
                } else {
			if ($global:Player.Health -le 0) {
			    Show-GameOverScreen
			}

		}
            }
            '2' {
                if ($global:Player.Gold -ge 10) {
                    $global:Player.Gold -= 10
                    $global:Player.Health = $global:Player.MaxHealth
                    $global:Player.Mana = $global:Player.MaxMana
                    Write-Host "You rest and recover all health and mana!" -ForegroundColor Green
                } else {
                    Write-Host "Not enough gold to rest!" -ForegroundColor Red
                }
            }
            '3' {
                Show-PlayerStats
            }
	    '4' {
		Show-Spells
		}
            '5' {
                Visit-Shop
            }
	    '6' {
	    	Show-Artifacts
	    }
	    '7' {
		$global:CurrentFloor++
		Write-Host "You descend to floor $global:CurrentFloor..." -ForegroundColor Cyan
		    
		$isBossFloor = $global:CurrentFloor % 3 -eq 0
		    
		if ($isBossFloor) {
			$bossMessages = @(
			    "A terrifying roar echoes through the chamber... A boss awaits!",
			    "The very air crackles with power... A formidable foe is near!",
			    "You sense a massive presence watching you... Prepare for battle!",
			    "Ancient runes glow ominously... This floor holds a great challenge!"
			)
			$randomMessage = $bossMessages | Get-Random
			Write-Typewriter $randomMessage -Color Red -Delay 40
			Write-Host "Boss encounter likely!" -ForegroundColor Yellow
		    } else {
			$normalMessages = @(
			    "Monsters grow stronger as you descend deeper.",
			    "The dungeon's challenges intensify.",
			    "You venture further into the unknown.",
			    "Deeper you go, where greater dangers await.",
			    "Each floor brings new threats and treasures."
			)
			$randomMessage = $normalMessages | Get-Random
			Write-Typewriter $randomMessage -Color Cyan -Delay 30
		    }
		}
		'0' {
		$continuePlaying = Show-ExitScreen
		if (!$continuePlaying) {
			$global:GameRunning = $false
		}
            }
            default {
                Write-Host "Invalid choice!" -ForegroundColor Red
            }
        }
        
	if ($global:GameRunning -and $choice -ne '1') {
	    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
	    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
    }
}

# Start the game
try {
    Start-Game
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
finally {
    Write-Host "`nGame session ended." -ForegroundColor Gray
}







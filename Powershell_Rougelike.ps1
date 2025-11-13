# Powershell Rougelike Game

# Game State
$global:Player = $null
$global:GameRunning = $true
$global:CurrentFloor = 1
$global:MonstersDefeated = 0
$global:BossesDefeated = 0

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
        Start-Sleep -Milliseconds 5
    }
    Write-Host ""
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
        Mana = 25
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
        Mana = 20
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

# Monster Definitions - TODO: Need more monster variant
$MonsterTypes = @(
    @{ Name = "Goblin"; Health = 12; Attack = 4; Defense = 2; XP = 10; Gold = 5 },
    @{ Name = "Skeleton"; Health = 15; Attack = 5; Defense = 3; XP = 15; Gold = 8 },
    @{ Name = "Orc"; Health = 20; Attack = 6; Defense = 4; XP = 20; Gold = 12 },
    @{ Name = "Dark Mage"; Health = 18; Attack = 7; Defense = 2; XP = 25; Gold = 15 },
    @{ Name = "Troll"; Health = 30; Attack = 8; Defense = 5; XP = 35; Gold = 20 },
    @{ Name = "Dragon Whelp"; Health = 25; Attack = 9; Defense = 4; XP = 40; Gold = 25 },
    @{ Name = "Vampire Bat"; Health = 16; Attack = 6; Defense = 1; XP = 18; Gold = 10 },
    @{ Name = "Stone Golem"; Health = 35; Attack = 7; Defense = 8; XP = 45; Gold = 22 },
    @{ Name = "Frost Elemental"; Health = 22; Attack = 8; Defense = 3; XP = 30; Gold = 18 },
    @{ Name = "Lich"; Health = 28; Attack = 10; Defense = 4; XP = 50; Gold = 30 },
    @{ Name = "Behemoth"; Health = 45; Attack = 12; Defense = 6; XP = 65; Gold = 40 },
    @{ Name = "Chaos Demon"; Health = 38; Attack = 14; Defense = 5; XP = 75; Gold = 50 }
)

# Boss Definitions - Need more variant
$BossTypes = @(
    @{ Name = "Ancient Dragon"; BaseHealth = 50; BaseAttack = 15; BaseDefense = 8; XP = 200; Gold = 100 },
    @{ Name = "Titan Lord"; BaseHealth = 60; BaseAttack = 12; BaseDefense = 12; XP = 180; Gold = 120 },
    @{ Name = "Archlich"; BaseHealth = 40; BaseAttack = 18; BaseDefense = 6; XP = 220; Gold = 90 },
    @{ Name = "Chaos God"; BaseHealth = 55; BaseAttack = 16; BaseDefense = 10; XP = 250; Gold = 150 },
    @{ Name = "World Eater"; BaseHealth = 70; BaseAttack = 14; BaseDefense = 14; XP = 300; Gold = 200 }
)

function Show-Title {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "         POWER ROUGE SHELL       " -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

function New-Player {
    Show-Title
    Write-Typewriter "CHARACTER CREATION" -Color Green -Delay 40
    Write-Host ""
    Write-Typewriter "It's dark, damp garderobe where your body lies, a voice called out to ask your name." -Color Yellow -Delay 30    
    Write-Typewriter "You've awaken without a memory, but you remembered your name." -Color Yellow -Delay 30    
    $name = Read-Host "My name is: "
    
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

function Get-RandomMonster {
    # Check for boss every 3 floors
    $isBossFloor = $global:CurrentFloor % 3 -eq 0
    $isBoss = $isBossFloor -and (Get-Random -Maximum 100) -lt 30  # 30% chance of boss on boss floors
    
    if ($isBoss) {
        $boss = $BossTypes[(Get-Random -Maximum $BossTypes.Count)].Clone()
        
        # Scale boss stats based on player level and stats - Need balancing?
		$scaleFactor = 1 + ($global:Player.Level * 0.3) + ($global:CurrentFloor * 0.15)
		$boss.Health = [Math]::Round($boss.BaseHealth * $scaleFactor)
		$boss.Attack = [Math]::Round($boss.BaseAttack * $scaleFactor)
		$boss.Defense = [Math]::Round($boss.BaseDefense * $scaleFactor)
		$boss.XP = [Math]::Round($boss.XP * $scaleFactor)
		$boss.Gold = [Math]::Round($boss.Gold * $scaleFactor)
		$boss.CriticalChance = 15  # Bosses have 15% critical chance
		$boss.CriticalMultiplier = 2.0  # Bosses do 2x critical damage 
       
		# Add special boss abilities with random modifieders.
        $boss.IsBoss = $true
		$randomAbility = $BossAbilities | Get-Random
		$boss.SpecialAbility = $randomAbility.Name
		$boss.SpecialDescription = $randomAbility.Description
		$boss.SpecialMultiplier = $randomAbility.DamageMultiplier
		$boss.SpecialEffect = $randomAbility.Effect
        
        Write-Typewriter "`n*** BOSS ENCOUNTER! ***" -ForegroundColor Red
        return $boss
    }
    else {
        $monsterIndex = [Math]::Min([Math]::Floor(($global:CurrentFloor - 1) / 2), $MonsterTypes.Count - 1)
        $baseMonster = $MonsterTypes[$monsterIndex].Clone()
        
# Scale monster stats calculation based on floor level
	$scaleFactor = 1 + ($global:CurrentFloor * 0.15)
	$baseMonster.Health = [Math]::Round($baseMonster.Health * $scaleFactor)
	$baseMonster.Attack = [Math]::Round($baseMonster.Attack * $scaleFactor)
	$baseMonster.Defense = [Math]::Round($baseMonster.Defense * $scaleFactor)
	$baseMonster.XP = [Math]::Round($baseMonster.XP * $scaleFactor)
	$baseMonster.Gold = [Math]::Round($baseMonster.Gold * $scaleFactor)
	$baseMonster.CriticalChance = 5  # Monsters have 5% base critical chance
	$baseMonster.CriticalMultiplier = 1.5  # Monsters do 1.5x critical damage        
        return $baseMonster
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
            Write-Host "2. Special Ability"
            Write-Host "3. Use Potion (5 gold)"
            Write-Host "4. Flee"
            
            $choice = Read-Host "Choose action"
            
	switch ($choice) {
	    '1' {
		$baseDamage = [Math]::Max(1, $global:Player.Attack - $monster.Defense + (Get-Random -Minimum -2 -Maximum 3))
		
		# Critical hit check - need balancing to prevent cheesing
		$isCritical = (Get-Random -Maximum 100) -lt $global:Player.CriticalChance
		if ($isCritical) {
		    $damage = [Math]::Round($baseDamage * $global:Player.CriticalMultiplier)
		    Write-Typewriter "CRITICAL HIT! You attack the $($monster.Name) for $damage damage!" -Color Cyan -Delay 20
		    # Write-Host "CRITICAL HIT! You attack the $($monster.Name) for $damage damage!" -ForegroundColor Cyan
		} else {
		    $damage = $baseDamage
		    Write-Host "You attack the $($monster.Name) for $damage damage!" -ForegroundColor Yellow
		}
		$monsterHealth -= $damage
	    }
	    '2' {
		if ($global:Player.Mana -ge 5) {
		    $global:Player.Mana -= 5
		    $baseDamage = $global:Player.Attack + (Get-Random -Minimum 2 -Maximum 6)
		    
		    # Critical hit check for special ability (higher chance)
		    $isCritical = (Get-Random -Maximum 100) -lt ($global:Player.CriticalChance + 10)
		    if ($isCritical) {
			$specialDamage = [Math]::Round($baseDamage * $global:Player.CriticalMultiplier)
			Write-Host "CRITICAL HIT! You use a special ability for $specialDamage damage!" -ForegroundColor Cyan
		    } else {
			$specialDamage = $baseDamage
			Write-Host "You use a special ability for $specialDamage damage!" -ForegroundColor Magenta
		    }
		    $monsterHealth -= $specialDamage
		} else {
		    Write-Host "Not enough mana!" -ForegroundColor Red
		    continue
		}
	    }
	    '3' {
                    if ($global:Player.Gold -ge 5) {
                        $global:Player.Gold -= 5
                        $heal = 15
                        $global:Player.Health = [Math]::Min($global:Player.MaxHealth, $global:Player.Health + $heal)
                        Write-Host "You use a potion and heal $heal health!" -ForegroundColor Green
                    } else {
                        Write-Host "Not enough gold!" -ForegroundColor Red
                        continue
                    }
                }
                '4' {
                    if ((Get-Random -Maximum 100) -lt 40) {
                        Write-Typewriter "You successfully fled from combat!" -ForegroundColor Green
                        return $false
                    } else {
                        Write-Typewriter "Failed to flee!" -ForegroundColor Red
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
    	switch ($monster.SpecialEffect) {
        	"lifedrain" {
            	$healAmount = [Math]::Round($baseDamage * 0.5)
            	$monsterHealth += $healAmount
            	$monsterHealth = [Math]::Min($monster.Health, $monsterHealth)  # Don't exceed max health
            	$effectMessage = " and drains $healAmount health from you!"
        	}
        	"critical" {
            	# Double critical chance for these abilities
            	$isCritical = (Get-Random -Maximum 100) -lt ($monster.CriticalChance * 2)
            		if ($isCritical) {
                	$baseDamage = [Math]::Round($baseDamage * $monster.CriticalMultiplier)
                	$effectMessage = " with enhanced critical strike!"
            	}
        	}
        	"debuff" {
            	# Reduce player attack temporarily
            	$attackReduction = 2
            	$global:Player.Attack = [Math]::Max(1, $global:Player.Attack - $attackReduction)
            	$effectMessage = " reducing your attack power by $attackReduction!"
        	}
        	"stun" {
            	# Chance to stun player (skip next turn)
            	if ((Get-Random -Maximum 100) -lt 40) {
                $playerTurn = $false  # Player loses next turn
                $effectMessage = " stunning you and making you lose your next turn!"
            } else {
                $effectMessage = " but you resist the stun!"
            }
        	}
        	"sacrifice" {
            # Boss takes some damage but gains more
            $bossSelfDamage = [Math]::Round($baseDamage * 0.3)
            $monsterHealth -= $bossSelfDamage
            $healAmount = [Math]::Round($baseDamage * 0.8)
            $monsterHealth += $healAmount
            $monsterHealth = [Math]::Min($monster.Health, $monsterHealth)
            $effectMessage = " sacrificing $bossSelfDamage health but gaining $healAmount!"
        	}
        	"armorbreak" {
            # Reduce player defense
            $defenseReduction = 2
            $global:Player.Defense = [Math]::Max(0, $global:Player.Defense - $defenseReduction)
            $effectMessage = " breaking your armor and reducing defense by $defenseReduction!"
        	}
        	"dot" {
            # Apply damage over time
            $dotDamage = [Math]::Round($baseDamage * 0.3)
            $global:Player.Health -= $dotDamage
            $effectMessage = " applying a damage over time effect for $dotDamage additional damage!"
        }
        default {
            $effectMessage = "!"
        }
    }
    
    	# Critical hit check for boss special
    	$isCritical = (Get-Random -Maximum 100) -lt $monster.CriticalChance
    		if ($isCritical -and $monster.SpecialEffect -ne "critical") {  # Don't double-dip on critical effects
        $specialDamage = [Math]::Round($baseDamage * $monster.CriticalMultiplier)
        Write-Typewriter "CRITICAL HIT! The $($monster.Name) $($monster.SpecialDescription) for $specialDamage damage$effectMessage" -Color DarkRed -Delay 20
    	} else {
        $specialDamage = $baseDamage
        Write-Typewriter "The $($monster.Name) $($monster.SpecialDescription) for $specialDamage damage$effectMessage" -Color Red -Delay 20
    	}
    	$global:Player.Health -= $specialDamage
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
        Write-Typewriter "`nYou have been defeated..." -ForegroundColor DarkRed
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
    Write-Typewriter "*** BOSS DEFEATED! ***" -ForegroundColor Magenta
	}    
        Write-Host "Earned $xpEarned XP and $goldEarned gold!" -ForegroundColor Yellow
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
        return $true
    }
}

function Level-Up {
    while ($global:Player.Experience -ge $global:Player.ExperienceToNextLevel) {
        $global:Player.Level++
        $global:Player.Experience -= $global:Player.ExperienceToNextLevel
        $global:Player.ExperienceToNextLevel = [Math]::Round($global:Player.ExperienceToNextLevel * 1.5)
        
        # Stat increases
        $healthIncrease = 5 + (Get-Random -Minimum 1 -Maximum 4)
        $attackIncrease = 1 + (Get-Random -Minimum 0 -Maximum 2)
        $defenseIncrease = 1 + (Get-Random -Minimum 0 -Maximum 2)
        $manaIncrease = 3 + (Get-Random -Minimum 1 -Maximum 3)
        
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
    Write-Host "`nWhat would you like to do?" -ForegroundColor Yellow
    Write-Host "1. Explore (Fight monsters)"
    Write-Host "2. Rest (Heal for 10 gold)"
    Write-Host "3. View Stats"
    Write-Host "4. Visit Shop"
    Write-Host "5. Descend to next floor"
    Write-Host "6. Quit Game"
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
        @{ Name = "Critical Charm"; Cost = 95; Description = "Permanently +5% Critical Chance" },
        @{ Name = "Keen Edge"; Cost = 180; Description = "Permanently +0.5 Critical Multiplier" }
    )
    
    for ($i = 0; $i -lt $shopItems.Count; $i++) {
        Write-Host "$($i + 1). $($shopItems[$i].Name) - $($shopItems[$i].Cost) gold" -ForegroundColor White
        Write-Host "   $($shopItems[$i].Description)" -ForegroundColor Gray
    }
    Write-Host "0. Leave Shop" -ForegroundColor Gray
    
    do {
        $choice = Read-Host "`nSelect item to purchase"
    } while ($choice -notin @('0','1','2','3','4','5','6'))
    
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
                $global:Player.CriticalChance += 5
                Write-Host "Critical chance increased by 5%! Current: $($global:Player.CriticalChance)%" -ForegroundColor Cyan
            }
            '6' {
                $global:Player.CriticalMultiplier += 0.5
                Write-Host "Critical multiplier increased by 0.5! Current: $($global:Player.CriticalMultiplier)x" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "Not enough gold!" -ForegroundColor Red
    }
}


function Start-Game {
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
                        Write-Typewriter "`nYou feel your body is fadind and going numb. Is this the end?" -ForegroundColor DarkRed
                        Write-Host "You reached floor $global:CurrentFloor and defeated $global:MonstersDefeated monsters!" -ForegroundColor Yellow
                        $global:GameRunning = $false
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
                Visit-Shop
            }
            '5' {
                $global:CurrentFloor++
                Write-Host "You descend to floor $global:CurrentFloor..." -ForegroundColor Cyan
                Write-Host "Monsters grow stronger!" -ForegroundColor Yellow
            }
            '6' {
                $global:GameRunning = $false
                Write-Host "You've perished into a dark realm, never to return." -ForegroundColor Green
            }
            default {
                Write-Host "Invalid choice!" -ForegroundColor Red
            }
        }
        
        if ($global:GameRunning) {
            Write-Host "`nPress any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

# Start the game
Start-Game




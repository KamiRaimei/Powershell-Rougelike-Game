import os
import time
import random
import sys
import platform

# Cross-platform "Press Any Key" function
def press_any_key():
    """Cross-platform method to wait for any key press"""
    if platform.system() == "Windows":
        import msvcrt
        print("\n")
        msvcrt.getch()
    else:
        # For Unix/Linux/Mac
        import termios
        import tty
        print("\n")
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

# Fast typewriter effect
def write_typewriter(text, color="white", delay=0.001):
    """Fast typewriter effect for text output"""
    colors = {
        "white": "\033[97m",
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "magenta": "\033[95m",
        "cyan": "\033[96m",
        "gray": "\033[90m",
        "darkred": "\033[31m",
        "darkgreen": "\033[32m",
        "darkyellow": "\033[33m",
        "reset": "\033[0m"
    }
    
    color_code = colors.get(color.lower(), colors["white"])
    reset_code = colors["reset"]
    
    for char in text:
        print(f"{color_code}{char}{reset_code}", end='', flush=True)
        time.sleep(delay)
    print()

#color definition for normal text
def print_color(text, color="white", end="\n"):
    """Print text with color but without typewriter effect"""
    colors = {
        "white": "\033[97m",
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "magenta": "\033[95m",
        "cyan": "\033[96m",
        "gray": "\033[90m",
        "darkred": "\033[31m",
        "darkgreen": "\033[32m",
        "darkyellow": "\033[33m",
        "reset": "\033[0m"
    }
    
    color_code = colors.get(color.lower(), colors["white"])
    reset_code = colors["reset"]
    
    print(f"{color_code}{text}{reset_code}", end=end, flush=True)

def write_quick(text, color="white"):
    """Quick text display with minimal delay"""
    write_typewriter(text, color, 0.002)

def clear_screen():
    """Cross-platform screen clearing"""
    os.system('cls' if platform.system() == 'Windows' else 'clear')

# Game State Variables
class GameState:
    def __init__(self):
        self.player = None
        self.player_base_stats = None
        self.game_running = True
        self.current_floor = 1
        self.monsters_defeated = 0
        self.bosses_defeated = 0
        self.player_equipment = {
            "Head": None,
            "Body": None,
            "Legs": None,
            "LeftHand": None,
            "RightHand": None,
            "Cloak": None,
            "Accessory1": None,
            "Accessory2": None
        }
        self.player_artifacts = []
        self.max_artifacts = 5
        
        # Refinement system
        self.refinement_costs = [100, 250, 500, 1000, 2000, 4000, 8000, 15000, 30000, 50000]
        self.refinement_success_rates = [100, 90, 80, 70, 60, 50, 40, 30, 20, 10]
        self.refinement_break_rates = [0, 0, 0, 10, 20, 30, 40, 50, 60, 70]
        self.refinement_stat_multipliers = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]

# Class Definitions
class_definitions = {
    "Warrior": {
        "Health": 30,
        "Mana": 10,
        "Attack": 8,
        "Defense": 6,
        "Speed": 4,
        "Description": "A strong melee fighter with high health and attack",
        "Ascensions": ["Paladin", "Barbarian", "Gladiator", "Warlord"]
    },
    "Mage": {
        "Health": 18,
        "Mana": 35,
        "Attack": 5,
        "Defense": 3,
        "Speed": 6,
        "Description": "A spellcaster with powerful magic but low defense",
        "Ascensions": ["Archmage", "Elementalist", "Necromancer", "Chronomancer"]
    },
    "Rogue": {
        "Health": 22,
        "Mana": 15,
        "Attack": 7,
        "Defense": 4,
        "Speed": 8,
        "Description": "An agile character with high speed and critical hits",
        "Ascensions": ["Assassin", "Shadowdancer", "Ninja", "Spymaster"]
    },
    "Cleric": {
        "Health": 25,
        "Mana": 30,
        "Attack": 5,
        "Defense": 5,
        "Speed": 4,
        "Description": "A holy warrior with healing and defensive abilities",
        "Ascensions": ["Templar", "Inquisitor", "Oracle", "Saint"]
    }
}

# Ascension Bonuses
ascension_bonuses = {
    # Warrior Ascensions
    "Paladin": {"Health": 15, "Mana": 10, "Attack": 3, "Defense": 5, "Speed": 1},
    "Barbarian": {"Health": 25, "Mana": 5, "Attack": 6, "Defense": 2, "Speed": 3},
    "Gladiator": {"Health": 20, "Mana": 8, "Attack": 5, "Defense": 3, "Speed": 4},
    "Warlord": {"Health": 18, "Mana": 12, "Attack": 4, "Defense": 4, "Speed": 2},
    
    # Mage Ascensions
    "Archmage": {"Health": 10, "Mana": 20, "Attack": 4, "Defense": 2, "Speed": 3},
    "Elementalist": {"Health": 12, "Mana": 18, "Attack": 5, "Defense": 3, "Speed": 4},
    "Necromancer": {"Health": 15, "Mana": 15, "Attack": 6, "Defense": 4, "Speed": 2},
    "Chronomancer": {"Health": 8, "Mana": 25, "Attack": 3, "Defense": 1, "Speed": 6},
    
    # Rogue Ascensions
    "Assassin": {"Health": 15, "Mana": 12, "Attack": 8, "Defense": 2, "Speed": 6},
    "Shadowdancer": {"Health": 18, "Mana": 15, "Attack": 6, "Defense": 3, "Speed": 8},
    "Ninja": {"Health": 20, "Mana": 10, "Attack": 7, "Defense": 4, "Speed": 7},
    "Spymaster": {"Health": 16, "Mana": 18, "Attack": 5, "Defense": 5, "Speed": 5},
    
    # Cleric Ascensions
    "Templar": {"Health": 20, "Mana": 15, "Attack": 4, "Defense": 6, "Speed": 2},
    "Inquisitor": {"Health": 18, "Mana": 12, "Attack": 6, "Defense": 4, "Speed": 4},
    "Oracle": {"Health": 15, "Mana": 20, "Attack": 3, "Defense": 3, "Speed": 5},
    "Saint": {"Health": 25, "Mana": 18, "Attack": 2, "Defense": 7, "Speed": 1}
}

# Spell Definitions
class_spells = {
    "Mage": [
        {
            "Name": "Fireball",
            "Description": "Hurl a ball of fire at your enemy",
            "BaseDamage": 15,
            "DamagePerLevel": 2,
            "DamagePerAttack": 0.5,
            "ManaCost": 12,
            "Element": "Fire",
            "Type": "Damage"
        },
        {
            "Name": "Ice Shard",
            "Description": "Launch sharp shards of ice",
            "BaseDamage": 12,
            "DamagePerLevel": 1.5,
            "DamagePerAttack": 0.3,
            "ManaCost": 10,
            "Element": "Ice",
            "Type": "Damage",
            "Effect": "Slow"
        },
        {
            "Name": "Lightning Bolt",
            "Description": "Strike with a bolt of lightning",
            "BaseDamage": 18,
            "DamagePerLevel": 2.5,
            "DamagePerAttack": 0.4,
            "ManaCost": 15,
            "Element": "Lightning",
            "Type": "Damage",
            "Effect": "Stun"
        },
        {
            "Name": "Minor Heal",
            "Description": "Basic healing magic",
            "BaseHeal": 10,
            "HealPerLevel": 1,
            "ManaCost": 8,
            "Type": "Heal"
        }
    ],
    "Cleric": [
        {
            "Name": "Holy Light",
            "Description": "Channel divine light to smite enemies",
            "BaseDamage": 8,
            "DamagePerLevel": 1,
            "DamagePerAttack": 0.2,
            "ManaCost": 6,
            "Element": "Holy",
            "Type": "Damage"
        },
        {
            "Name": "Divine Strike",
            "Description": "Empowered strike with holy energy",
            "BaseDamage": 10,
            "DamagePerLevel": 1.2,
            "DamagePerAttack": 0.25,
            "ManaCost": 8,
            "Element": "Holy",
            "Type": "Damage"
        },
        {
            "Name": "Purifying Flame",
            "Description": "Cleansing flames that burn impurities",
            "BaseDamage": 6,
            "DamagePerLevel": 0.8,
            "DamagePerAttack": 0.15,
            "ManaCost": 5,
            "Element": "Fire",
            "Type": "Damage"
        },
        {
            "Name": "Greater Heal",
            "Description": "Powerful divine healing",
            "BaseHeal": 25,
            "HealPerLevel": 3,
            "HealPerMaxHealth": 0.1,
            "ManaCost": 12,
            "Type": "Heal"
        }
    ]
}

# Elemental Effects
elemental_effects = {
    "Fire": {
        "Description": "burns intensely",
        "BonusDamage": 1.2
    },
    "Ice": {
        "Description": "freezes the target",
        "BonusDamage": 1.1,
        "Effect": "Reduces enemy speed by 2 for next turn"
    },
    "Lightning": {
        "Description": "electrocutes the target",
        "BonusDamage": 1.3,
        "Effect": "10% chance to stun enemy"
    },
    "Holy": {
        "Description": "purifies with divine energy",
        "BonusDamage": 1.15,
        "Effect": "Extra effective against undead"
    }
}

# Monster Definitions
monster_types = [
    # Tier 1: Early game monsters
    {"Name": "Goblin", "Health": 12, "Attack": 4, "Defense": 2, "XP": 10, "Gold": 5, "Tier": 1},
    {"Name": "Skeleton", "Health": 15, "Attack": 5, "Defense": 3, "XP": 15, "Gold": 8, "Tier": 1},
    {"Name": "Vampire Bat", "Health": 16, "Attack": 6, "Defense": 1, "XP": 18, "Gold": 10, "Tier": 1},
    {"Name": "Bandit", "Health": 20, "Attack": 5, "Defense": 2, "XP": 18, "Gold": 10, "Tier": 1},
    {"Name": "Giant Spider", "Health": 14, "Attack": 5, "Defense": 2, "XP": 12, "Gold": 6, "Tier": 1},

    # Tier 2: Early-mid game monsters
    {"Name": "Orc", "Health": 20, "Attack": 6, "Defense": 4, "XP": 20, "Gold": 12, "Tier": 2},
    {"Name": "Dark Mage", "Health": 18, "Attack": 7, "Defense": 2, "XP": 25, "Gold": 15, "Tier": 2},
    {"Name": "Frost Elemental", "Health": 22, "Attack": 8, "Defense": 3, "XP": 30, "Gold": 18, "Tier": 2},
    {"Name": "Demon Hound", "Health": 28, "Attack": 8, "Defense": 3, "XP": 30, "Gold": 18, "Tier": 2},
    
    # Tier 3: Mid game monsters
    {"Name": "Troll", "Health": 30, "Attack": 8, "Defense": 5, "XP": 35, "Gold": 20, "Tier": 3},
    {"Name": "Dragon Whelp", "Health": 25, "Attack": 9, "Defense": 4, "XP": 40, "Gold": 25, "Tier": 3},
    {"Name": "Stone Golem", "Health": 35, "Attack": 7, "Defense": 8, "XP": 45, "Gold": 22, "Tier": 3},
    
    # Tier 4: Late-mid game monsters
    {"Name": "Lich", "Health": 28, "Attack": 10, "Defense": 4, "XP": 50, "Gold": 30, "Tier": 4},
    {"Name": "Behemoth", "Health": 45, "Attack": 12, "Defense": 6, "XP": 65, "Gold": 40, "Tier": 4},
    {"Name": "High Orc", "Health": 59, "Attack": 15, "Defense": 6, "XP": 65, "Gold": 20, "Tier": 4},
    {"Name": "Orc Priestest", "Health": 120, "Attack": 15, "Defense": 6, "XP": 65, "Gold": 40, "Tier": 4},
    {"Name": "Lich Wench", "Health": 30, "Attack": 10, "Defense": 5, "XP": 65, "Gold": 25, "Tier": 4},
    
    # Tier 5: Late game monsters
    {"Name": "Chaos Demon", "Health": 38, "Attack": 14, "Defense": 5, "XP": 75, "Gold": 50, "Tier": 5},
    {"Name": "Nightmare", "Health": 38, "Attack": 16, "Defense": 5, "XP": 85, "Gold": 60, "Tier": 5},
    {"Name": "High Lich Priest", "Health": 38, "Attack": 12, "Defense": 9, "XP": 75, "Gold": 50, "Tier": 5},
    {"Name": "Orc Lord", "Health": 50, "Attack": 18, "Defense": 6, "XP": 75, "Gold": 90, "Tier": 5}
]

# Boss Definitions
boss_types = [
    {"Name": "Ancient Dragon", "BaseHealth": 50, "BaseAttack": 15, "BaseDefense": 8, "XP": 200, "Gold": 100},
    {"Name": "Basilisk King", "BaseHealth": 80, "BaseAttack": 5, "BaseDefense": 6, "XP": 200, "Gold": 100},
    {"Name": "Corrupted Diablos", "BaseHealth": 40, "BaseAttack": 6, "BaseDefense": 9, "XP": 280, "Gold": 120},
    {"Name": "Titan Lord", "BaseHealth": 60, "BaseAttack": 12, "BaseDefense": 12, "XP": 180, "Gold": 120},
    {"Name": "Archlich", "BaseHealth": 40, "BaseAttack": 18, "BaseDefense": 4, "XP": 220, "Gold": 90},
    {"Name": "Chaos God", "BaseHealth": 55, "BaseAttack": 16, "BaseDefense": 10, "XP": 250, "Gold": 150},
    {"Name": "Death Eater", "BaseHealth": 60, "BaseAttack": 4, "BaseDefense": 20, "XP": 350, "Gold": 150},
    {"Name": "World Eater", "BaseHealth": 70, "BaseAttack": 10, "BaseDefense": 14, "XP": 380, "Gold": 200}
]

# Boss Abilities
boss_abilities = [
    {
        "Name": "Dark Blast",
        "Description": "unleashes a wave of dark energy",
        "DamageMultiplier": 1.5,
        "Effect": "lifedrain"
    },
    {
        "Name": "Soul Drain",
        "Description": "drains your life force",
        "DamageMultiplier": 1.5,
        "Effect": "lifedrain"
    },
    {
        "Name": "Shadow Strike",
        "Description": "strikes from the shadows",
        "DamageMultiplier": 1.8,
        "Effect": "critical"
    },
    {
        "Name": "Necrotic Touch",
        "Description": "saps your strength with necrotic energy",
        "DamageMultiplier": 1.3,
        "Effect": "debuff"
    },
    {
        "Name": "Abyssal Scream",
        "Description": "lets out a terrifying scream from the abyss",
        "DamageMultiplier": 1.6,
        "Effect": "stun"
    },
    {
        "Name": "Blood Ritual",
        "Description": "performs a dark blood ritual",
        "DamageMultiplier": 1.4,
        "Effect": "sacrifice"
    },
    {
        "Name": "Void Slash",
        "Description": "attacks with a blade of pure void",
        "DamageMultiplier": 1.7,
        "Effect": "armorbreak"
    },
    {
        "Name": "Cursed Blight",
        "Description": "curses you with ancient blight",
        "DamageMultiplier": 1.2,
        "Effect": "dot"
    }
]

# Equipment Definitions
shop_equipment = [
    # Head Equipment
    {"Name": "Leather Cap", "Slot": "Head", "Cost": 30, "Stats": {"Defense": 2, "Health": 5}, "Description": "Basic head protection"},
    {"Name": "Iron Helmet", "Slot": "Head", "Cost": 75, "Stats": {"Defense": 4, "Health": 8}, "Description": "Sturdy metal helmet"},
    {"Name": "Mage's Circlet", "Slot": "Head", "Cost": 60, "Stats": {"Mana": 10, "CriticalChance": 2}, "Description": "Enhances magical abilities"},
    {"Name": "Crown of the Juggernaut", "Slot": "Head", "Cost": 800, "Stats": {"Defense": 12, "Health": 40, "Attack": 5}, "Description": "Forged in the heart of a volcano, this crown makes the wearer nearly invincible"},
    {"Name": "Assassin's Veil", "Slot": "Head", "Cost": 750, "Stats": {"CriticalChance": 15, "Speed": 6, "CriticalMultiplier": 0.5}, "Description": "Woven from shadow essence, it grants preternatural precision"},
    {"Name": "Archmage's Diadem", "Slot": "Head", "Cost": 780, "Stats": {"Mana": 50, "CriticalChance": 8, "CriticalMultiplier": 0.6}, "Description": "Contains crystallized starlight that enhances all magical abilities"},

    # Body Equipment
    {"Name": "Leather Armor", "Slot": "Body", "Cost": 50, "Stats": {"Defense": 3, "Health": 10}, "Description": "Basic body protection"},
    {"Name": "Chainmail", "Slot": "Body", "Cost": 120, "Stats": {"Defense": 6, "Health": 15, "Speed": -1}, "Description": "Heavy but protective"},
    {"Name": "Robe of the Magi", "Slot": "Body", "Cost": 100, "Stats": {"Mana": 12, "Defense": 2}, "Description": "Magically enhanced robes"},
    {"Name": "Titan's Plate", "Slot": "Body", "Cost": 1200, "Stats": {"Defense": 20, "Health": 60, "Attack": 8}, "Description": "Armor so heavy it reshapes the earth with each step"},
    {"Name": "Shadow Weave Tunic", "Slot": "Body", "Cost": 1100, "Stats": {"Speed": 8, "CriticalChance": 12, "CriticalMultiplier": 0.8}, "Description": "Moves with the wearer like a second skin, leaving afterimages"},
    {"Name": "Robe of the Void", "Slot": "Body", "Cost": 1150, "Stats": {"Mana": 60, "Defense": 12, "CriticalMultiplier": 1.0}, "Description": "Fabric woven from the space between stars, channeling cosmic energy"},

    # Legs Equipment
    {"Name": "Leather Pants", "Slot": "Legs", "Cost": 25, "Stats": {"Defense": 1, "Speed": 1}, "Description": "Light and flexible"},
    {"Name": "Plate Leggings", "Slot": "Legs", "Cost": 80, "Stats": {"Defense": 4, "Health": 5, "Speed": -1}, "Description": "Heavy leg protection"},
    {"Name": "Silk Trousers", "Slot": "Legs", "Cost": 45, "Stats": {"Mana": 5, "Speed": 2}, "Description": "Enchanted fabric"},
    {"Name": "Colossus Greaves", "Slot": "Legs", "Cost": 900, "Stats": {"Defense": 15, "Health": 35, "Speed": -2, "Attack": 5}, "Description": "Can stomp with enough force to create minor earthquakes"},
    {"Name": "Wind Dancer Leggings", "Slot": "Legs", "Cost": 850, "Stats": {"Speed": 12, "CriticalChance": 8, "CriticalMultiplier": 0.5}, "Description": "Allows the wearer to move faster than the eye can follow"},
    {"Name": "Astral Striders", "Slot": "Legs", "Cost": 880, "Stats": {"Mana": 35, "Speed": 8, "CriticalMultiplier": 0.7}, "Description": "Leave trails of shimmering energy with each step"},

    # Left Hand Equipment
    {"Name": "Wooden Shield", "Slot": "LeftHand", "Cost": 40, "Stats": {"Defense": 3}, "Description": "Basic defensive shield"},
    {"Name": "Tower Shield", "Slot": "LeftHand", "Cost": 100, "Stats": {"Defense": 7, "Speed": -2}, "Description": "Massive defensive shield"},
    {"Name": "Magic Focus", "Slot": "LeftHand", "Cost": 90, "Stats": {"Mana": 8, "CriticalMultiplier": 0.2}, "Description": "Channel magical energy"},
    {"Name": "Aegis of the Immortal", "Slot": "LeftHand", "Cost": 1000, "Stats": {"Defense": 25, "Health": 40, "CriticalChance": -5}, "Description": "Legendary shield said to have blocked the breath of an ancient dragon"},
    {"Name": "Parrying Dagger", "Slot": "LeftHand", "Cost": 950, "Stats": {"Speed": 6, "CriticalChance": 12, "CriticalMultiplier": 0.6}, "Description": "So perfectly balanced it can deflect spells and arrows with ease"},
    {"Name": "Orb of Infinite Potential", "Slot": "LeftHand", "Cost": 980, "Stats": {"Mana": 50, "CriticalMultiplier": 1.2, "CriticalChance": 6}, "Description": "Contains a miniature galaxy that amplifies magical energies"},

    # Right Hand Equipment
    {"Name": "Iron Sword", "Slot": "RightHand", "Cost": 60, "Stats": {"Attack": 4}, "Description": "Standard combat sword"},
    {"Name": "Great Axe", "Slot": "RightHand", "Cost": 130, "Stats": {"Attack": 8, "Speed": -1}, "Description": "Heavy two-handed weapon"},
    {"Name": "Enchanted Staff", "Slot": "RightHand", "Cost": 110, "Stats": {"Attack": 3, "Mana": 12, "CriticalChance": 3}, "Description": "Magical staff for spellcasters"},
    {"Name": "World Breaker", "Slot": "RightHand", "Cost": 1500, "Stats": {"Attack": 30, "Defense": 8, "Health": 25, "Speed": -4}, "Description": "A weapon so massive it warps gravity around itself"},
    {"Name": "Blade of a Thousand Cuts", "Slot": "RightHand", "Cost": 1400, "Stats": {"Attack": 22, "CriticalChance": 18, "CriticalMultiplier": 1.0, "Speed": 4}, "Description": "Moves so fast it appears to strike from multiple angles simultaneously"},
    {"Name": "Staff of Cosmic Alignment", "Slot": "RightHand", "Cost": 1450, "Stats": {"Attack": 12, "Mana": 45, "CriticalMultiplier": 1.5, "CriticalChance": 10}, "Description": "Channels the fundamental forces of the universe into spells"},

    # Cloak Equipment
    {"Name": "Traveler's Cloak", "Slot": "Cloak", "Cost": 35, "Stats": {"Speed": 1, "Defense": 1}, "Description": "Light cloak for journeys"},
    {"Name": "Shadow Cloak", "Slot": "Cloak", "Cost": 95, "Stats": {"Speed": 3, "CriticalChance": 2}, "Description": "Blends with shadows"},
    {"Name": "Mage's Cloak", "Slot": "Cloak", "Cost": 85, "Stats": {"Mana": 8, "Defense": 2}, "Description": "Enchanted with protective magic"},
    {"Name": "Mantle of the Mountain King", "Slot": "Cloak", "Cost": 900, "Stats": {"Defense": 18, "Health": 50, "Attack": 6}, "Description": "Woven from the beard of a mountain giant, grants titanic resilience"},
    {"Name": "Cloak of the Phantom", "Slot": "Cloak", "Cost": 850, "Stats": {"Speed": 10, "CriticalChance": 15, "CriticalMultiplier": 0.6}, "Description": "Allows the wearer to phase through solid matter for brief moments"},
    {"Name": "Voidweave Mantle", "Slot": "Cloak", "Cost": 880, "Stats": {"Mana": 40, "CriticalMultiplier": 0.9, "Defense": 10}, "Description": "Absorbs ambient magic, converting it into protective energies"},

    # Accessory1 - Rings
    {"Name": "Warrior's Band", "Slot": "Accessory1", "Cost": 80, "Stats": {"Attack": 4, "Health": 12}, "Description": "Reinforced combat ring"},
    {"Name": "Guardian's Seal", "Slot": "Accessory1", "Cost": 85, "Stats": {"Defense": 5, "Health": 15}, "Description": "Provides additional protection"},
    {"Name": "Berserker's Ring", "Slot": "Accessory1", "Cost": 95, "Stats": {"Attack": 7, "Speed": -1}, "Description": "Sacrifices speed for raw power"},
    {"Name": "Vitality Band", "Slot": "Accessory1", "Cost": 90, "Stats": {"Health": 25}, "Description": "Greatly enhances vitality"},
    {"Name": "Ring of Precision", "Slot": "Accessory1", "Cost": 120, "Stats": {"CriticalChance": 8, "Speed": 2}, "Description": "Improves accuracy dramatically"},
    {"Name": "Lucky Charm", "Slot": "Accessory1", "Cost": 110, "Stats": {"CriticalChance": 6, "CriticalMultiplier": 0.4}, "Description": "Brings fortune in combat"},
    {"Name": "Swiftstrike Band", "Slot": "Accessory1", "Cost": 130, "Stats": {"Speed": 4, "CriticalChance": 4}, "Description": "Enhances reflexes and timing"},
    {"Name": "Sage's Ring", "Slot": "Accessory1", "Cost": 100, "Stats": {"Mana": 15, "CriticalChance": 3}, "Description": "Enhances magical abilities"},
    {"Name": "Arcane Focus", "Slot": "Accessory1", "Cost": 140, "Stats": {"Mana": 20, "CriticalMultiplier": 0.4}, "Description": "Amplifies spell power"},
    {"Name": "Mage's Band", "Slot": "Accessory1", "Cost": 110, "Stats": {"Mana": 15, "Health": 8}, "Description": "Balances magic and vitality"},

    # Accessory2 - Amulets/Belts
    {"Name": "Amulet of Might", "Slot": "Accessory2", "Cost": 120, "Stats": {"Attack": 6, "Health": 15}, "Description": "Grants enhanced strength"},
    {"Name": "Belt of Endurance", "Slot": "Accessory2", "Cost": 130, "Stats": {"Health": 35, "Defense": 3}, "Description": "Greatly increases stamina"},
    {"Name": "Champion's Medallion", "Slot": "Accessory2", "Cost": 150, "Stats": {"Attack": 5, "Defense": 4, "Health": 12}, "Description": "Well-rounded combat enhancement"},
    {"Name": "Titan's Girdle", "Slot": "Accessory2", "Cost": 140, "Stats": {"Health": 40, "Speed": -1}, "Description": "Massive health boost at a mobility cost"},
    {"Name": "Assassin's Pendant", "Slot": "Accessory2", "Cost": 180, "Stats": {"CriticalChance": 10, "Speed": 3}, "Description": "Perfect for lethal strikes"},
    {"Name": "Fate's Favor", "Slot": "Accessory2", "Cost": 170, "Stats": {"CriticalMultiplier": 0.6, "CriticalChance": 4}, "Description": "Makes critical hits devastating"},
    {"Name": "Windwalker Charm", "Slot": "Accessory2", "Cost": 160, "Stats": {"Speed": 5, "CriticalChance": 3}, "Description": "Unmatched mobility"},
    {"Name": "Amulet of the Arcane", "Slot": "Accessory2", "Cost": 150, "Stats": {"Mana": 25, "CriticalChance": 3}, "Description": "Substantial magical reservoir"},
    {"Name": "Orb of Power", "Slot": "Accessory2", "Cost": 200, "Stats": {"Mana": 20, "CriticalMultiplier": 0.6, "Attack": 3}, "Description": "Enhances all offensive capabilities"},
    {"Name": "Crystal Pendant", "Slot": "Accessory2", "Cost": 130, "Stats": {"Mana": 15, "Defense": 4, "Health": 8}, "Description": "Balanced magical protection"}
]

# Artifact Definitions
low_tier_artifacts = [
    {"Name": "Rusty Amulet", "Description": "An old, tarnished amulet", "Stats": {"Health": 10, "Attack": 1}},
    {"Name": "Cracked Ring", "Description": "A ring with a hairline fracture", "Stats": {"Defense": 2, "Mana": 3}},
    {"Name": "Faded Cloak", "Description": "A cloak that has seen better days", "Stats": {"Speed": 2, "Health": 5}},
    {"Name": "Tarnished Dagger", "Description": "A dull blade once of the damn", "Stats": {"Attack": 8, "CriticalChance": 5, "CriticalMultiplier": 0.4}},
    {"Name": "Cracked Orb of Health", "Description": "Once used to give vitality, cracked beyond salvation", "Stats": {"Defense": 2, "Health": 10}},
    {"Name": "Chipped Blade", "Description": "A blade with several notches", "Stats": {"Attack": 8, "CriticalChance": 2}},
    {"Name": "Weathered Shield", "Description": "A shield bearing many scars", "Stats": {"Defense": 6, "Health": 2}},
    {"Name": "Dull Crystal", "Description": "A crystal that barely glows", "Stats": {"Mana": 5, "CriticalMultiplier": 0.1}},
    {"Name": "Ancient Bone", "Description": "A bone inscribed with faint runes", "Stats": {"Attack": 2, "Defense": 1, "Health": 2}},
    {"Name": "Tarnished Locket", "Description": "A locket that holds a faded picture", "Stats": {"Health": 4, "Mana": 2, "Speed": 1}},
    {"Name": "Fractured Orb", "Description": "An orb that hums with weak energy", "Stats": {"Mana": 4, "CriticalChance": 1}},
    {"Name": "Worn Bracers", "Description": "Bracers that fit perfectly", "Stats": {"Defense": 3, "Speed": 2, "Attack": 1}}
]

high_tier_artifacts = [
    {"Name": "Amulet of the Void", "Description": "An amulet that drinks the light around it", "Stats": {"Health": 35, "Attack": 3, "CriticalChance": 5}},
    {"Name": "Ring of Eternal Night", "Description": "A ring that feels unnaturally cold", "Stats": {"Defense": 5, "Mana": 25, "CriticalMultiplier": 1}},
    {"Name": "Cloak of Shadows", "Description": "A cloak that seems to blend with darkness", "Stats": {"Speed": 10, "Health": 45, "CriticalChance": 10}},
    {"Name": "Blade of the Abyss", "Description": "A blade that whispers promises of power", "Stats": {"Attack": 25, "CriticalChance": 7, "CriticalMultiplier": 0.3}},
    {"Name": "Shield of the Titan", "Description": "A shield that feels impossibly heavy", "Stats": {"Defense": 30, "Health": 20, "Speed": -5}},
    {"Name": "Crystal of Infinite Potential", "Description": "A crystal that contains swirling galaxies", "Stats": {"Mana": 55, "CriticalMultiplier": 0.7, "Attack": 2}},
    {"Name": "Bone of the First Lich", "Description": "A bone that pulses with necrotic energy", "Stats": {"Attack": 20, "Defense": -15, "Health": 85, "Mana": 35}},
    {"Name": "Locket of Lost Souls", "Description": "A locket that occasionally whispers", "Stats": {"Health": 42, "Mana": 28, "Speed": 2, "CriticalChance": 2}},
    {"Name": "Orb of Cosmic Truth", "Description": "An orb that shows impossible geometries", "Stats": {"Mana": 32, "CriticalChance": 4, "CriticalMultiplier": 0.4, "Defense": 2}},
    {"Name": "Bracers of Divine Wrath", "Description": "Bracers that glow with holy fire", "Stats": {"Defense": 14, "Speed": 3, "Attack": 23, "CriticalChance": 3}},
    {"Name": "Crown of the Fallen King", "Description": "A crown that weighs heavy with regret", "Stats": {"Health": 80, "Mana": 30, "Attack": 22, "Defense": 12}},
    {"Name": "Scepter of Unmaking", "Description": "A scepter that warps reality around it", "Stats": {"Attack": 40, "CriticalMultiplier": 1, "Mana": 8, "Speed": -5}}
]

# Initialize game state
game_state = GameState()

# Main Game Functions
def show_welcome_screen():
    clear_screen()
    print("\033[96m==========================================\033[0m")
    print("\033[93m         POWERSHELL RPG ADVENTURE\033[0m")
    print("\033[96m==========================================\033[0m")
    print()
    print("Welcome to the dungeon crawler!")
    print("Defeat monsters, collect artifacts, and descend deeper!")
    print()
    print("Controls:")
    print("  - Use number keys to select options")
    print("  - Press any key to skip text animations")
    print("  - Manage your health and mana carefully")
    print()
    print("Press any key to begin your adventure...")
    press_any_key()

def show_title():
    clear_screen()
    print("\033[96m==========================================\033[0m")
    print("\033[93m         POWERSHELL RPG ADVENTURE\033[0m")
    print("\033[96m==========================================\033[0m")
    print()

def new_player():
    show_title()
    write_typewriter("CHARACTER CREATION", "green", 0.04)
    print()
    write_typewriter("It's dark, damp garderobe where your body lies, a voice called out to ask your name.", "yellow", 0.03)
    write_typewriter("You've awaken without a memory, but you remembered your name.", "yellow", 0.03)
    
    name = input("My name is: ")
    
    print("\nChoose your class:")
    classes = list(class_definitions.keys())
    for i, cls in enumerate(classes, 1):
        print(f"{i}. {cls} - {class_definitions[cls]['Description']}")
    
    while True:
        choice = input("\nSelect class (1-4): ")
        if choice in ['1', '2', '3', '4']:
            break
    
    selected_class = classes[int(choice) - 1]
    
    # Initialize player
    game_state.player = {
        "Name": name,
        "Class": selected_class,
        "Level": 1,
        "Experience": 0,
        "ExperienceToNextLevel": 100,
        "Health": class_definitions[selected_class]["Health"],
        "MaxHealth": class_definitions[selected_class]["Health"],
        "Mana": class_definitions[selected_class]["Mana"],
        "MaxMana": class_definitions[selected_class]["Mana"],
        "Attack": class_definitions[selected_class]["Attack"],
        "Defense": class_definitions[selected_class]["Defense"],
        "Speed": class_definitions[selected_class]["Speed"],
        "Gold": 50,
        "Ascension": None,
        "AscensionsAvailable": class_definitions[selected_class]["Ascensions"],
        "CriticalChance": 10,
        "CriticalMultiplier": 2.0
    }
    
    # Store base stats
    game_state.player_base_stats = {
        "MaxHealth": game_state.player["MaxHealth"],
        "MaxMana": game_state.player["MaxMana"],
        "Attack": game_state.player["Attack"],
        "Defense": game_state.player["Defense"],
        "Speed": game_state.player["Speed"],
        "CriticalChance": game_state.player["CriticalChance"],
        "CriticalMultiplier": game_state.player["CriticalMultiplier"]
    }
    
    # Initialize equipment
    game_state.player_equipment = {
        "Head": None,
        "Body": None,
        "Legs": None,
        "LeftHand": None,
        "RightHand": None,
        "Cloak": None,
        "Accessory1": None,
        "Accessory2": None
    }
    
    apply_equipment_stats()
    
    print("\nCharacter created successfully!")
    write_typewriter("You made your way out, a town, underground, you heard a calling,", "yellow", 0.03)
    write_typewriter("Make your mark they said, clear up the underground dungeon, earn Gold and Fame", "yellow", 0.03)
    show_player_stats()
    write_typewriter("A goal was set, you took the first steps and march forth..", "yellow", 0.03)
    print("\nPress any key to begin your adventure...")
    press_any_key()

def show_player_stats():
    print_color("\n=== CHARACTER STATS ===", "magenta")
    print_color(f"Name: {game_state.player['Name']}", "white")
    print_color(f"Class: {game_state.player['Class']}", "white")
    if game_state.player["Ascension"]:
        print_color(f"Ascension: {game_state.player['Ascension']}", "darkyellow")
    print_color(f"Level: {game_state.player['Level']}", "yellow")
    print_color(f"XP: {game_state.player['Experience']}/{game_state.player['ExperienceToNextLevel']}", "cyan")
    print_color(f"Health: {game_state.player['Health']}/{game_state.player['MaxHealth']}", "green")
    print_color(f"Mana: {game_state.player['Mana']}/{game_state.player['MaxMana']}", "blue")
    print_color(f"Attack: {game_state.player['Attack']}", "darkred")
    print_color(f"Defense: {game_state.player['Defense']}", "darkgreen")
    print_color(f"Speed: {game_state.player['Speed']}", "darkyellow")
    print_color(f"Critical Chance: {game_state.player['CriticalChance']}%", "cyan")
    print_color(f"Critical Multiplier: {game_state.player['CriticalMultiplier']}x", "cyan")
    print_color(f"Gold: {game_state.player['Gold']}", "yellow")
    
    # Show refinement summary
    total_refinement = 0
    for slot, equipment in game_state.player_equipment.items():
        if equipment:
            total_refinement += equipment.get("RefinementLevel", 0)
    if total_refinement > 0:
        print(f"Total Refinement: +{total_refinement}")

def show_game_over_screen():
    clear_screen()
    print("\033[31m==========================================\033[0m")
    print("\033[91m               GAME OVER\033[0m")
    print("\033[31m==========================================\033[0m")
    print()
    
    print("You feel numb from the wound. You felt cold as your soul consumed by the Dark Lord")
    print("Your journey ends here..")
    print()
    print_color("Final Stats:", "magenta")
    print(f"  Reached Floor: {game_state.current_floor}")
    print(f"  Monsters Defeated: {game_state.monsters_defeated}")
    print(f"  Bosses Defeated: {game_state.bosses_defeated}")
    print(f"  Artifacts Collected: {len(game_state.player_artifacts)}")
    print(f"  Final Level: {game_state.player['Level']}")
    
    if game_state.player["Ascension"]:
        print(f"  Ascension: {game_state.player['Ascension']}")
    print()
    
    # Achievements
    if game_state.current_floor >= 10:
        print("Deep Explorer: Reached floor 10 or higher!")
    if game_state.bosses_defeated >= 5:
        print("Boss Slayer: Defeated 5 or more bosses!")
    if game_state.player["Level"] >= 10:
        print("Veteran Adventurer: Reached level 10 or higher!")
    if len(game_state.player_artifacts) >= 3:
        print("Artifact Collector: Found 3 or more artifacts!")
    
    print()
    print("What would you like to do?")
    print_color("1. Start New Game", "green")
    print_color("2. Exit Game", "red")
    print()
    
    while True:
        choice = input("Select option (1-2): ")
        if choice in ['1', '2']:
            break
    
    if choice == '1':
        initialize_game_state()
        start_game()
    else:
        print("\nThanks for playing!")
        print("Press any key to exit...")
        press_any_key()
        sys.exit()

def initialize_game_state():
    game_state.player = None
    game_state.game_running = True
    game_state.current_floor = 1
    game_state.monsters_defeated = 0
    game_state.bosses_defeated = 0
    game_state.player_artifacts = []
    game_state.player_equipment = {
        "Head": None,
        "Body": None,
        "Legs": None,
        "LeftHand": None,
        "RightHand": None,
        "Cloak": None,
        "Accessory1": None,
        "Accessory2": None
    }
    game_state.player_base_stats = None

def show_spells():
    if game_state.player["Class"] not in ["Mage", "Cleric"]:
        print("Your class doesn't use spells.")
        return
    
    print_color("\n=== YOUR SPELLS ===", "green")
    spells = class_spells[game_state.player["Class"]]
    
    for spell in spells:
        if spell["Type"] == "Damage":
            estimated_damage = round(spell["BaseDamage"] + (game_state.player["Level"] * spell["DamagePerLevel"]) + (game_state.player["MaxMana"] * spell["DamagePerAttack"]))
            print(f"{spell['Name']}: {spell['Description']}")
            print(f"  Damage: ~{estimated_damage} | Mana Cost: {spell['ManaCost']}")
            if spell.get("Element"):
                print(f"  Element: {spell['Element']}")
        else:
            if spell.get("HealPerMaxHealth"):
                estimated_heal = round(spell["BaseHeal"] + (game_state.player["Level"] * spell["HealPerLevel"]) + (game_state.player["MaxHealth"] * spell["HealPerMaxHealth"]))
            else:
                estimated_heal = round(spell["BaseHeal"] + (game_state.player["Level"] * spell["HealPerLevel"]))
            print(f"{spell['Name']}: {spell['Description']}")
            print(f"  Heal: ~{estimated_heal} | Mana Cost: {spell['ManaCost']}")
        if spell.get("Effect"):
            print(f"  Effect: {spell['Effect']}")
        print()

def show_equipment():
    print_color("\n=== YOUR EQUIPMENT ===", "green")
    
    slots = [
        {"Name": "Head", "Display": "Head"},
        {"Name": "Body", "Display": "Body"},
        {"Name": "Legs", "Display": "Legs"},
        {"Name": "LeftHand", "Display": "Left Hand"},
        {"Name": "RightHand", "Display": "Right Hand"},
        {"Name": "Cloak", "Display": "Cloak"},
        {"Name": "Accessory1", "Display": "Accessory 1"},
        {"Name": "Accessory2", "Display": "Accessory 2"}
    ]
    
    total_bonuses = {}
    has_equipment = False
    
    for slot in slots:
        slot_name = slot["Name"]
        equipment = game_state.player_equipment[slot_name]
        
        if equipment:
            has_equipment = True
            refinement_level = equipment.get("RefinementLevel", 0)
            is_broken = equipment.get("IsBroken", False)
            
            status_color = "red" if is_broken else "green"
            refinement_text = f" [+{refinement_level}]" if refinement_level > 0 else ""
            broken_text = " [BROKEN]" if is_broken else ""
            
            print(f"\n{slot['Display']}: {equipment['Name']}{refinement_text}{broken_text}")
            print(f"   {equipment['Description']}")
            
            # Get base stats and refined stats
            base_stats = equipment["Stats"]
            refined_stats = get_refinement_bonus(equipment)
            
            # Show equipment stats with refinement improvements
            for stat in base_stats.keys():
                base_value = base_stats[stat]
                refined_value = refined_stats[stat]
                improvement = refined_value - base_value
                
                color = "cyan" if improvement > 0 else "white"
                improvement_text = f" (+{improvement})" if improvement > 0 else ""
                
                if stat == "Health":
                    print(f"   {refined_value} Health{improvement_text}")
                    total_bonuses["Health"] = total_bonuses.get("Health", 0) + refined_value
                elif stat == "Mana":
                    print(f"   {refined_value} Mana{improvement_text}")
                    total_bonuses["Mana"] = total_bonuses.get("Mana", 0) + refined_value
                elif stat == "Attack":
                    print(f"   {refined_value} Attack{improvement_text}")
                    total_bonuses["Attack"] = total_bonuses.get("Attack", 0) + refined_value
                elif stat == "Defense":
                    print(f"   {refined_value} Defense{improvement_text}")
                    total_bonuses["Defense"] = total_bonuses.get("Defense", 0) + refined_value
                elif stat == "Speed":
                    print(f"   {refined_value} Speed{improvement_text}")
                    total_bonuses["Speed"] = total_bonuses.get("Speed", 0) + refined_value
                elif stat == "CriticalChance":
                    print(f"   {refined_value}% Critical Chance{improvement_text}")
                    total_bonuses["CriticalChance"] = total_bonuses.get("CriticalChance", 0) + refined_value
                elif stat == "CriticalMultiplier":
                    print(f"   {refined_value} Critical Multiplier{improvement_text}")
                    total_bonuses["CriticalMultiplier"] = total_bonuses.get("CriticalMultiplier", 0) + refined_value
        else:
            print(f"\n{slot['Display']}: [Empty]")
    
    if not has_equipment:
        print("\nYou have no equipment equipped.")
        print("Visit the shop to purchase equipment!")
    
    # Show total equipment bonuses
    if total_bonuses:
        print_color("\n=== TOTAL EQUIPMENT BONUSES ===", "cyan")
        for stat, value in total_bonuses.items():
            color = "green" if value > 0 else "red"
            symbol = "+" if value > 0 else ""
            
            if stat == "Health":
                print_color(f"{symbol}{value} Health", "green")
            elif stat == "Mana":
                print_color(f"{symbol}{value} Mana", "green")
            elif stat == "Attack":
                print_color(f"{symbol}{value} Attack", "green")
            elif stat == "Defense":
                print_color(f"{symbol}{value} Defense", "green")
            elif stat == "Speed":
                print_color(f"{symbol}{value} Speed", "green")
            elif stat == "CriticalChance":
                print_color(f"{symbol}{value}% Critical Chance", "green")
            elif stat == "CriticalMultiplier":
                print_color(f"{symbol}{value} Critical Multiplier", "green")
    
    print("\nPress any key to continue...")
    press_any_key()

def apply_equipment_stats():
    # First remove all equipment bonuses
    remove_equipment_stats()
    
    # Store current health/mana percentages
    health_percent = game_state.player["Health"] / game_state.player["MaxHealth"] if game_state.player["MaxHealth"] > 0 else 1
    mana_percent = game_state.player["Mana"] / game_state.player["MaxMana"] if game_state.player["MaxMana"] > 0 else 1
    
    # Then apply equipment bonuses on top of base stats
    for slot, equipment in game_state.player_equipment.items():
        if equipment and not equipment.get("IsBroken", False):
            refined_stats = get_refinement_bonus(equipment)
            
            for stat, value in refined_stats.items():
                if stat == "Health":
                    game_state.player["MaxHealth"] += value
                elif stat == "Mana":
                    game_state.player["MaxMana"] += value
                elif stat == "Attack":
                    game_state.player["Attack"] += value
                elif stat == "Defense":
                    game_state.player["Defense"] += value
                elif stat == "Speed":
                    game_state.player["Speed"] += value
                elif stat == "CriticalChance":
                    game_state.player["CriticalChance"] += value
                elif stat == "CriticalMultiplier":
                    game_state.player["CriticalMultiplier"] += value
    
    # Restore health and mana percentages after stat changes
    game_state.player["Health"] = round(game_state.player["MaxHealth"] * health_percent)
    game_state.player["Mana"] = round(game_state.player["MaxMana"] * mana_percent)
    
    # Ensure health and mana don't exceed their new maximums
    game_state.player["Health"] = min(game_state.player["Health"], game_state.player["MaxHealth"])
    game_state.player["Mana"] = min(game_state.player["Mana"], game_state.player["MaxMana"])
    
    # Ensure minimum values
    game_state.player["Health"] = max(1, game_state.player["Health"])
    game_state.player["Mana"] = max(0, game_state.player["Mana"])

def remove_equipment_stats():
    # Store current health/mana percentages to maintain them after stat removal
    health_percent = game_state.player["Health"] / game_state.player["MaxHealth"] if game_state.player["MaxHealth"] > 0 else 1
    mana_percent = game_state.player["Mana"] / game_state.player["MaxMana"] if game_state.player["MaxMana"] > 0 else 1
    
    # Reset player stats to base values only (no equipment)
    game_state.player["MaxHealth"] = game_state.player_base_stats["MaxHealth"]
    game_state.player["MaxMana"] = game_state.player_base_stats["MaxMana"]
    game_state.player["Attack"] = game_state.player_base_stats["Attack"]
    game_state.player["Defense"] = game_state.player_base_stats["Defense"]
    game_state.player["Speed"] = game_state.player_base_stats["Speed"]
    game_state.player["CriticalChance"] = game_state.player_base_stats["CriticalChance"]
    game_state.player["CriticalMultiplier"] = game_state.player_base_stats["CriticalMultiplier"]
    
    # Restore health and mana percentages
    game_state.player["Health"] = round(game_state.player["MaxHealth"] * health_percent)
    game_state.player["Mana"] = round(game_state.player["MaxMana"] * mana_percent)
    
    # Ensure minimum values
    game_state.player["Health"] = max(1, game_state.player["Health"])
    game_state.player["Mana"] = max(0, game_state.player["Mana"])

def get_available_equipment_for_slot(slot):
    return [eq for eq in shop_equipment if eq["Slot"] == slot]

def show_refinement_menu():
    while True:
        print("\n=== EQUIPMENT REFINEMENT ===")
        print(f"Your gold: {game_state.player['Gold']}")
        print("\nSelect equipment to refine:")
        
        slots = ["Head", "Body", "Legs", "LeftHand", "RightHand", "Cloak", "Accessory1", "Accessory2"]
        slot_options = {}
        option_number = 1
        
        for slot in slots:
            equipment = game_state.player_equipment[slot]
            if equipment and equipment.get("RefinementLevel", 0) < 10 and not equipment.get("IsBroken", False):
                slot_options[option_number] = slot
                current_level = equipment.get("RefinementLevel", 0)
                print(f"{option_number}. {equipment['Name']} [+{current_level}]")
                print(f"   Next level: +{current_level + 1} | Cost: {game_state.refinement_costs[current_level]} gold")
                success_rate = game_state.refinement_success_rates[current_level]
                break_rate = game_state.refinement_break_rates[current_level]
                color = "green" if success_rate >= 70 else "yellow" if success_rate >= 40 else "red"
                print(f"   Success: {success_rate}% | Break: {break_rate}%")
                option_number += 1
        
        if not slot_options:
            print("No equipment available for refinement!")
            print("All equipment is either broken or already at maximum refinement.")
            print("Press any key to continue...")
            press_any_key()
            return
        
        print("\n0. Back to Shop")
        
        choice = input("\nSelect equipment: ")
        
        if choice == '0':
            return
        
        if choice.isdigit() and int(choice) in slot_options:
            selected_slot = slot_options[int(choice)]
            start_refinement(selected_slot)
        else:
            print("Invalid selection!")

def start_refinement(slot):
    equipment = game_state.player_equipment[slot]
    current_level = equipment.get("RefinementLevel", 0)
    next_level = current_level + 1
    
    if next_level > 10:
        print("This equipment is already at maximum refinement!")
        return
    
    cost = game_state.refinement_costs[current_level]
    success_rate = game_state.refinement_success_rates[current_level]
    break_rate = game_state.refinement_break_rates[current_level]
    
    print(f"\n=== REFINING {equipment['Name']} ===")
    print(f"Current: +{current_level}")
    print(f"Target: +{next_level}")
    print(f"Cost: {cost} gold")
    print(f"Success Rate: {success_rate}%")
    print(f"Break Rate: {break_rate}%")
    
    if game_state.player["Gold"] < cost:
        print(f"Not enough gold! You need {cost} gold.")
        print("Press any key to continue...")
        press_any_key()
        return
    
    print("\nAre you sure you want to attempt refinement?")
    print("1. Yes, attempt refinement")
    print("2. No, go back")
    
    confirm = input("\nSelect option: ")
    
    if confirm != '1':
        return
    
    # Deduct cost
    game_state.player["Gold"] -= cost
    
    # Roll for success
    roll = random.randint(1, 100)
    write_typewriter(f"\nThe blacksmith begins refining your {equipment['Name']}...", "yellow", 0.05)
    
    if roll <= success_rate:
        # SUCCESS
        equipment["RefinementLevel"] = next_level
        write_typewriter(f"*** SUCCESS! {equipment['Name']} is now +{next_level}! ***", "green", 0.05)
        
        # Show stat improvements
        old_stats = get_refinement_bonus(equipment, current_level)
        new_stats = get_refinement_bonus(equipment, next_level)
        
        print("\nStat Improvements:")
        for stat in equipment["Stats"].keys():
            improvement = new_stats[stat] - old_stats[stat]
            if improvement > 0:
                print(f"  {stat}: +{improvement}")
        
        # Special effects at certain levels
        if next_level == 5:
            print("\nThe equipment glows with newfound power!")
        elif next_level == 10:
            print("\nLEGENDARY! The equipment radiates immense power!")
    else:
        # FAILURE
        write_typewriter("*** REFINEMENT FAILED! ***", "red", 0.05)
        
        # Check if equipment breaks
        break_roll = random.randint(1, 100)
        if break_roll <= break_rate:
            equipment["IsBroken"] = True
            write_typewriter(f"CATASTROPHIC FAILURE! Your {equipment['Name']} has been destroyed!", "darkred", 0.05)
            game_state.player_equipment[slot] = None
        else:
            print("The equipment survived the failed attempt.")
    
    # Force complete stat recalculation
    print("\nRecalculating all stats...")
    remove_equipment_stats()
    apply_equipment_stats()
    
    # Show updated player stats
    print("\nYour updated stats:")
    print(f"Health: {game_state.player['Health']}/{game_state.player['MaxHealth']}")
    print(f"Mana: {game_state.player['Mana']}/{game_state.player['MaxMana']}")
    print(f"Attack: {game_state.player['Attack']}")
    print(f"Defense: {game_state.player['Defense']}")
    print(f"Speed: {game_state.player['Speed']}")
    print(f"Critical Chance: {game_state.player['CriticalChance']}%")
    print(f"Critical Multiplier: {game_state.player['CriticalMultiplier']}x")
    
    print("\nPress any key to continue...")
    press_any_key()

def get_refinement_bonus(equipment, level=None):
    if level is None:
        level = equipment.get("RefinementLevel", 0)
    
    bonus_stats = {}
    for stat, base_value in equipment["Stats"].items():
        multiplier = game_state.refinement_stat_multipliers[level]
        bonus_stats[stat] = round(base_value * multiplier)
    return bonus_stats

def show_repair_menu():
    print("\n=== EQUIPMENT REPAIR ===")
    print(f"Your gold: {game_state.player['Gold']}")
    
    broken_items = []
    for slot, equipment in game_state.player_equipment.items():
        if equipment and equipment.get("IsBroken", False):
            broken_items.append({"Slot": slot, "Equipment": equipment})
    
    if not broken_items:
        print("No broken equipment to repair!")
        return
    
    print("\nBroken equipment:")
    for i, item in enumerate(broken_items, 1):
        repair_cost = round(game_state.refinement_costs[item["Equipment"].get("RefinementLevel", 0)] * 0.5)
        print(f"{i}. {item['Equipment']['Name']} [+{item['Equipment'].get('RefinementLevel', 0)}] - Repair: {repair_cost} gold")
    
    print("0. Back")
    
    choice = input("\nSelect equipment to repair: ")
    if choice == '0':
        return
    
    if choice.isdigit():
        selected_index = int(choice) - 1
        if 0 <= selected_index < len(broken_items):
            selected_item = broken_items[selected_index]
            repair_cost = round(game_state.refinement_costs[selected_item["Equipment"].get("RefinementLevel", 0)] * 0.5)
            
            if game_state.player["Gold"] >= repair_cost:
                game_state.player["Gold"] -= repair_cost
                selected_item["Equipment"]["IsBroken"] = False
                print(f"Repaired {selected_item['Equipment']['Name']} for {repair_cost} gold!")
            else:
                print(f"Not enough gold! Need {repair_cost} gold.")

def get_random_monster():
    # Boss spawn logic
    is_boss_floor = game_state.current_floor % 3 == 0
    
    # Calculate boss chance
    if is_boss_floor:
        boss_chance = 30  # 30% chance on boss floors
    else:
        base_chance = 0.5
        floor_bonus = min(game_state.current_floor * 0.05, 0.1)
        boss_chance = base_chance + floor_bonus
    
    is_boss = random.randint(1, 100) < boss_chance

    if is_boss:
        boss = random.choice(boss_types).copy()
        
        # Scale boss stats
        scale_factor = 2 + (game_state.current_floor * 0.8) + (game_state.player["Level"] * 0.5) + (game_state.player["ExperienceToNextLevel"] * 0.0003)
        boss["Health"] = round(boss["BaseHealth"] * scale_factor)
        boss["Attack"] = round(boss["BaseAttack"] * scale_factor)
        boss["Defense"] = round(boss["BaseDefense"] * scale_factor)
        boss["XP"] = round(boss["XP"] * scale_factor)
        boss["Gold"] = round(boss["Gold"] * scale_factor)
        boss["CriticalChance"] = 10
        boss["CriticalMultiplier"] = 1.8
       
        # Add special boss abilities
        boss["IsBoss"] = True
        random_ability = random.choice(boss_abilities)
        boss["SpecialAbility"] = random_ability["Name"]
        boss["SpecialDescription"] = random_ability["Description"]
        boss["SpecialMultiplier"] = random_ability["DamageMultiplier"]
        boss["SpecialEffect"] = random_ability["Effect"]
        
        write_typewriter("\n*** BOSS ENCOUNTER! ***", "red", 0.05)
        return boss
    else:
        # Automatic tier-based monster selection
        current_tier = min((game_state.current_floor + 2) // 3, 5)
        
        # Get all monsters in the current tier and one tier below
        available_tiers = [current_tier]
        if current_tier > 1:
            available_tiers.append(current_tier - 1)
        
        # Filter monsters by available tiers
        available_monsters = [m for m in monster_types if m["Tier"] in available_tiers]
        
        # If we have monsters available, select one randomly
        if available_monsters:
            base_monster = random.choice(available_monsters).copy()
        else:
            # Fallback: select any monster
            base_monster = random.choice(monster_types).copy()
        
        # Scale monster stats based on floor level
        scale_factor = 1 + (game_state.current_floor * 0.15) + (game_state.player["Level"] * 0.2)
        base_monster["Health"] = round(base_monster["Health"] * scale_factor)
        base_monster["Attack"] = round(base_monster["Attack"] * scale_factor)
        base_monster["Defense"] = round(base_monster["Defense"] * scale_factor)
        base_monster["XP"] = round(base_monster["XP"] * scale_factor)
        base_monster["Gold"] = round(base_monster["Gold"] * scale_factor)
        base_monster["CriticalChance"] = 5
        base_monster["CriticalMultiplier"] = 1.5
        
        return base_monster

def get_random_artifact(tier):
    if tier == "Low":
        artifact = random.choice(low_tier_artifacts)
    else:
        artifact = random.choice(high_tier_artifacts)
    
    return {
        "Name": artifact["Name"],
        "Description": artifact["Description"],
        "Tier": tier,
        "Stats": artifact["Stats"]
    }

def apply_artifact_stats(artifact):
    for stat, value in artifact["Stats"].items():
        if stat == "Health":
            game_state.player["MaxHealth"] += value
            game_state.player["Health"] += value
        elif stat == "Mana":
            game_state.player["MaxMana"] += value
            game_state.player["Mana"] += value
        elif stat == "Attack":
            game_state.player["Attack"] += value
        elif stat == "Defense":
            game_state.player["Defense"] += value
        elif stat == "Speed":
            game_state.player["Speed"] += value
        elif stat == "CriticalChance":
            game_state.player["CriticalChance"] += value
        elif stat == "CriticalMultiplier":
            game_state.player["CriticalMultiplier"] += value

def show_artifact_stats(artifact):
    print("Artifact Bonuses:")
    for stat, value in artifact["Stats"].items():
        color = "green" if value > 0 else "red"
        symbol = "+" if value > 0 else ""
        
        if stat == "Health":
            print(f"  {symbol}{value} Health")
        elif stat == "Mana":
            print(f"  {symbol}{value} Mana")
        elif stat == "Attack":
            print(f"  {symbol}{value} Attack")
        elif stat == "Defense":
            print(f"  {symbol}{value} Defense")
        elif stat == "Speed":
            print(f"  {symbol}{value} Speed")
        elif stat == "CriticalChance":
            print(f"  {symbol}{value}% Critical Chance")
        elif stat == "CriticalMultiplier":
            print(f"  {symbol}{value} Critical Multiplier")

def start_combat():
    monster = get_random_monster()
    monster_health = monster["Health"]
    
    print(f"\nA wild {monster['Name']} appears!")
    print(f"Monster HP: {monster_health} | Attack: {monster['Attack']} | Defense: {monster['Defense']}", "red")
    
    player_turn = game_state.player["Speed"] >= random.randint(1, 10)

    while monster_health > 0 and game_state.player["Health"] > 0:
        if player_turn:
            print_color("\n=== YOUR TURN ===", "green")
            print("1. Attack")
            
            # Show spells for Mage and Cleric
            if game_state.player["Class"] in ["Mage", "Cleric"]:
                spells = class_spells[game_state.player["Class"]]
                for i, spell in enumerate(spells, 2):
                    if spell["Type"] == "Damage":
                        estimated_damage = round(spell["BaseDamage"] + (game_state.player["Level"] * spell["DamagePerLevel"]) + (game_state.player["MaxMana"] * spell["DamagePerAttack"]))
                        print(f"{i}. {spell['Name']} - {spell['Description']} (Mana: {spell['ManaCost']}, Damage: ~{estimated_damage})")
                    else:
                        if spell.get("HealPerMaxHealth"):
                            estimated_heal = round(spell["BaseHeal"] + (game_state.player["Level"] * spell["HealPerLevel"]) + (game_state.player["MaxHealth"] * spell["HealPerMaxHealth"]))
                        else:
                            estimated_heal = round(spell["BaseHeal"] + (game_state.player["Level"] * spell["HealPerLevel"]))
                        print(f"{i}. {spell['Name']} - {spell['Description']} (Mana: {spell['ManaCost']}, Heal: ~{estimated_heal})")
            else:
                # Special ability for non-spellcasters
                print("2. Special Ability")
            
            # Standardized options for all classes
            print("6. Use Potion (12 gold)")
            print("7. Flee")
            
            choice = input("Choose action: ")
            
            # Validate input based on class
            if game_state.player["Class"] in ["Mage", "Cleric"]:
                valid_choices = ['1', '2', '3', '4', '5', '6', '7']
            else:
                valid_choices = ['1', '2', '6', '7']

            if choice not in valid_choices:
                print_color("Invalid choice! Please select a valid option.", "red")
                continue
            
            if choice == '1':
                # Regular attack for all classes
                base_damage = max(1, game_state.player["Attack"] - monster["Defense"] + random.randint(-2, 2))
                
                # Critical hit check
                is_critical = random.randint(1, 100) < game_state.player["CriticalChance"]
                if is_critical:
                    damage = round(base_damage * game_state.player["CriticalMultiplier"])
                    write_typewriter(f"CRITICAL HIT! You attack the {monster['Name']} for {damage} damage!", "cyan", 0.01)
                else:
                    damage = base_damage
                    write_quick(f"You attack the {monster['Name']} for {damage} damage!", "yellow")
                monster_health -= damage
            
            # Spells for Mage and Cleric (options 2-5)
            elif choice in ['2', '3', '4', '5'] and game_state.player["Class"] in ["Mage", "Cleric"]:
                spell_index = int(choice) - 2
                spells = class_spells[game_state.player["Class"]]
                
                if spell_index < len(spells):
                    selected_spell = spells[spell_index]
                    
                    if game_state.player["Mana"] >= selected_spell["ManaCost"]:
                        game_state.player["Mana"] -= selected_spell["ManaCost"]
                        
                        if selected_spell["Type"] == "Damage":
                            # Calculate spell damage
                            base_spell_damage = round(selected_spell["BaseDamage"] + (game_state.player["Level"] * selected_spell["DamagePerLevel"]) + (game_state.player["MaxMana"] * selected_spell["DamagePerAttack"]))
                            
                            # Apply elemental bonus if applicable
                            elemental_bonus = 1.0
                            element_description = ""
                            if selected_spell.get("Element") and selected_spell["Element"] in elemental_effects:
                                elemental_bonus = elemental_effects[selected_spell["Element"]]["BonusDamage"]
                                element_description = elemental_effects[selected_spell["Element"]]["Description"]
                            
                            spell_damage = round(base_spell_damage * elemental_bonus)
                            
                            # Critical hit check for spells
                            is_critical = random.randint(1, 100) < (game_state.player["CriticalChance"] + 5)
                            if is_critical:
                                spell_damage = round(spell_damage * game_state.player["CriticalMultiplier"])
                                if element_description:
                                    write_typewriter(f"CRITICAL HIT! You cast {selected_spell['Name']} and it {element_description} for {spell_damage} damage!", "cyan", 0.001)
                                else:
                                    write_typewriter(f"CRITICAL HIT! You cast {selected_spell['Name']} for {spell_damage} damage!", "cyan", 0.002)
                            else:
                                if element_description:
                                    write_typewriter(f"You cast {selected_spell['Name']} and it {element_description} for {spell_damage} damage!", "magenta", 0.002)
                                else:
                                    write_typewriter(f"You cast {selected_spell['Name']} for {spell_damage} damage!", "magenta", 0.002)
                            
                            # Apply spell effects
                            if selected_spell.get("Effect") == "Slow":
                                print(f"The {monster['Name']} is slowed!")
                            elif selected_spell.get("Effect") == "Stun" and random.randint(1, 100) < 10:
                                player_turn = True
                                print(f"The {monster['Name']} is stunned and loses its turn!")
                            
                            monster_health -= spell_damage
                            
                        elif selected_spell["Type"] == "Heal":
                            # Calculate heal
                            if selected_spell.get("HealPerMaxHealth"):
                                heal_amount = round(selected_spell["BaseHeal"] + (game_state.player["Level"] * selected_spell["HealPerLevel"]) + (game_state.player["MaxHealth"] * selected_spell["HealPerMaxHealth"]))
                            else:
                                heal_amount = round(selected_spell["BaseHeal"] + (game_state.player["Level"] * selected_spell["HealPerLevel"]))
                            
                            old_health = game_state.player["Health"]
                            game_state.player["Health"] = min(game_state.player["MaxHealth"], game_state.player["Health"] + heal_amount)
                            actual_heal = game_state.player["Health"] - old_health
                            
                            write_typewriter(f"You cast {selected_spell['Name']} and heal {actual_heal} health!", "green", 0.02)
                            print(f"Current HP: {game_state.player['Health']}/{game_state.player['MaxHealth']}")
                    else:
                        print(f"Not enough mana! You need {selected_spell['ManaCost']} mana.")
                        continue
                else:
                    print("Invalid spell selection!")
                    continue
            
            # Special ability for non-spellcasters (option 2)
            elif choice == '2' and game_state.player["Class"] not in ["Mage", "Cleric"]:
                if game_state.player["Mana"] >= 5:
                    game_state.player["Mana"] -= 5
                    special_damage = game_state.player["Attack"] + random.randint(2, 5)
                    monster_health -= special_damage
                    print(f"You use a special ability for {special_damage} damage!")
                else:
                    print("Not enough mana!")
                    continue
            
            # Potion for all classes (option 6)
            elif choice == '6':
                if game_state.player["Gold"] >= 12:
                    game_state.player["Gold"] -= 12
                    
                    # Scaled healing for health
                    base_heal = 20
                    level_bonus = game_state.player["Level"] * 3
                    health_percentage = game_state.player["MaxHealth"] * 0.15
                    heal = base_heal + level_bonus + round(health_percentage)
                    
                    # Scaled restoration for mana
                    base_mana_restore = 15
                    level_mana_bonus = game_state.player["Level"] * 2
                    mana_percentage = game_state.player["MaxMana"] * 0.10
                    mana_restore = base_mana_restore + level_mana_bonus + round(mana_percentage)

                    old_health = game_state.player["Health"]
                    old_mana = game_state.player["Mana"]
                    
                    # Apply healing
                    game_state.player["Health"] = min(game_state.player["MaxHealth"], game_state.player["Health"] + heal)
                    actual_heal = game_state.player["Health"] - old_health
                    
                    # Apply mana restoration
                    game_state.player["Mana"] = min(game_state.player["MaxMana"], game_state.player["Mana"] + mana_restore)
                    actual_mana_restore = game_state.player["Mana"] - old_mana
                    
                    print(f"You use a potion and heal {actual_heal} health and restore {actual_mana_restore} mana!")
                    print(f"Current HP: {game_state.player['Health']}/{game_state.player['MaxHealth']}")
                    print(f"Current Mana: {game_state.player['Mana']}/{game_state.player['MaxMana']}")
                else:
                    print("Not enough gold!")
                    continue
            
            # Flee for all classes (option 7)
            elif choice == '7':
                if random.randint(1, 100) < 40:
                    print("You successfully fled from combat!")
                    print("Press any key to continue...")
                    press_any_key()
                    return False
                else:
                    print("Failed to flee!")
            else:
                print("Invalid choice!")
                continue
        else:
            write_typewriter("\n=== MONSTER'S TURN ===", "red")
            
            # Boss special attacks
            if monster.get("IsBoss") and random.randint(1, 100) < 25:
                base_damage = max(2, (monster["Attack"] * monster["SpecialMultiplier"]) - game_state.player["Defense"])
                
                # Apply special effects based on ability type
                effect_message = ""
                additional_damage = 0
                
                if monster["SpecialEffect"] == "lifedrain":
                    heal_amount = round(base_damage * 0.25)
                    monster_health += heal_amount
                    monster_health = min(monster["Health"], monster_health)
                    effect_message = f" and drains {heal_amount} health from you!"
                elif monster["SpecialEffect"] == "critical":
                    # Double critical chance for these abilities
                    is_critical = random.randint(1, 100) < (monster["CriticalChance"] * 1.5)
                    if is_critical:
                        base_damage = round(base_damage * monster["CriticalMultiplier"])
                        effect_message = " with enhanced critical strike!"
                elif monster["SpecialEffect"] == "debuff":
                    # Reduce player attack temporarily
                    attack_reduction = 1
                    game_state.player["Attack"] = max(1, game_state.player["Attack"] - attack_reduction)
                    effect_message = f" reducing your attack power by {attack_reduction}!"
                elif monster["SpecialEffect"] == "stun":
                    # Chance to stun player (skip next turn)
                    if random.randint(1, 100) < 30:
                        player_turn = False
                        effect_message = " stunning you and making you lose your next turn!"
                    else:
                        effect_message = " but you resist the stun!"
                elif monster["SpecialEffect"] == "sacrifice":
                    # Boss takes some damage but gains more
                    boss_self_damage = round(base_damage * 0.5)
                    monster_health -= boss_self_damage
                    heal_amount = round(base_damage * 0.3)
                    monster_health += heal_amount
                    monster_health = min(monster["Health"], monster_health)
                    effect_message = f" sacrificing {boss_self_damage} health but gaining {heal_amount}!"
                elif monster["SpecialEffect"] == "armorbreak":
                    # Reduce player defense
                    defense_reduction = 2
                    game_state.player["Defense"] = max(0, game_state.player["Defense"] - defense_reduction)
                    effect_message = f" breaking your armor and reducing defense by {defense_reduction}!"
                elif monster["SpecialEffect"] == "dot":
                    # Apply damage over time
                    additional_damage = round(base_damage * 0.2)
                    effect_message = f" applying a damage over time effect for {additional_damage} additional damage!"
                else:
                    effect_message = "!"
                
                # Critical hit check for boss special
                is_critical = random.randint(1, 100) < monster["CriticalChance"]
                if is_critical and monster["SpecialEffect"] != "critical":
                    special_damage = round(base_damage * monster["CriticalMultiplier"])
                    write_typewriter(f"CRITICAL HIT! The {monster['Name']} {monster['SpecialDescription']} for {special_damage} damage{effect_message}", "darkred", 0.02)
                else:
                    special_damage = base_damage
                    write_typewriter(f"The {monster['Name']} {monster['SpecialDescription']} for {special_damage} damage{effect_message}", "red", 0.02)
                
                # Apply damage - ONLY ONCE
                game_state.player["Health"] -= special_damage
                if additional_damage > 0:
                    game_state.player["Health"] -= additional_damage
            else:
                base_damage = max(1, monster["Attack"] - game_state.player["Defense"] + random.randint(-1, 1))
                
                # Critical hit check for normal monster attack
                is_critical = random.randint(1, 100) < monster["CriticalChance"]
                if is_critical:
                    damage = round(base_damage * monster["CriticalMultiplier"])
                    write_typewriter(f"CRITICAL HIT! The {monster['Name']} attacks you for {damage} damage!", "darkred")
                else:
                    damage = base_damage
                    print_color(f"The {monster['Name']} attacks you for {damage} damage!")
                game_state.player["Health"] -= damage

        # Show combat status
        write_typewriter(f"\nYour HP: {game_state.player['Health']}/{game_state.player['MaxHealth']}", "green")
        write_typewriter(f"{monster['Name']} HP: {monster_health}/{monster['Health']}", "red")
        
        player_turn = not player_turn
    
    if game_state.player["Health"] <= 0:
        print_color("\n==========================================", "red")
        print_color("          YOU HAVE BEEN DEFEATED", "red")
        print_color("==========================================", "red")
        print()
        print("As your vision fades, you feel the cold embrace of death...")
        print()
        
        # Different death messages based on progress
        if game_state.current_floor <= 3:
            print("Your adventure ends before it truly began...")
        elif game_state.current_floor <= 7:
            print("You fought bravely, but the dungeon proved too formidable...")
        elif game_state.current_floor <= 12:
            print("A valiant effort, but even heroes must fall...")
        else:
            print("You ventured deeper than most, but even legends must end...")
        
        print()
        print("Press any key to face your fate...")
        press_any_key()
        return False
    else:
        print_color(f"\nYou defeated the {monster['Name']}!", "green")
        gold_earned = monster["Gold"]
        xp_earned = monster["XP"]
        game_state.player["Gold"] += gold_earned
        game_state.player["Experience"] += xp_earned
        game_state.monsters_defeated += 1

        if monster.get("IsBoss"):
            game_state.bosses_defeated += 1
            print_color("*** BOSS DEFEATED! ***", "green")

        print_color(f"Earned {xp_earned} XP and {gold_earned} gold!", "green")

        # Check for level up after combat victory
        level_up()

        # Check for artifact drops
        # Check for low tier artifact from normal monsters (2% chance)
        if not monster.get("IsBoss") and random.randint(1, 100) < 2:
            new_artifact = get_random_artifact("Low")
            if len(game_state.player_artifacts) < game_state.max_artifacts:
                game_state.player_artifacts.append(new_artifact)
                apply_artifact_stats(new_artifact)
                write_typewriter(f"*** You found a rare artifact: {new_artifact['Name']} ***", "yellow", 0.04)
                print(f"{new_artifact['Description']}")
                show_artifact_stats(new_artifact)
            else:
                print_color("You found an artifact but your inventory is full!", "red")
        
        # Check for high tier artifact from bosses (5% chance)
        if monster.get("IsBoss") and random.randint(1, 100) < 5:
            new_artifact = get_random_artifact("High")
            if len(game_state.player_artifacts) < game_state.max_artifacts:
                game_state.player_artifacts.append(new_artifact)
                apply_artifact_stats(new_artifact)
                write_typewriter(f"*** The boss dropped a legendary artifact: {new_artifact['Name']} ***", "magenta", 0.05)
                print(f"{new_artifact['Description']}")
                show_artifact_stats(new_artifact)
            else:
                print_color("The boss dropped an artifact but your inventory is full!", "red")

        print("Press any key to continue...")
        press_any_key()
        return True

def show_artifacts():
    print_color("\n=== YOUR ARTIFACTS ===", "green")
    print(f"Carrying: {len(game_state.player_artifacts)}/{game_state.max_artifacts}")
    
    if not game_state.player_artifacts:
        print("You haven't found any artifacts yet.")
        print("Defeat monsters and bosses to find rare artifacts!")
        return
    
    total_bonuses = {}
    
    for i, artifact in enumerate(game_state.player_artifacts, 1):
        tier_color = "magenta" if artifact["Tier"] == "High" else "yellow"
        
        print(f"\n{i}. {artifact['Name']} [{artifact['Tier']} Tier]")
        print(f"   {artifact['Description']}")
        
        # Show individual artifact stats
        for stat, value in artifact["Stats"].items():
            color = "green" if value > 0 else "red"
            symbol = "+" if value > 0 else ""
            
            if stat == "Health":
                print(f"   {symbol}{value} Health")
            elif stat == "Mana":
                print(f"   {symbol}{value} Mana")
            elif stat == "Attack":
                print(f"   {symbol}{value} Attack")
            elif stat == "Defense":
                print(f"   {symbol}{value} Defense")
            elif stat == "Speed":
                print(f"   {symbol}{value} Speed")
            elif stat == "CriticalChance":
                print(f"   {symbol}{value}% Critical Chance")
            elif stat == "CriticalMultiplier":
                print(f"   {symbol}{value} Critical Multiplier")
            
            # Accumulate total bonuses
            total_bonuses[stat] = total_bonuses.get(stat, 0) + value
    
    # Show total bonuses
    if total_bonuses:
        print_color("\n=== TOTAL ARTIFACT BONUSES ===", "cyan")
        for stat, value in total_bonuses.items():
            color = "green" if value > 0 else "red"
            symbol = "+" if value > 0 else ""
            
            if stat == "Health":
                print(f"{symbol}{value} Health")
            elif stat == "Mana":
                print(f"{symbol}{value} Mana")
            elif stat == "Attack":
                print(f"{symbol}{value} Attack")
            elif stat == "Defense":
                print(f"{symbol}{value} Defense")
            elif stat == "Speed":
                print(f"{symbol}{value} Speed")
            elif stat == "CriticalChance":
                print(f"{symbol}{value}% Critical Chance")
            elif stat == "CriticalMultiplier":
                print(f"{symbol}{value} Critical Multiplier")
    
    print("\nPress any key to continue...")
    press_any_key()

def level_up():
    while game_state.player["Experience"] >= game_state.player["ExperienceToNextLevel"]:
        game_state.player["Level"] += 1
        game_state.player["Experience"] -= game_state.player["ExperienceToNextLevel"]
        game_state.player["ExperienceToNextLevel"] = round(game_state.player["ExperienceToNextLevel"] * 1.5)
        
        # Stat increases
        health_increase = 5 + random.randint(2, 8)
        attack_increase = 1 + random.randint(0, 1)
        defense_increase = 1 + random.randint(0, 1)
        mana_increase = 5 + random.randint(2, 5)
        
        # Update base stats
        game_state.player_base_stats["MaxHealth"] += health_increase
        game_state.player_base_stats["MaxMana"] += mana_increase
        game_state.player_base_stats["Attack"] += attack_increase
        game_state.player_base_stats["Defense"] += defense_increase
        
        # Apply level up to current stats (equipment will be reapplied later)
        game_state.player["MaxHealth"] = game_state.player_base_stats["MaxHealth"]
        game_state.player["MaxMana"] = game_state.player_base_stats["MaxMana"]
        game_state.player["Attack"] = game_state.player_base_stats["Attack"]
        game_state.player["Defense"] = game_state.player_base_stats["Defense"]
        game_state.player["Health"] = game_state.player["MaxHealth"]
        game_state.player["Mana"] = game_state.player["MaxMana"]
        
        if random.randint(1, 100) < 30:
            game_state.player_base_stats["CriticalChance"] += 1
            game_state.player["CriticalChance"] = game_state.player_base_stats["CriticalChance"]
            print("Critical Chance +1%")
        
        print_color(f"\n*** LEVEL UP! You are now level {game_state.player['Level']} ***", "green")
        print_color(f"Health +{health_increase}, Attack +{attack_increase}, Defense +{defense_increase}, Mana +{mana_increase}", "cyan")
        
        # Reapply equipment stats after level up
        apply_equipment_stats()
        
        # Check for ascension at level 5
        if game_state.player["Level"] == 5 and not game_state.player["Ascension"]:
            start_ascension()

def start_ascension():
    write_typewriter("\n*** ASCENSION AVAILABLE! ***", "magenta", 0.04)
    write_typewriter("Choose your ascension path:", "yellow", 0.03)
    
    for i, ascension in enumerate(game_state.player["AscensionsAvailable"], 1):
        write_typewriter(f"{i}. {ascension}", "white", 0.03)
        bonus = ascension_bonuses[ascension]
        write_typewriter(f"   Bonus: +{bonus['Health']} HP, +{bonus['Mana']} Mana, +{bonus['Attack']} Attack, +{bonus['Defense']} Defense, +{bonus['Speed']} Speed", "gray", 0.03)
    
    while True:
        choice = input("\nSelect ascension (1-4): ")
        if choice in ['1', '2', '3', '4']:
            break
    
    selected_ascension = game_state.player["AscensionsAvailable"][int(choice) - 1]
    game_state.player["Ascension"] = selected_ascension
    
    # Apply ascension bonuses
    bonus = ascension_bonuses[selected_ascension]
    game_state.player_base_stats["MaxHealth"] += bonus["Health"]
    game_state.player_base_stats["MaxMana"] += bonus["Mana"]
    game_state.player_base_stats["Attack"] += bonus["Attack"]
    game_state.player_base_stats["Defense"] += bonus["Defense"]
    game_state.player_base_stats["Speed"] += bonus["Speed"]

    # Reapply equipment stat bonuses logic
    apply_equipment_stats()
    
    write_typewriter(f"\nYou have ascended to {selected_ascension}!", "magenta", 0.04)
    write_typewriter("All stats improved!", "green", 0.03)

def show_game_menu():
    print_color(f"\n=== FLOOR {game_state.current_floor} ===", "magenta")
    print(f"Monsters Defeated: {game_state.monsters_defeated}")
    print(f"Artifacts Found: {len(game_state.player_artifacts)}/{game_state.max_artifacts}")
    print("\nWhat would you like to do?")
    print("1. Explore (Fight monsters)")
    print("2. Rest (Heal for 10 gold)")
    print("3. View Stats")
    print("4. View Spells")
    print("5. View Equipment")
    print("6. View Artifacts")
    print("7. Visit Shop")
    print("8. Descend to next floor")
    print("0. Quit Game")

def show_exit_screen():
    clear_screen()
    print("\033[96m==========================================\033[0m")
    print("\033[93m          EXITING GAME\033[0m")
    print("\033[96m==========================================\033[0m")
    print()
    
    print("Your current progress:")
    print(f"  Current Floor: {game_state.current_floor}")
    print(f"  Monsters Defeated: {game_state.monsters_defeated}")
    print(f"  Bosses Defeated: {game_state.bosses_defeated}")
    print(f"  Artifacts Collected: {len(game_state.player_artifacts)}")
    print(f"  Current Level: {game_state.player['Level']}")
    print()
    
    print("Are you sure you want to exit?")
    print_color("1. Continue Playing", "green")
    print_color("2. Exit Game", "red")
    print()
    
    while True:
        choice = input("Select option (1-2): ")
        if choice in ['1', '2']:
            break
    
    if choice == '1':
        print_color("Continuing your adventure...", "green")
        return True
    else:
        print_color("\nThanks for playing! Your adventure awaits another day.", "red")
        print("Press any key to exit...")
        press_any_key()
        sys.exit()

def visit_shop():
    print_color("\n=== WELCOME TO THE SHOP ===", "cyan")
    print_color(f"Your gold: {game_state.player['Gold']}", "yellow")
    
    shop_items = [
        {"Name": "Health Potion", "Cost": 15, "Description": "Restore 25 HP"},
        {"Name": "Mana Potion", "Cost": 12, "Description": "Restore 20 Mana"},
        {"Name": "Attack Boost", "Cost": 50, "Description": "Permanently +2 Attack"},
        {"Name": "Defense Boost", "Cost": 50, "Description": "Permanently +2 Defense"},
        {"Name": "Critical Charm", "Cost": 200, "Description": "Permanently +0.5% Critical Chance"},
        {"Name": "Keen Edge", "Cost": 300, "Description": "Permanently +0.2 Critical Multiplier"}
    ]
    
    # Display regular items
    for i, item in enumerate(shop_items, 1):
        print_color(f"{i}. {item['Name']} - {item['Cost']} gold", "yellow")
        print(f"   {item['Description']}")
    
    # Display equipment options
    print_color("== EQUIPMENTS ==", "yellow")
    print()
    print_color("7. Buy Equipment", "cyan")
    print_color("8. Refine Equipment", "cyan")
    print_color("9. Repair Broken Equipment", "cyan")
    print_color("10. Sell Artifact (50 gold)", "cyan")
    print_color("0. Leave Shop")
    
    while True:
        choice = input("\nSelect option: ")
        if choice in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10']:
            break
    
    if choice == '0':
        return
    elif choice == '1':
        if game_state.player["Gold"] >= 15:
            game_state.player["Gold"] -= 15
            game_state.player["Health"] = min(game_state.player["MaxHealth"], game_state.player["Health"] + 25)
            print(f"Health restored! Current HP: {game_state.player['Health']}")
        else:
            print("Not enough gold!")
    elif choice == '2':
        if game_state.player["Gold"] >= 12:
            game_state.player["Gold"] -= 12
            game_state.player["Mana"] = min(game_state.player["MaxMana"], game_state.player["Mana"] + 20)
            print(f"Mana restored! Current Mana: {game_state.player['Mana']}")
        else:
            print("Not enough gold!")
    elif choice == '3':
        if game_state.player["Gold"] >= 50:
            game_state.player["Gold"] -= 50
            game_state.player_base_stats["Attack"] += 2
            update_all_stats()
            print("Attack permanently increased by 2!")
        else:
            print("Not enough gold!")
    elif choice == '4':
        if game_state.player["Gold"] >= 50:
            game_state.player["Gold"] -= 50
            game_state.player_base_stats["Defense"] += 2
            update_all_stats()
            print("Defense permanently increased by 2!")
        else:
            print("Not enough gold!")
    elif choice == '5':
        if game_state.player["Gold"] >= 200:
            game_state.player["Gold"] -= 200
            game_state.player_base_stats["CriticalChance"] += 0.5
            update_all_stats()
            print(f"Critical chance increased by 5%! Current: {game_state.player['CriticalChance']}%")
        else:
            print("Not enough gold!")
    elif choice == '6':
        if game_state.player["Gold"] >= 300:
            game_state.player["Gold"] -= 300
            game_state.player_base_stats["CriticalMultiplier"] += 0.2
            update_all_stats()
            print(f"Critical multiplier increased by 0.5! Current: {game_state.player['CriticalMultiplier']}x")
        else:
            print("Not enough gold!")
    elif choice == '7':
        show_equipment_shop()
    elif choice == '8':
        show_refinement_menu()
    elif choice == '9':
        show_repair_menu()
    elif choice == '10':
        if not game_state.player_artifacts:
            print("You have no artifacts to sell!")
            return
        
        print("\nSelect artifact to sell:")
        for i, artifact in enumerate(game_state.player_artifacts, 1):
            tier_color = "magenta" if artifact["Tier"] == "High" else "yellow"
            print(f"{i}. {artifact['Name']} [{artifact['Tier']} Tier] - {artifact['Description']}")
        print("0. Cancel")
        
        while True:
            sell_choice = input("\nSelect artifact: ")
            if sell_choice == '0' or (sell_choice.isdigit() and 1 <= int(sell_choice) <= len(game_state.player_artifacts)):
                break
        
        if sell_choice == '0':
            return
        
        artifact_index = int(sell_choice) - 1
        if 0 <= artifact_index < len(game_state.player_artifacts):
            sold_artifact = game_state.player_artifacts[artifact_index]
            
            # Remove artifact from list
            game_state.player_artifacts.pop(artifact_index)
            
            game_state.player["Gold"] += 50
            print(f"Sold {sold_artifact['Name']} for 50 gold!")
            
            # Recalculate all stats from scratch
            update_all_stats()

def update_all_stats():
    # Store current health/mana percentages to maintain them
    health_percent = game_state.player["Health"] / game_state.player["MaxHealth"] if game_state.player["MaxHealth"] > 0 else 1
    mana_percent = game_state.player["Mana"] / game_state.player["MaxMana"] if game_state.player["MaxMana"] > 0 else 1
    
    # Reset to base stats first
    remove_equipment_stats()
    
    # Reapply equipment stats
    apply_equipment_stats()
    
    # Reapply all artifact stats
    for artifact in game_state.player_artifacts:
        for stat, value in artifact["Stats"].items():
            if stat == "Health":
                game_state.player["MaxHealth"] += value
                # Only add to current health if it would exceed max
                if game_state.player["Health"] == (game_state.player["MaxHealth"] - value):
                    game_state.player["Health"] += value
            elif stat == "Mana":
                game_state.player["MaxMana"] += value
                # Only add to current mana if it would exceed max
                if game_state.player["Mana"] == (game_state.player["MaxMana"] - value):
                    game_state.player["Mana"] += value
            elif stat == "Attack":
                game_state.player["Attack"] += value
            elif stat == "Defense":
                game_state.player["Defense"] += value
            elif stat == "Speed":
                game_state.player["Speed"] += value
            elif stat == "CriticalChance":
                game_state.player["CriticalChance"] += value
            elif stat == "CriticalMultiplier":
                game_state.player["CriticalMultiplier"] += value
    
    # Restore health/mana percentages
    game_state.player["Health"] = round(game_state.player["MaxHealth"] * health_percent)
    game_state.player["Mana"] = round(game_state.player["MaxMana"] * mana_percent)
    
    # Ensure minimum values
    game_state.player["Health"] = max(1, game_state.player["Health"])
    game_state.player["Mana"] = max(0, game_state.player["Mana"])

def show_equipment_shop():
    while True:
        print_color("\n=== EQUIPMENT SHOP ===", "cyan")
        print_color(f"Your gold: {game_state.player['Gold']}", "yellow")
        
        # Display equipment slots
        print_color("\nSelect equipment slot to browse:", "white")
        print("1. Head")
        print("2. Body")
        print("3. Legs")
        print("4. Left Hand")
        print("5. Right Hand")
        print("6. Cloak")
        print("7. Accessory 1")
        print("8. Accessory 2")
        print("0. Back to Main Shop")
        
        slot_choice = input("\nSelect slot: ")
        
        slot_map = {
            '1': 'Head',
            '2': 'Body',
            '3': 'Legs',
            '4': 'LeftHand',
            '5': 'RightHand',
            '6': 'Cloak',
            '7': 'Accessory1',
            '8': 'Accessory2'
        }
        
        if slot_choice == '0':
            return
        
        if slot_choice in slot_map:
            selected_slot = slot_map[slot_choice]
            show_equipment_for_slot(selected_slot)
        else:
            print("Invalid selection!")

def show_equipment_for_slot(slot):
    slot_display_names = {
        "Head": "Head",
        "Body": "Body",
        "Legs": "Legs",
        "LeftHand": "Left Hand",
        "RightHand": "Right Hand",
        "Cloak": "Cloak",
        "Accessory1": "Accessory 1",
        "Accessory2": "Accessory 2"
    }
    
    while True:
        print_color(f"\n=== {slot_display_names[slot]} EQUIPMENT ===", "cyan")
        print_color(f"Your gold: {game_state.player['Gold']}", "yellow")
        
        available_equipment = get_available_equipment_for_slot(slot)
        current_equipment = game_state.player_equipment[slot]
        
        # Show current equipment
        if current_equipment:
            print_color("\nCurrently Equipped:", "green")
            print_color(f"{current_equipment['Name']}", "cyan")
            print(f"  {current_equipment['Description']}")
            show_equipment_stats(current_equipment)
        else:
            print("\nCurrently Equipped: [Empty]")
        
        print("\nAvailable Items:")
        
        if not available_equipment:
            print("No items available for this slot.")
            print("Press any key to return to slot selection...")
            press_any_key()
            return
        
        # Display available items
        for i, equip in enumerate(available_equipment, 1):
            print_color(f"\n{i}. {equip['Name']} - {equip['Cost']} gold", "yellow")
            print(f"   {equip['Description']}")
            show_equipment_stats(equip)
        
        print("\n0. Back to Slot Selection")
        
        choice = input("\nSelect item to purchase: ")
        
        if choice == '0':
            return
        
        if choice.isdigit() and 1 <= int(choice) <= len(available_equipment):
            selected_equipment = available_equipment[int(choice) - 1]
            purchase_equipment(selected_equipment, slot)
        else:
            print("Invalid selection!")

def purchase_equipment(equipment, slot):
    if game_state.player["Gold"] >= equipment["Cost"]:
        # Check if slot is occupied
        current_item = game_state.player_equipment[slot]
        if current_item:
            print(f"\nYou're already wearing {current_item['Name']} in this slot.")
            print(f"Equipping {equipment['Name']} will replace it.")
            confirm = input("Are you sure? (y/n): ")
            if confirm.lower() != 'y':
                return
        
        # Purchase and equip - CREATE A COPY WITH REFINEMENT PROPERTIES
        game_state.player["Gold"] -= equipment["Cost"]
        
        # Create a copy of the equipment with refinement properties
        equipped_item = {
            "Name": equipment["Name"],
            "Slot": equipment["Slot"],
            "Cost": equipment["Cost"],
            "Stats": equipment["Stats"],
            "Description": equipment["Description"],
            "RefinementLevel": 0,
            "IsBroken": False
        }
        
        game_state.player_equipment[slot] = equipped_item
        
        # Reapply all equipment stats
        remove_equipment_stats()
        apply_equipment_stats()
        
        print_color(f"\nYou purchased and equipped {equipment['Name']}!", "green")
        print("Stats updated accordingly.")
        
        # Show updated player stats
        print_color("\nYour updated stats:", "cyan")
        print_color(f"Health: {game_state.player['Health']}/{game_state.player['MaxHealth']}", "green")
        print_color(f"Mana: {game_state.player['Mana']}/{game_state.player['MaxMana']}", "blue")
        print_color(f"Attack: {game_state.player['Attack']}", "darkred")
        print_color(f"Defense: {game_state.player['Defense']}", "darkyellow")
        print_color(f"Speed: {game_state.player['Speed']}", "magenta")
        
        print("\nPress any key to continue...")
        press_any_key()
    else:
        print_color(f"Not enough gold! You need {equipment['Cost']} gold.", "red")
        print("Press any key to continue...")
        press_any_key()

def show_equipment_stats(equipment):
    for stat, value in equipment["Stats"].items():
        color = "green" if value > 0 else "red"
        symbol = "+" if value > 0 else ""
        
        if stat == "Health":
            print_color(f"   {symbol}{value} Health", "green")
        elif stat == "Mana":
            print_color(f"   {symbol}{value} Mana","green")
        elif stat == "Attack":
            print_color(f"   {symbol}{value} Attack", "green")
        elif stat == "Defense":
            print_color(f"   {symbol}{value} Defense", "green")
        elif stat == "Speed":
            print_color(f"   {symbol}{value} Speed", "green")
        elif stat == "CriticalChance":
            print_color(f"   {symbol}{value}% Critical Chance", "green")
        elif stat == "CriticalMultiplier":
            print_color(f"   {symbol}{value} Critical Multiplier", "green")

def start_game():
    show_welcome_screen()
    new_player()
    
    while game_state.game_running and game_state.player["Health"] > 0:
        show_title()
        show_player_stats()
        show_game_menu()
        
        choice = input("\nSelect action: ")
        
        if choice == '1':
            victory = start_combat()
            if victory:
                level_up()
            else:
                if game_state.player["Health"] <= 0:
                    show_game_over_screen()
        elif choice == '2':
            if game_state.player["Gold"] >= 10:
                game_state.player["Gold"] -= 10
                game_state.player["Health"] = game_state.player["MaxHealth"]
                game_state.player["Mana"] = game_state.player["MaxMana"]
                print("You rest and recover all health and mana!")
            else:
                print_color("Not enough gold to rest!", "red")
        elif choice == '3':
            show_player_stats()
        elif choice == '4':
            show_spells()
        elif choice == '5':
            show_equipment()
        elif choice == '6':
            show_artifacts()
        elif choice == '7':
            visit_shop()
        elif choice == '8':
            game_state.current_floor += 1
            print_color(f"You descend to floor {game_state.current_floor}...", "cyan")
            
            is_boss_floor = game_state.current_floor % 3 == 0
            
            if is_boss_floor:
                boss_messages = [
                    "A terrifying roar echoes through the chamber... A boss awaits!",
                    "The very air crackles with power... A formidable foe is near!",
                    "You sense a massive presence watching you... Prepare for battle!",
                    "Ancient runes glow ominously... This floor holds a great challenge!"
                ]
                random_message = random.choice(boss_messages)
                write_typewriter(random_message, "red", 0.04)
                print_color("Boss encounter likely!", "darkred")
            else:
                normal_messages = [
                    "Monsters grow stronger as you descend deeper.",
                    "The dungeon's challenges intensify.",
                    "You venture further into the unknown.",
                    "Deeper you go, where greater dangers await.",
                    "Each floor brings new threats and treasures."
                ]
                random_message = random.choice(normal_messages)
                write_typewriter(random_message, "cyan", 0.03)
        elif choice == '0':
            continue_playing = show_exit_screen()
            if not continue_playing:
                game_state.game_running = False
        else:
            print_color("Invalid choice!", "red")
        
        if game_state.game_running and choice != '1':
            print("\nPress any key to continue...")
            press_any_key()

# Start the game
if __name__ == "__main__":
    try:
        start_game()
    except Exception as e:
        print_color(f"An error occurred: {e}", "red")
        print("Press any key to exit...")
        press_any_key()
    finally:
        print("\nGame session ended.")

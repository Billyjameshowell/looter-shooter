-- Joe's Dialogue System
-- Provides random dialogue lines for Joe the Bartender

local Dialogue = {}

-- Joe's random dialogue lines
Dialogue.joeQuotes = {
    "Welcome back! The bar's always open for a hero.",
    "Heard you survived another wave out there. Impressive!",
    "Want something to take the edge off? My special blend cures what ails ya.",
    "Those monsters out there don't know what hit 'em.",
    "Careful out there. The loot's good but your health's priceless.",
    "I once saw a guy walk into my bar with three guns. Now he's a regular.",
    "The mission exit? Yeah, it leads to certain death. But hey, great loot!",
    "You know what they say... die twice, shame on you. Die a hundred times, that's just Tuesday.",
    "Rest up while you can. Those enemies don't take breaks.",
    "Word of advice: shoot first, ask questions never. Works every time.",
    "Ibartend because I got tired of being the one getting shot at.",
    "That gun vault of yours is looking nicer every day!",
    "Buy a drink, restore some health. What do you say?",
    "The waves are getting tougher. I can tell by the scars you bring in.",
    "Hey, you live to fight another day! That's worth a toast!"
}

-- Drink menu items
Dialogue.drinkMenu = {
    {name = "Health Potion", cost = 0, hpRestore = 25, description = "Restores 25 HP"},
    {name = "Big Brew", cost = 0, hpRestore = 50, description = "Restores 50 HP"},
    {name = "Just Chatting", cost = 0, hpRestore = 0, description = "Have a conversation"},
    {name = "Leave", cost = 0, hpRestore = 0, description = "Close dialogue"}
}

-- Get a random dialogue line
function Dialogue.getRandomQuote()
    local index = math.random(#Dialogue.joeQuotes)
    return Dialogue.joeQuotes[index]
end

-- Get all drink options
function Dialogue.getDrinkMenu()
    return Dialogue.drinkMenu
end

-- Get dialogue box dimensions
function Dialogue.getBoxConfig()
    return {
        width = 500,
        height = 200,
        x = (800 - 500) / 2,  -- Center horizontally (800 is HQ scene width)
        y = 600 - 220,         -- Position near bottom
        padding = 20,
        buttonHeight = 30,
        buttonGap = 10
    }
end

return Dialogue
local COLORS = mahiko_spells.COLORS
local COLORIZE = core.colorize
local ELEMENT_INT = mahiko_spells.intFromCategory("other")
local DEFAULT_SPELL_ICON = "mahiko_spells_element_other.png"

mahiko_spells.registerSimpleSpell("zoltraak", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Zoltraak"),
        "Left-click: launch a large beam of power."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("doragate", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Doragate"),
        "Left-click: launch rocks as bullets."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("nepthear", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Nepthear"),
        "Left-click: summon spears of ice and launch them."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("daosdorg", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Daosdorg"),
        "Left-click: launch a tornado of fire."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("reamstroha", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Reamstroha"),
        "Left-click: launch a large sphere of water."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("volizanbel", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Volizanbel"),
        "Left-click: launch a large blast of fire."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("medrozobait", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Medrozobait"),
        "Left-click: create a large rift in the ground."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("bargland", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Bargland"),
        "Left-click: form a large fissure in the ground."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("digardnacht", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Digardnacht"),
        "Left-click: form a large fissure in the ground."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})
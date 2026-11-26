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

mahiko_spells.registerSimpleSpell("medrozobalt", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Medrozobalt"),
        "Left-click: create a large rift of light."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("digardnacht", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Digardnacht"),
        "Left-click: grow a pair of giant black wings."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("jubelade", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Jubelade"),
        "Left-click: transform flower petals into steel."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("sorganeil", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Sorganeil"),
        "Left-click: completely prevent someone from moving."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})

mahiko_spells.registerSimpleSpell("nebeladora", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.OTHER, "Nebeladora"),
        "Left-click: create a large fog."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
})
local Entity = require("lib.Entity")
local Vector2 = require("lib.Vector2")

local EF = {}

local Class = require("lib.Class")

local ent_classes = {}

ent_classes.ENTITY = require("classes.entities.ENTITY")
ent_classes.HP = require("classes.entities.HP")
ent_classes.CREATURE = require("classes.entities.CREATURE")
ent_classes.GUN = require("classes.entities.GUN")
ent_classes.PLAYER = require("classes.entities.PLAYER")
ent_classes.PROJECTILE = require("classes.entities.PROJECTILE")

local form_classes = {}

local components = {} -- alphabetical

-- components
components.Anim = require("lib.Animation")
components.CC = require("lib.components.physics.CircleCollider")
components.Gizmo = require("lib.components.Gizmo")
components.PC = require("lib.components.physics.PolygonCollider")
components.Sprite = require("lib.components.Sprite")
components.Sat = require("lib.Sat")
components.Shadow = require("lib.components.Shadow")
components.StateMachine = require("lib.components.StateMachine")
components.Transform = require("lib.components.Transform")

-- entity forms

-- player character forms
components.Candy = require("entities.characters.Candy")
components.Cookie = require("entities.characters.Cookie")
components.cc2f7b = require("entities.characters.cc2f7b")
components.Flour = require("entities.characters.Flour")
components.Vase = require("entities.characters.Vase")

-- mob forms
components.Missile = require("entities.mobs.Missile")
components.PlantZombie = require("entities.mobs.PlantZombie")
components.Mom1 = require("entities.mobs.Mom1")
components.Mom2 = require("entities.mobs.Mom2")

-- gun forms
components.Uzi = require("entities.guns.Uzi")
-- components.Revolver = require("entities.guns.Revolver") -- doesn't exist yet
components.PumpAction = require("entities.guns.PumpAction")
components.Ak47 = require("entities.guns.Ak47")
components.M16 = require("entities.guns.M16")
components.MagnumRevolver = require("entities.guns.MagnumRevolver")
components.PopGun = require("entities.guns.PopGun")
components.RustyPeacekeeper = require("entities.guns.RustyPeacekeeper")

-- projectile forms
components.MediumBullet = require("entities.projectiles.MediumBullet")

-- atlases, alphbetical
local atlases = {}

-- player character atlases
atlases.Candy = love.graphics.newImage("assets/gfx/Characters/candy.png")
atlases.cc2f7b = love.graphics.newImage("assets/gfx/Characters/cc2f7b.png")
atlases.Cookie = love.graphics.newImage("assets/gfx/Characters/Cookie.png")
atlases.Flour = love.graphics.newImage("assets/gfx/Characters/Flour.png")
atlases.Vase = love.graphics.newImage("assets/gfx/Characters/Vase.png")

-- mob atlases
atlases.Missile = love.graphics.newImage("assets/gfx/missile.png")
atlases.PlantZombie = love.graphics.newImage("assets/gfx/grfxkid/dungeon_set/plant_zombie_sheet.png")
atlases.Mom1 = love.graphics.newImage("mom1.png")
atlases.Mom2 = love.graphics.newImage("mom2.png")

-- gun atlases
atlases.Revolver = love.graphics.newImage("assets/gfx/Weapons/Guns/Revolver.png")
atlases.Uzi = love.graphics.newImage("assets/gfx/Weapons/Guns/Uzi.png")
atlases.PumpAction = love.graphics.newImage("assets/gfx/Weapons/Guns/PumpAction.png")
atlases.Ak47 = love.graphics.newImage("assets/gfx/Weapons/Guns/Ak47.png")
atlases.M16 = love.graphics.newImage("assets/gfx/Weapons/Guns/M16.png")
atlases.PopGun = love.graphics.newImage("assets/gfx/Weapons/Guns/PopGun.png")
atlases.MagnumRevolver = love.graphics.newImage("assets/gfx/Weapons/Guns/MagnumRevolver.png")
atlases.RustyPeacekeeper = love.graphics.newImage("assets/gfx/Weapons/Guns/RustyPeacekeeper.png")

-- projectile atlases
atlases.MediumBullet = love.graphics.newImage("assets/gfx/Weapons/Guns/MediumBullet.png")

-- runs run()
_G.events:add("EF")
_G.events:hook("EF", function(tbl)
	EF:run(tbl)
end)

-- runs the :spawn() on the ent_name given on the form component
_G.events:add("EF_spawn")
_G.events:hook("EF_spawn", function(ent_name, ...)
	components[ent_name]:spawn(...)
end)

function EF:run(arg)
	-- chooses class to base entity core on
	local ent
	if arg.ent_class then
		ent = ent_classes[arg.ent_class]()
	else
		ent = Entity()
	end

	for i = 1, #arg do
		local L = nil
		if type(arg[i]) == "table" then
			-- same thing here, specific removes and unpack() -- all this needs to be condensed into one table
			L = table.remove(arg[i], 1) -- L for label
			local component = components[L](unpack(arg[i]))
			-- .type property needed on components for naming on Entity
			ent:add(component)
		elseif type(arg[i]) == "string" then
			L = arg[i]
			-- .type property needed on components for naming on Entity
			ent:add(components[L]())
		end
		--add sprite here
		if L and components[L].create_sprite then
			-- errors resulting from this line = components table and atlases table omissions, probably
			local Sprite = components[L].create_sprite(atlases[L])
			ent:add(Sprite)
		end
	end

	-- add Gizmo to every entity if enabled
	if IsGizmoOn then
		ent:add(components["Gizmo"]())
	end

	ent:on_start() -- start it for initialization stuff

	_G.events:invoke("add to em", ent)

	return ent -- will this return values to the calling scope?
end

return EF


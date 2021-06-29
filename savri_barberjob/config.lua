Config = {}
Config.Price = 0
Config.DrawDistance = 15.0
Config.MarkerSize = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor = {r = 102, g = 102, b = 204}
Config.MarkerType = 27
Config.Locale = 'fr'
Config.Zones = {}

Config.Shops = {
	{x = -814.308, y = -183.823, z = 36.668},
	{x = 139.183, y = -1709.082, z = 28.391},
	{x = -1282.604, y = -1116.757, z = 6.00}
}

Config.Chests = {
	vector3(-808.434, -179.627, 36.569),
	vector3(141.424, -1705.845, 28.391),
	vector3(-1278.210, -1119.233, 6.00)
}

for i=1, #Config.Shops, 1 do
	Config.Zones['Shop_' .. i] = {
		Pos = Config.Shops[i],
		Size = Config.MarkerSize,
		Color = Config.MarkerColor,
		Type = Config.MarkerType
	}
end

Shop = {
    Scissors = {
        Model = GetHashKey("p_cs_scissors_s"),
        Location = vector3(0.0, 0.0, 0.0)
    },
}

Default = {
    EnableDebug = false, -- This will enable debug mode and will print things in F8

    MenuAlignment = "left",

    AnimDict = "misshair_shop@hair_dressers"
}
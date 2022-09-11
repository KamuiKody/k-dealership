Config = {}

Config.Blips = true -- if true blips will display for purchased dealers if false no blips will display (feature setup by LlamaPalooza#7852!)
Config.BlipLocations = { -- Set the blip locations here for each dealership
    --{title = "Vehicle Imports", colour = 4, id = 523, x = 765.09, y = -3208.21, z = 6.03}, -- Don't change this unless you change Config.CarSpawn locations!
    {title = "Benefactor", colour = 2, id = 523, x = -69.3, y = 62.95, z = 71.89}
} 

Config.Target = false
Config.mojia = false
Config.Fuel = 'LegacyFuel'

--[[ when adding a new dealer must make an sql file as well with the following layout
    INSERT INTO `dealerships` (`citizenid`, `dealername`, `funds`, `purchased`) VALUES (NULL, 'Benefactor', '0',false)
]]
Config.Dealerships = {
    ['Benefactor'] = { -- make this match the name it just works better this way
        name = 'Benefactor',
        price = 500000,
        buylocation = vector3(-69.3, 62.95, 71.89),
        menu = vector3(-53.89, 73.97, 71.89),
        interiorspawn = vector3(-65.72, 81.53, 71.55),-- can be same as exterior spawn if there is nowhere inside
        interiorheading = 244.51,
        exteriorspawn = vector3(-65.72, 81.53, 71.55),
        exteriorheading = 64.51,
        storage = vector3(-65.86, 81.58, 71.55),
        center = vector3(-70.98, 77.61, 71.61), -- center of the lot used to keep from placing vehicles too far from the lot
        ["purchased"] = false
    },    
}


RegisterNetEvent('k-dealership:changeshopstate', function(name)---DO NOT CHANG THIS EVENT OR ULL BE IN MY INBOX FOR SUPPORT XD
    Config.Dealerships[name]["purchased"] = true
end)

Config.Shops = {
    ['Categories'] = { -- Categories available to browse
        ['sportsclassics'] = 'sportsclassics',
        ['import'] = 'import',
        ['coupes'] = 'coupes',
        ['suvs'] = 'suvs',
        ['offroad'] = 'offroad',
        ['muscle'] = 'muscle',
        ['compacts'] = 'compacts',
        ['motorcycles'] = 'motorcycles',
        ['vans'] = 'vans',
        ['super'] = 'super',
        ['sports'] = 'sports'
    }
}

Config.CarSpawn = {
        {coords = vec3(874.475403, -2054.819824, 30.058064), heading = 175.27778625488},
        {coords = vec3(919.283386, -2152.074951, 29.982906), heading = 179.84938049316},
        {coords = vec3(883.978455, -2236.926270, 30.125431), heading = 353.48468017578},
        {coords = vec3(805.301147, -2226.209229, 29.210808), heading = 150.2370300293},
        {coords = vec3(770.238159, -2327.018799, 25.590919), heading = 355.16061401367},
        {coords = vec3(827.704834, -2119.446289, 28.956724), heading = 352.23260498047},
        {coords = vec3(837.906555, -1804.795776, 28.638887), heading = 354.71508789062},
        {coords = vec3(855.304077, -1583.609497, 30.638309), heading = 11.90945148468},
        {coords = vec3(955.205017, -1449.828369, 30.676065), heading = 265.57629394531},
        {coords = vec3(1157.573486, -1477.500244, 34.313255), heading = 271.15753173828},
        {coords = vec3(1149.118774, -987.120544, 45.359497), heading = 183.50849914551},
        {coords = vec3(937.220032, -990.590149, 37.980316), heading = 92.756286621094},
        {coords = vec3(-13.639869, -738.832336, 43.757362), heading = 70.903282165527},
        {coords = vec3(-256.255005, -755.493408, 32.290485), heading = 158.94142150879},
        {coords = vec3(-319.185059, -753.940735, 52.865677), heading = 338.77502441406},
        {coords = vec3(-578.589722, -384.782532, 34.540924), heading = 272.39389038086},
        {coords = vec3(-519.900818, -264.471436, 34.953945), heading = 111.35218048096},
        {coords = vec3(-531.569214, -33.275074, 44.133018), heading = 176.54475402832},
        {coords = vec3(1.874170, -148.811630, 55.909004), heading = 2.4608762264252},
        {coords = vec3(235.828156, -370.375427, 43.846329), heading = 249.77178955078},
        {coords = vec3(894.989685, -52.110512, 78.383148), heading = 56.029094696045},
        {coords = vec3(599.538269, 102.187729, 92.525299), heading = 68.989639282227},
        {coords = vec3(457.183838, 257.197479, 102.827911), heading = 70.995712280273},
        {coords = vec3(106.385048, 318.114105, 111.729881), heading = 164.25820922852},
        {coords = vec3(-201.895584, 409.761688, 110.145683), heading = 187.30302429199},
        {coords = vec3(-352.790314, 475.724945, 112.406677), heading = 99.033241271973},
        {coords = vec3(-408.949463, 559.767273, 123.943352), heading = 334.80426025391},
        {coords = vec3(-483.061127, 548.819153, 119.551987), heading = 155.51902770996},
        {coords = vec3(-577.175781, 497.865692, 105.951698), heading = 190.91799926758},
        {coords = vec3(-1109.707764, 795.984070, 164.931076), heading = 4.4619402885437},
        {coords = vec3(-1020.340271, 693.859436, 160.894562), heading = 180.0753326416},
        {coords = vec3(-707.132202, 652.762146, 154.794662), heading = 167.86824035645},
        {coords = vec3(-667.750427, 670.737244, 150.064224), heading = 258.0166015625},
        {coords = vec3(1574.730591, 3633.542725, 34.912216), heading = 29.354362487793},
        {coords = vec3(1783.390625, 3757.725098, 33.274326), heading = 21.022678375244},
        {coords = vec3(1713.312134, 3777.068604, 34.106121), heading = 38.424613952637},
        {coords = vec3(1668.477783, 3833.841553, 34.521732), heading = 43.457736968994},
        {coords = vec3(1824.641113, 3873.149658, 33.337330), heading = 201.26377868652},
        {coords = vec3(1838.306641, 3899.266113, 32.953144), heading = 18.109794616699},
        {coords = vec3(1941.397827, 3901.028320, 31.897278), heading = 209.99194335938},
        {coords = vec3(1956.330322, 3844.300537, 31.628366), heading = 123.36110687256},
        {coords = vec3(2001.421509, 3769.454346, 31.799669), heading = 120.73233032227},
        {coords = vec3(2462.677490, 4050.543945, 37.186340), heading = 337.19934082031},
        {coords = vec3(2514.981201, 4220.413574, 39.529598), heading = 59.487377166748},
        {coords = vec3(2112.655029, 4769.799316, 40.790825), heading = 297.12219238281},
        {coords = vec3(2020.358276, 4975.642578, 40.854153), heading = 44.832366943359},
        {coords = vec3(1701.123779, 4947.446777, 42.229649), heading = 307.15093994141},
        {coords = vec3(1677.659912, 4888.124023, 41.673450), heading = 268.81689453125},
        {coords = vec3(1661.389282, 4850.240234, 41.463528), heading = 188.94943237305},
        {coords = vec3(1670.942261, 4751.602051, 41.493523), heading = 104.98779296875},
        {coords = vec3(1690.661499, 4774.413086, 41.540447), heading = 90.023963928223},
        {coords = vec3(1724.266479, 4630.737793, 42.850597), heading = 298.75811767578},
        {coords = vec3(1784.549927, 4584.395508, 37.117916), heading = 7.2457947731018},
        {coords = vec3(424.375916, 6523.549805, 27.322767), heading = 175.94703674316},
        {coords = vec3(63.584835, 6377.790039, 30.859179), heading = 211.6919708252},
        {coords = vec3(-136.033249, 6279.104004, 30.967766), heading = 47.622501373291},
        {coords = vec3(-152.604538, 6358.912598, 31.111982), heading = 43.363212585449},
        {coords = vec3(-93.367119, 6423.568848, 31.094280), heading = 314.39804077148},
        {coords = vec3(-125.512993, 6454.695801, 31.079048), heading = 130.26977539062},
        {coords = vec3(-176.925034, 6442.374512, 31.108559), heading = 225.17175292969},
        {coords = vec3(-220.044510, 6431.958984, 30.817690), heading = 47.100311279297},
        {coords = vec3(-223.792770, 6387.317383, 31.218140), heading = 43.316108703613},
        {coords = vec3(-250.544861, 6407.665039, 30.774837), heading = 41.261196136475},
        {coords = vec3(-255.038162, 6360.312012, 31.100174), heading = 224.63748168945},
        {coords = vec3(-315.836456, 6313.411133, 31.888029), heading = 225.32542419434},
        {coords = vec3(-353.001190, 6335.701172, 29.470644), heading = 45.144416809082},
        {coords = vec3(-338.801453, 6246.223145, 31.112741), heading = 136.27172851562},
        {coords = vec3(-347.729462, 6214.838867, 31.107910), heading = 45.114711761475},
        {coords = vec3(-378.237732, 6183.902344, 31.110792), heading = 47.754096984863},
        {coords = vec3(-351.247162, 6150.440430, 31.098238), heading = 134.77537536621},
        {coords = vec3(-411.663269, 6173.113281, 31.097357), heading = 350.81469726562},
        {coords = vec3(-431.160889, 6264.943359, 29.954264), heading = 67.134521484375},
        {coords = vec3(-384.639832, 6270.455566, 30.127350), heading = 231.61666870117},
        {coords = vec3(-391.868744, 6306.571289, 29.028719), heading = 40.712451934814},
        {coords = vec3(-386.131561, 6076.632812, 31.122814), heading = 307.43490600586},
        {coords = vec3(-312.154419, 6095.776855, 31.099512), heading = 224.52746582031},
        {coords = vec3(-759.307007, 5548.188477, 33.106659), heading = 1.5957970619202},
        {coords = vec3(387.979309, -1153.313232, 28.911030), heading = 178.86639404297},
        {coords = vec3(306.736237, -1081.431396, 28.985823), heading = 300.58764648438},
        {coords = vec3(252.539627, -992.935913, 28.758015), heading = 340.66625976562},
        {coords = vec3(391.854584, -767.351562, 28.909920), heading = 4.4275026321411},
        {coords = vec3(501.229279, -720.005737, 24.363285), heading = 177.27311706543},
        {coords = vec3(471.892578, -1105.798096, 28.819700), heading = 271.54415893555}
}

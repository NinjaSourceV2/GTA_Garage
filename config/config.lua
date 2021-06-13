Config = {
    vehicles_list_menu = {}, --> Tableau qui contient la liste des véhicule du joueurs.
    getEmplacement = 0,
    Locations = {
        [1] = {
            ["GarageEntrer"] = {
                ["x"] = 215.124, ["y"] = -791.377, ["z"] = 29.936, ["h"] = 0.0,
                ["AfficherBlip"] = true,
                ["NomZone"] = "Garage centrale",
                ["MaxVeh"] = 4 --> Garage avec 4 Place.
            },
        },

        [2] = {
            ["GarageEntrer"] = {
                ["x"] = 2061.7312011719, ["y"] = 3439.1110839844, ["z"] = 43.962757110596-1, ["h"] = 0.0,
                ["AfficherBlip"] = true,
                ["NomZone"] = "Garage nord",
                ["MaxVeh"] = 3 --> Garage avec 3 Place.
            },
        },

        [3] = {
            ["GarageEntrer"] = {
                ["x"] = -462.576, ["y"] = -619.159, ["z"] = 31.2744-1, ["h"] = 0.0,
                ["AfficherBlip"] = true,
                ["NomZone"] = "Garage city",
                ["MaxVeh"] = 3 --> Garage avec 3 Place.
            },
        },
    },

    pos_receler = { --> position revente de véhicule (receler).
        [1] = {
            ["Receler"] = {
                ["x"] = 261.49, ["y"] = -1156.5, ["z"] = 29.26, ["h"] = 0.0,
                ["AfficherBlip"] = true,
                ["NomZone"] = "Receler de véhicule"
            },
        },
    },
}
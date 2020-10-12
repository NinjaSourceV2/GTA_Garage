-- Export de la structure de la table gta_serveur. gta_joueurs_vehicle
DROP TABLE IF EXISTS `gta_joueurs_vehicle`;
CREATE TABLE IF NOT EXISTS `gta_joueurs_vehicle` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `vehicle_name` varchar(60) COLLATE utf8mb4_bin DEFAULT 'Véhicule',
  `vehicle_model` int(255) DEFAULT NULL,
  `vehicle_plate` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL,
  `vehicle_state` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL,
  `vehicle_colorprimary` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL,
  `vehicle_colorsecondary` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL,
  `vehicle_pearlescentcolor` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `vehicle_wheelcolor` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `zone_garage` varchar(155) COLLATE utf8mb4_bin DEFAULT 'Aucun',
  `proprietaire` varchar(155) COLLATE utf8mb4_bin DEFAULT 'Volé',
  `prix` int(255) DEFAULT 0,
  KEY `ID` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
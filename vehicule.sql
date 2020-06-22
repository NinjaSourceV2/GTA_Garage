-- Listage de la structure de la table gta_serveur. gta_joueurs_vehicle
DROP TABLE IF EXISTS `gta_joueurs_vehicle`;
CREATE TABLE IF NOT EXISTS `gta_joueurs_vehicle` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `vehicle_name` varchar(60) DEFAULT NULL,
  `vehicle_model` varchar(60) DEFAULT NULL,
  `vehicle_plate` varchar(60) DEFAULT NULL,
  `vehicle_state` varchar(60) DEFAULT NULL,
  `vehicle_colorprimary` varchar(60) DEFAULT NULL,
  `vehicle_colorsecondary` varchar(60) DEFAULT NULL,
  `vehicle_pearlescentcolor` varchar(60) NOT NULL,
  `vehicle_wheelcolor` varchar(60) NOT NULL,
  KEY `ID` (`ID`)
)

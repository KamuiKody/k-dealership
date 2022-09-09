CREATE TABLE `dealerships` (
    `citizenid` text  NULL,
  `dealername` text  NOT NULL,
  `funds` text  NOT NULL,
  `purchased` text NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `dealership_cars` (
    `citizenid` text  NOT NULL,
  `vehicleplate` text  NOT NULL,
  `vehicleprops` longtext  NOT NULL,
  `hash` text NOT NULL,
  `entityid` text NULL,
  `dealername` text  NOT NULL,
  `x` text  NULL,
  `y` text  NULL,
  `z` text  NULL,
  `w` text  NULL,
  `price` text  NULL,
  `fuel` longtext NOT NULL,
  `bodydamage` longtext NOT NULL,
  `enginedamage` longtext NOT NULL,
  `state` text NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `dealerships` (`citizenid`, `dealername`, `funds`, `purchased`) VALUES (NULL, 'Benefactor', '0', false)

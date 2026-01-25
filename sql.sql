CREATE TABLE IF NOT EXISTS `territories` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `gang` VARCHAR(50) NOT NULL,
    `influence` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Only for ESX

INSERT INTO `jobs` (name, label,type,whitelisted) VALUES
	('tga', 'TGA','gang',0),
	('srra', 'SRRA','gang',0),
	('kva', 'KVA','gang',0)
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('tva', 0, 'employee', 'Employee', 0, '{}', '{}'),
	('kva', 0, 'employee', 'Employee', 0, '{}', '{}'),
	('srra', 0, 'employee', 'Employee', 0, '{}', '{}'),
	('tga', 0, 'employee', 'Employee', 0, '{}', '{}')
;
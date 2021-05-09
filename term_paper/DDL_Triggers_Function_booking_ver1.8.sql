 -- Для курсового проекта выбрана модель хранения данных веб-сайта booking.com

DROP DATABASE IF EXISTS term_paper_booking;
CREATE DATABASE term_paper_booking;
USE term_paper_booking;


-- Создаём таблицу отелей
DROP TABLE IF EXISTS `hotels`;
CREATE TABLE `hotels` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор строки(первичный ключ)',
  `title` varchar(255) NOT NULL COMMENT 'Название отеля',
  `gps_x` float DEFAULT NULL COMMENT 'координаты местонахождения 1',
  `gps_y` float DEFAULT NULL COMMENT 'координаты местонахождения 2',
  `stars` enum('1','2','3','4','5') DEFAULT NULL COMMENT 'Количество звёзд',
  `rates_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Число отзывов',
  `rates_summary` int UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Сумма оценок по отзывам',
  PRIMARY KEY (`id`)
) COMMENT "Отели";


-- Создаём таблицу доступных услуг в гостинице и номерах
DROP TABLE IF EXISTS `services`;
CREATE TABLE `services` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор строки(первичный ключ)',
  `rubric` enum('Питание','Оборудование в номере','Услуги ресепшена','Фитнес и развлечения','Услуги в номере') DEFAULT NULL COMMENT 'Рубрики(разделы) услуг',
  `title` varchar(255) NOT NULL COMMENT 'Услуги',
  PRIMARY KEY (`id`)
) COMMENT='Таблица услуг в гостинице и номерах';


 -- Создаем таблицу связи отелей и сервисов
DROP TABLE IF EXISTS `hotels_services`;
CREATE TABLE `hotels_services` (
  `hotel_id` int UNSIGNED NOT NULL COMMENT "Ссылка на отель",
  `service_id` int UNSIGNED NOT NULL COMMENT "Ссылка на сервис",
  PRIMARY KEY (`hotel_id`),
  INDEX `hotels2services_service`(`service_id`),
  CONSTRAINT `hotels2services_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `hotels2services_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) COMMENT "Таблица связи отелей и сервисов";


 -- Создаём таблицу номеров
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор строки",
  `hotel_id` int UNSIGNED NOT NULL COMMENT "Ссылка на отель",
  `title` varchar(255) DEFAULT NULL COMMENT "характеристика комнаты (люкс, полулюкс и т.д.)",
  `area` int UNSIGNED DEFAULT NULL COMMENT 'Площадь номера',
  `floor` tinyint UNSIGNED DEFAULT NULL COMMENT 'Этаж',
  `rates_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество отзывов',
  `rates_summary` int UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Суммарный рейтинг',
  PRIMARY KEY (`id`),
  INDEX `hotel`(`hotel_id`),
  CONSTRAINT `hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) COMMENT='Таблица номеров';


-- Таблица стоимости номера по датам
DROP TABLE IF EXISTS `rooms_price`;
CREATE TABLE `rooms_price` (
  `room_id` int UNSIGNED NOT NULL COMMENT "Ссылка на номер",
  `date` date NOT NULL COMMENT "Дата для фиксации стоимости",
  `price` numeric(10,2) DEFAULT 0 COMMENT "Стоимость",
  PRIMARY KEY (`room_id`,`date`),
  CONSTRAINT `room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) COMMENT "Стоимость номера по датам";


 -- Создаем таблицу связи сервисов и номеров
DROP TABLE IF EXISTS `rooms_services`;
CREATE TABLE `rooms_services` (
  `service_id` int UNSIGNED NOT NULL COMMENT "Ссылка на сервис",
  `room_id` int UNSIGNED NOT NULL COMMENT "Ссылка на номер",
  PRIMARY KEY (`service_id`,`room_id`),
  INDEX `room2service_room`(`room_id`),
  CONSTRAINT `room2service_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `room2service_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) COMMENT "Таблица связи сервисов и номеров";


-- Создаём таблицу пользователей
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор строки",
  `title` varchar(255) DEFAULT NULL COMMENT "ФИО",
  `birthdate` datetime DEFAULT NULL COMMENT "Дата рождения",
  `gender` enum('мальчик','девочка','эльф') NOT NULL COMMENT "Пол",
  `email` varchar(255) DEFAULT NULL COMMENT "Почта",
  `phone` varchar(20) DEFAULT NULL COMMENT "Телефон",
  PRIMARY KEY (`id`)
) COMMENT "Пользователи";


-- Таблица выставления счета клиенту
DROP TABLE IF EXISTS `users_bills`;
CREATE TABLE `users_bills` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор строки",
  `user_id` int UNSIGNED NOT NULL COMMENT "Ссылка на пользователя",
  `room_id` int UNSIGNED NOT NULL COMMENT "Ссылка на команту",
  `date_in` date NOT NULL COMMENT "Дата заезда",
  `date_out` date NOT NULL COMMENT "Дата отъезда",
  `price` numeric(10,2) DEFAULT 0.00 COMMENT "Цена, формируемая триггером `users_bills_BI`",
  `has_billed` tinyint(1) DEFAULT 0 COMMENT "Факт оплаты",
  `date_created` datetime DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания счёта",
  `date_billed` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT "Время последнего обновления",
  PRIMARY KEY (`id`),
  UNIQUE INDEX `bills_uniq`(`user_id`, `room_id`, `date_in`) COMMENT 'Ограничение уникальности счетов относительно юзера, номера, и даты заезда',
  INDEX `non_billed_by_room_and_dates`(`room_id`, `date_in`, `date_out`, `has_billed`) COMMENT 'Индекс для оптимизации запроса в триггере `rooms_price_AU`',
  CONSTRAINT `bills2rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `bills2users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) COMMENT "Таблица выставления счета клиенту";


-- Создаем таблицу отзывов
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор строки",
  `user_id` int UNSIGNED NOT NULL COMMENT "Ссылка на пользователя",
  `room_id` int UNSIGNED NOT NULL COMMENT "Ссылка на комнату",
  `body` longtext NULL COMMENT "Текст отзыва",
  `rate` tinyint(1) DEFAULT NULL COMMENT "Рейтинг",
  `date_created` datetime DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания отзыва",
  `date_updated` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления отзыва",
  PRIMARY KEY (`id`),
  INDEX `comments2users_fk`(`user_id`),
  INDEX `comments2rooms_fk`(`room_id`),
  CONSTRAINT `comments2rooms_fk` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `comments2users_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
)  COMMENT "Отзывы";


-- Таблица медиафайлов
DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор строки",
  `path` varchar(255) DEFAULT NULL COMMENT "Путь к файлу",
  `metadata` json DEFAULT NULL COMMENT "Метаданные файла",
  `user_id` int UNSIGNED NOT NULL COMMENT "Ссылка на пользователя, который загрузил файл",
  `date_created` datetime DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `date_updated` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  PRIMARY KEY (`id`),
  CONSTRAINT `media2users_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) COMMENT "Медиафайлы";


-- Таблица связи медиафайлов
-- Уточнение: поскольку не знаем к чему будет относиться медиа(фото отеля для портфолио, фото посетителя, фото в комментариях) использованы "сущности"
DROP TABLE IF EXISTS `media_links`;
CREATE TABLE `media_links` (
  `media_id` int UNSIGNED NOT NULL COMMENT "Ссылка на файл",
  `entity_id` int NOT NULL COMMENT "Ссылка на иеднтификатор сущности",
  `entity_type` enum('user','comment','room','hotel') NOT NULL COMMENT "Данные к какой сущности относится медиафайл",
  `actor_id` int UNSIGNED NOT NULL COMMENT "Cсылка на создателя связи медиа и сущности",
  `date_created` datetime DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания",
  PRIMARY KEY (`media_id`, `entity_id`, `entity_type`),
  INDEX `media_links2actor_fk`(`actor_id`),
  INDEX `media_entity`(`entity_id`, `entity_type`),
  CONSTRAINT `media_links2actor_fk` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `media_links2media_fk` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) COMMENT "Таблица связи медиафайлов";




DROP TRIGGER IF EXISTS `comments_AI`;
DROP TRIGGER IF EXISTS `comments_AU`;
DROP TRIGGER IF EXISTS `comments_AD`;
DROP TRIGGER IF EXISTS `hotels_AD`;
DROP TRIGGER IF EXISTS `rooms_AU`;
DROP TRIGGER IF EXISTS `rooms_AD`;
DROP TRIGGER IF EXISTS `rooms_price_AU`;
DROP TRIGGER IF EXISTS `users_AD`;
DROP TRIGGER IF EXISTS `users_bills_BI`;
DROP TRIGGER IF EXISTS `users_bills_BU`;
DROP FUNCTION IF EXISTS `room_costs_by_dates`;

-- -------------------------
-- Функции
-- -------------------------

/* Поскольку было поставленно условие использование процедуры или функции в курсовом проекте, создаем функцию для получения суммарной цены за весь период пребывания в номере и далее используем её в триггерах для таблицы `users_bills`
*/
DELIMITER ;;
CREATE FUNCTION `room_costs_by_dates`(room_id int UNSIGNED, date_start date, date_end date)
 RETURNS numeric
  DETERMINISTIC
BEGIN
		RETURN (
				SELECT SUM( `price` ) FROM `rooms_price` WHERE `room_id` = room_id AND `date` >= date_start AND `date` <= date_end
		);
END;
;;
DELIMITER ;
-- ------------------------
-- Триггеры
-- ------------------------
DELIMITER ;;
/* создаем триггер, который после удаления записи так же удалит связанные с ним записи в таблице `media_links` (поскольку не знаем заранее к чему будет относится медиафайл, то таблицу ссылок на медиа реализовал через сущности) 
*/
CREATE TRIGGER `hotels_AD` AFTER DELETE ON `hotels` FOR EACH ROW BEGIN
		DELETE FROM `media_links` WHERE `entity_id` = OLD.`id` AND `entity_type` = 'hotel';
END;
;;
DELIMITER ;

DELIMITER ;;
/* Для таблицы `rooms` создаем триггер на удаления данных:
   - +++ первая часть после удаления записи в таблице `rooms` изменит количество отзывов и суммарный рейтинг, отняв проставленный в удаленном отзыве рейтинг
   
   - вторая часть после удаления записи комнаты в таблице `rooms` так же удалит связанные с ней записи в таблице `media_links` (поскольку не знаем заранее к чему будет относится медиафайл, то таблицу ссылок на медиа реализовал через сущности) 

   - для соблюдения консистентности данных следовало бы что-то сделать со счетами, возможно комнаты надо переносить в "архивные комнаты" с сохранением ID без дальнейшнего права редактирования
*/
CREATE TRIGGER `rooms_AD` AFTER DELETE ON `rooms` FOR EACH ROW BEGIN	
		/* обновление рейтинга гостиницы после удаления номера */
		IF ( OLD.rates_count > 0 ) THEN
				UPDATE `hotels` SET `rates_count` = `rates_count` - OLD.rates_count, `rates_summary` = `rates_summary` - OLD.`rates_summary`
				WHERE `id` = OLD.`hotel_id`;
		END IF;
		/* удаление лишних связей */
		DELETE FROM `media_links` WHERE `entity_id` = OLD.`id` AND `entity_type` = 'room';
    /* удаление теперь осиротевших коментариев */
    DELETE FROM `comments` WHERE `room_id` = OLD.`id`;
END;
;;
DELIMITER ;
/* Создаем триггер для обновления данных:
после обновления записи в таблице `rooms` изменит количество отзывов и суммарный рейтинг, отняв проставленный в удаленном отзыве рейтинг и прибавив новый 
*/
DELIMITER ;;
CREATE TRIGGER `rooms_AU` AFTER UPDATE ON `rooms` FOR EACH ROW BEGIN	
		IF ( NEW.`rates_count` != OLD.rates_count OR NEW.`rates_summary` != OLD.`rates_summary` ) THEN
				UPDATE `hotels` SET `rates_count` = `rates_count` - OLD.rates_count + NEW.rates_count, `rates_summary` = `rates_summary` - OLD.`rates_summary` + NEW.`rates_summary`
				WHERE `id` = NEW.`hotel_id`;
		END IF;
END;
;;
DELIMITER ;
/* Для таблицы стоимости номера `rooms_price` создаем триггер, который для всех ещё неоплаченных счетов пересчитывает итоговую цену в таблицу выставления счетов `users_bills`, цена которых обновилась.
Можно сделать через UPDATE, но для иллюстрации работы курсора использовал такой вариант. 
*/
DELIMITER ;;
CREATE TRIGGER `rooms_price_AU` AFTER UPDATE ON `rooms_price` FOR EACH ROW BEGIN
		DECLARE done INT DEFAULT FALSE;
		DECLARE bill_id INTEGER;
		DECLARE cur CURSOR FOR SELECT `id` FROM `users_bills` WHERE `room_id` = NEW.`room_id` AND `date_in` <= NEW.`date` AND `date_out` >= NEW.`date` AND NOT `has_billed`;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
		
		IF ( OLD.`price` != NEW.`price` ) THEN
				OPEN cur;
						read_loop: LOOP
								FETCH cur INTO bill_id;
								IF done THEN
										LEAVE read_loop;
								END IF;
								UPDATE `users_bills` SET `price` = `price` - OLD.`price` + NEW.`price` WHERE `id` = bill_id;
						END LOOP;
				CLOSE cur;
		END IF;
 END;
;;
DELIMITER ;
/* Создаем триггер, который после удаления записи пользователя в таблице `users` так же удалит связанные с ним записи в таблице `media_links`
*/
DELIMITER ;;
CREATE TRIGGER `users_AD` AFTER DELETE ON `users` FOR EACH ROW BEGIN
    DELETE FROM `media_links` WHERE `entity_id` = OLD.`id` AND `entity_type` = 'user';
    /*дальнейшие удаления только с целью сохранения консистентности, наверное это надо делать как-то не так, но вообще это уже другой уровень логики проекта должен быть*/
    DELETE FROM `media_links` WHERE `actor_id` = OLD.`id`;
    DELETE FROM `comments` WHERE `user_id` = OLD.`id`;
END;
;;
DELIMITER ;
-- Создаем триггер для автоматического подсчёта итоговой цены в выставленном клиенту счете (по комнате и датам заездf)
DELIMITER ;;
CREATE TRIGGER `users_bills_BI` BEFORE INSERT ON `users_bills` FOR EACH ROW BEGIN
		SET NEW.`price` = room_costs_by_dates( NEW.`room_id`, NEW.`date_in`, NEW.`date_out` );
END;
;;
DELIMITER ;
-- Дополнение предыдущего триггера подсчета цены заранее для блокировки изменения итоговой цены со стороны
DELIMITER ;;
CREATE TRIGGER `users_bills_BU` BEFORE UPDATE ON `users_bills` FOR EACH ROW BEGIN
    IF ( NEW.`price` != OLD.`PRICE` ) THEN
		    SET NEW.`price` = room_costs_by_dates( NEW.`room_id`, NEW.`date_in`, NEW.`date_out` );
    END IF;
END;
;;
DELIMITER ;
/* Создаем триггер, который при добавлении записи увеличивает счетчик отзывов и добавляет значение в рейтинг */
DELIMITER ;;
CREATE TRIGGER `comments_AI` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
		UPDATE `rooms` SET `rates_count` = `rates_count` + 1, `rates_summary` = `rates_summary` + NEW.`rate` 
		WHERE `id` = NEW.`room_id`;
END;
;;
DELIMITER ;
/* Создаем триггер, который при обновления записи проверяет условия неравенства нового и старого ретинга, и в случае неравенства вычитает старый и добавляет новый */
DELIMITER ;;
CREATE TRIGGER `comments_AU` AFTER UPDATE ON `comments` FOR EACH ROW BEGIN
		IF ( OLD.`rate` != NEW.`rate` ) THEN
				UPDATE `rooms` SET `rates_summary` = `rates_summary` - OLD.`rate` + NEW.`rate` 
				WHERE `id` = NEW.`room_id`;
		END IF;
END;
;;
DELIMITER ;
/* Создаем триггер для удаления данных:
   - первая часть росле удаления записи уменьшает счетчик отзывов и отнимает значение в рейтинг
   
   - вторая часть после удаления записи отзыва в таблице `comments` так же удалит связанные с ней записи в таблице `media_links` 
*/
DELIMITER ;;
CREATE TRIGGER `comments_AD` AFTER DELETE ON `comments` FOR EACH ROW BEGIN
		UPDATE `rooms` SET `rates_count` = `rates_count` - 1, `rates_summary` = `rates_summary` - OLD.`rate` 
		WHERE `id` = OLD.`room_id`;

		/*удаление лишних связей */
		DELETE FROM `media_links` WHERE `entity_id` = OLD.`id` AND `entity_type` = 'comment';
END;
;;
DELIMITER ;

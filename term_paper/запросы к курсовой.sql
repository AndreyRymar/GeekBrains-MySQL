USE term_paper_booking;

/* Запрос №1 */
/* Выбрать отель с самым дешёвым номером на сегодня ( взято 2021-05-02 ), в котором есть бассейн */
SELECT 
h.`id`, h.`title`, MIN( p.`price` )
FROM
`rooms` AS r
INNER JOIN `hotels` AS h ON h.`id` = r.`hotel_id`
/*и проверим что в номере есть бассейн */
INNER JOIN `rooms_services` AS rs ON rs.`room_id` = r.`id`
INNER JOIN `services` AS s ON s.`id` = rs.`service_id` AND lower( s.`title` ) = lower( 'бассейн' )
INNER JOIN `rooms_price` AS p ON p.`room_id` = r.`id` AND p.`date` = '2021-05-02'
/* чтобы не дублировались номера*/
GROUP BY h.`id` 
ORDER BY MIN( p.`price` )
LIMIT 1


/* Запрос №2 */
/* Получить средний возраст посетителя пятёрки самых дорогих отелей */
WITH top_hotels AS (
		SELECT x.`id` FROM (
				SELECT h.`id`, COUNT(p.`price`) AS p_count, AVG(p.`price`) AS p_avg FROM 
				`hotels` AS h
				INNER JOIN `rooms` AS r ON r.`hotel_id` = h.`id`
				INNER JOIN `rooms_price` AS p ON p.`room_id` = r.`id`
				GROUP BY r.`id` ORDER BY AVG(p.`price`) / COUNT(1) DESC
		) AS x
		GROUP BY x.`id`
		ORDER BY MAX( p_avg ) DESC
		LIMIT 5
)

SELECT AVG( DATE_FORMAT( NOW(), '%Y' ) - DATE_FORMAT( u.`birthdate`, '%Y' ) ) AS `result`
FROM
`users` AS u
INNER JOIN `users_bills` AS b ON b.`has_billed` AND b.`date_in` <= NOW()
INNER JOIN `rooms` AS r ON r.`id` = b.`room_id` AND r.`hotel_id` IN ( SELECT `id` FROM top_hotels)
/* CTE был использован поскольку нельзя класть ORDER BY и LIMIT в подзапросы.*/


/* Запрос №3 */
/* Мы хотим выбрать самые популярные номера у эльфов ( причём в которых они были или находятся сейчас ), разрешающие услуги бассейна */
SELECT 
CONCAT( h.`title`, ' - ', r.`title` ) AS `room_full_title`, CASE r.rates_count > 0 WHEN true THEN r.rates_summary / r.rates_count ELSE 'not rated yet' END AS `rating`, r.*
FROM
/*оттолкнёмся от оплаченных счетов*/
`users_bills` AS `bill` 
/*он не только там был, но должен был оставить комментарий*/
INNER JOIN `comments` AS c ON c.`user_id` = `bill`.`user_id` AND c.`room_id` = `bill`.`room_id`
/*пользователь должен быть эльфом */
INNER JOIN `users` AS u ON u.`id` = `bill`.`user_id` AND u.`gender` = 'эльф'
/*ну и наконец получим номера*/
INNER JOIN `rooms` AS r ON r.`id` = `bill`.`room_id`
INNER JOIN `hotels` AS h ON h.`id` = r.`hotel_id`
/*и проверим что в номере есть бассейн*/
INNER JOIN `rooms_services` AS rs ON rs.`room_id` = r.`id`
INNER JOIN `services` AS s ON s.`id` = rs.`service_id` AND lower( s.`title` ) = lower( 'бассейн' )
/*отталкиваясь от оплаченных счетов учтём что юзер там уже был, или сейчас находится*/
WHERE `bill`.`has_billed` AND `bill`.`date_in` <= NOW() 
/*чтобы не дублировались номера*/
GROUP BY r.`id`


/* Представления сделал из наших запросов, поскольку нет конкретных задач */
CREATE VIEW popular_elves_rooms
AS
	SELECT 
	CONCAT( h.`title`, ' - ', r.`title` ) AS `room_full_title`, CASE r.rates_count > 0 WHEN true THEN r.rates_summary / r.rates_count ELSE 'not rated yet' END AS `rating`, r.*
	FROM
	`users_bills` AS `bill` 
	INNER JOIN `comments` AS c ON c.`user_id` = `bill`.`user_id` AND c.`room_id` = `bill`.`room_id`
	INNER JOIN `users` AS u ON u.`id` = `bill`.`user_id` AND u.`gender` = 'эльф'
	INNER JOIN `rooms` AS r ON r.`id` = `bill`.`room_id`
	INNER JOIN `hotels` AS h ON h.`id` = r.`hotel_id`
	INNER JOIN `rooms_services` AS rs ON rs.`room_id` = r.`id`
	INNER JOIN `services` AS s ON s.`id` = rs.`service_id` AND lower( s.`title` ) = lower( 'бассейн' )
	WHERE `bill`.`has_billed` AND `bill`.`date_in` <= NOW() 
	GROUP BY r.`id`
;
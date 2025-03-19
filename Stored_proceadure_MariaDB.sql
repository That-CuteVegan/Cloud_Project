DELIMITER //

CREATE PROCEDURE frontend_fetch(IN hotel_id_param INT)
BEGIN
    SELECT h.hotel_name, r.room_number, r.room_type, p.room_price
    FROM hotel_informations h
    JOIN room_informations r ON r.room_id = h.hotel_id
    JOIN room_prices p ON p.room_id = r.room_id
    WHERE h.hotel_id = hotel_id_param;
END //
-- Script for our MariaDB database to be able to show our hotel informations on our HTML.

-- Specifies what database we are working in.
USE cloud_project;

-- Sets first table "hotel_informations" and specifies the colums.
CREATE TABLE hotel_informations (
    hotel_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_address VARCHAR(50) NOT NULL,
    hotel_phone VARCHAR(12) NOT NULL UNIQUE,
    hotel_mail VARCHAR(50) NOT NULL UNIQUE,
    hotel_rooms INT NOT NULL,
    hotel_name VARCHAR(50) NOT NULL
);

-- Sets 2nd table to be "room_informations" and specifies the colums.
CREATE TABLE room_informations (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number INT NOT NULL UNIQUE,
    room_type VARCHAR(25) NOT NULL
);

-- Sets 3rd table to be "worker_informations" and specifies the colums.
CREATE TABLE worker_informations (
    worker_id INT AUTO_INCREMENT PRIMARY KEY,
    worker_name VARCHAR(30) NOT NULL,
    worker_ocupation VARCHAR(50) NOT NULL
);

-- Sets 4th table to be "room_prices" and specifies the colums.
CREATE TABLE room_prices (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL UNIQUE,
    room_price DECIMAL(7,2) NOT NULL,

    -- Defines forign key for room_id.
    FOREIGN KEY (room_id) REFERENCES room_informations(room_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sets 5th table to be "room_services" and specifies the colums.
CREATE TABLE room_services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    breakfast ENUM('Yes','No') NOT NULL DEFAULT 'No',
    bike ENUM('Yes','No') NOT NULL DEFAULT 'No',
    balcony ENUM('Yes','No') NOT NULL DEFAULT 'No',

    -- Defines forign key for room_id.
    FOREIGN KEY (room_id) REFERENCES room_informations(room_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sets 6th table to be "worker_backend" and specifies the colums.
CREATE TABLE worker_backend (
    hotel_id INT NOT NULL,
    worker_id INT NOT NULL,

    -- Defines forign key for hotel_id and worker_id.
    FOREIGN KEY (hotel_id) REFERENCES hotel_informations(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (worker_id) REFERENCES worker_informations(worker_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sets 7th table to be "frontend" and specifies the colums.
CREATE TABLE frontend (
    hotel_id INT NOT NULL,
    room_id INT NOT NULL,
    price_id INT NOT NULL,
    service_id INT NOT NULL,

    -- Defines forign key for hotel_id, room_id, room_price, brakefast, bike and balcony.
    FOREIGN KEY (hotel_id) REFERENCES hotel_informations(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES room_informations(room_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (price_id) REFERENCES room_prices(price_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (service_id) REFERENCES room_services(service_id) ON DELETE CASCADE ON UPDATE CASCADE
);
<?php
/**
 * Plugin Name: Hotel Display
 * Description: A plugin to display hotel and room information from MariaDB.
 * Version: 1.0
 * Author: That_CuteVegan
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Register REST API endpoints
add_action('rest_api_init', function() {
    register_rest_route('hotel-api/v1', '/hotels', [
        'methods' => 'GET',
        'callback' => 'get_hotels',
    ]);

    register_rest_route('hotel-api/v1', '/hotels/(?P<id>\d+)', [
        'methods' => 'GET',
        'callback' => 'get_hotel_details',
    ]);
    
    register_rest_route('hotel-api/v1', '/rooms/(?P<id>\d+)', [
        'methods' => 'GET',
        'callback' => 'get_room_details',
    ]);
});

// Database connection
function get_db_connection() {
    global $wpdb;
    return new wpdb('db_user', 'db_password', 'cloud_project', 'localhost');
}

// Fetch all hotels
function get_hotels() {
    $db = get_db_connection();
    return $db->get_results("SELECT * FROM hotel_informations");
}

// Fetch hotel details + rooms
function get_hotel_details($request) {
    $hotel_id = $request['id'];
    $db = get_db_connection();
    
    $hotel = $db->get_row($db->prepare("SELECT * FROM hotel_informations WHERE hotel_id = %d", $hotel_id));
    $rooms = $db->get_results($db->prepare("SELECT * FROM room_informations WHERE hotel_id = %d", $hotel_id));
    
    return ['hotel' => $hotel, 'rooms' => $rooms];
}

// Fetch room details
function get_room_details($request) {
    $room_id = $request['id'];
    $db = get_db_connection();
    return $db->get_row($db->prepare("SELECT * FROM room_informations WHERE room_id = %d", $room_id));
}

// Shortcode to display hotels
function display_hotels() {
    return '<div id="hotels-container"></div><script src="/wp-content/plugins/hotel-display/script.js"></script>';
}
add_shortcode('hotel_list', 'display_hotels');
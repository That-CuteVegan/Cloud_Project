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
        'permission_callback' => '__return_true',
    ]);

    register_rest_route('hotel-api/v1', '/hotels/(?P<id>\d+)', [
        'methods' => 'GET',
        'callback' => 'get_hotel_details',
        'permission_callback' => '__return_true',
    ]);
    
    register_rest_route('hotel-api/v1', '/rooms/(?P<id>\d+)', [
        'methods' => 'GET',
        'callback' => 'get_room_details',
        'permission_callback' => '__return_true',
    ]);
});

// Fetch all hotels
function get_hotels() {
    global $wpdb;
    return $wpdb->get_results("SELECT * FROM cloud_project.hotel_informations");
}

// Fetch hotel details + rooms
function get_hotel_details($request) {
    global $wpdb;
    $hotel_id = $request['id'];
    
    $hotel = $wpdb->get_row($wpdb->prepare("SELECT * FROM cloud_project.hotel_informations WHERE hotel_id = %d", $hotel_id));
    $rooms = $wpdb->get_results($wpdb->prepare("SELECT * FROM cloud_project.frontend WHERE hotel_id = %d", $hotel_id));
    
    return ['hotel' => $hotel, 'rooms' => $rooms];
}

// Fetch room details
function get_room_details($request) {
    global $wpdb;
    $room_id = $request['id'];
    return $wpdb->get_row($wpdb->prepare("SELECT * FROM cloud_project.room_informations WHERE room_id = %d", $room_id));
}

// Shortcode to display hotels
function display_hotels() {
    return '<div id="hotels-container"></div><script src="'.plugin_dir_url(__FILE__).'script.js"></script>';
}
add_shortcode('hotel_list', 'display_hotels');

function enqueue_hotel_details_script() {
    if (is_page('hotel-details')) { 
        wp_enqueue_script(
            'hotel-details-script',
            plugins_url('hotel_details.js', __FILE__),
            array(),
            null,
            true
        );
    }
}
add_action('wp_enqueue_scripts', 'enqueue_hotel_details_script');
?>
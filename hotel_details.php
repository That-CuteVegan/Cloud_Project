<?php
/**
 * Template Name: Hotel Details
 * Description: A template to display hotel information from MariaDB.
 * Version: 1.0
 * Author: That_CuteVegan
 */
get_header();
?>

<div id="hotel-details-container">
    <h1 id="hotel-name"></h1>
    <p id="hotel-address"></p>
    <h2>Available Rooms</h2>
    <div id="rooms-container"></div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", async function() {
        const params = new URLSearchParams(window.location.search);
        const hotelId = params.get("id");
        
        if (!hotelId) {
            document.getElementById("hotel-details-container").innerHTML = "<p>Hotel not found.</p>";
            return;
        }

        try {
            const response = await fetch(`/wp-json/hotel-api/v1/hotels/${hotelId}`);
            const data = await response.json();
            
            document.getElementById("hotel-name").textContent = data.hotel.hotel_name;
            document.getElementById("hotel-address").textContent = data.hotel.hotel_address;

            const roomsContainer = document.getElementById("rooms-container");
            data.rooms.forEach(room => {
                const div = document.createElement("div");
                div.className = "room-box";
                div.innerHTML = `
                    <p>Room: ${room.room_number} - Type: ${room.room_type}</p>
                    <button onclick="viewRoom(${room.room_id})">View Details</button>
                `;
                roomsContainer.appendChild(div);
            });
        } catch (error) {
            console.error("Error fetching hotel details:", error);
        }
    });
    
    function viewRoom(roomId) {
        window.location.href = `/room-details/?id=${roomId}`;
    }
</script>

<?php
get_footer();
?>

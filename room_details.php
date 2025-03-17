<?php
/**
 * Template Name: Room Details
 * Description: A template to display hotel information from MariaDB.
 * Version: 1.0
 * Author: That_CuteVegan
 */
get_header();
?>

<div id="room-details-container">
    <h1 id="room-title"></h1>
    <p id="room-type"></p>
</div>

<script>
    document.addEventListener("DOMContentLoaded", async function() {
        const params = new URLSearchParams(window.location.search);
        const roomId = params.get("id");
        
        if (!roomId) {
            document.getElementById("room-details-container").innerHTML = "<p>Room not found.</p>";
            return;
        }

        try {
            const response = await fetch(`/wp-json/hotel-api/v1/rooms/${roomId}`);
            const room = await response.json();
            
            document.getElementById("room-title").textContent = `Room ${room.room_number}`;
            document.getElementById("room-type").textContent = `Type: ${room.room_type}`;
        } catch (error) {
            console.error("Error fetching room details:", error);
        }
    });
</script>

<?php
get_footer();
?>
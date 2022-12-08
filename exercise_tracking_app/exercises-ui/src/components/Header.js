import React from "react";

function Header () {
    return (
        <header id="header">
                <h1 id='title'>EXERCISE TRACKING APP</h1>
                <div id='header-directions'>
                <h2 id="directions-title">DIRECTIONS:</h2>
                <hr id="header-hr"></hr>
                <ul id="directions-list">
                <li>click the 'ADD EXERCISE' button above to enter a new exercise measurement</li>
                <li>once an exercise has been added, you can edit and delete it in the table</li>
                <li>dates added into the app must be in the format 'MM-DD-YY'</li>
                </ul>
                </div>
        </header>
    )
}

export default Header;
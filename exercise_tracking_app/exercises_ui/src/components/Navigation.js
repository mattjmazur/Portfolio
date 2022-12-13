import React from "react";
import { Link } from "react-router-dom";
import '../App.css'

function Navigation () {
    return (
        <>
        <div id="nav-menu">
        <Link to="/" id='links'>HOME</Link>
        <Link to="/add-exercise" id='links'>ADD EXERCISE</Link>
        </div>
        </>
    )
}

export default Navigation;
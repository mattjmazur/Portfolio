import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../components/Header';
import Footer from '../components/Footer';

export const AddExercisePage = () => {
    const [name, setName] = useState('');
    const [weight, setWeight] = useState('');
    const [reps, setReps] = useState('');
    const [unit, setUnit] = useState('');
    const [date, setDate] = useState('');

    let navigate = useNavigate()


    const addExercise = async () => {
        const newExercise = {name, reps, weight, unit, date};
        const response = await fetch('/exercises', {
            method: 'POST',
            body: JSON.stringify(newExercise),
            headers: {'Content-Type': 'application/json', 
        }
        });
        if (response.status === 201) {
            alert("Successfully added the exercise");
        } else {
            alert(`Failed to add exercise, status code is ${response.status}`);
        }
        navigate("/");
    };

    return (
        <div>
            <Header />
            <h1 id='edit-exercise'>ADD EXERCISE BELOW:</h1>
            <input
                type="text"
                placeholder="name"
                value={name}
                onChange={e => setName(e.target.value)} />
            <input
                type="number"
                value={reps}
                placeholder="reps"
                onChange={e => setReps(e.target.value)} />
            <input
                type="number"
                value={weight}
                placeholder="weight"
                onChange={e => setWeight(e.target.value)} />
            <select value={unit} onChange={e => setUnit(e.target.value)}>
                <option></option>
                <option selected='selected'>kgs</option>
                <option>lbs</option>
            </select>
            <input
                type="text"
                placeholder="date"
                value={date}
                onChange={e => setDate(e.target.value)} />
            <button
                onClick={addExercise}
            >ADD</button>
            <Footer />
        </div>
    );
}

export default AddExercisePage;
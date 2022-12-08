import 'dotenv/config';
import * as exercises from './exercises_model.mjs';
import express from 'express';

const PORT = process.env.PORT;
const app = express();

/*
'exercises_controller.mjs' acts as the controller of the 'Exercise Tracking App'. Express.js is used to route requests from the client to
'exercises_model.mjs', which acts as the model of the app. Functions that validate the client-entered data are also included.
*/


//returns true if the date format is MM-DD-YY where MM, DD and YY are 2 digit integers
function isDateValid(date) {
    const format = /^\d\d-\d\d-\d\d$/;
    return format.test(date);
}

//returns true if the data entered by the user is in the correct format
const requestValidation = (request) => {
    if (!request.name) {
        return false
    } else if (request.reps <= 0) {
        return false
    } else if (request.weight <= 0) {
        return false
    } else if (!isDateValid(request.date)) {
        return false
    } return true
}

app.use(express.json());

//ADDING AN DOCUMENT TO THE COLLECTION
app.post('/exercises', (req, res) => {
    exercises.createExercise(req.body.name, req.body.reps, req.body.weight, req.body.unit, req.body.date)
    .then(exercise => {
        if (!requestValidation(exercise)) {
            res.status(400).json({Error: 'Invalid Request'})
        }
    })
    .then(exercise => {
        res.status(201).json(exercise);
    })
    .catch(error => {
        console.error(error);
        res.status(400).json({Error: 'Invalid Request'})
    });
})

//RETREIEVE A SPECIFIC DOCUMENT FROM THE COLLECTION
app.get('/exercises/:_id', (req, res) => {
    const exerciseId = req.params._id;
    exercises.findExerciseById({_id : exerciseId})
        .then(exercise => {
            if (exercise.length !== 0 ){
                res.json(exercise);
            } else {
                res.status(404).json({ Error: 'Not found' });
            }
        })
        .catch( () => {
            res.status(400).json({ Error: 'Request failed' });
        })
});

//RETRIEVE ALL DOCUMENTS IN COLLECTION
app.get('/exercises', (req, res) => {
    exercises.findExercise()
        .then(exercises => {
            res.json(exercises);
        })
        .catch( () => {
            res.send({ Error: 'Request failed' });
        });
});

//UPDATE A SPECIFIC DOCUMENT IN THE COLLECTION
app.put('/exercises/:id', (req, res) => {
    if (!requestValidation(req.body)) {
        res.status(400).json({Error: 'Invalid request'})
    } else {
    exercises.replaceExercise(req.params.id, req.body.name, req.body.reps, req.body.weight, req.body.unit, req.body.date)
        .then(numUpdated => {
            if (numUpdated === 1) {
                res.json({ _id: req.params.id, name: req.body.name, reps: req.body.reps, weight: req.body.weight, unit: req.body.unit, date: req.body.date })
            } else {
                res.status(404).json({ Error: 'Not found' });
            }
        })
        .catch(error => {
            console.error(error);
            res.status(400).json({ Error: 'Invalid request' });
        });
}});

//DELETE A SPECIFIC DOCUMENT IN THE COLLECTION
app.delete('/exercises/:id', async (req, res) => {
    let success = await exercises.deleteExercise(req.params.id)
    if (success === 1) {
        res.status(204).send()
    } else {
        res.status(404).json({Error: "Not found"})
    }
});

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}...`);
});


import mongoose from 'mongoose';
import 'dotenv/config';

/*
'exercises_model.mjs' acts as the model of the 'Exercise Tracking App'. It receives data from 'exercises_controller.mjs' and 
performs CRUD operations on the connected mongodb collection.
*/

mongoose.connect(
    process.env.MONGODB_CONNECT_STRING,
    { useNewUrlParser: true }
);

const db = mongoose.connection;
db.once("open", () => {
    console.log("Successfully connected to MongoDB using Mongoose!");
});

//defines the schema for an exercise
const exerciseSchema = mongoose.Schema({
    name: { type: String, required: true },
    reps: { type: Number, required: true },
    weight: { type: Number, required: true},
    unit: { type: String, required: true, enum: ["kgs", "lbs"]},
    date: { type: String, required: true }
});

//creates a new exercise with the parameters and adds the exercise to the mongodb collection
const Exercise = mongoose.model("Exercise", exerciseSchema);
const createExercise = async (name, reps, weight, unit, date) => {
    const exercise = await new Exercise({name: name, reps: reps, weight: weight, unit: unit, date: date});
    return exercise.save();
}

//retrieves the mongodb document with the matching parameter-id
const findExerciseById = async (exerciseId) => {
    const query = Exercise.find(exerciseId)
    return query
}

//retrieves all of the mongodb documents in the collection that match the parameter-filter
const findExercise = async (filter) => {
    const query = Exercise.find(filter)
    return query;
}

//updates the document in the collection with the matching 'search_id' with the parameters
const replaceExercise = async (search_id, name, reps, weight, unit, date) => {
    let update = {}
    if (name !== undefined) {
        update.name = name
    } if (reps !== undefined) {
        update.reps = reps
    } if (weight !== undefined) {
        update.weight = weight
    } if (unit !== undefined) {
        update.unit = unit
    } if (date !== undefined) {
        update.date = date
    }
    const result = await Exercise.updateOne({ _id: search_id }, update)
    return result.modifiedCount
}

//deletes the document in the collection with the matching 'search_id'
const deleteExercise = async (search_id) => {
    const result = await Exercise.deleteOne({_id:search_id})
    return result.deletedCount
}

export {createExercise, findExerciseById, findExercise, replaceExercise, deleteExercise}
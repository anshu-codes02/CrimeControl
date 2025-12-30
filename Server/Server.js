const express= require('express');
const cors= require('cors');
require('dotenv').config();
const mongoose= require('mongoose');

const app= express();

app.use(cors());
app.use(express.json()); 




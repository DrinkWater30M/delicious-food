var express = require('express');
var router = express.Router();
const passport = require('passport');
const driverController = require('../controllers/driverController');
const authController = require('../auth/authController');
const middleware = require('../middleware/verifyLogin');

// GET login page
router.get('/login', driverController.getLoginPage);

// POST login page
router.post('/login', passport.authenticate('local', {
    successRedirect: '/driver/home',
    failureRedirect: '/driver/login',
    failureFlash : true
}) );

// POST logout page
router.post('/logout', authController.driverLogout);


// GET login page
router.get('/home', driverController.getHomePage);

// GET pendding page
router.get('/pending', middleware.verifyDriverLogin, driverController.getPendingPage);

// GET in transit page
router.get('/inTransit', middleware.verifyDriverLogin, driverController.getInTransitPage);

// GET login page
router.get('/delivered', middleware.verifyDriverLogin, driverController.getDeliveredPage);

// POST /driver/receiveBill
router.post('/receiveBill', middleware.verifyDriverLogin, driverController.receiveBill);

// get active Location bill 
router.get('/getLocationBill', middleware.verifyDriverLogin, driverController.getLocationBill);

module.exports = router;

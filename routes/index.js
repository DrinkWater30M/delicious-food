var express = require('express');
var router = express.Router();

//root path
const homeRouter = require('./homeRouter');
router.use('/', homeRouter);

//user path
const userRouter = require('./userRouter');
router.use('/user', userRouter);

////user path
const driverRouter = require('./driverRouter');
router.use('/driver', driverRouter);

//product path
const productRouter = require('./productRouter');
router.use('/product', productRouter);

//food shop path
const foodShopRouter = require('./foodShopRouter');
router.use('/foodShop', foodShopRouter);

//admin path
const adminRouter = require('./adminRouter');
router.use('/admin', adminRouter)

module.exports = router;

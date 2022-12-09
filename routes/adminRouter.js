var express = require('express');
var router = express.Router();
const adminController = require('../controllers/adminController');

//Chỉ dùng cho việc demo tranh chấp
//get insert product page
router.get('/insertPage', adminController.insertProductPage);

//insert product
router.post('/insert', adminController.insertProduct);
module.exports = router;

var express = require('express');
var router = express.Router();
const passport = require('passport');
const userController = require('../controllers/userController');
const authController = require('../auth/authController');
const middleware = require('../middleware/verifyLogin');

// Hiển thị thông tin cá nhân
router.get('/profile', middleware.verifyLogin, userController.getProfilePage);

// Hiển thị trang chỉnh sửa
router.get('/updateProfile', middleware.verifyLogin, userController.getUpdateProfilePage);

// Cập nhật profile
router.post('/updateProfile', middleware.verifyLogin, userController.updateProfile);

// GET login page
router.get('/login', userController.getLoginPage);

// POST login page
// Xác thực tài khoản
router.post('/login', passport.authenticate('local', {
    successRedirect: '/',
    failureRedirect: '/user/login',
    failureFlash : true
}) );

// POST logout page
router.post('/logout', authController.logout);

// GET register page
router.get('/register', userController.getRegisterPage);

// POST register
router.post('/register', userController.register);

// page Thanh toán
router.get('/thanhtoan', middleware.verifyLogin, userController.showThanhtoan)
// Xử lý thanh toán
router.post('/xulithanhtoan', middleware.verifyLogin, userController.xulithanhtoan)

//Hiển thị giỏ hàng
router.get('/shoppingcart', middleware.verifyLogin, userController.getShoppingCart);

//Xóa món hàng trong giỏ hàng
router.get('/shoppingcart/delete/:id',userController.deleteAtShoppingCart);

//Hiển thị danh sách đơn hàng
router.get('/purchase',middleware.verifyLogin, userController.getPurchase);

// POST remove bill
router.post('/purchase', userController.removeBill);

//Hiển thị đánh giá
router.get('/note',userController.getNote)

module.exports = router;

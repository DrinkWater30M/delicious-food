const userService = require('../services/userService');
const bcrypt = require('bcrypt');
const saltRounds = 10;

async function getProfilePage(req, res){
    try{
        //get id from request
        const KhachHangID = req.user.KhachHangID;
        const userInfo = await userService.getInfoByID(KhachHangID);

        // const info = userInfo[0];
        //
        res.render('userView/profile.hbs', {userInfo: {...userInfo}});
    
    }
    catch(error){
        console.log(error);
    }
}

async function getUpdateProfilePage(req, res){
    try{
        //get id from request
        const KhachHangID = req.user.KhachHangID;
        const userInfo = await userService.getInfoByID(KhachHangID);
        
        // const info = userInfo[0];
        //
        res.render('userView/updateProfile.hbs', {userInfo: {...userInfo}});
    }
    catch(error){
        console.log(error);
    }
}

async function updateProfile(req, res){
    try{
        //get id user
        const KhachHangID = req.user.KhachHangID;
        const [Email, SoDienThoai, DiaChi, HoTen] = [req.body.email, req.body.sodienthoai, req.body.diachi, req.body.hoten];
        
        //update
        await userService.updateProfile(KhachHangID, HoTen, SoDienThoai, Email, DiaChi);

        // res.redirect('/user/profile');
        res.redirect('/user/profile');
    }
    catch(error){
        console.log(error);
    }
}

async function getLoginPage(req, res){
    try{
        res.render('userView/login.hbs', {error: req.flash('error')[0]});
    }
    catch(error){
        console.log(error);
    }
} 

async function login(req, res){
    try{
        console.log(req.body)
    }
    catch(error){
        console.log(error);
    }
}

async function getRegisterPage(req, res){
    try{
        res.render('userView/register.hbs', {error: req.flash('error')[0]});
    }
    catch(error){
        console.log(error);
    }
}

// Đăng ký tài khoản
async function register(req, res){
    try{
        const {username, password} = req.body;
        //check username
        const userAccount = await userService.getAccount(username);
        if(userAccount){
            res.render('userView/register', {error: "Username already exists!"});
            return;
        }

        //hash password
        const hashPassword = await bcrypt.hash(password, saltRounds);

        //add new account
        await userService.addAccount(username, hashPassword);

        //return
        const userInfo = await userService.getInfoByUserName(username);
        req.login({KhachHangID: userInfo.KhachHangID, Username: userInfo.Username}, function(err) {
            if (err) { return next(err); }
            res.redirect('/');
        });
    }
    catch(error){
        console.log(error);
    }

}

async function showThanhtoan(req, res) {
    try {
        const id = req.user.KhachHangID;
        const giohang = await userService.showCart(id)
        let sum = giohang[0]
        let phisanpham = 0;
        sum.forEach(function (item, index) {
            phisanpham += item.Gia * item.SoLuong;
        });
        res.render('userView/payment', {giohang: giohang[0], phisanpham: phisanpham});
    }
    catch(err){
        console.log(err);
    }
}

async function xulithanhtoan(req, res){
    try {
        const id = req.user.KhachHangID;
        let giohang = await userService.showCart(id)
        const nguoinhan = req.body.name;
        const sdt = req.body.sdt;
        const diachi = req.body.diachi;
        let phisanpham = 0;
        giohang = giohang[0];
        // Tính phí sản phẩm
        giohang.forEach(function (item, index) {
            phisanpham += item.Gia * item.SoLuong;
        });
        // Thêm đơn hàng
        const add = await userService.themDonHang(nguoinhan, sdt, diachi, phisanpham, id)
        var bool = add[1];

        // Gọi hàm thêm chi tiết đơn hàng
        giohang.forEach(function (item, index) {
            userService.themChiTietDonHang(item.MonID, item.SoLuong, item.Gia);
            userService.deleteShoppingCartByID(item.MonID, id);
        });
        if (!add) res.render('userView/payment', {giohang: giohang[0], phisanpham: phisanpham, status: "Thanh toán đơn hàng không thành công!"});
        else
        res.redirect('/user/thanhtoan?checkout=true');
    }
    catch(err){
        console.log(err);
    }
}

async function getShoppingCart(req, res){
    try{
        //get id from request
        const KhachHangID = req.user.KhachHangID;
        const cart = await userService.getShoppingCartByID(KhachHangID);

        res.render('userView/shoppingcart.hbs', { cart});
    
    }
    catch(error){
        console.log(error);
    }
}

async function deleteAtShoppingCart(req, res, next){
    try{
        const MonID = req.params.id;
        const KhachHangID = req.user.KhachHangID;
        userService.deleteShoppingCartByID(MonID, KhachHangID);
        res.redirect('back');
    }
    catch(error){
        console.log(error);
    }
}

async function getPurchase(req, res){
    try{
        //get id from request
        const KhachHangID = req.user.KhachHangID;
        const search =  req.query.search;
        const purchase = await userService.getPurchaseByID(KhachHangID, search);
        
        //
        res.render('userView/purchase.hbs', { purchase});
    
    }
    catch(error){
        console.log(error);
    }
}

async function removeBill(req, res){
    try{
        //
        const DonHangID = req.body.billID;
        
        //
        await userService.removeBill(DonHangID);

        //
        res.redirect('/user/purchase');
    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    getLoginPage,
    login,
    getRegisterPage,
    register,
    getProfilePage,
    getUpdateProfilePage,
    updateProfile,
    showThanhtoan,
    xulithanhtoan,
    getShoppingCart,
    deleteAtShoppingCart,
    getPurchase,
    removeBill,
}
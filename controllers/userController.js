const userService = require('../services/userService');
const bcrypt = require('bcrypt');
const { restart } = require('nodemon');
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

async function getShoppingCart(req, res){
    try{
        //get id from request
        const KhachHangID = req.user.KhachHangID;
        const userInfo = await userService.getShoppingCartByID(KhachHangID);

        // const info = userInfo[0];
        //
        res.render('userView/shoppingcart.hbs', { userInfo});
    
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

module.exports = {
    getLoginPage,
    login,
    getRegisterPage,
    register,
    getProfilePage,
    getUpdateProfilePage,
    updateProfile,
    getShoppingCart,
    deleteAtShoppingCart,
}
const driverService = require('../services/driverService');
const bcrypt = require('bcrypt');
const saltRounds = 10;

async function getLoginPage(req, res){
    try{
        res.render('driverView/login.hbs', {error: req.flash('error')[0]});
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

async function getHomePage(req, res){
    try{
        console.log(req.user);
        res.render('driverView/home.hbs');
    }
    catch(error){
        console.log(error);
    }
}

async function getPendingPage(req, res){
    try{
        //get info
        const TrangThai = "Chờ Nhận";
        
        //get data
        const billList = await driverService.getBillList(null, TrangThai);

        //return
        res.render('driverView/billList.hbs', {billList});
    }
    catch(error){
        console.log(error);
    }
}

async function getInTransitPage(req, res){
    try{
        //get info
        const TaiXeID = req.user.KhachHangID;
        const TrangThai = "Đang Giao";
        
        //get data
        const billList = await driverService.getBillList(TaiXeID, TrangThai);

        //return
        res.render('driverView/billList.hbs', {billList});
    }
    catch(error){
        console.log(error);
    }
}

async function getDeliveredPage(req, res){
    try{
        //get info
        const TaiXeID = req.user.KhachHangID;
        const TrangThai = "Đã Giao";
        
        //get data
        const billList = await driverService.getBillList(TaiXeID, TrangThai);

        //return
        res.render('driverView/billList.hbs', {billList});
    }
    catch(error){
        console.log(error);
    }
}

async function getLocationBill(req, res) {
    try {
        const TaiXeID = req.user.KhachHangID;
        const locationOrder = await driverService.getBillListLocation(TaiXeID)

        res.render('driverView/billListLocation.hbs', {billList: locationOrder[0]});
    }
    catch(err) {

    }
}
async function receiveBill(req, res){
    try{
        //get info
        const TaiXeID = req.user.KhachHangID;
        const DonHangID = req.body.billID;
        
        //update driver
        await driverService.updateBillDriver(TaiXeID, DonHangID);

        //return
        res.redirect('/driver/inTransit');
    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    getLoginPage,
    login,
    getHomePage,
    getPendingPage,
    getInTransitPage,
    getDeliveredPage,
    receiveBill,
    getLocationBill,
}
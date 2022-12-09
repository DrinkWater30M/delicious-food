const adminService = require('../services/adminService');
const { log } = require('handlebars');

async function insertProductPage(req, res) {
    try{
        res.render('adminView/insertProduct.hbs')
    }
    catch (error){
        console.log(error);
    }
}

async function insertProduct(req, res) {
    try{
        const TenMon = req.body.tenmon;
        const MieuTa = req.body.mieuta;
        const Gia = Number(req.body.gia);
        const TinhTrang = req.body.tinhtrang;
        const ThucDonID = req.body.thucdonid;
        const LinkHinhAnh = req.body.hinhanh;
    
        await adminService.insertProductRB(TenMon, MieuTa, Gia, TinhTrang, ThucDonID, LinkHinhAnh);
        res.redirect('/product/list?foodShop=&search=&page=1');
    }
    catch (error){
        console.log(error);
    }
}

module.exports = {
    insertProductPage,
    insertProduct,
}
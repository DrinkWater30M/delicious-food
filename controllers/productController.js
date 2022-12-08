const { log } = require('handlebars');
const productService = require('../services/productService');

async function getProductListPage(req, res){
    try{
        //get params
        const foodShop = req.query.foodShop;
        const search = req.query.search;
        const page = req.query.page;
        
        //get product list
        const productList = await productService.getProductList(foodShop, search, page);

        //return client
        res.render('productView/productList.hbs', {productList});
    }
    catch(error){
        console.log(error);
    }
}

async function getProductDetail(req, res) {
    try {
        let id = req.params.id;
        console.log(id);

        const detail = await productService.getProductDetail(id);
        console.log(detail[0]);
        res.render('productView/productDetail', {detail: detail[0]})
    }
    catch(error){
        console.log(error);
    }
}

// Thêm vào giỏ hàng
async function addtoCart(req, res) {
    try {
        const KhachHangID = req.user.KhachHangID;
        let id = req.params.id;
        const soluong = req.body.soluong;
        const addtoCart = await productService.addtoCart(KhachHangID, id, soluong)
        const detail = await productService.getProductDetail(id);
        let result = 'Bạn đã thêm thành công!'
        if (!addtoCart) {
            result = 'Thêm vào giỏ hàng thất bại!'
        }
        res.render('productView/productDetail', {detail: detail[0], result: result})
    }
    catch (error){
        console.log(error);
    }
}

async function insertProductPage(req, res) {
    try{

        res.render('productView/productInsert.hbs')
    }
    catch (error){
        console.log(error);
    }
}

async function insertProduct(req, res) {
    try{
        const MonID = req.body.monid;
        const TenMon = req.body.tenmon;
        const MieuTa = req.body.mieuta;
        const Gia = Number(req.body.gia);
        const TinhTrang = req.body.tinhtrang;
        const ThucDonID = req.body.thucdonid;
        const LinkHinhAnh = req.body.hinhanh;
    
        await productService.insertProductRB(MonID, TenMon, MieuTa, Gia, TinhTrang, ThucDonID, LinkHinhAnh);
        res.redirect('/product/list?foodShop=&search=&page=1');
    }
    catch (error){
        console.log(error);
    }
}

async function deleteProduct(req, res){
    try{
        const MonID = req.params.id;
        await productService.deleteProductByID(MonID);
        
        res.redirect('/product/list?foodShop=&search=&page=1');
    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    getProductListPage,
    getProductDetail,
    addtoCart,
    insertProductPage,
    insertProduct,
    deleteProduct,
}
const sequelize = require('../models');
const { QueryTypes } = require('sequelize');
const generateID = require('../utils/generateID');

async function getProductList(foodShop, search, page){
    try{
        const subSql = foodShop ? `ChiNhanh.ChiNhanhID = '${foodShop}' and` : '';
        const sql = 
            `select Mon.*, ChiNhanh.TenChiNhanh 
            from Mon join ChiNhanh on Mon.ThucDonID = ChiNhanh.ThucDonID
            where ${subSql} Mon.TenMon like N'%${search}%'
            order by Mon.MonID asc
            offset ${(page-1)*12} rows fetch next ${page*12} rows only`;
        
        const productList = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return productList.length === 0 ? null : productList;
    }
    catch(error){
        console.log(error);
    }
}

// Lấy thông tin chi tiết sản phẩm
async function getProductDetail(id) {
    const sql = `select * from Mon where MonID = '${id}'`;
    const detail = await sequelize.query(sql, { type: QueryTypes.SELECT });

    return detail.length === 0 ? null : detail; 
}

// Thêm vào giỏ hàng
async function addtoCart(KhachHangID, MonID, soluong) {
    try {
        const GioHangID = generateID('GH');
        const sql = `exec CapNhatGioHang '${GioHangID}', '${KhachHangID}','${MonID}', ${soluong}`;
        return await sequelize.query(sql);
    }
    catch(error){
        console.log(error);
    }
}


module.exports = {
    getProductList,
    getProductDetail,
    addtoCart,
}
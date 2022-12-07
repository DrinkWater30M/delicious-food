const sequelize = require('../models');
const { QueryTypes } = require('sequelize');
const generateID = require('../utils/generateID');
const { log } = require('handlebars');
const transactionConfig = require('../transactionConfig');

async function getInfoByUserName(username){
    try{
        const sql = `select * from TaiXe where TaiXe.Username = '${username}'`;
        
        const userInfo = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return userInfo.length === 0 ? null : userInfo[0];
    }
    catch(error){
        console.log(error);
    }
}

async function getInfoByID(TaiXeID){
    try{
        const sql = `select * from TaiXe where TaiXe.TaiXeID = '${TaiXeID}'`;
        
        const userInfo = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return userInfo.length === 0 ? null : userInfo[0];
    }
    catch(error){
        console.log(error);
    }
}

async function getAccount(username){
    try{
        const sql = `select * from TaiKhoan where TaiKhoan.Username = '${username}'`;
        
        const userInfo = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return userInfo.length === 0 ? null : userInfo[0];
    }
    catch(error){
        console.log(error);
    }
}

async function getBillList(TaiXeID,  status){
    try{
        const subSql = TaiXeID ? `DonHang.TaiXeID = '${TaiXeID}' and` : '';
        const sql = 
        `select *, TaiXe.SoDienThoai as SDT 
        from DonHang left join TaiXe on DonHang.TaiXeID = TaiXe.TaiXeID
        join ChiTietDonHang on DonHang.DonHangID = ChiTietDonHang.DonHangID
        join Mon on ChiTietDonHang.MonID = Mon.MonID
        where ${subSql} DonHang.TrangThai = N'${status}'
        order by DonHang.DonHangID desc`;

        const billList = await sequelize.query(sql,  { type: QueryTypes.SELECT });
        
        if (billList.length === 0){ return null;}

        let result = [];
        billList.forEach(function(item) {
            var existing = result.filter(function(v, i) {
              return v.DonHangID == item.DonHangID;
            });
            if (existing.length) {
                let Mon = {
                    TenMon: item.TenMon, 
                    LinkHinhAnh: item.LinkHinhAnh, 
                    SoLuong: item.SoLuong,
                    GiaBan: item.GiaBan,
                }

                const existingIndex = result.indexOf(existing[0]);
                result[existingIndex].DanhSachMon.push(Mon);
            } else {
                item.DanhSachMon = [{
                    TenMon: item.TenMon, 
                    LinkHinhAnh: item.LinkHinhAnh, 
                    SoLuong: item.SoLuong,
                    GiaBan: item.GiaBan,
                }]
                delete item.TenMon;
                delete item.LinkHinhAnh;
                delete item.SoLuong;
                delete item.GiaBan;
                result.push(item);
            }
        });
        
        console.log(result);
        return result;
    }
    catch(error){
        console.log(error);
    }
}

async function getBillListLocation(TaiXeID){
    try {
        const sql = `exec pTaiXeXemDanhSachDonHang '${TaiXeID}'`
        const orderList = await sequelize.query(sql); 
        console.log(orderList);
        return orderList;
    }
    catch(err) {
        console.log(err);
    }
}

async function updateBillDriver(TaiXeID, DonHangID){
    try{
        const sql = `exec ${transactionConfig.pTaiXeNhanDonHang} '${TaiXeID}', ${DonHangID}`;
        await sequelize.query(sql);        
    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    getInfoByUserName,
    getInfoByID,
    getAccount,
    getBillList,
    updateBillDriver,
    getBillListLocation
}
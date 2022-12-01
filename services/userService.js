const sequelize = require('../models');
const { QueryTypes } = require('sequelize');
const generateID = require('../utils/generateID');
const { log } = require('handlebars');

async function getInfoByUserName(username){
    try{
        const sql = `select * from KhachHang where KhachHang.Username = '${username}'`;
        
        const userInfo = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return userInfo.length === 0 ? null : userInfo[0];
    }
    catch(error){
        console.log(error);
    }
}

async function getInfoByID(KhachHangID){
    try{
        const sql = `select * from KhachHang where KhachHang.KhachHangID = '${KhachHangID}'`;
        
        const userInfo = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return userInfo.length === 0 ? null : userInfo[0];
    }
    catch(error){
        console.log(error);
    }
}

async function updateProfile(KhachHangID, HoTen, SoDienThoai, Email, DiaChi){
    try{
        const sqlHoTen = HoTen ? `N'${HoTen}'` : null;
        const sqlSoDienThoai = SoDienThoai ? `'${SoDienThoai}'` : null;
        const sqlEmail = Email ? `'${Email}'` : null;
        const sqlDiaChi = DiaChi ? `N'${DiaChi}'` : null;
        const sql = 
            `UPDATE KhachHang SET 
                HoTen = ${sqlHoTen}, Email = ${sqlEmail}, SoDienThoai = ${sqlSoDienThoai}, DiaChi= ${sqlDiaChi}
            where KhachHang.KhachHangID = '${KhachHangID}'`;
        
        await sequelize.query(sql,  { type: QueryTypes.UPDATE });
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

async function addAccount(username, hashPassword){
    try{
        //generate id
        const KhachHangID = generateID("KH");
        const sql = 
        `
            insert into TaiKhoan values ('${username}', '${hashPassword}', null);
            insert into KhachHang(KhachHangID, Username) values ('${KhachHangID}', '${username}');
        `;
        
        await sequelize.query(sql);
    }
    catch(error){
        console.log(error);
    }
}

async function showCart(id){
    try{
        const sql = `select m.MonID, m.TenMon, m.Gia, ct.SoLuong from ChiTietGioHang ct, MON m where ct.KhachHangID = '${id}' and ct.MonID = m.MonID`
        
        return await sequelize.query(sql);
    }
    catch(error){
        console.log(error);
    }
}

async function themDonHang(nguoinhan, sdt, diachi, phisanpham, id){
    try{
        const sql = `insert into DonHang(NguoiNhan, SoDienThoai, DiaChiNhanHang, NgayDatHang, PhiSanPham, PhiVanChuyen, TrangThai, KhachHangID)
        values ('${nguoinhan}', '${sdt}', '${diachi}', CAST(GETDATE() AS DATE), ${phisanpham}, 15000, 'Chờ nhận', '${id}')`
        
        return await sequelize.query(sql);
    }
    catch(error){
        console.log(error);
    }
}

async function themChiTietDonHang(idmon, soluong, gia){
    try{
        const sql = `exec ThemChiTietDonHang '${idmon}', ${soluong}, ${gia}`;
        
        return await sequelize.query(sql);
    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    getInfoByUserName,
    getInfoByID,
    getAccount,
    addAccount,
    updateProfile,
    showCart,
    themDonHang,
    themChiTietDonHang
}
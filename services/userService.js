const sequelize = require('../models');
const { QueryTypes } = require('sequelize');
const generateID = require('../utils/generateID');
const { log } = require('handlebars');
const transactionConfig = require('../transactionConfig');

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
        const sql = `select m.*, ct.SoLuong from ChiTietGioHang ct, MON m where ct.KhachHangID = '${id}' and ct.MonID = m.MonID`
        
        return await sequelize.query(sql);
    }
    catch(error){
        console.log(error);
    }
}

async function themDonHang(nguoinhan, sdt, diachi, phisanpham, id){
    try{
        const sql = `insert into DonHang(NguoiNhan, SoDienThoai, DiaChiNhanHang, NgayDatHang, PhiSanPham, PhiVanChuyen, TrangThai, KhachHangID)
        values ('${nguoinhan}', '${sdt}', '${diachi}', CAST(GETDATE() AS DATE), ${phisanpham}, 15000, N'Chờ nhận', '${id}')`
        
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

async function getShoppingCartByID(KhachHangID){
    try{
        const sql = `select M.*, CTGH.SoLuong, M.Gia, CTGH.MonID
                    from ChiTietGioHang CTGH, Mon M
                    where CTGH.KhachHangID = '${KhachHangID}' and CTGH.MonID = M.MonID`;
        
        const cart = await sequelize.query(sql,  { type: QueryTypes.SELECT });

        return cart.length === 0 ? null : cart;
    }
    catch(error){
        console.log(error);
    }
}

async function deleteShoppingCartByID(MonID, KhachHangID){
    try{
        const sql = `delete from  ChiTietGioHang
                    where KhachHangID = '${KhachHangID}' and MonID = '${MonID}'`;
        
         await sequelize.query(sql,  { type: QueryTypes.DELETE });

    }
    catch(error){
        console.log(error);
    }
}

async function getPurchaseByID(KhachHangID, search){
    try{
        let purchase = [];
        if (search === undefined){
            const sql = `select DH.NguoiNhan, DH.SoDienThoai as SDT, DH. NgayDatHang, DH.TrangThai, DH.DiaChiNhanHang,
            CTDH.SoLuong, CTDH.GiaBan, 
            M.TenMon, M.LinkHinhAnh,
            M.MonID, DH.DonHangID, TX.TaiXeID, TX.HoTen, TX.BienSoXe, TX.SoDienThoai
            from DonHang DH left join TaiXe TX on DH.TaiXeID = TX.TaiXeID, Mon M, ChiTietDonHang CTDH
            where DH.KhachHangID = '${KhachHangID}' and DH.DonHangID = CTDH.DonHangID and CTDH.MonID = M.MonID
            order by DonHangID desc`;
        
            purchase = await sequelize.query(sql,  { type: QueryTypes.SELECT });
        }
        else{
             const sql = `select DH.NguoiNhan, DH.SoDienThoai as SDT, DH. NgayDatHang, DH.TrangThai, DH.DiaChiNhanHang, 
             CTDH.SoLuong, CTDH.GiaBan,
             M.TenMon, M.LinkHinhAnh,
             M.MonID, DH.DonHangID, TX.HoTen, TX.BienSoXe, TX.SoDienThoai
             from DonHang DH left join TaiXe TX on DH.TaiXeID = TX.TaiXeID, Mon M, ChiTietDonHang CTDH
             where DH.KhachHangID = '${KhachHangID}' and DH.DonHangID = CTDH.DonHangID and CTDH.MonID = M.MonID and M.TenMon like N'%${search}%'
             order by DonHangID DESC`;
            purchase = await sequelize.query(sql,  { type: QueryTypes.SELECT });
        }
        
        if (purchase.length === 0){ return null;}

        let result = [];
        purchase.forEach(function(item) {
            var existing = result.filter(function(v, i) {
              return v.DonHangID == item.DonHangID;
            });
            if (existing.length) {
                let Mon = {
                    TenMon: item.TenMon, 
                    LinkHinhAnh: item.LinkHinhAnh, 
                    SoLuong: item.SoLuong,
                    GiaBan: item.GiaBan,
                    MonID: item.MonID,
                    DonHangID: item.DonHangID
                }

                const existingIndex = result.indexOf(existing[0]);
                result[existingIndex].DanhSachMon.push(Mon);
            } else {
                item.DanhSachMon = [{
                    TenMon: item.TenMon, 
                    LinkHinhAnh: item.LinkHinhAnh, 
                    SoLuong: item.SoLuong,
                    GiaBan: item.GiaBan,
                    MonID: item.MonID,
                    DonHangID: item.DonHangID
                }]
                delete item.TenMon;
                delete item.LinkHinhAnh;
                delete item.SoLuong;
                delete item.GiaBan;
                result.push(item);
            }
        });
        
        return result;
    }
    catch(error){
        console.log(error);
    }
}

async function removeBill(DonHangID){
    try{
        const sql = `update DonHang 
                    set TrangThai = N'Đã Hủy' 
                    where DonHang.DonHangID = '${DonHangID}' and DonHang.TrangThai = N'Chờ Nhận'`;
        
        await sequelize.query(sql, { type: QueryTypes.UPDATE });
    }
    catch(error){
        console.log(error);
    }
}

async function getNoteInfo(KhachHangID, DonHangID, MonID){
    try{
        const sql = `exec ${transactionConfig.pXemDanhGiaMonAn}'${KhachHangID}', ${DonHangID}, '${MonID}' `;
        
        const note = await sequelize.query(sql, { type: QueryTypes.SELECT });

        return note.length === 0 ? null : note;
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
    themChiTietDonHang,
    getShoppingCartByID,
    deleteShoppingCartByID,
    getPurchaseByID,
    removeBill,
    getNoteInfo,
}
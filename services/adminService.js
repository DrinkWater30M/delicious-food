const sequelize = require('../models');
const { QueryTypes } = require('sequelize');
const generateID = require('../utils/generateID');
const transactionConfig = require('../transactionConfig');

async function insertProductRB(TenMon, MieuTa, Gia, TinhTrang, ThucDonID, LinkHinhAnh){
    try{
        const MonID = generateID('mon');
        const sql = `exec doitac_ThemMonAn '${MonID}', '${TenMon}', '${MieuTa}', ${Gia}, '${TinhTrang}', '${ThucDonID}', '${LinkHinhAnh}'`;
        
        await sequelize.query(sql);

    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    insertProductRB,
}
const config = {
    //tên các transaction chưa fix tranh chấp
    Normal:{
        pTaiXeNhanDonHang: "pTaiXeNhanDonHang",
        pTaiXeXemDanhSachDonHang: "pTaiXeXemDanhSachDonHang",
        pKhachHangKiemTraDonHang: "pKhachHangKiemTraDonHang",
    },

    //tên các transaction đã fix tranh chấp
    Fix:{
        pTaiXeNhanDonHang: "pTaiXeNhanDonHang_Fix",
        pTaiXeXemDanhSachDonHang: "pTaiXeXemDanhSachDonHang_Fix",
        pKhachHangKiemTraDonHang: "pKhachHangKiemTraDonHang_Fix"
    }
}

module.exports = config.Fix;
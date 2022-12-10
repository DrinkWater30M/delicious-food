-- Tạo và phân quyền
use ESHOPPING
go

-- Phân hệ khách hàng
create login KhachHang with PASSWORD = 'mk1234'
create user KhachHang for login KhachHang
grant select on ThucDon to KhachHang
grant select on Mon to KhachHang
grant select, insert, delete on ChiTietDonHang to KhachHang
grant select, insert, delete on ChiTietGioHang to KhachHang
grant insert, update on DonHang to KhachHang
grant select on Quan to KhachHang
grant select on ChiNhanh to KhachHang
grant select, update, insert on KhachHang to KhachHang
grant insert, update on TaiKhoan to KhachHang
-- Phân hệ tài xế
create login TaiXe with PASSWORD = 'mk12345'
create user TaiXe for login TaiXe

grant select, update on DonHang to TaiXe
grant insert, update on TaiKhoan to TaiXe
grant select, update, insert to TaiXe
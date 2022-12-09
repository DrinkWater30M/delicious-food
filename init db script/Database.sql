-- Script tạo và nhập lệu DB cho hệ thống giao thức ăn
use master
go

drop database if exists ESHOPPING
go

create database ESHOPPING
go

use ESHOPPING
go

create table QuanTri
(
	AdminID char(50),
	HoTen nvarchar(50),
	Email varchar(50),
	SoDienThoai char(10),
	Username varchar(50),

	constraint pkQuanTri primary key(AdminID)
)
go

create table NhanVien
(
	NhanVienID char(50),
	HoTen nvarchar(50),
	Email varchar(50),
	SoDienThoai char(10),
	Username varchar(50),

	constraint pkNhanVien primary key(NhanVienID)
)
go

create table KhachHang
(
	KhachHangID char(50),
	HoTen nvarchar(50),
	SoDienThoai char(10),
	DiaChi ntext,
	Email varchar(50),
	TKNganHangID char(50),
	Username varchar(50),

	constraint pkKhachHang primary key(KhachHangID)
)
go

create table DoiTac
(
	DoiTacID char(50),
	Email varchar(50),
	NguoiDaiDien nvarchar(50),
	SoLuongQuan int,
	SoLuongDonDuKien int,
	DiaChiKinhDoanh ntext,
	SoDienThoai char(10),
	TrangThai nvarchar(20),
	Username varchar(50),

	constraint pkDoiTac primary key(DoiTacID)
)
go

create table TaiXe
(
	TaiXeID char(50),
	HoTen nvarchar(50),
	CMND varchar(20),
	SoDienThoai char(10),
	DiaChi ntext,
	BienSoXe varchar(10),
	KhuVucHoatDong ntext,
	Email varchar(50),
	TKNganHangID char(50),
	Username varchar(50),

	constraint pkTaiXe primary key(TaiXeID)
)
go

create table TaiKhoan
(
	Username varchar(50),
	MatKhau text,
	TrangThai nvarchar(20),

	constraint pkTaiKhoan primary key(Username)
)
go

create table TaiKhoanNganHang
(
	TKNganHangID char(50),
	SoTaiKhoan varchar(20),
	NganHang nvarchar(20),
	ChiNhanh ntext,

	constraint pkTaiKhoanNganHang primary key(TKNganHangID)
)
go

create table HopDong
(
	HopDongID char(50),
	MaSoThue varchar(10),
	NguoiDaiDien nvarchar(50),
	SoChiNhanh int,
	TKNganHangID char(50),
	NgayKichHoat date,
	NgayHetHan date,
	TrangThai nvarchar(20),
	NhanVienLap char(50),
	DoiTacID char(50),

	constraint pkHopDong primary key(HopDongID)
)
go

create table Quan
(
	QuanID char(50),
	TenQuan nvarchar(50),
	LoaiAmThuc nvarchar(20),
	NgayDangKi date,
	TinhTrang nvarchar(20),
	DoiTacID char(50),

	constraint pkQuan primary key(QuanID)
)
go

create table ChiNhanh
(
	ChiNhanhID char(50),
	TenChiNhanh nvarchar(50),
	DiaChi ntext,
	MoCua time,
	DongCua time,
	QuanID char(50),
	HopDongID char(50),
	ThucDonID char(50),
	TinhTrang nvarchar(20),
	LinkHinhAnh text,

	constraint pkChiNhanh primary key(ChiNhanhID)
)
go

create table ThucDon
(
	ThucDonID char(50),
	TenThucDon nvarchar(50),

	constraint pkThucDon primary key(ThucDonID)
)
go

create table Mon
(
	MonID char(50),
	TenMon nvarchar(50),
	MieuTaMon ntext,
	Gia int,
	TinhTrang nvarchar(20),
	ThucDonID char(50),
	LinkHinhAnh text,

	constraint pkMon primary key(MonID)
)
go

create table ChiTietGioHang
(
	GioHangID char(50),
	KhachHangID char(50),
	MonID char(50),
	SoLuong int,
	TrangThai nvarchar(20)

	constraint pkGioHang primary key(GioHangID)
)
go

create table DonHang
(
	DonHangID int identity(1,1),
	NguoiNhan nvarchar(50),
	SoDienThoai char(10),
	DiaChiNhanHang ntext,
	NgayDatHang date,
	PhiSanPham int,
	PhiVanChuyen int,
	TrangThai nvarchar(20),
	KhachHangID char(50),
	TaiXeID char(50),

	constraint pkDonHang primary key(DonHangID)
)
go

create table ChiTietDonHang
(
	MonID char(50),
	DonHangID int,
	SoLuong int,
	GiaBan int,
	GhiChuTuyChon ntext,
	DanhGia nvarchar(20),

	constraint pkChiTietDonHang primary key(MonID, DonHangID)
)
go

alter table QuanTri add
constraint fkQuanTri_Username foreign key(Username) references TaiKhoan(Username)
go

alter table NhanVien add
constraint fkNhanVien_Username foreign key(Username) references TaiKhoan(Username)
go

alter table KhachHang add
constraint fkKhachHang_Username foreign key(Username) references TaiKhoan(Username),
constraint fkKhachHang_TKNganHangID foreign key(TKNganHangID) references TaiKhoanNganHang(TKNganHangID)
go

alter table DoiTac add
constraint fkDoiTac_Username foreign key(Username) references TaiKhoan(Username)
go

alter table TaiXe add
constraint fkTaiXe_Username foreign key(Username) references TaiKhoan(Username),
constraint fkTaiXe_TKNganHangID foreign key(TKNganHangID) references TaiKhoanNganHang(TKNganHangID)
go

alter table HopDong add
constraint fkHopDong_TKNganHangID foreign key(TKNganHangID) references TaiKhoanNganHang(TKNganHangID),
constraint fkHopDong_NhanVienLap foreign key(NhanVienLap) references NhanVien(NhanVienID),
constraint fkHopDong_DoiTacID foreign key(DoiTacID) references DoiTac(DoiTacID)
go

alter table Quan add
constraint fkQuan_DoiTacID foreign key(DoiTacID) references DoiTac(DoiTacID)
go

alter table ChiNhanh add
constraint fkChiNhanh_HopDongID foreign key(HopDongID) references HopDong(HopDongID),
constraint fkChiNhanh_ThucDonID foreign key(ThucDonID) references ThucDon(ThucDonID)
go

alter table Mon add
constraint fkMon_ThucDonID foreign key(ThucDonID) references ThucDon(ThucDonID)
go

alter table ChiTietGioHang add
constraint fkChiTietGioHang_KhachHangID foreign key(KhachHangID) references KhachHang(KhachHangID),
constraint fkChiTietGioHang_MonID foreign key(MonID) references Mon(MonID)
go

alter table DonHang add
constraint fkDonHang_KhachHangID foreign key(KhachHangID) references KhachHang(KhachHangID),
constraint fkDonHang_TaiXeID foreign key(TaiXeID) references TaiXe(TaiXeID)
go

alter table ChiTietDonHang add
constraint fkChiTietDonHang_MonID foreign key(MonID) references Mon(MonID),
constraint fkChiTietDonHang_DonHangID foreign key(DonHangID) references DonHang(DonHangID)
go

--Nhập dữ liệu cho DB
INSERT INTO TaiKhoan
values('nv1','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('nv2','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('nv3','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('nv4','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('nv5','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('nv6','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('nv7','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('nv8','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('nv9','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('nv10','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin1','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin2','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin3','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin4','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin5','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin6','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin7','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin8','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin9','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('admin10','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe01','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe02','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe03','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe04','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe05','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe06','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe07','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe08','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe09','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('taixe10','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac01','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac02','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac03','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac04','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac05','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('doitac06','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac07','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac08','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac09','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('doitac10','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null), 
		('khachhang01','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang02','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang03','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang04','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang05','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang06','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang07','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang08','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang09','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null),
		('khachhang10','$2b$10$zjFUdoqac3awbxSdCwImG.EApvI1XDys2UXlbIRTVUOUCcXKwT.Im',null)

INSERT INTO TaiKhoanNganHang
values('001','0194278904','ocb',N'Bình Thạnh'), 
		('002','0294235454','ocb',N'Bình Thạnh'), 
		('003','0398765454','acb','pham van dong'), 
		('004','0494278904','ocb',N'Bình Thạnh'), 
		('005','0594235454','ocb',N'Bình Thạnh'), 
		('006','0698765454','acb',N'pham van dong'), 
		('007','0794278904','ocb',N'Bình Thạnh'), 
		('008','0894235454','ocb',N'Bình Thạnh'), 
		('009','0998765454','acb',N'pham van dong'), 
		('010','0094278904','ocb',N'Bình Thạnh'), 
		('011','0394235454','ocb',N'Bình Thạnh'), 
		('012','0698765454','acb',N'pham van dong'), 
		('013','094278904','ocb',N'Bình Thạnh'), 
		('014','0942335454','ocb',N'Bình Thạnh'), 
		('015','0987653454','acb',N'pham van dong'), 
		('016','094278904','ocb',N'Bình Thạnh'), 
		('017','0942353454','ocb',N'Bình Thạnh'), 
		('018','0987654454','acb',N'pham van dong'),
		('019','0942748904','ocb',N'Bình Thạnh'), 
		('020','0942435454','ocb',N'Bình Thạnh'),
		('021','0194278904','ocb',N'Bình Thạnh'), 
		('022','0294235454','ocb',N'Bình Thạnh'), 
		('023','0398765454','acb',N'pham van dong'), 
		('024','0494278904','ocb',N'Bình Thạnh'), 
		('025','0594235454','ocb',N'Bình Thạnh'), 
		('026','0698765454','acb',N'pham van dong'), 
		('027','0794278904','ocb',N'Bình Thạnh'), 
		('028','0894235454','ocb',N'Bình Thạnh'), 
		('029','0998765454','acb',N'pham van dong'), 
		('030','0094278904','ocb',N'Bình Thạnh')

INSERT INTO QuanTri
values('ad01',N'Lê Minh Phú','lmp@gmail.com','123452289','admin1'), 
	('ad02',N'Lê Minh Tâm','lmt@gmail.com','023452289','admin2'), 
	('ad03',N'Lê Minh Hoàng','lmh@gmail.com','013452289','admin3'), 
	('ad04',N'Lê  Phú','lp@gmail.com','012452289','admin4'), 
	('ad05',N'Lê  Tâm','lt@gmail.com','012352289','admin5'), 
	('ad06',N'Lê  Hoàng','lh@gmail.com','012342289','admin6'), 
	('ad07',N'Lê Minh ','lm@gmail.com','012345289','admin7'), 
	('ad08',N' Minh Tâm','mt@gmail.com','012345289','admin8'), 
	('ad09',N'Lê Minh Anh','lma@gmail.com','012452289','admin9'), 
	('ad10',N'Lê Minh Em','lme@gmail.com','012345289','admin10')


INSERT INTO NhanVien
values('nv01',N'Lê Minh Đức','lmd@gmail.com','0123456789','nv1'), 
		('nv02',N'Lê Minh Phúc','lmp@gmail.com','0123456789','nv2'), 
		('nv03',N'Lê Minh Anh','lma@gmail.com','0123456789','nv3'), 
		('nv04',N'Lê Minh My','lmm@gmail.com','0123456789','nv4'), 
		('nv05',N'Lê Minh ','lm@gmail.com','0123456789','nv5'), 
		('nv06',N'Lê Minh Trinh','lmt@gmail.com','0123456789','nv6'), 
		('nv07',N'Lê Minh Tú','lmtu@gmail.com','0123456789','nv7'), 
		('nv08',N'Lê Minh Cường','lmc@gmail.com','0123456789','nv8'), 
		('nv09',N'Lê Minh Hương','lmh@gmail.com','0123456789','nv9'), 
		('nv10',N'Lê Minh Xương','lmx@gmail.com','0123456789','nv10') 

INSERT INTO KhachHang
values('kh01',N'Nguyễn văn A','0123456789',N'123 cmt8 Tân Bình Hồ Chí Minh','nva@gmail.com','001','khachhang01'), 
	('kh02',N'Nguyễn văn B','0123456789',N'12 cmt8 Tân Bình Hồ Chí Minh','nvb@gmail.com','002','khachhang02'), 
	('kh03',N'Nguyễn văn C','0123456789',N'13 cmt8 Tân Bình Hồ Chí Minh','nvc@gmail.com','003','khachhang03'), 
	('kh04',N'Nguyễn văn D','0123456789',N'23 cmt8 Tân Bình Hồ Chí Minh','nvd@gmail.com','004','khachhang04'), 
	('kh05',N'Nguyễn văn E','0123456789',N'124 cmt8 Tân Bình Hồ Chí Minh','nve@gmail.com','005','khachhang05'), 
	('kh06',N'Nguyễn văn F','0123456789',N'125 cmt8 Tân Bình Hồ Chí Minh','nvf@gmail.com','006','khachhang06'), 
	('kh07',N'Nguyễn văn G','0123456789',N'126 cmt8 Tân Bình Hồ Chí Minh','nvg@gmail.com','007','khachhang07'), 
	('kh08',N'Nguyễn văn H','0123456789',N'127 cmt8 Tân Bình Hồ Chí Minh','nvh@gmail.com','008','khachhang08'), 
	('kh09',N'Nguyễn văn I','0123456789',N'128 cmt8 Tân Bình Hồ Chí Minh','nvi@gmail.com','009','khachhang09'), 
	('kh10',N'Nguyễn văn K','0123456789',N'129 cmt8 Tân Bình Hồ Chí Minh','nv@kgmail.com','010','khachhang10') 



INSERT INTO TaiXe
values('tx01',N'Dương Quá','123123123','1233455678',N'101 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dq@gmail.com','011','taixe01'),
('tx02',N'Dương Quá A','123123123','1233455678',N'102 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqa@gmail.com','012','taixe02'),
('tx03',N'Dương Quá B','123123123','1233455678',N'103 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqb@gmail.com','013','taixe03'),
('tx04',N'Dương Quá C','123123123','1233455678',N'104 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqc@gmail.com','014','taixe04'),
('tx05',N'Dương Quá D','123123123','1233455678',N'105 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqd@gmail.com','015','taixe05'),
('tx06',N'Dương Quá E','123123123','1233455678',N'106 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqe@gmail.com','016','taixe06'),
('tx07',N'Dương Quá F','123123123','1233455678',N'107 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqf@gmail.com','017','taixe07'),
('tx08',N'Dương Quá G','123123123','1233455678',N'108 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqg@gmail.com','018','taixe08'),
('tx09',N'Dương Quá H','123123123','1233455678',N'109 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqh@gmail.com','019','taixe09'),
('tx10',N'Dương Quá I','123123123','1233455678',N'110 Bắc Hải Quận 10 HCM','123321',N'Quận 10','dqi@gmail.com','020','taixe10')
	

INSERT INTO DoiTac
values
	('dt01','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac01'), 
	('dt02','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac02'),
	('dt03','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac03'),
	('dt04','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac04'),
	('dt05','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac05'),
	('dt06','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac06'),
	('dt07','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac07'),
	('dt08','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac08'),
	('dt09','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac09'),
	('dt10','nvb@gmail.com',N'Nguyễn văn b',3,4,N'345 Nguyễn Thị minh Khai quận 1 HCM','123456778',null,'doitac10')


---------

insert into ThucDon
values('thucdon01',N'bánh Tráng'),
('thucdon02',N'Trà sữa'),
('thucdon03',N'Bánh mỳ'),
('thucdon04',N'Bún'),
('thucdon05',N'Cơm'),
('thucdon06',N'Trà')

INSERT INTO HopDong
values('hopdong01','11111',N'Nguyễn văn b',1,'021','20221010','20241010',null,'nv01','dt01'),
('hopdong02','11111',N'Nguyễn văn b',1,'022','20221010','20241010',null,'nv02','dt02'),
('hopdong03','11111',N'Nguyễn văn b',1,'023','20221010','20241010',null,'nv02','dt03'),
('hopdong04','11111',N'Nguyễn văn b',1,'024','20221010','20241010',null,'nv03','dt04'),
('hopdong05','11111',N'Nguyễn văn b',1,'025','20221010','20241010',null,'nv03','dt05'),
('hopdong06','11111',N'Nguyễn văn b',1,'026','20221010','20241010',null,'nv05','dt06'),
('hopdong07','11111',N'Nguyễn văn b',1,'027','20221010','20241010',null,'nv05','dt07'),
('hopdong08','11111',N'Nguyễn văn b',1,'028','20221010','20241010',null,'nv06','dt08'),
('hopdong09','11111',N'Nguyễn văn b',1,'029','20221010','20241010',null,'nv07','dt09'),
('hopdong10','11111',N'Nguyễn văn b',1,'030','20221010','20241010',null,'nv09','dt10')



insert into Mon
values('mon01',N'Bánh tráng nướng',N'abc',10000,N'Còn','thucdon01', 'https://zinfood.com/upload/images/bi-quyet-nau-bun-bo-hue-ngon-cuc-dinh-2.jpg'),
('mon02',N'Bánh tráng Trộn',N'abc',10000,N'Còn','thucdon01', 'https://cdn.daotaobeptruong.vn/wp-content/uploads/2021/01/gioi-thieu-ve-banh-mi-viet-nam.jpg'),
('mon03',N'Bánh tráng Cuốn',N'abc',10000,N'Còn','thucdon01', 'https://monngonmoingay.com/wp-content/uploads/2019/03/pho-bo-bap-hoa-500.jpg'),
('mon04',N'Bánh tráng Tỏi',N'abc',10000,N'Còn','thucdon01', 'https://dauhomemade.vn/apps/uploads/2021/04/20210325-IMG_2718.jpg'),
('mon05',N'Bánh tráng Mở hành',N'abc',10000,N'Còn','thucdon01', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon06',N'Bánh tráng Tắc',N'abc',10000,N'Còn','thucdon01', 'https://ngonaz.com/wp-content/uploads/2021/09/cach-lam-ca-vien-chien-1.jpg'),
('mon07',N'Trà sữa truyền thống',N'abc',15000,N'Còn','thucdon02', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon08',N'Trà sữa thái xanh',N'abc',15000,N'Còn','thucdon02', 'https://cdn.daotaobeptruong.vn/wp-content/uploads/2021/01/gioi-thieu-ve-banh-mi-viet-nam.jpg'),
('mon09',N'Trà sữa thái đỏ',N'abc',15000,N'Còn','thucdon02', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon10',N'Trà sữa thạch ',N'abc',15000,N'Còn','thucdon02', 'https://ngonaz.com/wp-content/uploads/2021/09/cach-lam-ca-vien-chien-1.jpg'),
('mon11',N'Trà sữa phô mai',N'abc',15000,N'Còn','thucdon02', 'https://cdn.daotaobeptruong.vn/wp-content/uploads/2021/01/gioi-thieu-ve-banh-mi-viet-nam.jpg'),
('mon12',N'Bánh mỳ thịt',N'abc',15000,N'Còn','thucdon03', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon13',N'Bánh mỳ hà nội',N'abc',15000,N'Còn','thucdon03', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon14',N'Bánh mỳ thập cẩm',N'abc',15000,N'Còn','thucdon03', 'https://cdn.daotaobeptruong.vn/wp-content/uploads/2021/01/gioi-thieu-ve-banh-mi-viet-nam.jpg'),
('mon15',N'Bánh mỳ heo quay',N'abc',15000,N'Còn','thucdon03', 'https://ngonaz.com/wp-content/uploads/2021/09/cach-lam-ca-vien-chien-1.jpg'),
('mon16',N'Bánh mỳ dân tổ',N'abc',15000,N'Còn','thucdon03', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon17',N'Bún bò',N'abc',25000,N'Còn','thucdon04', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon18',N'Bún riêu',N'abc',25000,N'Còn','thucdon04', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon19',N'Bún miến',N'abc',25000,N'Còn','thucdon04', 'https://ngonaz.com/wp-content/uploads/2021/09/cach-lam-ca-vien-chien-1.jpg'),
('mon20',N'Cơm tấm',N'abc',25000,N'Còn','thucdon05', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon21',N'Cơm cháy',N'abc',25000,N'Còn','thucdon05', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon22',N'Cơm Chiên',N'abc',25000,N'Còn','thucdon05', 'https://ngonaz.com/wp-content/uploads/2021/09/cach-lam-ca-vien-chien-1.jpg'),
('mon23',N'Trà tắt',N'abc',15000,N'Còn','thucdon06', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg'),
('mon24',N'Trà đào',N'abc',15000,N'Còn','thucdon06', 'https://ngonaz.com/wp-content/uploads/2021/09/cach-lam-ca-vien-chien-1.jpg'),
('mon25',N'Trà chanh',N'abc',15000,N'Còn','thucdon06', 'https://yummyday.vn/uploads/images/cach-lam-banh-trang-tron-chay-2.jpg')


INSERT INTO ChiTietGioHang values
('gh01', 'kh01', 'mon02', 10, N'Đã Thêm'),
('gh02', 'kh01', 'mon03', 10, N'Đã Thêm'),
('gh03', 'kh01', 'mon01', 10, N'Đã Thêm'),
('gh04', 'kh01', 'mon04', 10, N'Đã Thêm'),
('gh05', 'kh01', 'mon05', 10, N'Đã Thêm'),
('gh06', 'kh02', 'mon06', 10, N'Đã Thêm'),
('gh07', 'kh02', 'mon07', 10, N'Đã Thêm'),
('gh08', 'kh02', 'mon08', 10, N'Đã Thêm'),
('gh09', 'kh03', 'mon09', 10, N'Đã Thêm'),
('gh10', 'kh03', 'mon10', 10, N'Đã Thêm'),
('gh11', 'kh04', 'mon11', 10, N'Đã Thêm'),
('gh12', 'kh04', 'mon12', 10, N'Đã Thêm'),
('gh13', 'kh04', 'mon13', 10, N'Đã Thêm'),
('gh14', 'kh05', 'mon14', 10, N'Đã Thêm'),
('gh15', 'kh05', 'mon15', 10, N'Đã Thêm'),
('gh16', 'kh05', 'mon16', 10, N'Đã Thêm'),
('gh17', 'kh05', 'mon17', 10, N'Đã Thêm'),
('gh18', 'kh05', 'mon18', 10, N'Đã Thêm'),
('gh19', 'kh06', 'mon19', 10, N'Đã Thêm'),
('gh20', 'kh06', 'mon20', 10, N'Đã Thêm'),
('gh21', 'kh06', 'mon21', 10, N'Đã Thêm')


INSERT INTO Quan
values('quan01',N'Tam Mao',N'Ăn Vặt','20221022',N'Còn','dt01'),
('quan02',N'Chú 10',N'Ăn Vặt','20221022',N'Còn','dt02'),
('quan03',N'Cô Pa',N'Ăn Vặt','20221022',N'Còn','dt03'),
('quan04',N'Hai Mão',N'Ăn Vặt','20221022',N'Còn','dt04'),
('quan05',N'Vĩa hè',N'Ăn Vặt','20221022',N'Còn','dt05'),
('quan06',N'LALALA',N'Ăn Vặt','20221022',N'Còn','dt06'),
('quan07',N'PaPa',N'Ăn Vặt','20221022',N'Còn','dt07'),
('quan08',N'Chiều tà',N'Ăn Vặt','20221022',N'Còn','dt08'),
('quan09',N'Ngày Mai',N'Ăn Vặt','20221022',N'Còn','dt09'),
('quan10',N'Ông sao',N'Ăn Vặt','20221022',N'Còn','dt10')


insert into ChiNhanh
values('chinhanh01',N'Tam Mao',N'33 Cao Thắng Quận 1 HCM','07:00','20:00','quan01','hopdong01','thucdon01',null, 'https://bunboha.com/wp-content/uploads/2022/09/Logo-Bun-bo-Ha.jpg'),
('chinhanh02',N'Chú 10',N'334 Sala Quận 2 HCM','07:00','20:00','quan02','hopdong02','thucdon01',null, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAgijJtB1J9JJk9Q05xCzVmoG69FiEt5XeNAypBp0yAr9EnKGCIX74glHoEjXZi8J7z8Y&usqp=CAU'),
('chinhanh03',N'Cô Pa',N'323 Cao Thắng Quận 3 HCM','07:00','20:00','quan03','hopdong03','thucdon02',null, 'https://bunboha.com/wp-content/uploads/2022/09/Logo-Bun-bo-Ha.jpg'),
('chinhanh04',N'Hai Mão',N'353 Bắt Vinh Quận 4 HCM','07:00','20:00','quan04','hopdong04','thucdon02',null, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEmaDIC-Q0XeWMxmTmckkxV3uJ-hlHHWGKuyGmC2UqN9u_WBJS0mQHX8iiDxCjhQ26_U0&usqp=CAU'),
('chinhanh05',N'Vĩa hè',N'336 Hùng Vương Quận 5 HCM','07:00','20:00','quan05','hopdong05','thucdon03',null, 'https://bunboha.com/wp-content/uploads/2022/09/Logo-Bun-bo-Ha.jpg'),
('chinhanh06',N'LALALA',N'337 Rạch giá Quận 6 HCM','07:00','20:00','quan06','hopdong06','thucdon03',null, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEmaDIC-Q0XeWMxmTmckkxV3uJ-hlHHWGKuyGmC2UqN9u_WBJS0mQHX8iiDxCjhQ26_U0&usqp=CAU'),
('chinhanh07',N'PaPa',N'338 Vân Hà Quận 7 HCM','07:00','20:00','quan07','hopdong07','thucdon04',null, 'https://bunboha.com/wp-content/uploads/2022/09/Logo-Bun-bo-Ha.jpg'),
('chinhanh08',N'Chiều tà',N'233 Bạch đằng Quận 8 HCM','07:00','20:00','quan08','hopdong08','thucdon04',null, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRUvKM1vMAbOoHY4jOqgZc4Ca9F-Mi8nJnrQ&usqp=CAU'),
('chinhanh09',N'Ngày Mai',N'133 Cao Vân Quận 9 HCM','07:00','20:00','quan09','hopdong09','thucdon05',null, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAgijJtB1J9JJk9Q05xCzVmoG69FiEt5XeNAypBp0yAr9EnKGCIX74glHoEjXZi8J7z8Y&usqp=CAU'),
('chinhanh10',N'Ông sao',N'323 CMT8 Quận 10 HCM','07:00','20:00','quan10','hopdong10','thucdon06',null, 'https://bunboha.com/wp-content/uploads/2022/09/Logo-Bun-bo-Ha.jpg')


insert into DonHang(NguoiNhan, SoDienThoai, DiaChiNhanHang, NgayDatHang, PhiSanPham, PhiVanChuyen, TrangThai, KhachHangID, TaiXeID)
values
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh01','tx01'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh02','tx02'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh03','tx03'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh04','tx04'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh05','tx05'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh06','tx06'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh07','tx07'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh08','tx08'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh09','tx09'),
('abc','0987654321',N'123 nguyễn văn cừ quận 5 hcm','20221022',10000,15000,N'Đang Giao','kh10','tx10'),
('bac','0123456789',N'123 nguyễn văn cừ quận 5 hcm','20221022',20000,15000,N'Đã Nhận','kh10','tx10'),

insert into ChiTietDonHang
values('mon01',1 ,3,10000,'abc','5 sao'),
('mon02',2 ,3,10000,'abc','5 sao'),
('mon03',3 ,3,10000,'abc','5 sao'),
('mon04',4,3,10000,'abc','5 sao'),
('mon05',5,3,10000,'abc','5 sao'),
('mon06',6,3,10000,'abc','5 sao'),
('mon07',7,3,10000,'abc','5 sao'),
('mon08',8,3,10000,'abc','5 sao'),
('mon09',9,3,10000,'abc','5 sao'),
('mon10',10,3,10000,'abc','5 sao')

--test
select * from ChiNhanh
select * from ChiTietDonHang
select * from DoiTac
select * from DonHang
select * from HopDong
select * from KhachHang
select * from Mon
select * from NhanVien
select * from Quan
select * from QuanTri
select * from TaiKhoan
select * from TaiKhoanNganHang
select * from TaiXe--
select * from ThucDon
select * from ChiTietGioHang
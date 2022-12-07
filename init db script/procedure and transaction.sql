--Cập nhật giỏ hàng
use ESHOPPING
go

create PROC CapNhatGioHang
	@magh char(50), @makh char(50), @idmon  char(50), @soluong int
AS
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai tai khoan
		IF EXISTS (SELECT * FROM ChiTietGioHang WHERE KhachHangID = @makh and MonID = @idmon and TrangThai = N'Đã Thêm')
			BEGIN
				update ChiTietGioHang set SoLuong = SoLuong + @soluong where  KhachHangID = @makh and MonID = @idmon			
				commit
				RETURN 1
			END
		ELSE
			begin 
				insert into ChiTietGioHang values (@magh, @makh , @idmon, @soluong, N'Đã Thêm')
				commit
				return 1
			end
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 0
		end catch
		
go

--Them Chi tiết đơn hàng
CREATE PROC ThemChiTietDonHang
	@idmon char(50), @soluong int, @gia int 
AS
BEGIN TRANSACTION
	begin try
	--
		declare @idDonHang int
		set @idDonHang = (select max(DonHangID) from DonHang)
		insert into ChiTietDonHang(MonID, DonHangID, SoLuong, GiaBan) 
		values (@idmon, @idDonHang, @soluong, @gia)
		commit
		return 1
	end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 0
		end catch
		
go

--TRANH CHẤP ĐỒNG THỜI

--19120565 - Nguyễn Văn Lợi
--Tình huống 1: Lost update trên DonHang(TrangThai)
--Chưa fix:
--Đối tác chấp nhận đơn hàng, đơn hàng chuyển qua trạng thái "Tiếp Nhận"
create proc pDoiTacChapNhanDonHang @maDH char(10)
as
	begin transaction
		begin try
			--kiem tra ma don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDH)
			begin
				print N'Mã đơn hàng không tồn tại!'
				rollback transaction
				return 0
			end

			--lost update xay ra o day, khi co transaction khac chen vao
			waitfor delay '00:00:10'

			--cap nhat chap nhan don hang
			update DonHang
			set TrangThai = N'Tiếp Nhận'
			where DonHangID = @maDH

			--xac nhan hoan thanh transaction
			commit transaction
			print N'Đã tiếp nhận đơn hàng thành công!'
			return 1
		end try
		
		begin catch
			print N'Hệ thống xảy ra lỗi, hãy thử lại!'
			rollback transaction
			return 0
		end catch
go

--Khách hàng hủy đơn hàng đã đặt và đơn hàng đang trong trạng thái "Chờ Nhận"
create proc pKhachHangHuyDonHang @maDH char(10)
as
	begin transaction
		begin try
			--kiem tra ma don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDH)
			begin
				print N'Mã đơn hàng không tồn tại!'
				rollback transaction
				return 0
			end

			--kiem tra trang thai don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDH and DonHang.TrangThai = N'Chờ Nhận')
			begin
				print N'Đơn hàng không được phép hủy!'
				rollback transaction
				return 0
			end

			--cap nhat huy don hang
			update DonHang
			set TrangThai = N'Đã Hủy'
			where DonHang.DonHangID = @maDH

			--xac nhan hoan thanh transaction
			commit transaction
			print N'Đã hủy đơn hàng thành công!'
			return 1
		end try
		begin catch
			print N'Hệ thống xảy ra lỗi, hãy thử lại!'
			rollback transaction
			return 0
		end catch
go

--Đã fix:
--Đối tác chấp nhận đơn hàng, đơn hàng chuyển qua trạng thái "Tiếp Nhận"
create proc pDoiTacChapNhanDonHang_Fix @maDH char(10)
as
	begin transaction
	set transaction isolation level serializable
		begin try
			--kiem tra ma don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDH)
			begin
				print N'Mã đơn hàng không tồn tại!'
				rollback transaction
				return 0
			end

			--lost update xay ra o day, khi co transaction khac chen vao
			waitfor delay '00:00:10'

			--cap nhat chap nhan don hang
			update DonHang
			set TrangThai = N'Tiếp Nhận'
			where DonHangID = @maDH

			--xac nhan hoan thanh transaction
			commit transaction
			print N'Đã tiếp nhận đơn hàng thành công!'
			return 1
		end try
		
		begin catch
			print N'Hệ thống xảy ra lỗi, hãy thử lại!'
			rollback transaction
			return 0
		end catch
go

--Khách hàng hủy đơn hàng đã đặt và đơn hàng đang trong trạng thái "Chờ Nhận"
create proc pKhachHangHuyDonHang_Fix @maDH char(10)
as
	begin transaction
	set transaction isolation level serializable
		begin try
			--kiem tra ma don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDH)
			begin
				print N'Mã đơn hàng không tồn tại!'
				rollback transaction
				return 0
			end

			--kiem tra trang thai don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDH and DonHang.TrangThai = N'Chờ Nhận')
			begin
				print N'Đơn hàng không được phép hủy!'
				rollback transaction
				return 0
			end

			--cap nhat huy don hang
			update DonHang
			set TrangThai = N'Đã Hủy'
			where DonHang.DonHangID = @maDH

			--xac nhan hoan thanh transaction
			commit transaction
			print N'Đã hủy đơn hàng thành công!'
			return 1
		end try
		begin catch
			print N'Hệ thống xảy ra lỗi, hãy thử lại!'
			rollback transaction
			return 0
		end catch
go

--Tình huống 2: Lost update trên DonHang(TaiXe)
--Chưa fix:
--Cập nhật tài xế nhận đơn hàng
create proc pTaiXeNhanDonHang @maTaiXe char(10), @maDonHang int
as
	begin transaction
		begin try
			--kiem tra ma don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDonHang)
			begin
				print N'Mã đơn hàng không tồn tại!'
				rollback transaction
				return 0
			end

			--kiem tra ma tai xe
			if not exists(select * from TaiXe where TaiXe.TaiXeID = @maTaiXe)
			begin
				print N'Mã tài xế không tồn tại!'
				rollback transaction
				return 0
			end

			--kiem tra dieu kien cap nhat
			if not exists(
				select * from DonHang 
				where DonHang.DonHangID = @maDonHang and DonHang.TrangThai = N'Chờ Nhận')
			begin
				print N'Đơn hàng đang giao!'
				rollback transaction
			end

			--tranh chap lost update tai day
			waitfor delay '00:00:10'

			--cap nhat tai xe da nhan don hang
			update DonHang
			set TaiXeID = @maTaiXe, TrangThai = N'Đang Giao'
			where DonHang.DonHangID = @maDonHang

			print N'Tài xế nhận đơn hàng thành công!'
			commit transaction
			return 1
		end try

		begin catch
			print N'Lỗi hệ thống!'
			rollback transaction
			return 0
		end catch
go
--Đã fix:
--Cập nhật tài xế nhận đơn hàng
create proc pTaiXeNhanDonHang_Fix @maTaiXe char(10), @maDonHang int
as
	begin transaction
	set transaction isolation level serializable
		begin try
			--kiem tra ma don hang
			if not exists(select * from DonHang where DonHang.DonHangID = @maDonHang)
			begin
				print N'Mã đơn hàng không tồn tại!'
				rollback transaction
				return 0
			end

			--kiem tra ma tai xe
			if not exists(select * from TaiXe where TaiXe.TaiXeID = @maTaiXe)
			begin
				print N'Mã tài xế không tồn tại!'
				rollback transaction
				return 0
			end

			--kiem tra dieu kien cap nhat
			if not exists(
				select * from DonHang 
				where DonHang.DonHangID = @maDonHang and DonHang.TrangThai = N'Chờ Nhận')
			begin
				print N'Đơn hàng đang giao!'
				rollback transaction
			end

			--tranh chap lost update tai day
			waitfor delay '00:00:10'

			--cap nhat tai xe da nhan don hang
			update DonHang
			set TaiXeID = @maTaiXe, TrangThai = N'Đang Giao'
			where DonHang.DonHangID = @maDonHang

			print N'Tài xế nhận đơn hàng thành công!'
			commit transaction
			return 1
		end try

		begin catch
			print N'Lỗi hệ thống!'
			rollback transaction
			return 0
		end catch
go

--Tình huống 3: Phantom trên TaiKhoan(Username)
--Chưa fix:
--Tạo tài khoản mới cho khách hàng
create proc pTaoTaiKhoan @username varchar(50), @hashPassword text
as
	begin transaction
		begin try
			--kiem tra usename trong he thong
			if exists(select * from TaiKhoan where TaiKhoan.Username = @username)
			begin
				print N'Username đã tồn tại!'
				rollback transaction
				return 0
			end

			--tranh chap tai day, do co 1 username cung gia tri, duoc them vao o transaction khac
			waitfor delay '00:00:10'

			--them tai khoan moi
			insert into TaiKhoan values(@username, @hashPassword, N'Hoạt Động')

			--hoan thanh giao tac
			print N'Tạo tài khoản thành công!'
			commit transaction
			return 1
		end try

		begin catch
			print N'Lỗi hệ thống!'
			rollback transaction
			return
		end catch
go

--Đã fix:
--Tạo tài khoản mới cho khách hàng
create proc pTaoTaiKhoan_Fix @username varchar(50), @hashPassword text
as
	begin transaction
	set transaction isolation level serializable
		begin try
			--kiem tra usename trong he thong
			if exists(select * from TaiKhoan where TaiKhoan.Username = @username)
			begin
				print N'Username đã tồn tại!'
				rollback transaction
				return 0
			end

			--tranh chap tai day, do co 1 username cung gia tri, duoc them vao o transaction khac
			waitfor delay '00:00:10'

			--them tai khoan moi
			insert into TaiKhoan values(@username, @hashPassword, N'Hoạt Động')

			--hoan thanh giao tac
			print N'Tạo tài khoản thành công!'
			commit transaction
			return 1
		end try

		begin catch
			print N'Lỗi hệ thống!'
			rollback transaction
			return
		end catch
go

-- 19120585-Nguyễn Hải Nhật Minh
-- Tình huống 1: Dirty Read Trên DonHang(TrangThai)
-- Khách hàng hủy đơn hàng đơn hàng
create PROC pCapNhatTrangThaiDonHang
	@DonHangID char(10), @TrangThai nvarchar(20)
AS
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @DonHangID)
			BEGIN
				PRINT 'id ' + @DonHangID + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			begin 
				
				if exists (select * from DonHang where DonHangID = @DonHangID and TrangThai != @TrangThai)
					begin
						update DonHang
						set TrangThai = @TrangThai
						where DonHangID = @DonHangID and TrangThai != @TrangThai
					end
			end
			WAITFOR DELAY '00:00:15'
			-- Nếu phí vận chuyển nhỏ hơn 20000, khách hàng không thể hủy đơn hàng có phí vận chuyển < 20000
			if exists (select * from DonHang dh where dh.PhiVanChuyen < 20000 and DonHangID = @DonHangID)
			print 'Cap nhat khong thanh cong'	
			rollback transaction
			return
		end try
		
		begin catch
			print N'Đã xảy ra lỗi!'	
			rollback transaction
			return 
		end catch
		
		commit
go
-- Tài xế xem danh sách đơn hàng trong khu vực hoạt động
create PROC pXemDanhSachDonHang
	@DonHangID char(10), @taixeId char(50) 
AS
set transaction isolation level read uncommitted
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @DonHangID)
			BEGIN
				PRINT 'id ' + @DonHangID + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			declare @vitri ntext
			set @vitri = (select KhuVucHoatDong from TaiXe where TaiXeID = @taixeId)
			-- Hiển thị các đơn hàng ở khu vực mà tài xế hoạt động 
			select * from DonHang where DonHangID = @DonHangID and DiaChiNhanHang like '%' + @vitri + '%'
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 
		end catch
		commit
go

-- Đã fix:
-- Tài xế xem danh sách đơn hàng trong khu vực hoạt động
create PROC pXemDanhSachDonHang_Fix
	@DonHangID char(10), @taixeId char(50) 
AS
set transaction isolation level read uncommitted
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @DonHangID)
			BEGIN
				PRINT 'id ' + @DonHangID + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			declare @vitri ntext
			set @vitri = (select KhuVucHoatDong from TaiXe where TaiXeID = @taixeId)
			-- Hiển thị các đơn hàng ở khu vực mà tài xế hoạt động 
			select * from DonHang where DonHangID = @DonHangID and DiaChiNhanHang like '%' + @vitri + '%'
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 
		end catch
		commit
go
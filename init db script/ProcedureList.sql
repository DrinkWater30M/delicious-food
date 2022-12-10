--Procedure và Transaction(Có tranh chấp và fix tranh chấp)
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
-- Chưa fix:
-- Khách hàng hủy đơn hàng 
create PROC pKhachHangHuyDonHang
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
				begin
					print 'Cap nhat khong thanh cong'	
					rollback transaction
					return
				end
		end try
		
		begin catch
			print N'Đã xảy ra lỗi!'	
			rollback transaction
			return 
		end catch
		
		commit
go
-- Tài xế xem danh sách đơn hàng trong khu vực hoạt động
CREATE PROC pTaiXeXemDanhSachDonHang
	 @taixeId char(50) 
AS
set transaction isolation level read uncommitted
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM TaiXe WHERE TaiXeID = @taixeId)
			BEGIN
				PRINT 'id ' + @taixeId + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE 
			select * from DonHang where cast(DiaChiNhanHang as nvarchar) like '%' + cast((select KhuVucHoatDong from TaiXe where TaiXeID = @taixeId)as nvarchar) + '%'
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
CREATE PROC pTaiXeXemDanhSachDonHang_Fix
	 @taixeId char(50) 
AS
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM TaiXe WHERE TaiXeID = @taixeId)
			BEGIN
				PRINT 'id ' + @taixeId + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			 
			select * from DonHang where cast(DiaChiNhanHang as nvarchar) like '%' + cast((select KhuVucHoatDong from TaiXe where TaiXeID = @taixeId)as nvarchar) + '%'
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 
		end catch
		commit
go
--- Tình huống 2: Dirty read trên DonHang(TrangThai)
-- Chưa fix:
-- Tài xế nhận đơn hàng
create PROC pTaiXeNhanDonHang
	@DonHangID char(10), @taixeId char(50), @TrangThai nvarchar(20)
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
			-- Tài xế không được nhận quá 3 đơn trong cùng 1 ngày
			declare @count int
			set @count = (select count(*) from DonHang where TaiXeID = @taixeId
					group by NgayDatHang)
			if (@count > 3)
				begin
					print 'Cap nhat khong thanh cong'	
					rollback transaction
					return
				end
		end try
		
		begin catch
			print N'Đã xảy ra lỗi!'	
			rollback transaction
			return 
		end catch
		
		commit
go
-- Khách hàng kiểm tra đơn hàng của mình
create PROC pKhachHangKiemTraDonHang
	@khachhangID char(50)
AS
set transaction isolation level read uncommitted
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM DonHang WHERE KhachHangID = @khachhangID)
			BEGIN
				PRINT 'id ' + @khachhangID + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			
			-- Hiển thị các đơn hàng của khách hàng 
			select * from DonHang where KhachHangID = @khachhangID
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 
		end catch
		commit
go

-- Đã fix:
create PROC pKhachHangKiemTraDonHang_Fix
	@khachhangID char(50)
AS
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai id
		IF NOT EXISTS (SELECT * FROM DonHang WHERE KhachHangID = @khachhangID)
			BEGIN
				PRINT 'id ' + @khachhangID + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			
			-- Hiển thị các đơn hàng của khách hàng 
			select * from DonHang where KhachHangID = @khachhangID
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 
		end catch
		commit
go

--20120289 - Võ Minh Hiếu
--UNREPEATABLE READ
--Mô tả: Khách hàng muốn xem đánh giá món ăn, trong khi đó đối tác xóa món ăn khách hàng cần xem đánh giá.
--Thao tác xem của khách hàng không báo lỗi nhưng không hiển thị ra món ăn cần xem
--T1: Khách hàng xem đánh giá món ăn thuộc một đơn hàng
--T2: Đối tác xóa món ăn

--T1:
CREATE
--ALTER
PROC usr_XemDanhGiaMonAn
	@KhachHangID char(50),
	@DonHangID int,
	@MonID char(50)
AS
	BEGIN TRAN
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE KhachHangID = @KhachHangID AND DonHangID = @DonHangID)
				BEGIN
					PRINT N'Không tồn tại đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END
			IF NOT EXISTS (SELECT * FROM ChiTietDonHang WHERE DonHangID = @DonHangID AND MonID = @MonID)
				BEGIN
					PRINT N'Không tồn tại chi tiết đơn hàng với mã món ăn = ' + CAST(@MonID AS NVARCHAR)
					ROLLBACK TRAN
					RETURN 0
				END
			WAITFOR DELAY '00:00:10'

			SELECT M.TenMon, CTDH.DanhGia
			FROM ChiTietDonHang CTDH, Mon M
			WHERE CTDH.DonHangID = @DonHangID AND CTDH.MonID = @MonID AND CTDH.MonID = M.MonID
		END TRY

		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--T2:
CREATE
--ALTER
PROC doitac_XoaMonAn
	@monid char(50)
AS
	BEGIN TRAN
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM Mon WHERE MonID = @monid)
				BEGIN
					PRINT N'Không tồn tại món ăn'
					ROLLBACK TRAN
					RETURN 0
				END

			--xóa ở chi tiết giỏ hàng
			IF EXISTS (SELECT * FROM ChiTietGioHang WHERE MonID = @monid)
				BEGIN
					DELETE FROM ChiTietGioHang
					WHERE MonID = @monid
				END

			--xóa ở Chi tiết đơn hàng
			IF EXISTS (SELECT * FROM ChiTietDonHang WHERE MonID = @monid)
				BEGIN
					DELETE FROM ChiTietDonHang
					WHERE MonID = @monid
				END
			
			DELETE FROM Mon
			WHERE MonID = @monid
		END TRY
		
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--Fix T1
CREATE
--ALTER
PROC usr_XemDanhGiaMonAn_FIX
	@KhachHangID char(50),
	@DonHangID int,
	@MonID char(50)
AS
	BEGIN TRAN
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE KhachHangID = @KhachHangID AND DonHangID = @DonHangID)
				BEGIN
					PRINT N'Không tồn tại đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END
			IF NOT EXISTS (SELECT * FROM ChiTietDonHang WHERE DonHangID = @DonHangID AND MonID = @MonID)
				BEGIN
					PRINT N'Không tồn tại chi tiết đơn hàng với mã món ăn = ' + CAST(@MonID AS NVARCHAR)
					ROLLBACK TRAN
					RETURN 0
				END
			WAITFOR DELAY '00:00:10'

			SELECT M.TenMon, CTDH.DanhGia
			FROM ChiTietDonHang CTDH, Mon M
			WHERE CTDH.DonHangID = @DonHangID AND CTDH.MonID = @MonID AND CTDH.MonID = M.MonID
		END TRY

		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--DIRTY READ
--Mô tả: Đối tác đang thêm món ăn nhưng xảy ra sự cố (giao tác ROLLBACK mô phỏng sự cố xảy ra), khách hàng vào xem những
--món ăn của đối tác, thấy món ăn đối tác định thêm nhưng không thể thao tác do chưa được ghi xuống hệ thống
--T1: Đối tác thêm món ăn
--T2: Khách hàng xem các món ăn của đối tác
--T1:
CREATE
--ALTER
PROC doitac_ThemMonAn
	@monid char(50),
	@tenmon nvarchar(50),
	@mieuta text,
	@gia int,
	@tinhtrang nvarchar(20),
	@thucdonid char(50),
	@linkhinhanh text
AS
	BEGIN TRAN
		BEGIN TRY
			IF NOT EXISTS (SELECT  * FROM ThucDon WHERE ThucDonID = @thucdonid)
				BEGIN
					PRINT N'Không tồn tại thực đơn'
					ROLLBACK TRAN
					RETURN 0
				END
			IF EXISTS (SELECT * FROM Mon WHERE MonID = @monid AND ThucDonID = @thucdonid)
				BEGIN
					PRINT N'Đã tồn tại món ăn trong thực đơn'
					ROLLBACK TRAN
					RETURN 0
				END

			INSERT INTO Mon
			VALUES(@monid, @tenmon, @mieuta, @gia, @tinhtrang, @thucdonid, @linkhinhanh)
			WAITFOR DELAY '00:00:10'

			--Giả sử hệ thống xảy ra lỗi, phải rollback
			ROLLBACK TRAN
			RETURN 0
			
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--T2:
CREATE
--ALTER
PROC usr_XemDSMonAn
	@chinhanhid char(50)
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM ChiNhanh WHERE ChiNhanhID = @chinhanhid)
				BEGIN
					PRINT N'Không tồn tại chi nhánh'
					ROLLBACK TRAN
					RETURN 0
				END
			SELECT M.*, CN.TenChiNhanh
			FROM Mon M JOIN ChiNhanh CN ON CN.ThucDonID = M.ThucDonID
			WHERE CN.ChiNhanhID = @chinhanhid

		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--FIX T2
CREATE
--ALTER
PROC usr_XemDSMonAn_FIX
	@chinhanhid char(50)
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM ChiNhanh WHERE ChiNhanhID = @chinhanhid)
				BEGIN
					PRINT N'Không tồn tại chi nhánh'
					ROLLBACK TRAN
					RETURN 0
				END
			SELECT M.*, CN.TenChiNhanh
			FROM Mon M JOIN ChiNhanh CN ON CN.ThucDonID = M.ThucDonID
			WHERE CN.ChiNhanhID = @chinhanhid

		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--Conversion deadlock
--Mô tả: Đối tác và khách hàng cùng xem tình trạng đơn hàng giữ khóa đọc,
--cả hai cần ghi trên đơn hàng nhưng không ghi được do không xin được khóa ghi, xảy ra deadlock
--T1: Đối tác nhận đơn hàng
--T2: khách hàng hủy đơn hàng
--T1:
CREATE
--ALTER
PROC doitac_NhanDonHang
	@donhangid int
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @donhangid)
				BEGIN
					PRINT N'Không tồn tại đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END

			DECLARE @trangthai nvarchar(20)
			SET @trangthai = (SELECT TrangThai FROM DonHang WHERE DonHangID = @donhangid)

			WAITFOR DELAY '00:00:10'

			IF @trangthai = N'Chờ nhận'
				BEGIN
					SET @trangthai = N'Đang chuẩn bị'
					UPDATE DonHang
					SET TrangThai = @trangthai
					WHERE DonHangID = @donhangid
				END
			ELSE
				BEGIN
					PRINT N'Không thể nhận đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--T2:
CREATE 
--ALTER
PROC usr_HuyDonHang
	@donhangid int
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @donhangid)
					BEGIN
						PRINT N'Không tồn tại đơn hàng'
						ROLLBACK TRAN
						RETURN 0
					END

			DECLARE @trangthai nvarchar(20)
			SET @trangthai = (SELECT TrangThai FROM DonHang WHERE DonHangID = @donhangid)


			IF @trangthai = N'Chờ nhận'
				BEGIN
					SET @trangthai = N'Đã hủy'
					UPDATE DonHang
					SET TrangThai = @trangthai
					WHERE DonHangID = @donhangid
				END
			ELSE
				BEGIN
					PRINT N'Không thể hủy đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--Fix T1
CREATE
--ALTER
PROC doitac_NhanDonHang_Fix
	@donhangid int
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @donhangid)
				BEGIN
					PRINT N'Không tồn tại đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END

			DECLARE @trangthai nvarchar(20)
			SET @trangthai = (SELECT TrangThai FROM DonHang with (XLOCK, HOLDLOCK) WHERE DonHangID = @donhangid)

			WAITFOR DELAY '00:00:10'

			IF @trangthai = N'Chờ nhận'
				BEGIN
					SET @trangthai = N'Đang chuẩn bị'
					UPDATE DonHang
					SET TrangThai = @trangthai
					WHERE DonHangID = @donhangid
				END
			ELSE
				BEGIN
					PRINT N'Không thể nhận đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--Cycle Deadlock
--Mô tả: Đối tác nhận đơn hàng và update hết món, giữ X lock trên đơn hàng và yêu cầu X lock trên món
--Khách hàng xem còn món và đặt hàng, giữ S lock trên món và yêu cầu X lock trên đơn hàng, xảy ra deadlock
--T1: Đối tác nhận đơn hàng và update món
--T2: Khách hàng xem món và đặt đơn hàng
--T1:
CREATE 
--ALTER
PROC doitac_NhanDonHangVaCapNhatMon
	@donhangid int
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @donhangid)
				BEGIN
					PRINT N'Không tồn tại đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END

			DECLARE @trangthai nvarchar(20)
			SET @trangthai = (SELECT TrangThai FROM DonHang WHERE DonHangID = @donhangid)

			IF @trangthai = N'Chờ nhận'
				BEGIN
					SET @trangthai = N'Đang chuẩn bị'
					UPDATE DonHang
					SET TrangThai = @trangthai
					WHERE DonHangID = @donhangid
				END
			ELSE
				BEGIN
					PRINT N'Không thể nhận đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END

			DECLARE @monid char(50)
			SET @monid = (SELECT MonID FROM ChiTietDonHang WHERE DonHangID = @donhangid)

			WAITFOR DELAY '00:00:10'

			UPDATE Mon
			SET TinhTrang = N'Hết'
			WHERE MonID = @monid
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--T2:
CREATE
--ALTER
PROC usr_XemTinhTrangMonVaDatHang
	@monid char(50),
	@nguoinhan nvarchar(50),
	@sdt char(10),
	@diachi ntext,
	@ngaydat date,
	@phi int,
	@ship int,
	@trangthai nvarchar(20),
	@khachhangid char(50),
	@soluong int,
	@gia int,
	@ghichu ntext,
	@danhgia nvarchar(20)
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM Mon WHERE MonID = @monid)
				BEGIN
					PRINT N'Không tồn tại món ăn'
					ROLLBACK TRAN
					RETURN 0
				END
			DECLARE @tinhtrang nvarchar(20)
			SET @tinhtrang = (SELECT TinhTrang FROM Mon WHERE MonID = @monid)

			IF @tinhtrang != 'Còn'
				BEGIN
					PRINT N'Món ăn hết. Không thể đặt'
					ROLLBACK TRAN
					RETURN 0
				END

			INSERT INTO DonHang(NguoiNhan, SoDienThoai, DiaChiNhanHang, NgayDatHang, PhiSanPham, PhiVanChuyen, TrangThai, KhachHangID, TaiXeID)
			VALUES (@nguoinhan, @sdt, @diachi, @ngaydat, @phi, @ship, @trangthai, @khachhangid, NULL)

			DECLARE @donhangid int
			SET @donhangid = (SELECT DonHangID FROM DonHang WHERE NguoiNhan = @nguoinhan AND SoDienThoai = @sdt AND  KhachHangID = @khachhangid)
			INSERT INTO ChiTietDonHang
			VALUES (@monid, @donhangid, @soluong, @gia, @ghichu, @danhgia)
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO

--Fix T1:
CREATE 
--ALTER
PROC doitac_NhanDonHangVaCapNhatMon_Fix
	@donhangid int
AS
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM DonHang WHERE DonHangID = @donhangid)
				BEGIN
					PRINT N'Không tồn tại đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END

			DECLARE @trangthai nvarchar(20)
			SET @trangthai = (SELECT TrangThai FROM DonHang WHERE DonHangID = @donhangid)

			IF @trangthai = N'Chờ nhận'
				BEGIN
					SET @trangthai = N'Đang chuẩn bị'
					UPDATE DonHang
					SET TrangThai = @trangthai
					WHERE DonHangID = @donhangid
				END
			ELSE
				BEGIN
					PRINT N'Không thể nhận đơn hàng'
					ROLLBACK TRAN
					RETURN 0
				END

			DECLARE @monid char(50)
			SET @monid = (SELECT MonID FROM ChiTietDonHang WHERE DonHangID = @donhangid)
			
			DECLARE @tinhtrang nvarchar(20)
			SET @tinhtrang = (SELECT TinhTrang FROM Mon WITH (TABLOCKX, HOLDLOCK) WHERE MonID = @monid)

			WAITFOR DELAY '00:00:10'

			SET @tinhtrang = N'Hết'
			UPDATE Mon
			SET TinhTrang = @tinhtrang
			WHERE MonID = @monid
		END TRY
		BEGIN CATCH
			PRINT N'Hệ thống xảy ra lỗi, hãy thử lại!'
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	COMMIT TRAN
	RETURN 1
GO
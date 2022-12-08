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

--20120289 - Võ Minh Hiếu
--UNREPEATETABLE READ
--Mô tả: Khách hàng muốn xem đánh giá món ăn, trong khi đó đối tác xóa món ăn khách hàng cần xem đánh giá.
--Thao tác xem của khách hàng không báo lỗi nhưng không hiển thị ra món ăn cần xem
--T1: T1: Khách hàng xem đánh giá món ăn thuộc một đơn hàng
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

--Fix lỗi
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

--FIX
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
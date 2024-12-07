-- 11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
CREATE TRIGGER TRG_HD_KH ON HOADON FOR INSERT
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME, @MAKH CHAR(4)
	SELECT @NGHD = NGHD, @MAKH = MAKH FROM INSERTED
	SELECT	@NGDK = NGDK FROM KHACHHANG WHERE MAKH = @MAKH

	IF (@NGHD >= @NGDK)
		PRINT N'Thành công.'
	ELSE
	BEGIN
		PRINT N'Không thành công.'
		ROLLBACK TRANSACTION
	END
END
GO

-- 12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
CREATE TRIGGER TRG_HD_NV ON HOADON FOR INSERT
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGVL SMALLDATETIME, @MANV CHAR(4)
	SELECT @NGHD = NGHD, @MANV = MANV FROM INSERTED
	SELECT	@NGVL = NGVL FROM NHANVIEN WHERE MANV = @MANV

	IF (@NGHD >= @NGVL)
		PRINT N'Thành công.'
	ELSE
	BEGIN
		PRINT N'Không thành công.'
		ROLLBACK TRANSACTION
	END
END
GO

-- 13. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
CREATE TRIGGER TRG_TRIGIA ON HOADON FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @SOHD CHAR(5), @TRIGIA DECIMAL(18, 2)
    SELECT @SOHD = SOHD FROM INSERTED

    SELECT @TRIGIA = SUM(CTHD.SL * SANPHAM.GIA)
    FROM CTHD
    JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
    WHERE CTHD.SOHD = @SOHD

    UPDATE HOADON SET TRIGIA = @TRIGIA WHERE SOHD = @SOHD

    PRINT N'Đã cập nhật trị giá hoá đơn.'
END
GO

-- 14. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.
CREATE TRIGGER TRG_DOANHSO_KH ON HOADON FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MAKH CHAR(4), @TRIGIA DECIMAL(18, 2), @DOANHSO DECIMAL(18, 2)
    SELECT @MAKH = MAKH, @TRIGIA = TRIGIA FROM INSERTED

    SELECT @DOANHSO = ISNULL(DOANHSO, 0) FROM KHACHHANG WHERE MAKH = @MAKH

    UPDATE KHACHHANG
    SET DOANHSO = @DOANHSO + @TRIGIA
    WHERE MAKH = @MAKH

    PRINT N'Đã cập nhật doanh số'
END
GO

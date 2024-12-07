-- 9. Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE TRIGGER TRG_LopTruong ON LOP
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MALOP CHAR(3), @TRGLOP CHAR(5)
    SELECT @MALOP = MALOP, @TRGLOP = TRGLOP FROM INSERTED

    IF NOT EXISTS (SELECT 1 FROM HOCVIEN WHERE MAHV = @TRGLOP AND MALOP = @MALOP)
    BEGIN
        PRINT N'Lớp trưởng phải là học viên của lớp.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thành công.'
    END
END
GO

-- 10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER TRG_TruongKhoa ON KHOA
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MAKHOA VARCHAR(4), @TRGKHOA CHAR(4)
    SELECT @MAKHOA = MAKHOA, @TRGKHOA = TRGKHOA FROM INSERTED

    IF NOT EXISTS (SELECT 1 FROM GIAOVIEN WHERE MAGV = @TRGKHOA AND MAKHOA = @MAKHOA AND (HOCHAM = 'TS' OR HOCHAM = 'PTS'))
    BEGIN
        PRINT N'Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thành công.'
    END
END
GO

-- 15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER TRG_KiemTraThi ON KETQUATHI
FOR INSERT
AS
BEGIN
    DECLARE @MAHV CHAR(5), @MAMH VARCHAR(10), @MALOP CHAR(3)
    SELECT @MAHV = MAHV, @MAMH = MAMH FROM INSERTED
    SELECT @MALOP = MALOP FROM HOCVIEN WHERE MAHV = @MAHV

    IF NOT EXISTS (SELECT 1 FROM GIANGDAY WHERE MALOP = @MALOP AND MAMH = @MAMH AND HOCKY = (SELECT MAX(HOCKY) FROM GIANGDAY WHERE MALOP = @MALOP))
    BEGIN
        PRINT N'Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thành công.'
    END
END
GO

-- 16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
CREATE TRIGGER TRG_KiemTraSoMonHoc ON GIANGDAY
FOR INSERT
AS
BEGIN
    DECLARE @MALOP CHAR(3), @HOCKY TINYINT, @NAM INT
    SELECT @MALOP = MALOP, @HOCKY = HOCKY, @NAM = NAM FROM INSERTED

    IF (SELECT COUNT(*) FROM GIANGDAY WHERE MALOP = @MALOP AND HOCKY = @HOCKY AND NAM = @NAM) >= 3
    BEGIN
        PRINT N'Mỗi lớp chỉ được học tối đa 3 môn trong một học kỳ.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thành công.'
    END
END
GO

-- 17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
CREATE TRIGGER TRG_SiSoLop ON HOCVIEN
FOR INSERT, DELETE
AS
BEGIN
    DECLARE @MALOP CHAR(3)
    SELECT @MALOP = MALOP FROM INSERTED

    UPDATE LOP
    SET SISO = (SELECT COUNT(*) FROM HOCVIEN WHERE MALOP = @MALOP)
    WHERE MALOP = @MALOP

    PRINT N'Thành công.'
END
GO

-- 18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
CREATE TRIGGER TRG_KiemTraDieuKien ON DIEUKIEN
FOR INSERT
AS
BEGIN
    DECLARE @MAMH VARCHAR(10), @MAMH_TRUOC VARCHAR(10)
    SELECT @MAMH = MAMH, @MAMH_TRUOC = MAMH_TRUOC FROM INSERTED

    IF @MAMH = @MAMH_TRUOC
    BEGIN
        PRINT N'Không cho phép MAMH và MAMH_TRUOC giống nhau.'
        ROLLBACK TRANSACTION
    END

    IF EXISTS (SELECT 1 FROM DIEUKIEN WHERE MAMH = @MAMH_TRUOC AND MAMH_TRUOC = @MAMH)
    BEGIN
        PRINT N'Không cho phép tồn tại hai bộ MAMH và MAMH_TRUOC ngược lại.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thành công.'
    END
END
GO

-- 19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER TRG_KiemTraLuong ON GIAOVIEN
FOR INSERT
AS
BEGIN
    DECLARE @HOCHAM VARCHAR(10), @HESO NUMERIC(4, 2), @MUCLUONG MONEY
    SELECT @HOCHAM = HOCHAM, @HESO = HESO, @MUCLUONG = MUCLUONG FROM INSERTED

    IF EXISTS (SELECT 1 FROM GIAOVIEN WHERE HOCHAM = @HOCHAM AND HESO = @HESO AND MUCLUONG != @MUCLUONG)
    BEGIN
        PRINT N'Mức lương của các giáo viên có học vị, học hàm, hệ số giống nhau phải bằng nhau.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        PRINT N'Thành công.'
    END
END
GO

-- 20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER TRG_KIEMTRA_THILAI ON KETQUATHI
FOR INSERT
AS
BEGIN
    DECLARE @MAHV CHAR(5), @MAMH VARCHAR(10), @LANTHI TINYINT, @DIEM NUMERIC(4, 2), @DIEM_CU NUMERIC(4, 2)
    SELECT @MAHV = MAHV, @MAMH = MAMH, @LANTHI = LANTHI, @DIEM = DIEM FROM INSERTED
    
    IF @LANTHI > 1
    BEGIN
        SELECT @DIEM_CU = DIEM FROM KETQUATHI WHERE MAHV = @MAHV AND MAMH = @MAMH AND LANTHI = @LANTHI - 1
        IF @DIEM_CU >= 5
        BEGIN
            PRINT N'Không đủ điều kiện thi lại.'
            ROLLBACK TRANSACTION
        END
    END
END
GO

-- 21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
CREATE TRIGGER TRG_KIEMTRA_NGAYTHI ON KETQUATHI
FOR INSERT
AS
BEGIN
    DECLARE @MAHV CHAR(5), @MAMH VARCHAR(10), @LANTHI TINYINT, @NGTHI SMALLDATETIME, @NGTHI_CU SMALLDATETIME
    SELECT @MAHV = MAHV, @MAMH = MAMH, @LANTHI = LANTHI, @NGTHI = NGTHI FROM INSERTED
    
    IF @LANTHI > 1
    BEGIN
        SELECT @NGTHI_CU = NGTHI FROM KETQUATHI WHERE MAHV = @MAHV AND MAMH = @MAMH AND LANTHI = @LANTHI - 1
        IF @NGTHI <= @NGTHI_CU
        BEGIN
            PRINT N'Ngày thi không hợp lệ.'
            ROLLBACK TRANSACTION
        END
    END
END
GO

-- 22. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau).
CREATE TRIGGER TRG_KIEMTRA_MONHOC_TRUOC ON GIANGDAY
FOR INSERT
AS
BEGIN
    DECLARE @MAMH VARCHAR(10), @MAMH_TRUOC VARCHAR(10)
    SELECT @MAMH = MAMH FROM INSERTED
    SELECT @MAMH_TRUOC = MAMH_TRUOC FROM DIEUKIEN WHERE MAMH = @MAMH

    IF @MAMH_TRUOC IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM KETQUATHI WHERE MAHV = (SELECT MAHV FROM INSERTED) AND MAMH = @MAMH_TRUOC AND KQUA = N'Đạt')
        BEGIN
            PRINT N'Học viên chưa đạt môn học trước.'
            ROLLBACK TRANSACTION
        END
    END
END
GO

-- 23. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER TRG_KIEMTRA_KHOA_GIAOVIEN ON GIANGDAY
FOR INSERT
AS
BEGIN
    DECLARE @MAGV CHAR(4), @MAMH VARCHAR(10), @MAKHOA_GV VARCHAR(4), @MAKHOA_MONHOC VARCHAR(4)
    SELECT @MAGV = MAGV, @MAMH = MAMH FROM INSERTED
    SELECT @MAKHOA_GV = MAKHOA FROM GIAOVIEN WHERE MAGV = @MAGV
    SELECT @MAKHOA_MONHOC = MAKHOA FROM MONHOC WHERE MAMH = @MAMH
    
    IF @MAKHOA_GV != @MAKHOA_MONHOC
    BEGIN
        PRINT N'Giáo viên không thuộc khoa môn học này.'
        ROLLBACK TRANSACTION
    END
END
GO

-- Không tìm thấy câu 24

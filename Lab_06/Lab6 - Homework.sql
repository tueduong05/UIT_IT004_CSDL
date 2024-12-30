-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger

-- Cơ bản:
-- 1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT * FROM ChuyenGia;

-- 2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email FROM ChuyenGia
WHERE GioiTinh = N'Nữ';

-- 3. Liệt kê các công ty có trên 100 nhân viên.
SELECT * FROM CongTy
WHERE SoNhanVien > 100;

-- 4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau FROM DuAN
WHERE YEAR(NgayBatDau) = 2023 AND YEAR(NgayKetThuc) = 2023;

-- 5. ??

-- Trung cấp:
-- 6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY HoTen;

-- 7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT DuAn.TenDuAn FROM DuAn
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
INNER JOIN ChuyenGia_KyNang ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
INNER JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE KyNang.TenKyNang = N'Python' AND CapDo >= 4;

-- 8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAnDangThucHien FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy AND TrangThai = N'Đang thực hiện'
GROUP BY TenCongTy;

-- 9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT cg.HoTen, cg.ChuyenNganh, cg.NamKinhNghiem FROM ChuyenGia cg
WHERE NamKinhNghiem IN (
    SELECT MAX(NamKinhNghiem)
	FROM ChuyenGia
	WHERE ChuyenNganh = cg.ChuyenNganh
	GROUP BY ChuyenNganh
);

-- 10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2
FROM ChuyenGia_DuAn cgda1
JOIN ChuyenGia_DuAn cgda2 ON cgda1.MaDuAn = cgda2.MaDuAn
JOIN ChuyenGia cg1 ON cgda1.MaChuyenGia = cg1.MaChuyenGia
JOIN ChuyenGia cg2 ON cgda2.MaChuyenGia = cg2.MaChuyenGia
WHERE cgda1.MaChuyenGia < cgda2.MaChuyenGia;

-- Nâng cao:
-- 11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT cg.HoTen, SUM(DATEDIFF(DAY, da.NgayBatDau, da.NgayKetThuc)) AS TongThoiGianTheoNgay
FROM ChuyenGia_DuAn cgda
JOIN DuAn da ON cgda.MaDuAn = da.MaDuAn
JOIN ChuyenGia cg ON cgda.MaChuyenGia = cg.MaChuyenGia
GROUP BY cg.MaChuyenGia, cg.HoTen;

-- 12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT ct.MaCongTy, ct.TenCongTy, 
       (COUNT(CASE WHEN da.TrangThai = N'Hoàn thành' THEN 1 END) * 1.0 / COUNT(da.MaDuAn)) * 100 AS TyLeHoanThanh
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
GROUP BY ct.MaCongTy, ct.TenCongTy
HAVING (COUNT(CASE WHEN da.TrangThai = N'Hoàn thành' THEN 1 END) * 1.0 / COUNT(da.MaDuAn)) * 100 > 90;

-- 13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT TOP 3 kn.MaKyNang, kn.TenKyNang, COUNT(cgd.MaDuAn) AS SoLuongDuAn
FROM KyNang kn
JOIN ChuyenGia_KyNang cgn ON kn.MaKyNang = cgn.MaKyNang
JOIN ChuyenGia_DuAn cgd ON cgn.MaChuyenGia = cgd.MaChuyenGia
GROUP BY kn.MaKyNang, kn.TenKyNang
ORDER BY SoLuongDuAn DESC;

-- 14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
ALTER TABLE ChuyenGia
ADD Luong MONEY DEFAULT 25000000;
GO

SELECT 
    CASE 
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        WHEN NamKinhNghiem > 5 THEN 'Senior'
    END AS CapDoKinhNghiem,
    AVG(cg.Luong) AS LuongTrungBinh
FROM ChuyenGia cg
GROUP BY 
    CASE 
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        WHEN NamKinhNghiem > 5 THEN 'Senior'
    END;

-- 15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT da.MaDuAn, da.TenDuAn
FROM DuAn da
JOIN ChuyenGia_DuAn cgda ON da.MaDuAn = cgda.MaDuAn
JOIN ChuyenGia cg ON cgda.MaChuyenGia = cg.MaChuyenGia
GROUP BY da.MaDuAn, da.TenDuAn
HAVING COUNT(DISTINCT cg.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- Trigger:
-- 16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
ALTER TABLE CongTy
ADD SoLuongDuAn INT DEFAULT 0;
GO

CREATE TRIGGER TRG_ThemDuAn ON DuAn
AFTER INSERT
AS
BEGIN
	UPDATE CongTy
		SET SoLuongDuAn = SoLuongDuAn + 1
		FROM CongTy
		INNER JOIN Inserted i ON CongTy.MaCongTy = i.MaCongTy;
END;
GO

CREATE TRIGGER TRG_XoaDuAn ON DuAn
AFTER INSERT
AS
BEGIN
	UPDATE CongTy
		SET SoLuongDuAn = SoLuongDuAn - 1
		FROM CongTy
		INNER JOIN Inserted i ON CongTy.MaCongTy = i.MaCongTy;
END;
GO
-- 17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TABLE Log_ChuyenGia (
    LogID INT PRIMARY KEY,
    MaChuyenGia INT,
    HoTen NVARCHAR(100),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    Email NVARCHAR(100),
    SoDienThoai NVARCHAR(20),
    ChuyenNganh NVARCHAR(50),
    NamKinhNghiem INT,
    Action NVARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER TRG_LogChuyenGia
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO Log_ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, Action)
        SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, 'INSERT'
        FROM INSERTED;
    END

    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO Log_ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, Action)
        SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, 'UPDATE'
        FROM INSERTED;
    END

    IF EXISTS (SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
    BEGIN
        INSERT INTO Log_ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, Action)
        SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, 'DELETE'
        FROM DELETED;
    END
END;
GO

-- 18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER TRG_CheckChuyenGiaDuAn
ON ChuyenGia_DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT MaChuyenGia, COUNT(*) AS SoDuAn
            FROM ChuyenGia_DuAn
            GROUP BY MaChuyenGia
            HAVING COUNT(*) > 5
        ) AS ExceededProjects
        INNER JOIN INSERTED i ON ExceededProjects.MaChuyenGia = i.MaChuyenGia
    )
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT (N'Một chuyên gia không thể tham gia quá 5 dự án cùng một lúc.');
    END
END;
GO

-- 19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
CREATE TRIGGER TRG_UpdateTrangThaiDuAn
ON ChuyenGia_DuAn
AFTER UPDATE, INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaDuAn INT;

    SELECT @MaDuAn = MaDuAn FROM inserted;

    IF NOT EXISTS (
        SELECT 1
        FROM ChuyenGia_DuAn
        WHERE MaDuAn = @MaDuAn
        AND (NgayThamGia IS NULL OR NgayThamGia < GETDATE())
    )
    BEGIN
        UPDATE DuAn
        SET TrangThai = N'Hoàn thành'
        WHERE MaDuAn = @MaDuAn;
    END
END;
GO

-- 20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
ALTER TABLE DuAn
ADD DiemDanhGia INT;

ALTER TABLE CongTy
ADD DiemDanhGiaTB INT;
GO

CREATE TRIGGER trg_CapNhatDiemDanhGiaTrungBinhCongTy
ON DuAn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaCongTy INT;

    SELECT @MaCongTy = MaCongTy FROM INSERTED;

    IF @MaCongTy IS NULL
    BEGIN
        SELECT @MaCongTy = MaCongTy FROM DELETED;
    END

    DECLARE @DiemTrungBinh FLOAT;

    SELECT @DiemTrungBinh = AVG(DiemDanhGia)
    FROM DuAn
    WHERE MaCongTy = @MaCongTy;

    UPDATE CongTy
    SET DiemDanhGiaTB = @DiemTrungBinh
    WHERE MaCongTy = @MaCongTy;
END;
GO


-- Câu hỏi và ví dụ về Triggers (101-110)
-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
ALTER TABLE ChuyenGia ADD NgayCapNhat SMALLDATETIME;
GO

CREATE TRIGGER TRG_UpdateNgayCapNhat_ChuyenGia
ON ChuyenGia
FOR UPDATE
AS
BEGIN
    UPDATE ChuyenGia
    SET NgayCapNhat = GETDATE()
    WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM INSERTED);
END;
GO

-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
CREATE TABLE Log_DuAn (
    MaLog INT PRIMARY KEY,
    MaDuAn INT,
    TenDuAn NVARCHAR(200),
    ThoiGian SMALLDATETIME,
    ThaoTac NVARCHAR(50)
);
GO

CREATE TRIGGER TRG_DuAn_Log
ON DuAn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @ThaoTac NVARCHAR(50), @MaDuAn INT, @TenDuAn NVARCHAR(200);
    
    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        SET @ThaoTac = 'INSERT';
        SELECT @MaDuAn = MaDuAn, @TenDuAn = TenDuAn FROM INSERTED;
    END
    ELSE IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        SET @ThaoTac = 'DELETE';
        SELECT @MaDuAn = MaDuAn, @TenDuAn = TenDuAn FROM DELETED;
    END
    ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        SET @ThaoTac = 'UPDATE';
        SELECT @MaDuAn = MaDuAn, @TenDuAn = TenDuAn FROM INSERTED;
    END
    
    INSERT INTO Log_DuAn (MaDuAn, TenDuAn, ThoiGian, ThaoTac)
    VALUES (@MaDuAn, @TenDuAn, GETDATE(), @ThaoTac);
END;
GO

-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER TRG_ChuyenGia_MaxDuAn
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT, @SoDuAn INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM INSERTED;
    SELECT @SoDuAn = COUNT(*) FROM ChuyenGia_DuAn WHERE MaChuyenGia = @MaChuyenGia;
    
    IF @SoDuAn > 5
    BEGIN
        PRINT N'Một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.';
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TRIGGER TRG_CongTy_UpdateNhanVien
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaCongTy INT;

    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        SELECT @MaChuyenGia = MaChuyenGia FROM INSERTED;
        SELECT @MaCongTy = DuAn.MaCongTy
        FROM ChuyenGia_DuAn AS cgda
        JOIN DuAn ON cgda.MaDuAn = DuAn.MaDuAn
        WHERE cgda.MaChuyenGia = @MaChuyenGia;

        UPDATE CongTy
        SET SoNhanVien = (SELECT COUNT(*) FROM ChuyenGia_DuAn AS cgda
                          INNER JOIN DuAn ON cgda.MaDuAn = DuAn.MaDuAn
                          WHERE DuAn.MaCongTy = @MaCongTy)
        WHERE MaCongTy = @MaCongTy;
    END

    IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        SELECT @MaChuyenGia = MaChuyenGia FROM DELETED;
        SELECT @MaCongTy = DuAn.MaCongTy
        FROM ChuyenGia_DuAn AS cgda
        INNER JOIN DuAn ON cgda.MaDuAn = DuAn.MaDuAn
        WHERE cgda.MaChuyenGia = @MaChuyenGia;

        UPDATE CongTy
        SET SoNhanVien = (SELECT COUNT(*) FROM ChuyenGia_DuAn AS cgda
                          INNER JOIN DuAn ON cgda.MaDuAn = DuAn.MaDuAn
                          WHERE DuAn.MaCongTy = @MaCongTy)
        WHERE MaCongTy = @MaCongTy;
    END
END;
GO

-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER TRG_DuAn_HoanThanh
ON DuAn
AFTER DELETE
AS
BEGIN
    DECLARE @TrangThai NVARCHAR(50);
    SELECT @TrangThai = TrangThai FROM DELETED;
    
    IF @TrangThai = 'Hoàn thành'
    BEGIN
        PRINT N'Không thể xóa dự án đã hoàn thành.';
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.
CREATE TRIGGER TRG_ChuyenGia_CapNhatKyNang
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaDuAn INT;
    SELECT @MaChuyenGia = MaChuyenGia, @MaDuAn = MaDuAn FROM INSERTED;
    
    UPDATE ChuyenGia_KyNang
    SET CapDo += 1
    WHERE MaChuyenGia = @MaChuyenGia;
END;
GO

-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TABLE Log_KyNang (
    MaLog INT IDENTITY PRIMARY KEY,
    MaChuyenGia INT,
    MaKyNang INT,
    CapDo INT,
    ThoiGian DATETIME
);
GO

CREATE TRIGGER TRG_KyNang_Log
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaKyNang INT, @CapDo INT;
    SELECT @MaChuyenGia = MaChuyenGia, @MaKyNang = MaKyNang, @CapDo = CapDo FROM INSERTED;
    
    INSERT INTO Log_KyNang (MaChuyenGia, MaKyNang, CapDo, ThoiGian)
    VALUES (@MaChuyenGia, @MaKyNang, @CapDo, GETDATE());
END;
GO

-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
CREATE TRIGGER TRG_DuAn_NgayKetThuc
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @NgayBatDau DATE, @NgayKetThuc DATE;
    SELECT @NgayBatDau = NgayBatDau, @NgayKetThuc = NgayKetThuc FROM INSERTED;
    
    IF @NgayKetThuc <= @NgayBatDau
    BEGIN
        PRINT N'Ngày kết thúc phải lớn hơn ngày bắt đầu.';
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.
CREATE TRIGGER TRG_KyNang_XoaKyNang
ON KyNang
AFTER DELETE
AS
BEGIN
    DECLARE @MaKyNang INT;
    SELECT @MaKyNang = MaKyNang FROM DELETED
    DELETE FROM ChuyenGia_KyNang WHERE MaKyNang = @MaKyNang;
END;
GO

-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER TRG_CongTy_MaxDuAn
ON DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaCongTy INT, @SoDuAn INT;
    SELECT @MaCongTy = MaCongTy FROM INSERTED;
    SELECT @SoDuAn = COUNT(*) FROM DuAn WHERE MaCongTy = @MaCongTy AND TrangThai = N'Đang thực hiện';
    
    IF @SoDuAn > 10
    BEGIN
        PRINT N'Công ty không thể có quá 10 dự án đang thực hiện.';
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)
-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.
ALTER TABLE ChuyenGia ADD Luong MONEY;
GO

CREATE TRIGGER TRG_UpdateLuongChuyenGia
ON ChuyenGia_KyNang
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @CapDo INT, @NamKinhNghiem INT, @Luong INT;
    SELECT @MaChuyenGia = MaChuyenGia
    FROM INSERTED;
    
    SELECT @CapDo = CapDo
    FROM ChuyenGia_KyNang
    WHERE MaChuyenGia = @MaChuyenGia;
    
    SELECT @NamKinhNghiem = NamKinhNghiem
    FROM ChuyenGia
    WHERE MaChuyenGia = @MaChuyenGia;

    SET @Luong = (@CapDo * 1000) + (@NamKinhNghiem * 500);
    
    UPDATE ChuyenGia
    SET Luong = @Luong
    WHERE MaChuyenGia = @MaChuyenGia;
END;
GO

-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).
CREATE TABLE ThongBao (
    MaThongBao INT PRIMARY KEY,
    MaDuAn INT,
    NoiDung NVARCHAR(255),
    ThoiGian SMALLDATETIME
);
GO

CREATE TRIGGER TRG_ThongBaoDuAn
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @NgayKetThuc DATE, @NoiDung NVARCHAR(255);
    SELECT @MaDuAn = MaDuAn, @NgayKetThuc = NgayKetThuc FROM INSERTED;

    IF (DATEDIFF(DAY, GETDATE(), @NgayKetThuc) = 7)
    BEGIN
        SET @NoiDung = N'Dự án ' + (SELECT TenDuAn FROM DuAn WHERE MaDuAn = @MaDuAn) + N' sắp đến hạn (còn 7 ngày)';
        
        INSERT INTO ThongBao (MaDuAn, NoiDung, ThoiGian)
        VALUES (@MaDuAn, @NoiDung, GETDATE());
    END
END;
GO

-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.
CREATE TRIGGER TRG_NganXoaChuyenGiaDangThamGiaDuAn
ON ChuyenGia
FOR DELETE, UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM DELETED;

    IF EXISTS (SELECT 1 FROM ChuyenGia_DuAn WHERE MaChuyenGia = @MaChuyenGia)
    BEGIN
        PRINT N'Không thể xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.';
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.
CREATE TABLE ThongKeChuyenNganh (
    ChuyenNganh NVARCHAR(50),
    SoLuong INT
);
GO

CREATE TRIGGER TRG_UpdateThongKeChuyenNganh
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @ChuyenNganh NVARCHAR(50);

    IF EXISTS (SELECT * FROM INSERTED)
        SELECT @ChuyenNganh = ChuyenNganh FROM INSERTED;
    ELSE
        SELECT @ChuyenNganh = ChuyenNganh FROM DELETED;

    IF EXISTS (SELECT * FROM ThongKeChuyenNganh WHERE ChuyenNganh = @ChuyenNganh)
    BEGIN
        UPDATE ThongKeChuyenNganh
        SET SoLuong = (SELECT COUNT(*) FROM ChuyenGia WHERE ChuyenNganh = @ChuyenNganh)
        WHERE ChuyenNganh = @ChuyenNganh;
    END
    ELSE
    BEGIN
        INSERT INTO ThongKeChuyenNganh (ChuyenNganh, SoLuong)
        VALUES (@ChuyenNganh, 1);
    END
END;
GO

-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.
CREATE TABLE DuAnHoanThanh (
    MaDuAn INT PRIMARY KEY,
    TenDuAn NVARCHAR(200),
    NgayHoanThanh SMALLDATETIME
);
GO

CREATE TRIGGER TRG_BackupDuAnHoanThanh
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @TrangThai NVARCHAR(50);
    SELECT @MaDuAn = MaDuAn, @TrangThai = TrangThai FROM INSERTED;

    IF @TrangThai = N'Hoàn thành'
    BEGIN
        INSERT INTO DuAnHoanThanh (MaDuAn, TenDuAn, NgayHoanThanh)
        SELECT MaDuAn, TenDuAn, GETDATE()
        FROM DuAn
        WHERE MaDuAn = @MaDuAn;
    END
END;
GO

-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
ALTER TABLE CongTy ADD AvgDiemDanhGia INT;
ALTER TABLE DuAn ADD DiemDanhGia INT;
GO

CREATE TRIGGER TRG_UpdateDiem
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaCongTy INT;
    SELECT @MaCongTy = MaCongTy FROM INSERTED;

    UPDATE CongTy
    SET AvgDiemDanhGia = (SELECT AVG(DiemDanhGia) FROM DuAn WHERE MaCongTy = @MaCongTy)
    WHERE MaCongTy = @MaCongTy;
END;
GO

-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.
CREATE TRIGGER TRG_PhansGiaChuyenGia
ON DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaDuAn INT, @TenDuAn NVARCHAR(200);
    SELECT @MaDuAn = MaDuAn, @TenDuAn = TenDuAn FROM INSERTED;

    INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
    SELECT MaChuyenGia, @MaDuAn, N'Chuyên gia', GETDATE()
    FROM ChuyenGia
    WHERE ChuyenNganh = 'Phát triển phần mềm' AND NamKinhNghiem >= 5;
END;
GO

-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.
ALTER TABLE ChuyenGia ADD TrangThai NVARCHAR(50);
GO

CREATE TRIGGER TRG_UpdateTrangThaiChuyenGia
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM INSERTED;

    UPDATE ChuyenGia
    SET TrangThai = N'Bận'
    WHERE MaChuyenGia = @MaChuyenGia;
END;
GO

-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.
CREATE TRIGGER TRG_KyNang_TrungLap ON ChuyenGia_KyNang
FOR INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaKyNang INT;
    SELECT @MaChuyenGia = MaChuyenGia, @MaKyNang = MaKyNang FROM INSERTED;

    IF EXISTS (SELECT 1 FROM ChuyenGia_KyNang WHERE MaChuyenGia = @MaChuyenGia AND MaKyNang = @MaKyNang)
    BEGIN
        PRINT N'Kỹ năng đã tồn tại.';
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.
CREATE TABLE BaoCaoTongKet (
    MaDuAn INT PRIMARY KEY,
	NgayTao SMALLDATETIME,
	NoiDung NVARCHAR(255)
);
GO

CREATE TRIGGER TRG_BaoCaoTongKet ON DuAn
FOR UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @TrangThai NVARCHAR(50);
    SELECT @MaDuAn = MaDuAn, @TrangThai = TrangThai FROM INSERTED;

    IF (@TrangThai = N'Hoàn thành')
    BEGIN
        INSERT INTO BaoCaoTongKet(MaDuAn, NgayTao, NoiDung)
        VALUES (@MaDuAn, GETDATE(), N'Dự án ' + CAST(@MaDuAn AS NVARCHAR(10)) + ' đã hoàn thành.');
    END
END;
GO

-- 133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.
ALTER TABLE CongTy ADD SoDuAnHoanThanh INT, DiemDanhGia INT, ThuHang CHAR(1);
GO

CREATE TRIGGER TRG_CapNhatThuHangCongTy
ON DuAn
FOR UPDATE
AS
BEGIN
    DECLARE @MaCongTy INT, @TrangThai NVARCHAR(50);
    SELECT @MaCongTy = MaCongTy, @TrangThai = TrangThai FROM INSERTED;

    WITH ThuHangCongTy AS (
        SELECT MaCongTy, 
               SoDuAnHoanThanh, 
               DiemDanhGia,
               RANK() OVER (ORDER BY SoDuAnHoanThanh DESC, DiemDanhGia DESC) AS ThuTu
        FROM CongTy
    )
    UPDATE CongTy
    SET ThuHang = ThuHangCongTy.ThuTu
    FROM ThuHangCongTy
    WHERE CongTy.MaCongTy = ThuHangCongTy.MaCongTy;
END;
GO

-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).
CREATE TABLE ThongBaoChuyenGia (
    MaChuyenGia INT,
    NoiDung NVARCHAR(255),
    NgayThongBao DATE,
    FOREIGN KEY (MaChuyenGia) REFERENCES ChuyenGia(MaChuyenGia)
);
GO

CREATE TRIGGER TRG_ThongBaoThangCap ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @NamKinhNghiem INT, @NoiDung NVARCHAR(255);
    SELECT @MaChuyenGia = MaChuyenGia, @NamKinhNghiem = NamKinhNghiem FROM INSERTED;

    IF @NamKinhNghiem >= 10
    BEGIN
        SET @NoiDung = N'Chuyên gia ' + (SELECT HoTen FROM ChuyenGia WHERE MaChuyenGia = @MaChuyenGia) + N' đã được thăng cấp';

        INSERT INTO ThongBaoChuyenGia (MaChuyenGia, NoiDung, NgayThongBao)
        VALUES (@MaChuyenGia, @NoiDung, GETDATE());
    END;
END;
GO

-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.
CREATE TRIGGER TRG_UpdateTrangThai ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @NgayBatDau SMALLDATETIME, @NgayKetThuc SMALLDATETIME, @TrangThai NVARCHAR(50);
    SELECT @MaDuAn = MaDuAn, @NgayBatDau = NgayBatDau, @NgayKetThuc = NgayKetThuc FROM INSERTED;

    IF DATEDIFF(DAY, GETDATE(), @NgayKetThuc) <= DATEDIFF(DAY, @NgayBatDau, @NgayKetThuc) * 0.1
    BEGIN
        UPDATE DuAn
        SET TrangThai = 'Khẩn cấp'
        WHERE MaDuAn = @MaDuAn;
    END;
END;
GO

-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.
CREATE TABLE ThongKeDuAn (
    MaChuyenGia INT,
    SoDuAnDangThucHien INT,
    FOREIGN KEY (MaChuyenGia) REFERENCES ChuyenGia(MaChuyenGia)
);
GO

CREATE TRIGGER TRG_UpdateSoDuAn ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @SoDuAnDangThucHien INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM INSERTED;
    SELECT @SoDuAnDangThucHien = COUNT(*) 
    FROM ChuyenGia_DuAn
    WHERE MaChuyenGia = @MaChuyenGia AND VaiTro = N'Đang thực hiện';

    UPDATE ThongKeDuAn
    SET SoDuAnDangThucHien = @SoDuAnDangThucHien
    WHERE MaChuyenGia = @MaChuyenGia;
END;
GO

-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.
CREATE TRIGGER TRG_UpdateTyLeThanhCongCongTy ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaCongTy INT, @SoDuAnHoanThanh INT, @TongDuAn INT, @TyLeThanhCong FLOAT;
    SELECT @MaCongTy = MaCongTy FROM INSERTED;
    SELECT @SoDuAnHoanThanh = COUNT(*) FROM DuAn WHERE MaCongTy = @MaCongTy AND TrangThai = N'Hoàn thành';
    SELECT @TongDuAn = COUNT(*) FROM DuAn WHERE MaCongTy = @MaCongTy;

    IF @TongDuAn > 0
        SET @TyLeThanhCong = (CAST(@SoDuAnHoanThanh AS FLOAT) / @TongDuAn) * 100;
    ELSE
        SET @TyLeThanhCong = 0;

    UPDATE CongTy
    SET SoNhanVien = ROUND(@TyLeThanhCong, 2)
    WHERE MaCongTy = @MaCongTy;
END;
GO

-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.
CREATE TABLE LogLuongChuyenGia (
    MaChuyenGia INT,
    LuongCu INT,
    LuongMoi INT,
    NgayThayDoi SMALLDATETIME,
    FOREIGN KEY (MaChuyenGia) REFERENCES ChuyenGia(MaChuyenGia)
);
GO

CREATE TRIGGER TRG_LogThayDoiLuong ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @LuongCu MONEY, @LuongMoi MONEY;
    SELECT @MaChuyenGia = MaChuyenGia, @LuongCu = Luong, @LuongMoi = Luong FROM INSERTED;

    INSERT INTO LogLuongChuyenGia (MaChuyenGia, LuongCu, LuongMoi, NgayThayDoi)
    VALUES (@MaChuyenGia, @LuongCu, @LuongMoi, GETDATE());
END;
GO

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.
ALTER TABLE CongTy ADD SoCapCao INT;
GO

CREATE TRIGGER TRG_UpdateSoLuongChuyenGiaCapCao ON ChuyenGia_DuAn
FOR INSERT, DELETE
AS
BEGIN
    DECLARE @MaCongTy INT, @SoLuongCapCao INT;
    SELECT @MaCongTy = d.MaCongTy
    FROM DuAn d
    JOIN INSERTED i ON d.MaDuAn = i.MaDuAn
    WHERE i.MaChuyenGia IN (SELECT MaChuyenGia FROM INSERTED);

    SELECT @SoLuongCapCao = COUNT(*) 
    FROM ChuyenGia c
    JOIN ChuyenGia_DuAn cgd ON c.MaChuyenGia = cgd.MaChuyenGia
    JOIN DuAn d ON cgd.MaDuAn = d.MaDuAn
    WHERE d.MaCongTy = @MaCongTy AND c.NamKinhNghiem >= 10;

    UPDATE CongTy
    SET SoCapCao = @SoLuongCapCao
    WHERE MaCongTy = @MaCongTy;
END;
GO

-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.
ALTER TABLE DuAn ADD SoLuongYeuCau INT;
GO

CREATE TRIGGER TRG_UpdateTrangThaiCungCap ON ChuyenGia_DuAn
FOR INSERT, DELETE
AS
BEGIN
    DECLARE @MaDuAn INT, @SoLuongChuyenGia INT, @SoLuongYeuCau INT, @TrangThai NVARCHAR(50);
    SELECT @MaDuAn = MaDuAn FROM INSERTED;
    SELECT @SoLuongChuyenGia = COUNT(*) 
    FROM ChuyenGia_DuAn 
    WHERE MaDuAn = @MaDuAn;

    SELECT @SoLuongYeuCau = SoLuongYeuCau FROM DuAn WHERE MaDuAn = @MaDuAn;

    IF @SoLuongChuyenGia < @SoLuongYeuCau
    BEGIN
        UPDATE DuAn
        SET TrangThai = N'Cần bổ sung nhân lực'
        WHERE MaDuAn = @MaDuAn;
    END
END;
GO

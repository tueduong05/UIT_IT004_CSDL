CREATE TABLE TACGIA (
	MaTG CHAR(5) PRIMARY KEY,
	HoTen VARCHAR(20),
	DiaChi VARCHAR(50),
	NgSinh SMALLDATETIME,
	SoDT VARCHAR(15)
);

CREATE TABLE SACH (
	MaSach CHAR(5) PRIMARY KEY,
	TenSach VARCHAR(25),
	TheLoai VARCHAR(25)
);

CREATE TABLE TACGIA_SACH (
	MaTG CHAR(5),
	FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG),
	MaSach CHAR(5),
	FOREIGN KEY (MaSach) REFERENCES SACH(MaSach),
	CONSTRAINT PK_TG_S PRIMARY KEY (MaTG, MaSach)
);

CREATE TABLE PHATHANH (
	MaPH CHAR(5) PRIMARY KEY,
	MaSach CHAR(5),
	FOREIGN KEY (MaSach) REFERENCES SACH(MaSach),
	NgayPH SMALLDATETIME,
	SoLuong INT,
	NhaXuatBan VARCHAR(20)
);
GO

CREATE TRIGGER TRG_NgPH_NgSinh
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaSach CHAR(5), @NgayPH SMALLDATETIME, @NgSinh SMALLDATETIME;

    SELECT @MaSach = MaSach, @NgayPH = NgayPH FROM INSERTED;

    SELECT @NgSinh = NgSinh
    FROM TACGIA tg
    INNER JOIN TACGIA_SACH ts ON tg.MaTG = ts.MaTG
    WHERE ts.MaSach = @MaSach;

    IF @NgayPH <= @NgSinh
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT(N'Ngày phát hành phải lớn hơn ngày sinh của tác giả.');
    END
END;
GO

CREATE TRIGGER TRG_SGK_NXBGD
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaSach CHAR(5), @TheLoai VARCHAR(25), @NhaXuatBan VARCHAR(20);

    SELECT @MaSach = MaSach, @NhaXuatBan = NhaXuatBan FROM INSERTED;

    SELECT @TheLoai = TheLoai FROM SACH WHERE MaSach = @MaSach;

    IF @TheLoai = N'Giáo khoa' AND @NhaXuatBan <> N'Giáo dục'
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT(N'Sách thể loại “Giáo khoa” chỉ do nhà xuất bản “Giáo dục” phát hành.');
    END
END;
GO

SELECT tg.MaTG, tg.HoTen, tg.SoDT
FROM TACGIA tg
INNER JOIN TACGIA_SACH ts ON tg.MaTG = ts.MaTG
INNER JOIN SACH s ON ts.MaSach = s.MaSach
INNER JOIN PHATHANH ph ON s.MaSach = ph.MaSach
WHERE s.TheLoai = N'Văn học' AND ph.NhaXuatBan = N'Trẻ';

SELECT TOP 1 ph.NhaXuatBan
FROM PHATHANH ph
JOIN SACH s ON ph.MaSach = s.MaSach
GROUP BY ph.NhaXuatBan
ORDER BY COUNT(DISTINCT s.TheLoai) DESC;

SELECT ph.NhaXuatBan, tg.MaTG, tg.HoTen
FROM PHATHANH ph
JOIN TACGIA_SACH ts ON ph.MaSach = ts.MaSach
JOIN TACGIA tg ON ts.MaTG = tg.MaTG
WHERE NOT EXISTS (
    SELECT 1
    FROM PHATHANH ph1
    JOIN TACGIA_SACH ts1 ON ph1.MaSach = ts1.MaSach
    WHERE ph1.NhaXuatBan = ph.NhaXuatBan
    GROUP BY ph1.NhaXuatBan, ts1.MaTG
    HAVING COUNT(*) > (
        SELECT COUNT(*)
        FROM PHATHANH ph2
        JOIN TACGIA_SACH ts2 ON ph2.MaSach = ts2.MaSach
        WHERE ph2.NhaXuatBan = ph.NhaXuatBan AND ts2.MaTG = tg.MaTG
    )
);

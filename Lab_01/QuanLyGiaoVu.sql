CREATE TABLE KHOA (
	MAKHOA VARCHAR(4) NOT NULL PRIMARY KEY,
	TENKHOA VARCHAR(40) NOT NULL,
	NGTLAP SMALLDATETIME NOT NULL,
	TRGKHOA CHAR(4) NOT NULL
);

CREATE TABLE LOP (
	MALOP CHAR(3) NOT NULL PRIMARY KEY,
	TENLOP VARCHAR(40) NOT NULL,
	TRGLOP CHAR(5) NOT NULL,
	SISO TINYINT NOT NULL,
	MAGVCN CHAR(4) NOT NULL
);

CREATE TABLE MONHOC (
	MAMH VARCHAR(10) NOT NULL PRIMARY KEY,
	TENMH VARCHAR(40) NOT NULL,
	TCTL TINYINT NOT NULL,
	TCTH TINYINT NOT NULL,
	MAKHOA VARCHAR(4) NOT NULL,
	FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);

CREATE TABLE DIEUKIEN (
	MAMH VARCHAR(10) NOT NULL,
	FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH),
	MAMH_TRUOC VARCHAR(10) NOT NULL,
	FOREIGN KEY (MAMH_TRUOC) REFERENCES MONHOC(MAMH),
	CONSTRAINT PK_DIEUKIEN PRIMARY KEY (MAMH, MAMH_TRUOC)
);

CREATE TABLE GIAOVIEN (
	MAGV CHAR(4) NOT NULL PRIMARY KEY,
	HOTEN VARCHAR(40) NOT NULL,
	HOCVI VARCHAR(10) NOT NULL,
	HOCHAM VARCHAR(10) NOT NULL,
	GIOITINH VARCHAR(3) NOT NULL,
	NGSINH SMALLDATETIME NOT NULL,
	NGVL SMALLDATETIME NOT NULL,
	HESO NUMERIC(4, 2) NOT NULL,
	MUCLUONG MONEY NOT NULL,
	MAKHOA VARCHAR(4) NOT NULL,
	FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);

CREATE TABLE HOCVIEN (
	MAHV CHAR(5) NOT NULL PRIMARY KEY,
	HO VARCHAR(40) NOT NULL,
	TEN VARCHAR(10) NOT NULL,
	NGSINH SMALLDATETIME NOT NULL,
	GIOITINH VARCHAR(3) NOT NULL,
	NOISINH VARCHAR(40) NOT NULL,
	MALOP CHAR(3) NOT NULL,
	FOREIGN KEY (MALOP) REFERENCES LOP(MALOP)
);

CREATE TABLE GIANGDAY (
	MALOP CHAR(3) NOT NULL,
	FOREIGN KEY (MALOP) REFERENCES LOP(MALOP),
	MAMH VARCHAR(10) NOT NULL,
	FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH),
	CONSTRAINT PK_GIANGDAY PRIMARY KEY(MALOP, MAMH),
	MAGV CHAR(4) NOT NULL,
	FOREIGN KEY (MAGV) REFERENCES GIAOVIEN(MAGV),
	HOCKY TINYINT NOT NULL,
	NAM SMALLINT NOT NULL,
	TUNGAY SMALLDATETIME NOT NULL,
	DENNGAY SMALLDATETIME NOT NULL
);

CREATE TABLE KETQUATHI (
	MAHV CHAR(5) NOT NULL,
	FOREIGN KEY (MAHV) REFERENCES HOCVIEN(MAHV),
	MAMH VARCHAR(10) NOT NULL,
	FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH),
	LANTHI TINYINT NOT NULL,
	CONSTRAINT PK_KETQUATHI PRIMARY KEY (MAHV, MAMH, LANTHI),
	NGTHI SMALLDATETIME NOT NULL,
	DIEM NUMERIC(4, 2) NOT NULL,
	KQUA VARCHAR(10) NOT NULL
);

ALTER TABLE KHOA
	ADD FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN(MAGV);
ALTER TABLE LOP
	ADD FOREIGN KEY (TRGLOP) REFERENCES HOCVIEN(MAHV);
ALTER TABLE LOP
	ADD FOREIGN KEY (MAGVCN) REFERENCES GIAOVIEN(MAGV);

ALTER TABLE HOCVIEN
	ADD CONSTRAINT CK_GIOITINHHV CHECK (GIOITINH IN ('Nam', 'Nu'));
ALTER TABLE GIAOVIEN
	ADD CONSTRAINT CK_GIOITINHGV CHECK (GIOITINH IN ('Nam', 'Nu'));

ALTER TABLE KETQUATHI
	ADD CONSTRAINT CK_DIEM CHECK (DIEM BETWEEN 0 AND 10);

UPDATE KETQUATHI
	SET KQUA = CASE
		WHEN DIEM >= 5 AND DIEM <= 10 THEN 'Dat'
		WHEN DIEM < 5 THEN 'Khong dat'
		ELSE KQUA
	END;

ALTER TABLE KETQUATHI
	ADD CONSTRAINT CK_LANTHI CHECK (LANTHI BETWEEN 1 AND 3);

ALTER TABLE GIANGDAY
	ADD CONSTRAINT CK_HOCKY CHECK (HOCKY BETWEEN 1 AND 3);

ALTER TABLE GIAOVIEN
	ADD CONSTRAINT CK_HOCVI CHECK (HOCVI IN ('CN', 'KS', 'ThS', 'TS', 'PTS'));

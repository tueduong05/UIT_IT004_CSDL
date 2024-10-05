CREATE TABLE KHOA (
	MAKHOA VARCHAR(4) NOT NULL PRIMARY KEY,
	TENKHOA VARCHAR(40) NOT NULL,
	NGTLAP SMALLDATETIME NOT NULL,
	TRGKHOA CHAR(4)
);

CREATE TABLE LOP (
	MALOP CHAR(3) NOT NULL PRIMARY KEY,
	TENLOP VARCHAR(40) NOT NULL,
	TRGLOP CHAR(5),
	SISO TINYINT NOT NULL,
	MAGVCN CHAR(4) NOT NULL
);

CREATE TABLE MONHOC (
	MAMH VARCHAR(10) NOT NULL PRIMARY KEY,
	TENMH VARCHAR(40) NOT NULL,
	TCLT TINYINT NOT NULL,
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
	HOCHAM VARCHAR(10),
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

ALTER TABLE KETQUATHI
	ADD CONSTRAINT CK_KQUA
		CHECK (
    		KQUA = CASE 
             	WHEN DIEM BETWEEN 5 AND 10 THEN 'Dat' 
             	ELSE 'Khong dat' 
           		END
		);

ALTER TABLE KETQUATHI
	ADD CONSTRAINT CK_LANTHI CHECK (LANTHI BETWEEN 1 AND 3);

ALTER TABLE GIANGDAY
	ADD CONSTRAINT CK_HOCKY CHECK (HOCKY BETWEEN 1 AND 3);

ALTER TABLE GIAOVIEN
	ADD CONSTRAINT CK_HOCVI CHECK (HOCVI IN ('CN', 'KS', 'ThS', 'TS', 'PTS'));
    
INSERT INTO KHOA (MAKHOA, TENKHOA, NGTLAP)
VALUES
('KHMT', 'Khoa hoc may tinh', '2005/6/7'),
('HTTT', 'He thong thong tin', '2005/6/7'),
('CNPM', 'Cong nghe phan mem', '2005/6/7'),
('MTT', 'Mang va truyen thong', '2005/10/20'),
('KTMT', 'Ky thuat may tinh', '2005/12/20');

INSERT INTO GIAOVIEN
VALUES
('GV01', 'Ho Thanh Son', 'PTS', 'GS', 'Nam', '1950/5/2', '2004/1/11', 5.00, '2,250,000', 'KHMT'),
('GV02', 'Tran Tam Thanh', 'TS', 'PGS', 'Nam', '1965/12/17', '2004/4/20', 4.50, '2,025,000', 'HTTT'),
('GV03', 'Do Nghiem Phung', 'TS', 'GS', 'Nu', '1950/8/1', '2004/9/23', 4.00, '1,800,000', 'CNPM'),
('GV04', 'Tran Nam Son', 'TS', 'PGS', 'Nam', '1961/2/22', '2005/1/12', 4.50, '2,025,000', 'KTMT'),
('GV05', 'Mai Thanh Danh', 'ThS', 'GV', 'Nam', '1958/3/12', '2005/1/12', 3.00, '1,350,000', 'HTTT'),
('GV06', 'Tran Doan Hung', 'TS', 'GV', 'Nam', '1953/3/11', '2005/1/12', 4.50, '2,025,000', 'KHMT'),
('GV07', 'Nguyen Minh Tien', 'ThS', 'GV', 'Nam', '1971/11/23', '2005/3/1', 4.00, '1,800,000', 'KHMT'),
('GV08', 'Le Thi Tran', 'KS', NULL, 'Nu', '1974/3/26', '2005/3/1', 1.69, '760,500', 'KHMT'),
('GV09', 'Nguyen To Lan', 'ThS', 'GV', 'Nu', '1966/12/31', '2005/3/1', 4.00, '1,800,000', 'HTTT'),
('GV10', 'Le Tran Anh Loan', 'KS', NULL, 'Nu', '1972/7/17', '2005/3/1', 1.86, '837,000', 'CNPM'),
('GV11', 'Ho Thanh Tung', 'CN', 'GV', 'Nam', '1980/1/12', '2005/5/15', 2.67, '1,201,500', 'MTT'),
('GV12', 'Tran Van Anh', 'CN', NULL, 'Nu', '1981/3/29', '2005/5/15', 1.69, '760,500', 'CNPM'),
('GV13', 'Nguyen Linh Dan', 'CN', NULL, 'Nu', '1980/5/23', '2005/5/15', 1.69, '760,500', 'KTMT'),
('GV14', 'Truong Minh Chau', 'ThS', 'GV', 'Nu', '1976/11/30', '2005/5/15', 3.00, '1,350,000', 'MTT'),
('GV15', 'Le Ha Thanh', 'ThS', 'GV', 'Nam', '1978/5/4', '2005/5/15', 3.00, '1,350,000', 'KHMT');

INSERT INTO MONHOC
VALUES
('THDC', 'Tin hoc dai cuong', 4, 1, 'KHMT'),
('CTRR', 'Cau truc roi rac', 5, 2, 'KHMT'),
('CSDL', 'Co so du lieu', 3, 1, 'HTTT'),
('CTDLGT', 'Cau truc du lieu va giai thuat', 3, 1, 'KHMT'),
('PTTKTT', 'Phan tich thiet ke thuat toan', 3, 0, 'KHMT'),
('DHMT', 'Do hoa may tinh', 3, 1, 'KHMT'),
('KTMT', 'Kien truc may tinh', 3, 0, 'KTMT'),
('TKCSDL', 'Thiet ke co so du lieu', 3, 1, 'HTTT'),
('PTTKHTTT', 'Phan tich thiet ke he thong thong tin', 4, 1, 'HTTT'),
('HDH', 'He dieu hanh', 4, 1, 'KTMT'),
('NMCNPM', 'Nhap mon cong nghe phan mem', 3, 0, 'CNPM'),
('LTCFW', 'Lap trinh C for win', 3, 1, 'CNPM'),
('LTHDT', 'Lap trinh huong doi tuong', 3, 1, 'CNPM');

INSERT INTO DIEUKIEN
VALUES
('CSDL', 'CTRR'),
('CSDL', 'CTDLGT'),
('CTDLGT', 'THDC'),
('PTTKTT', 'THDC'),
('PTTKTT', 'CTDLGT'),
('DHMT', 'THDC'),
('LTHDT', 'THDC'),
('PTTKHTTT', 'CSDL');

INSERT INTO LOP (MALOP, TENLOP, SISO, MAGVCN)
VALUES
('K11', 'Lop 1 khoa 1', 11, 'GV07'),
('K12', 'Lop 2 khoa 1', 12, 'GV09'),
('K13', 'Lop 3 khoa 1', 12, 'GV14');

INSERT INTO HOCVIEN
VALUES
('K1101', 'Nguyen Van', 'A', '1986/1/27', 'Nam', 'TpHCM', 'K11'),
('K1102', 'Tran Ngoc', 'Han', '1986/3/14', 'Nu', 'Kien Giang', 'K11'),
('K1103', 'Ha Duy', 'Lap', '1986/4/18', 'Nam', 'Nghe An', 'K11'),
('K1104', 'Tran Ngoc', 'Linh', '1986/3/30', 'Nu', 'Tay Ninh', 'K11'),
('K1105', 'Tran Minh', 'Long', '1986/2/27', 'Nam', 'TpHCM', 'K11'),
('K1106', 'Le Nhat', 'Minh', '1986/1/24', 'Nam', 'TpHCM', 'K11'),
('K1107', 'Nguyen Nhu', 'Nhut', '1986/1/27', 'Nam', 'Ha Noi', 'K11'),
('K1108', 'Nguyen Manh', 'Tam', '1986/2/27', 'Nam', 'Kien Giang', 'K11'),
('K1109', 'Phan Thi Thanh', 'Tam', '1986/1/27', 'Nu', 'Vinh Long', 'K11'),
('K1110', 'Le Hoai', 'Thuong', '1986/2/5', 'Nu', 'Can Tho', 'K11'),
('K1111', 'Le Ha', 'Vinh', '1986/12/25', 'Nam', 'Vinh Long', 'K11'),
('K1201', 'Nguyen Van', 'B', '1986/2/11', 'Nam', 'TpHCM', 'K12'),
('K1202', 'Nguyen Thi Kim', 'Duyen', '1986/1/18', 'Nu', 'TpHCM', 'K12'),
('K1203', 'Tran Thi Kim', 'Duyen', '1986/9/17', 'Nu', 'TpHCM', 'K12'),
('K1204', 'Truong My', 'Hanh', '1986/5/19', 'Nu', 'Dong Nai', 'K12'),
('K1205', 'Nguyen Thanh', 'Nam', '1986/4/17', 'Nam', 'TpHCM', 'K12'),
('K1206', 'Nguyen Thi Truc', 'Thanh', '1986/3/4', 'Nu', 'Kien Giang', 'K12'),
('K1207', 'Tran Thi Bich', 'Thuy', '1986/2/8', 'Nu', 'Nghe An', 'K12'),
('K1208', 'Huynh Thi Kim', 'Trieu', '1986/4/8', 'Nu', 'Tay Ninh', 'K12'),
('K1209', 'Pham Thanh', 'Trieu', '1986/2/23', 'Nam', 'TpHCM', 'K12'),
('K1210', 'Ngo Thanh', 'Tuan', '1986/2/14', 'Nam', 'TpHCM', 'K12'),
('K1211', 'Do Thi', 'Xuan', '1986/3/9', 'Nu', 'Ha Noi', 'K12'),
('K1212', 'Le Thi Phi', 'Yen', '1986/3/12', 'Nu', 'TpHCM', 'K12'),
('K1301', 'Nguyen Thi Kim', 'Cuc', '1986/6/9', 'Nu', 'Kien Giang', 'K13'),
('K1302', 'Truong Thi My', 'Hien', '1986/3/18', 'Nu', 'Nghe An', 'K13'),
('K1303', 'Le Duc', 'Hien', '1986/3/21', 'Nam', 'Tay Ninh', 'K13'),
('K1304', 'Le Quang', 'Hien', '1986/4/18', 'Nam', 'TpHCM', 'K13'),
('K1305', 'Le Thi', 'Huong', '1986/3/27', 'Nu', 'TpHCM', 'K13'),
('K1306', 'Nguyen Thai', 'Huu', '1986/3/30', 'Nam', 'Ha Noi', 'K13'),
('K1307', 'Tran Minh', 'Man', '1986/5/28', 'Nam', 'TpHCM', 'K13'),
('K1308', 'Nguyen Hieu', 'Nghia', '1987/4/8', 'Nam', 'Kien Giang', 'K13'),
('K1309', 'Nguyen Trung', 'Nghia', '1986/1/18', 'Nam', 'Nghe An', 'K13'),
('K1310', 'Tran Thi Hong', 'Tham', '1986/4/22', 'Nu', 'Tay Ninh', 'K13'),
('K1311', 'Tran Minh', 'Thuc', '1986/4/4', 'Nam', 'TpHCM', 'K13'),
('K1312', 'Nguyen Thi Kim', 'Yen', '1986/9/7', 'Nu', 'TpHCM', 'K13');

INSERT INTO GIANGDAY
VALUES
('K11', 'THDC', 'GV07', 1, 2006, '2006/1/2', '2006/5/12'),
('K12', 'THDC', 'GV06', 1, 2006, '2006/1/2', '2006/5/12'),
('K13', 'THDC', 'GV15', 1, 2006, '2006/1/2', '2006/5/12'),
('K11', 'CTRR', 'GV02', 1, 2006, '2006/1/9', '2006/5/17'),
('K12', 'CTRR', 'GV02', 1, 2006, '2006/1/9', '2006/5/17'),
('K13', 'CTRR', 'GV08', 1, 2006, '2006/1/9', '2006/5/17'),
('K11', 'CSDL', 'GV05', 2, 2006, '2006/6/1', '2006/7/15'),
('K12', 'CSDL', 'GV09', 2, 2006, '2006/6/1', '2006/7/15'),
('K13', 'CTDLGT', 'GV15', 2, 2006, '2006/6/1', '2006/7/15'),
('K13', 'CSDL', 'GV05', 3, 2006, '2006/8/1', '2006/12/15'),
('K13', 'DHMT', 'GV07', 3, 2006, '2006/8/1', '2006/12/15'),
('K11', 'CTDLGT', 'GV15', 3, 2006, '2006/8/1', '2006/12/15'),
('K12', 'CTDLGT', 'GV15', 3, 2006, '2006/8/1', '2006/12/15'),
('K11', 'HDH', 'GV04', 1, 2007, '2007/1/2', '2007/2/18'),
('K12', 'HDH', 'GV04', 1, 2007, '2007/1/2', '2007/3/20'),
('K11', 'DHMT', 'GV07', 1, 2007, '2007/2/18', '2007/3/20');

INSERT INTO KETQUATHI
VALUES
('K1101', 'CSDL', 1, '2006/7/20', 10.00, 'Dat'),
('K1101', 'CTDLGT', 1, '2006/12/28', 9.00, 'Dat'),
('K1101', 'THDC', 1, '2006/5/20', 9.00, 'Dat'),
('K1101', 'CTRR', 1, '2006/5/13', 9.50, 'Dat'),
('K1102', 'CSDL', 1, '2006/7/20', 4.00, 'Khong dat'),
('K1102', 'CSDL', 2, '2006/7/27', 4.25, 'Khong dat'),
('K1102', 'CSDL', 3, '2006/8/10', 4.50, 'Khong dat'),
('K1102', 'CTDLGT', 1, '2006/12/28', 4.50, 'Khong dat'),
('K1102', 'CTDLGT', 2, '2007/1/5', 4.00, 'Khong dat'),
('K1102', 'CTDLGT', 3, '2007/1/15', 6.00, 'Dat'),
('K1102', 'THDC', 1, '2006/5/20', 5.00, 'Dat'),
('K1102', 'CTRR', 1, '2006/5/13', 7.00, 'Dat'),
('K1103', 'CSDL', 1, '2006/7/20', 3.50, 'Khong dat'),
('K1103', 'CSDL', 2, '2006/7/27', 8.25, 'Dat'),
('K1103', 'CTDLGT', 1, '2006/12/28', 7.00, 'Dat'),
('K1103', 'THDC', 1, '2006/5/20', 8.00, 'Dat'),
('K1103', 'CTRR', 1, '2006/5/13', 6.50, 'Dat'),
('K1104', 'CSDL', 1, '2006/7/20', 3.75, 'Khong dat'),
('K1104', 'CTDLGT', 1, '2006/12/28', 4.00, 'Khong dat'),
('K1104', 'THDC', 1, '2006/5/20', 4.00, 'Khong dat'),
('K1104', 'CTRR', 2, '2006/5/13', 4.00, 'Khong dat'),
('K1104', 'CTRR', 3, '2006/5/20', 3.50, 'Khong dat'),
('K1104', 'CTRR', 1, '2006/6/30', 4.00, 'Khong dat'),
('K1201', 'CSDL', 1, '2006/7/20', 6.00, 'Dat'),
('K1201', 'CTDLGT', 1, '2006/12/28', 5.00, 'Dat'),
('K1201', 'THDC', 1, '2006/5/20', 8.50, 'Dat'),
('K1201', 'CTRR', 1, '2006/5/13', 9.00, 'Dat'),
('K1202', 'CSDL', 2, '2006/7/20', 8.00, 'Dat'),
('K1202', 'CTDLGT', 1, '2006/12/28', 4.00, 'Khong dat'),
('K1202', 'CTDLGT', 2, '2007/1/5', 5.00, 'Dat'),
('K1202', 'THDC', 1, '2006/5/20', 4.00, 'Khong dat'),
('K1202', 'THDC', 2, '2006/5/27', 4.00, 'Khong dat'),
('K1202', 'CTRR', 1, '2006/5/13', 3.00, 'Khong dat'),
('K1202', 'CTRR', 2, '2006/5/20', 4.00, 'Khong dat'),
('K1202', 'CTRR', 3, '2006/6/30', 6.25, 'Dat'),
('K1203', 'CSDL', 1, '2006/7/20', 9.25, 'Dat'),
('K1203', 'CTDLGT', 1, '2006/12/28', 9.50, 'Dat'),
('K1203', 'THDC', 1, '2006/5/20', 10.00, 'Dat'),
('K1203', 'CTRR', 1, '2006/5/13', 10.00, 'Dat'),
('K1204', 'CSDL', 1, '2006/7/20', 8.50, 'Dat'),
('K1204', 'CTDLGT', 1, '2006/12/28', 6.75, 'Dat'),
('K1204', 'THDC', 1, '2006/5/20', 4.00, 'Khong dat'),
('K1204', 'CTRR', 1, '2006/5/13', 6.00, 'Dat'),
('K1301', 'CSDL', 1, '2006/12/20', 4.25, 'Khong dat'),
('K1301', 'CTDLGT', 1, '2006/7/25', 8.00, 'Dat'),
('K1301', 'THDC', 1, '2006/5/20', 7.75, 'Dat'),
('K1301', 'CTRR', 1, '2006/5/13', 8.00, 'Dat'),
('K1302', 'CSDL', 1, '2006/12/20', 6.75, 'Dat'),
('K1302', 'CTDLGT', 1, '2006/7/25', 5.00, 'Dat'),
('K1302', 'THDC', 1, '2006/5/20', 8.00, 'Dat'),
('K1302', 'CTRR', 1, '2006/5/13', 8.50, 'Dat'),
('K1303', 'CSDL', 1, '2006/12/20', 4.00, 'Khong dat'),
('K1303', 'CTDLGT', 1, '2006/7/25', 4.50, 'Khong dat'),
('K1303', 'CTDLGT', 2, '2006/8/7', 4.00, 'Khong dat'),
('K1303', 'CTDLGT', 3, '2006/8/15', 4.25, 'Khong dat'),
('K1303', 'THDC', 1, '2006/5/20', 4.50, 'Khong dat'),
('K1303', 'CTRR', 1, '2006/5/13', 3.25, 'Khong dat'),
('K1303', 'CTRR', 2, '2006/5/20', 5.00, 'Dat'),
('K1304', 'CSDL', 1, '2006/12/20', 7.75, 'Dat'),
('K1304', 'CTDLGT', 1, '2006/7/25', 9.75, 'Dat'),
('K1304', 'THDC', 1, '2006/5/20', 5.50, 'Dat'),
('K1304', 'CTRR', 1, '2006/5/13', 5.00, 'Dat'),
('K1305', 'CSDL', 1, '2006/12/20', 9.25, 'Dat'),
('K1305', 'CTDLGT', 1, '2006/7/25', 10.00, 'Dat'),
('K1305', 'THDC', 1, '2006/5/20', 8.00, 'Dat'),
('K1305', 'CTRR', 1, '2006/5/13', 10.00, 'Dat');

UPDATE KHOA
SET TRGKHOA = CASE 
                WHEN MAKHOA = 'KHMT' THEN 'GV01'
                WHEN MAKHOA = 'HTTT' THEN 'GV02'
                WHEN MAKHOA = 'CNPM' THEN 'GV04'
				WHEN MAKHOA = 'MTT' THEN 'GV03'
            END
WHERE MAKHOA IN ('KHMT', 'HTTT', 'CNPM', 'MTT');

UPDATE LOP
SET TRGLOP = CASE 
                WHEN MALOP = 'K11' THEN 'K1108'
                WHEN MALOP = 'K12' THEN 'K1205'
                WHEN MALOP = 'K13' THEN 'K1305'
           END
WHERE MALOP IN ('K11', 'K12', 'K13');

ALTER TABLE HOCVIEN
ADD CONSTRAINT CHK_NGSINH CHECK (YEAR(GETDATE()) - YEAR(NGSINH) >= 18);

ALTER TABLE GIANGDAY
ADD CONSTRAINT CHK_NGGIANGDAY CHECK (TUNGAY < DENNGAY);

ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHK_NGVL CHECK (YEAR(NGVL) - YEAR(NGSINH) >= 22);

ALTER TABLE MONHOC
ADD CONSTRAINT CHK_CHENHLECHTC CHECK ((TCLT - TCTH) <= 3);

SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, HOCVIEN.NGSINH, HOCVIEN.MALOP FROM HOCVIEN
JOIN LOP ON LOP.TRGLOP = HOCVIEN.MAHV;

SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, KETQUATHI.LANTHI, KETQUATHI.DIEM FROM HOCVIEN
JOIN KETQUATHI ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE KETQUATHI.MAMH = 'CTRR' AND HOCVIEN.MALOP = 'K12'
ORDER BY HOCVIEN.TEN, HOCVIEN.HO;

SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, MONHOC.TENMH FROM HOCVIEN
JOIN KETQUATHI ON KETQUATHI.MAHV = HOCVIEN.MAHV
JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE LANTHI = 1 AND KQUA = 'Dat';

SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN FROM HOCVIEN
JOIN KETQUATHI ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE MALOP = 'K11' AND (MAMH = 'CTRR' AND LANTHI = 1 AND KQUA = 'Khong dat');

SELECT DISTINCT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN FROM HOCVIEN
JOIN KETQUATHI ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE (LEFT(MALOP, 1) = 'K' AND KQUA = 'Khong dat') AND MAMH = 'CTRR';

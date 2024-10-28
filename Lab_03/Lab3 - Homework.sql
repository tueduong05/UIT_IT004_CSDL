-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT KyNang.TenKyNang, ChuyenGia_KyNang.CapDo FROM ChuyenGia_KyNang
JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE ChuyenGia_KyNang.MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT ChuyenGia.HoTen FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE ChuyenGia_DuAn.MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT CongTy.TenCongTy, DuAn.TenDuAn FROM DuAn
JOIN CongTy ON CongTy.MaCongTy = DuAn.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(*) AS SoChuyenGia FROM ChuyenGia 
GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT HoTen FROM ChuyenGia 
WHERE NamKinhNghiem = (SELECT MAX(NamKinhNghiem) FROM ChuyenGia);

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_DuAn.MaDuAn) AS SoDuAn FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT CongTy.TenCongTy, COUNT(DuAn.MaDuAn) AS SoDuAn FROM CongTy
LEFT JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
GROUP BY CongTy.TenCongTy;

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT TOP 1 KyNang.TenKyNang, COUNT(ChuyenGia_KyNang.MaChuyenGia) AS SoChuyenGia FROM KyNang
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
GROUP BY KyNang.TenKyNang
ORDER BY SoChuyenGia DESC;

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT ChuyenGia.HoTen FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE KyNang.TenKyNang = 'Python' AND ChuyenGia_KyNang.CapDo >= 4;

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TOP 1 DuAn.TenDuAn, COUNT(ChuyenGia_DuAn.MaChuyenGia) AS SoChuyenGia FROM DuAn
JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
GROUP BY DuAn.TenDuAn
ORDER BY SoChuyenGia DESC;

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoKyNang FROM ChuyenGia
LEFT JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2, DuAn.TenDuAn FROM ChuyenGia_DuAn cgd1
JOIN ChuyenGia_DuAn cgd2 ON cgd1.MaDuAn = cgd2.MaDuAn AND cgd1.MaChuyenGia < cgd2.MaChuyenGia
JOIN ChuyenGia cg1 ON cgd1.MaChuyenGia = cg1.MaChuyenGia
JOIN ChuyenGia cg2 ON cgd2.MaChuyenGia = cg2.MaChuyenGia
JOIN DuAn ON cgd1.MaDuAn = DuAn.MaDuAn
ORDER BY DuAn.TenDuAn, ChuyenGia1, ChuyenGia2;

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoKyNangCapDo5 FROM ChuyenGia
LEFT JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE ChuyenGia_KyNang.CapDo = 5
GROUP BY ChuyenGia.HoTen;

-- 21. Tìm các công ty không có dự án nào.
SELECT CongTy.TenCongTy FROM CongTy
LEFT JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
WHERE DuAn.MaDuAn IS NULL;

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT ChuyenGia.HoTen, DuAn.TenDuAn FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
LEFT JOIN DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT ChuyenGia.HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
HAVING COUNT(ChuyenGia_KyNang.MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT CongTy.TenCongTy, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem FROM CongTy
JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY CongTy.TenCongTy;

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT ChuyenGia.HoTen FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE ChuyenGia_KyNang.MaKyNang = (SELECT MaKyNang FROM KyNang WHERE TenKyNang = 'Java')
    AND ChuyenGia.MaChuyenGia NOT IN (
        SELECT ChuyenGia_KyNang.MaChuyenGia FROM ChuyenGia_KyNang 
        WHERE ChuyenGia_KyNang.MaKyNang = (SELECT MaKyNang FROM KyNang WHERE TenKyNang = 'Python')
    );

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT TOP 1 ChuyenGia.HoTen, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
ORDER BY SoKyNang DESC;

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2, cg1.ChuyenNganh FROM ChuyenGia cg1
JOIN ChuyenGia cg2 ON cg1.MaChuyenGia < cg2.MaChuyenGia
WHERE cg1.ChuyenNganh = cg2.ChuyenNganh
ORDER BY cg1.ChuyenNganh, ChuyenGia1, ChuyenGia2;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 CongTy.TenCongTy, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem FROM CongTy
JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY CongTy.TenCongTy
ORDER BY TongNamKinhNghiem DESC;

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT KyNang.TenKyNang FROM KyNang
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
GROUP BY KyNang.TenKyNang
HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia);


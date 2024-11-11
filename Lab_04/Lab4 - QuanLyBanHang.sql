-- 19. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(*) AS SoHoaDonKPKHDKTVMua
FROM HOADON 
WHERE MAKH IS NULL;

-- 20. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(DISTINCT MASP) AS SoSPBanNam2006
FROM CTHD 
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE YEAR(NGHD) = 2006;

-- 21. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
SELECT MAX(TRIGIA) AS TriGiaHDCaoI, MIN(TRIGIA) AS TriGiaHDThapI
FROM HOADON;

-- 22. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) AS TriGiaTB2006
FROM HOADON 
WHERE YEAR(NGHD) = 2006;

-- 23. Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) AS DoanhThu2006
FROM HOADON 
WHERE YEAR(NGHD) = 2006;

-- 24. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT SOHD AS SoHDTriGiaCaoI2006
FROM HOADON 
WHERE YEAR(NGHD) = 2006 
AND TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = 2006);

-- 25. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT KH.HOTEN AS HoTenKHMuaHDCoTGCaoI2006
FROM HOADON HD
JOIN KHACHHANG KH ON HD.MAKH = KH.MAKH
WHERE HD.SOHD = (
  SELECT SOHD 
  FROM HOADON 
  WHERE YEAR(NGHD) = 2006 
  AND TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = 2006)
);

-- 26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.
SELECT TOP 3 MAKH, HOTEN 
FROM KHACHHANG 
ORDER BY DOANHSO DESC;

-- 27. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP 
FROM SANPHAM
WHERE GIA IN (
  SELECT DISTINCT TOP 3 GIA 
  FROM SANPHAM 
  ORDER BY GIA DESC
);

-- 28. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức
-- giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP 
FROM SANPHAM 
WHERE NUOCSX = 'Thai Lan' 
AND GIA IN (
  SELECT DISTINCT TOP 3 GIA 
  FROM SANPHAM 
  ORDER BY GIA DESC
);

-- 29. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức
-- giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP 
FROM SANPHAM 
WHERE NUOCSX = 'Trung Quoc' 
AND GIA IN (
  SELECT DISTINCT TOP 3 GIA 
  FROM SANPHAM 
  WHERE NUOCSX = 'Trung Quoc' 
  ORDER BY GIA DESC
);

-- 30. * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).
SELECT TOP 3 MAKH, HOTEN 
FROM KHACHHANG 
ORDER BY DOANHSO DESC;

-- 31. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT SUM(SL) AS TongSoSPTQSX
FROM CTHD 
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE SANPHAM.NUOCSX = 'Trung Quoc';

-- 32. Tính tổng số sản phẩm của từng nước sản xuất.
SELECT SANPHAM.NUOCSX, SUM(CTHD.SL) AS TongSoSP
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
GROUP BY SANPHAM.NUOCSX;

-- 33. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX, MAX(GIA) AS CaoNhat, MIN(GIA) AS ThapNhat, AVG(GIA) AS TB
FROM SANPHAM
GROUP BY NUOCSX;

-- 34. Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, SUM(TRIGIA) AS DoanhThuMoiNgay
FROM HOADON
GROUP BY NGHD;

-- 35. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT MASP, SUM(SL) AS TongSLBanRa102006
FROM CTHD 
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD 
WHERE MONTH(NGHD) = 10 AND YEAR(NGHD) = 2006
GROUP BY MASP;

-- 36. Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) AS Thang, SUM(TRIGIA) AS DoanhThuThang2006
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD);

-- 37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD 
FROM CTHD 
GROUP BY SOHD 
HAVING COUNT(DISTINCT MASP) >= 4;

-- 38. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT DISTINCT hd.SOHD
FROM HOADON HD
JOIN CTHD ON HD.SOHD = CTHD.SOHD
JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
WHERE SP.NUOCSX = 'Viet Nam'
GROUP BY HD.SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3;

-- 39. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
SELECT TOP 1 KH.MAKH, KH.HOTEN, COUNT(HD.SOHD) AS SoLanMua
FROM KHACHHANG KH
JOIN HOADON HD ON KH.MAKH = HD.MAKH
GROUP BY KH.MAKH, KH.HOTEN
ORDER BY SoLanMua DESC;

-- 40. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất?
SELECT TOP 1 MONTH(NGHD) AS Thang, SUM(TRIGIA) AS DoanhSo
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY DoanhSo DESC;

-- 41. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT TOP 1 SP.MASP, SP.TENSP, SUM(CTHD.SL) AS TongSL
FROM CTHD
JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY SP.MASP, SP.TENSP
ORDER BY TongSL ASC;

-- 42. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT SP.NUOCSX, SP.MASP, SP.TENSP, SP.GIA
FROM SANPHAM SP
WHERE SP.GIA = (
    SELECT MAX(SP1.GIA)
    FROM SANPHAM SP1
    WHERE SP1.NUOCSX = SP.NUOCSX
)
ORDER BY SP.NUOCSX;

-- 43. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

-- 44. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất
WITH Top10KhachHang AS (
    SELECT TOP 10 KH.MAKH, KH.HOTEN, SUM(HO.TRIGIA) AS DoanhSo
    FROM KHACHHANG KH
    JOIN HOADON HO ON KH.MAKH = HO.MAKH
    GROUP BY KH.MAKH, KH.HOTEN
    ORDER BY DoanhSo DESC
)
SELECT TOP 1 KH.MAKH, KH.HOTEN, COUNT(HO.SOHD) AS SoLanMua
FROM Top10KhachHang KH
JOIN HOADON HO ON KH.MAKH = HO.MAKH
GROUP BY KH.MAKH, KH.HOTEN
ORDER BY SoLanMua DESC;

-- KHÔNG TÌM THẤY CÂU 45

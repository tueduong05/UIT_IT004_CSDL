-- 12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT SOHD FROM CTHD
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20
GROUP BY SOHD;

-- 13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT SOHD FROM CTHD
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) = 2;

-- 14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007.
SELECT SANPHAM.MASP, SANPHAM.TENSP FROM SANPHAM
JOIN CTHD ON CTHD.MASP = SANPHAM.MASP
JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
WHERE NUOCSX = 'Trung Quoc' OR NGHD = '2007-1-1'
GROUP BY SANPHAM.MASP, SANPHAM.TENSP;

-- 15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT MASP, TENSP FROM SANPHAM
WHERE MASP NOT IN (SELECT MASP FROM CTHD);

-- 16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT MASP, TENSP FROM SANPHAM
WHERE MASP NOT IN (
    SELECT DISTINCT MASP FROM CTHD
	JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
    WHERE YEAR(NGHD) = 2006
);

-- 17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND MASP NOT IN (
    SELECT DISTINCT MASP FROM CTHD
	JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
    WHERE YEAR(NGHD) = 2006
);

-- 18. Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.
SELECT HOADON.SOHD FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE YEAR(HOADON.NGHD) = 2006 AND SANPHAM.NUOCSX = 'Singapore'
GROUP BY HOADON.SOHD
HAVING COUNT(DISTINCT SANPHAM.MASP) = (
    SELECT COUNT(DISTINCT MASP) FROM SANPHAM
    WHERE NUOCSX = 'Singapore'
);

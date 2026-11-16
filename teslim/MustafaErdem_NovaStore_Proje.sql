-- ============================================================
-- Mustafa Erdem - NovaStore E-Ticaret Veri Yönetim Sistemi
-- SQL Server (T-SQL) Teslim Scripti
-- Dosya: MustafaErdem_NovaStore_Proje.sql
-- ============================================================

-- ============================================================
-- BÖLÜM 1 — DDL (Veritabanı ve Tablo Oluşturma)
-- ============================================================

-- Bölüm 1 / Veritabanı oluşturma
CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- Bölüm 1 / Categories tablosu
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

-- Bölüm 1 / Products tablosu (Categories'e FK)
CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL DEFAULT 0,
    CategoryID  INT NOT NULL,
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- Bölüm 1 / Customers tablosu
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName   VARCHAR(50) NOT NULL,
    City       VARCHAR(20) NOT NULL,
    Email      VARCHAR(100) NOT NULL UNIQUE
);
GO

-- Bölüm 1 / Orders tablosu (Customers'a FK)
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   DATETIME NOT NULL DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Bölüm 1 / OrderDetails tablosu (Orders ve Products'a FK)
CREATE TABLE OrderDetails (
    DetailID  INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity  INT NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- ============================================================
-- BÖLÜM 2 — DML (Örnek Veri Ekleme)
-- ============================================================

-- Bölüm 2 / Kategoriler (5 adet)
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');
GO

-- Bölüm 2 / Ürünler (12 adet, tüm kategorilere dağıtılmış)
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Kablosuz Kulaklık',        1299.90, 45, 1),  -- Elektronik
('Akıllı Saat',              3499.00, 18, 1),  -- Elektronik
('USB-C Şarj Aleti',          299.50, 12, 1),  -- Elektronik (stok < 20)
('Erkek Pamuk Tişört',        249.90, 60, 2),  -- Giyim
('Kadın Kot Pantolon',        599.00,  8, 2),  -- Giyim (stok < 20)
('Kapüşonlu Sweatshirt',      749.00, 25, 2),  -- Giyim
('Veri Bilimi Kitabı',        320.00, 40, 3),  -- Kitap
('SQL ile Veritabanı',        275.50, 15, 3),  -- Kitap (stok < 20)
('Nemlendirici Krem',         189.90, 55, 4),  -- Kozmetik
('Parfüm Seti',               899.00,  9, 4),  -- Kozmetik (stok < 20)
('Kahve Makinesi',           2199.00, 14, 5),  -- Ev ve Yaşam (stok < 20)
('Yatak Örtüsü Takımı',       450.00, 30, 5);  -- Ev ve Yaşam
GO

-- Bölüm 2 / Müşteriler (6 adet; Ahmet Yılmaz çoklu JOIN sorgusu için)
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz',   'İstanbul', 'ahmet.yilmaz@email.com'),
('Ayşe Demir',     'Ankara',   'ayse.demir@email.com'),
('Mehmet Kaya',    'İzmir',    'mehmet.kaya@email.com'),
('Zeynep Çelik',   'Bursa',    'zeynep.celik@email.com'),
('Can Öztürk',     'Antalya',  'can.ozturk@email.com'),
('Elif Şahin',     'İstanbul', 'elif.sahin@email.com');
GO

-- Bölüm 2 / Siparişler (10 adet, farklı tarihler)
-- TotalAmount = sipariş kalemlerinin (Price * Quantity) toplamı
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-01-15 10:30:00', 4798.90),  -- Ahmet: Kulaklık + Akıllı Saat
(1, '2026-02-20 14:00:00',  525.40),  -- Ahmet: Tişört + SQL Kitabı
(2, '2026-01-22 09:15:00', 1348.00),  -- Ayşe: Kot Pantolon + Sweatshirt
(2, '2026-03-05 16:45:00', 2199.00),  -- Ayşe: Kahve Makinesi
(3, '2026-02-10 11:20:00',  575.00),  -- Mehmet: USB-C + SQL Kitabı
(3, '2026-03-18 13:00:00', 1349.00),  -- Mehmet: Parfüm + Yatak Örtüsü
(4, '2026-01-30 08:50:00',  640.00),  -- Zeynep: Veri Bilimi Kitabı x2
(4, '2026-04-02 17:30:00',  899.00),  -- Zeynep: Parfüm Seti
(5, '2026-02-28 12:10:00', 1549.80),  -- Can: Kulaklık + Tişört
(6, '2026-03-25 15:40:00',  938.90);  -- Elif: Sweatshirt + Nemlendirici
GO

-- Bölüm 2 / Sipariş detayları (TotalAmount ile tutarlı)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),   -- Sipariş 1: Kablosuz Kulaklık
(1, 2, 1),   -- Sipariş 1: Akıllı Saat
(2, 4, 1),   -- Sipariş 2: Erkek Pamuk Tişört
(2, 8, 1),   -- Sipariş 2: SQL ile Veritabanı
(3, 5, 1),   -- Sipariş 3: Kadın Kot Pantolon
(3, 6, 1),   -- Sipariş 3: Kapüşonlu Sweatshirt
(4, 11, 1),  -- Sipariş 4: Kahve Makinesi
(5, 3, 1),   -- Sipariş 5: USB-C Şarj Aleti
(5, 8, 1),   -- Sipariş 5: SQL ile Veritabanı
(6, 10, 1),  -- Sipariş 6: Parfüm Seti
(6, 12, 1),  -- Sipariş 6: Yatak Örtüsü Takımı
(7, 7, 2),   -- Sipariş 7: Veri Bilimi Kitabı x2
(8, 10, 1),  -- Sipariş 8: Parfüm Seti
(9, 1, 1),   -- Sipariş 9: Kablosuz Kulaklık
(9, 4, 1),   -- Sipariş 9: Erkek Pamuk Tişört
(10, 6, 1),  -- Sipariş 10: Kapüşonlu Sweatshirt
(10, 9, 1);  -- Sipariş 10: Nemlendirici Krem
GO

-- ============================================================
-- BÖLÜM 3 — SORGULAR
-- ============================================================

-- Bölüm 3 / Soru 1
-- Stok miktarı 20'den az olan ürünlerin adını ve stok bilgisini,
-- stok miktarına göre azalan sırada listeleyiniz.
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- Bölüm 3 / Soru 2
-- Customers ve Orders tablolarını INNER JOIN ile birleştirerek
-- müşteri adı, şehir, sipariş tarihi ve toplam tutarı getiriniz.
SELECT
    c.FullName,
    c.City,
    o.OrderDate,
    o.TotalAmount
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;
GO

-- Bölüm 3 / Soru 3
-- Ahmet Yılmaz'ın sipariş ettiği ürünlerin adını, fiyatını ve
-- kategori bilgisini zincir (çoklu) JOIN ile getiriniz.
SELECT
    p.ProductName,
    p.Price,
    cat.CategoryName
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN Products AS p
    ON od.ProductID = p.ProductID
INNER JOIN Categories AS cat
    ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';
GO

-- Bölüm 3 / Soru 4
-- Her kategorideki ürün sayısını GROUP BY, COUNT ve LEFT JOIN
-- kullanarak listeleyiniz.
SELECT
    cat.CategoryName,
    COUNT(p.ProductID) AS UrunSayisi
FROM Categories AS cat
LEFT JOIN Products AS p
    ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryName;
GO

-- Bölüm 3 / Soru 5
-- Her müşterinin toplam harcama tutarını SUM ve GROUP BY ile
-- hesaplayıp harcama tutarına göre azalan sırada gösteriniz.
SELECT
    c.FullName,
    SUM(o.TotalAmount) AS ToplamHarcama
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY c.FullName
ORDER BY ToplamHarcama DESC;
GO

-- Bölüm 3 / Soru 6
-- Her siparişin üzerinden kaç gün geçtiğini DATEDIFF ile hesaplayınız.
SELECT
    o.OrderID,
    c.FullName,
    o.OrderDate,
    DATEDIFF(DAY, o.OrderDate, GETDATE()) AS GecenGun
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;
GO

-- ============================================================
-- BÖLÜM 4 — VIEW ve YEDEKLEME
-- ============================================================

-- Bölüm 4 / Soru 1
-- Sipariş özet görünümü: Müşteri Adı, Sipariş Tarihi, Ürün Adı, Adet
CREATE VIEW vw_SiparisOzet
AS
SELECT
    c.FullName   AS [Müşteri Adı],
    o.OrderDate  AS [Sipariş Tarihi],
    p.ProductName AS [Ürün Adı],
    od.Quantity  AS [Adet]
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN Products AS p
    ON od.ProductID = p.ProductID;
GO

-- View kontrol sorgusu (opsiyonel doğrulama)
SELECT * FROM vw_SiparisOzet;
GO

-- Bölüm 4 / Soru 2
-- Veritabanı yedeği
-- NOT: 'C:\Yedek\' klasörünün sunucuda önceden oluşturulmuş olması gerekir.
-- Aksi halde BACKUP komutu hata verir.
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT,
     NAME = 'NovaStoreDB-Full Backup',
     DESCRIPTION = 'NovaStore E-Ticaret veritabanının tam yedeği';
GO

-- ============================================================
-- Script sonu
-- ============================================================

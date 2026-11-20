CREATE DATABASE QuanLyPhongKhamDB;
GO

USE QuanLyPhongKhamDB;
GO

-- 1. Phân quyền & Tài khoản
CREATE TABLE NhomNguoiDung (
    MaNhom INT PRIMARY KEY IDENTITY(1,1),
    TenNhom NVARCHAR(50) NOT NULL
);

CREATE TABLE ChucNang (
    MaChucNang VARCHAR(50) PRIMARY KEY,
    TenChucNang NVARCHAR(100) NOT NULL
);

CREATE TABLE ChiTietPhanQuyen (
    MaNhom INT FOREIGN KEY REFERENCES NhomNguoiDung(MaNhom),
    MaChucNang VARCHAR(50) FOREIGN KEY REFERENCES ChucNang(MaChucNang),
    CoQuyen BIT DEFAULT 0,
    PRIMARY KEY (MaNhom, MaChucNang)
);

CREATE TABLE NguoiDung (
    MaND INT PRIMARY KEY IDENTITY(1,1),
    TenDN VARCHAR(50) UNIQUE NOT NULL,
    MatKhau VARCHAR(256) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    MaNhom INT FOREIGN KEY REFERENCES NhomNguoiDung(MaNhom),
    TrangThai BIT DEFAULT 1
);

-- 2. Danh mục
CREATE TABLE BenhNhan (
    MaBN INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    SDT VARCHAR(15),
    DiaChi NVARCHAR(200),
    LaVIP BIT DEFAULT 0
);

CREATE TABLE BacSi (
    MaBS INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    ChuyenKhoa NVARCHAR(100),
    SDT VARCHAR(15)
);

CREATE TABLE Thuoc (
    MaThuoc INT PRIMARY KEY IDENTITY(1,1),
    TenThuoc NVARCHAR(100) NOT NULL,
    DonViTinh NVARCHAR(20),
    SoLuongTon INT NOT NULL CHECK (SoLuongTon >= 0),
    DonGia DECIMAL(18,2) NOT NULL
);

CREATE TABLE DichVu (
    MaDV INT PRIMARY KEY IDENTITY(1,1),
    TenDV NVARCHAR(100) NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL
);

-- 3. Nghiệp vụ Khám & Thanh toán
CREATE TABLE PhieuKham (
    MaPK INT PRIMARY KEY IDENTITY(1,1),
    MaBN INT FOREIGN KEY REFERENCES BenhNhan(MaBN),
    MaBS INT FOREIGN KEY REFERENCES BacSi(MaBS),
    NgayKham DATETIME DEFAULT GETDATE(),
    ChanDoan NVARCHAR(500),
    TrangThai NVARCHAR(50) 
);

CREATE TABLE ChiTietDichVu (
    MaPK INT FOREIGN KEY REFERENCES PhieuKham(MaPK),
    MaDV INT FOREIGN KEY REFERENCES DichVu(MaDV),
    DonGia DECIMAL(18,2),
    PRIMARY KEY (MaPK, MaDV)
);

CREATE TABLE ChiTietDonThuoc (
    MaPK INT FOREIGN KEY REFERENCES PhieuKham(MaPK),
    MaThuoc INT FOREIGN KEY REFERENCES Thuoc(MaThuoc),
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18,2),
    ThanhTien AS (SoLuong * DonGia),
    PRIMARY KEY (MaPK, MaThuoc)
);

CREATE TABLE HoaDon (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaPK INT FOREIGN KEY REFERENCES PhieuKham(MaPK),
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTienThuoc DECIMAL(18,2) DEFAULT 0,
    TongTienDichVu DECIMAL(18,2) DEFAULT 0,
    PhanTramGiamGia INT DEFAULT 0,
    TongThanhToan DECIMAL(18,2),
    MaNDLap INT FOREIGN KEY REFERENCES NguoiDung(MaND)
);

-- Dữ liệu khởi tạo (Seed Data)
INSERT INTO NhomNguoiDung (TenNhom) VALUES (N'Admin'), (N'Bác sĩ'), (N'Lễ tân');

INSERT INTO ChucNang (MaChucNang, TenChucNang) VALUES 
('USER_MGMT', N'Quản lý Người dùng'),
('ROLE_MGMT', N'Phân quyền'),
('PATIENT_MGMT', N'Quản lý Bệnh nhân'),
('EXAM_MGMT', N'Màn hình Khám bệnh'),
('BILLING_MGMT', N'Thanh toán & Hóa đơn'),
('MEDICINE_MGMT', N'Quản lý Kho thuốc'),
('REPORT_MGMT', N'Báo cáo Doanh thu');

-- Cấp toàn quyền cho nhóm Admin (MaNhom = 1)
INSERT INTO ChiTietPhanQuyen (MaNhom, MaChucNang, CoQuyen)
SELECT 1, MaChucNang, 1 FROM ChucNang;

-- Tạo tài khoản Admin mặc định (mật khẩu 'admin123' mã hóa SHA-256)
INSERT INTO NguoiDung (TenDN, MatKhau, HoTen, MaNhom, TrangThai) 
VALUES ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'Quản trị hệ thống', 1, 1);
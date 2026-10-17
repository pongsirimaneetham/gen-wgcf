#!/data/data/com.termux/files/usr/bin/bash

cd ~

# 1. เช็กและติดตั้งเครื่องมือพื้นฐาน + ใบรับรอง SSL (เช็กแยกให้ครบทุกตัว)
if ! command -v proot &> /dev/null || ! command -v wget &> /dev/null || [ ! -f "$PREFIX/etc/tls/cert.pem" ]; then
    echo "⏳ กำลังติดตั้งเครื่องมือและใบรับรอง SSL..."
    pkg update -y
    pkg install proot wget ca-certificates -y
fi

# 2. เช็กว่ามีตัวรัน wgcf หรือยัง ถ้าไม่มีให้ดาวน์โหลด
if [ ! -f "$HOME/wgcf" ]; then
    echo "📥 กำลังดาวน์โหลด wgcf v2.3.1..."
    wget -q --show-progress -O wgcf https://github.com/ViRb3/wgcf/releases/download/v2.3.1/wgcf_2.3.1_linux_arm64
    chmod +x wgcf
fi

# 3. ตั้งค่า DNS และชี้เป้าใบรับรอง SSL (แก้ปัญหา [::1]:53 และ x509)
printf "nameserver 1.1.1.1\nnameserver 8.8.8.8\n" > $PREFIX/etc/resolv.conf
export SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem
export SSL_CERT_DIR=$PREFIX/etc/tls/certs

# 4. เช็กสิทธิ์เข้าถึงหน่วยความจำเครื่อง
if [ ! -d "$HOME/storage" ]; then
    echo "📂 กรุณากดอนุญาต (Allow) สิทธิ์เข้าถึงไฟล์บนหน้าจอ..."
    termux-setup-storage
    sleep 4
fi

# 5. ลบบัญชีเก่าและเจนไฟล์ใหม่
echo "🔄 กำลังลงทะเบียนและสร้างไฟล์คอนฟิกใหม่..."
rm -f wgcf-account.toml wgcf-profile.conf

termux-chroot ./wgcf register --accept-tos
termux-chroot ./wgcf generate

# 6. คัดลอกไฟล์ไปยัง /storage/emulated/0/Download/
FILE_NAME="wgcf-$(date +%Y%m%d_%H%M%S).conf"
if [ -f "wgcf-profile.conf" ]; then
    cp wgcf-profile.conf "/storage/emulated/0/Download/$FILE_NAME"
    echo "✅ สำเร็จ! บันทึกไฟล์ $FILE_NAME ลงในโฟลเดอร์ Download เรียบร้อย"
else
    echo "❌ เกิดข้อผิดพลาด: สร้างไฟล์ไม่สำเร็จ (หากติด 429 Too Many Requests ให้สลับเน็ต/เปิดโหมดเครื่องบินแล้วพิมพ์ gen ใหม่)"
fi

#!/data/data/com.termux/files/usr/bin/bash

cd ~

# 1. เช็กและติดตั้งแพ็กเกจที่จำเป็น (proot และ wget)
if ! command -v proot &> /dev/null || ! command -v wget &> /dev/null; then
    echo "⏳ กำลังติดตั้งเครื่องมือพื้นฐาน..."
    pkg update -y
    pkg install proot wget -y
fi

# 2. เช็กว่ามีตัวรัน wgcf หรือยัง ถ้าไม่มีให้โหลดไฟล์สำเร็จรูปทันที (ไม่ต้องรอคอมไพล์)
if [ ! -f "$HOME/wgcf" ]; then
    echo "📥 กำลังดาวน์โหลด wgcf v2.3.1..."
    wget -q --show-progress -O wgcf https://github.com/ViRb3/wgcf/releases/download/v2.3.1/wgcf_2.3.1_linux_arm64
    chmod +x wgcf
fi

# 3. สร้างไฟล์ DNS เพื่อป้องกันปัญหา [::1]:53 connection refused
printf "nameserver 1.1.1.1\nnameserver 8.8.8.8\n" > ~/resolv.conf

# 4. เช็กสิทธิ์เข้าถึงหน่วยความจำเครื่องอย่างถูกต้อง
if [ ! -d "$HOME/storage" ]; then
    echo "📂 กรุณากดอนุญาต (Allow) สิทธิ์เข้าถึงไฟล์บนหน้าจอ..."
    termux-setup-storage
    sleep 4
fi

# 5. ลบบัญชีเก่าและเจนไฟล์ใหม่ (ใช้ --accept-tos เพื่อกดยอมรับเงื่อนไขอัตโนมัติ)
echo "🔄 กำลังลงทะเบียนและสร้างไฟล์คอนฟิกใหม่..."
rm -f wgcf-account.toml wgcf-profile.conf

proot -b ~/resolv.conf:/etc/resolv.conf ./wgcf register --accept-tos
proot -b ~/resolv.conf:/etc/resolv.conf ./wgcf generate

# 6. คัดลอกไฟล์ไปยัง /storage/emulated/0/Download/
FILE_NAME="wgcf-$(date +%Y%m%d_%H%M%S).conf"
if [ -f "wgcf-profile.conf" ]; then
    cp wgcf-profile.conf "/storage/emulated/0/Download/$FILE_NAME"
    echo "✅ สำเร็จ! บันทึกไฟล์ $FILE_NAME ลงในโฟลเดอร์ Download เรียบร้อย"
else
    echo "❌ เกิดข้อผิดพลาด: สร้างไฟล์ไม่สำเร็จ (หากติด 429 Too Many Requests ให้เปิด-ปิดโหมดเครื่องบินแล้วพิมพ์ gen ใหม่)"
fi

fi

# 3. ลบบัญชีเก่าและเจนไฟล์ใหม่
echo "🔄 กำลังลงทะเบียนและสร้างไฟล์คอนฟิกใหม่..."
rm -f wgcf-account.toml wgcf-profile.conf
echo "y" | ./wgcf register
./wgcf generate

# 4. คัดลอกไฟล์ไปยัง /storage/emulated/0/Download/
FILE_NAME="wgcf-$(date +%Y%m%d_%H%M%S).conf"
if [ -f "wgcf-profile.conf" ]; then
    cp wgcf-profile.conf "/storage/emulated/0/Download/$FILE_NAME"
    echo "✅ สำเร็จ! บันทึกไฟล์ $FILE_NAME ลงในโฟลเดอร์ Download เรียบร้อย"
else
    echo "❌ เกิดข้อผิดพลาด: ไม่สามารถสร้างไฟล์คอนฟิกได้ (อาจติด Rate Limit ให้ลองสลับเน็ต/เปิดโหมดเครื่องบิน)"
fi

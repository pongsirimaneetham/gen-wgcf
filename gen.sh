#!/data/data/com.termux/files/usr/bin/bash

cd ~

# 1. เช็กว่ามีตัวรัน wgcf ที่คอมไพล์แล้วหรือยัง ถ้าไม่มีให้ติดตั้งอัตโนมัติ
if [ ! -f "$HOME/wgcf" ]; then
    echo "⏳ กำลังติดตั้งระบบและสร้างตัวรัน wgcf (ทำแค่ครั้งแรก รอประมาณ 1 นาที)..."
    pkg update -y
    pkg install golang git -y
    go install github.com/ViRb3/wgcf/v2@v2.3.1
    cp ~/go/bin/wgcf ~/wgcf
    chmod +x ~/wgcf
fi

# 2. เช็กสิทธิ์เข้าถึงโฟลเดอร์ Download
if [ ! -d "/storage/emulated/0/Download" ]; then
    termux-setup-storage
    sleep 3
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

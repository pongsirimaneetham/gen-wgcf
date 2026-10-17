# gen-wgcf
#!/data/data/com.termux/files/usr/bin/bash

cd ~

# ตรวจสอบว่ามีไฟล์ wgcf หรือยัง ถ้ายังไม่มีให้ติดตั้งและคอมไพล์ใหม่ (ทำแค่รอบแรก)
if [ ! -f "$HOME/wgcf" ]; then
    echo "⏳ กำลังติดตั้งระบบและสร้างตัวรัน wgcf (รอประมาณ 1 นาที)..."
    pkg update -y
    pkg install golang git -y
    go install github.com/ViRb3/wgcf/v2@v2.3.1
    cp ~/go/bin/wgcf ~/wgcf
    chmod +x ~/wgcf
fi

# ตรวจสอบสิทธิ์เข้าถึงโฟลเดอร์ Download
if [ ! -d "/storage/emulated/0/Download" ]; then
    termux-setup-storage
    sleep 3
fi

# ลบบัญชีเก่าและเจนไฟล์ใหม่
echo "🔄 กำลังลงทะเบียนและสร้างไฟล์คอนฟิกใหม่..."
rm -f wgcf-account.toml wgcf-profile.conf
echo "y" | ./wgcf register
./wgcf generate

# คัดลอกไฟล์ไปยัง Download
FILE_NAME="wgcf-$(date +%Y%m%d_%H%M%S).conf"
cp wgcf-profile.conf "/storage/emulated/0/Download/$FILE_NAME"

echo "✅ สำเร็จ! บันทึกไฟล์ $FILE_NAME ลงในโฟลเดอร์ Download เรียบร้อย"

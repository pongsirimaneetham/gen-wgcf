#!/data/data/com.termux/files/usr/bin/bash

cd ~

# รับค่าจำนวนครั้งจากคำสั่ง (ถ้าไม่ใส่ตัวเลข จะตั้งค่าเริ่มต้นเป็น 1 ครั้ง)
COUNT=${1:-1}

# 1. เช็กและติดตั้งเครื่องมือพื้นฐาน + ใบรับรอง SSL
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

# 3. ตั้งค่า DNS และชี้เป้าใบรับรอง SSL
printf "nameserver 1.1.1.1\nnameserver 8.8.8.8\n" > $PREFIX/etc/resolv.conf
export SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem
export SSL_CERT_DIR=$PREFIX/etc/tls/certs

# 4. เช็กสิทธิ์เข้าถึงหน่วยความจำเครื่อง
if [ ! -d "$HOME/storage" ]; then
    echo "📂 กรุณากดอนุญาต (Allow) สิทธิ์เข้าถึงไฟล์บนหน้าจอ..."
    termux-setup-storage
    sleep 4
fi

# 5. วนลูปสร้างไฟล์ตามจำนวนครั้งที่ระบุ
echo "🚀 เริ่มต้นการสร้างไฟล์คอนฟิกจำนวน $COUNT ไฟล์..."

for (( i=1; i<=COUNT; i++ ))
do
    echo "----------------------------------------"
    echo "🔄 [รอบที่ $i/$COUNT] กำลังลงทะเบียนและสร้างไฟล์..."
    rm -f wgcf-account.toml wgcf-profile.conf

    termux-chroot ./wgcf register --accept-tos
    termux-chroot ./wgcf generate

    # ตั้งชื่อไฟล์ตามวันเวลา + ลำดับรอบ เพื่อไม่ให้ชื่อไฟล์ซ้ำกัน
    FILE_NAME="wgcf-$(date +%Y%m%d_%H%M%S)_${i}.conf"
    
    if [ -f "wgcf-profile.conf" ]; then
        cp wgcf-profile.conf "/storage/emulated/0/Download/$FILE_NAME"
        echo "✅ [รอบที่ $i/$COUNT] สำเร็จ! บันทึกไฟล์ $FILE_NAME เรียบร้อย"
    else
        echo "❌ [รอบที่ $i/$COUNT] ล้มเหลว: สร้างไฟล์ไม่สำเร็จ (อาจติด Rate Limit จาก Cloudflare)"
        echo "💡 แนะนำ: ให้เปิด-ปิดโหมดเครื่องบินเพื่อเปลี่ยน IP ก่อนลองใหม่"
        break
    fi

    # หน่วงเวลา 2 วินาทีก่อนเริ่มรอบถัดไป เพื่อลดโอกาสโดน Cloudflare บล็อก
    if [ $i -lt $COUNT ]; then
        echo "⏳ รอ 2 วินาทีก่อนเริ่มรอบถัดไป..."
        sleep 2
    fi
done

echo "----------------------------------------"
echo "🎉 เสร็จสิ้นการทำงาน! ตรวจสอบไฟล์ทั้งหมดได้ในโฟลเดอร์ Download"

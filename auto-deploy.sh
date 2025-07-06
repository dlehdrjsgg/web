#!/bin/bash

# Beef Website 자동 배포 스크립트
# 로컬 → GitHub → 서버 자동 배포

set -e  # 에러 발생시 스크립트 중단

echo "🚀 Beef Website 자동 배포 시작..."
echo "=====================================\n"

# 1. 로컬 변경사항 커밋 및 푸시
echo "📝 로컬 변경사항 Git 처리..."
git add .
if git diff --cached --quiet; then
    echo "✅ 변경사항 없음"
else
    echo "📤 변경사항 커밋 중..."
    git commit -m "Auto deploy $(date '+%Y-%m-%d %H:%M:%S')"
    echo "📤 GitHub에 푸시 중..."
    git push origin main
    echo "✅ GitHub 푸시 완료"
fi

echo ""

# 2. 서버 배포
echo "🔄 서버 배포 시작..."
ssh root@172.104.89.33 << 'EOF'
echo "📁 웹 디렉토리로 이동..."
cd /var/www/html

echo "🔄 Git에서 최신 코드 가져오기..."
git reset --hard HEAD  # 로컬 변경사항 무시
git pull origin main

echo "🔐 파일 권한 설정..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "🌐 Nginx 설정 테스트..."
nginx -t

echo "🔄 Nginx 재시작..."
systemctl reload nginx

echo "📊 서버 상태 확인..."
systemctl status nginx --no-pager -l

echo "📋 배포된 파일 목록:"
echo "- HTML: $(ls -la index.html | awk '{print $9, $5, $6, $7, $8}')"
echo "- CSS: $(ls -la style.css | awk '{print $9, $5, $6, $7, $8}')"
echo "- Icons: $(ls -la icon/ | wc -l) files"

echo ""
echo "✅ 서버 배포 완료!"
echo "🌐 브라우저에서 https://beeef.kr 확인하세요!"
EOF

echo ""
echo "🎉 자동 배포 완료!"
echo "=====================================\n"
echo "📋 배포 요약:"
echo "• 로컬 → GitHub: ✅"
echo "• GitHub → 서버: ✅"
echo "• 서버 재시작: ✅"
echo "• 브라우저 확인: https//beeef.kr"
echo ""

#!/bin/bash
set -e
echo "==== 长德鑫 H5 自动部署 ===="
echo "[1/3] 下载文件..."
mkdir -p /var/www/h5 && cd /var/www/h5
curl -sL -o "预约审厂.html" "https://raw.githubusercontent.com/173407760-droid/H5/main/预约审厂.html"
curl -sL -o "logo.svg.png" "https://raw.githubusercontent.com/173407760-droid/H5/main/logo.svg.png"
ls -la /var/www/h5/
echo "[2/3] 配置Nginx..."
CFILE=""
for f in /etc/nginx/conf.d/*.conf /etc/nginx/sites-enabled/*; do
  if [ -f "$f" ] && grep -q "aitiktoktool" "$f"; then CFILE="$f"; break; fi
done
if [ -z "$CFILE" ]; then
  CFILE="/etc/nginx/conf.d/h5-appointment.conf"
  printf "server {\n    listen 80;\n    server_name aitiktoktool.cn;\n    location /appointment/ {\n        alias /var/www/h5/;\n        try_files $uri $uri/ /appointment/预约审厂.html;\n    }\n    location / {\n        proxy_pass http://127.0.0.1:3000;\n        proxy_http_version 1.1;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n    }\n}\n" > "$CFILE"
else
  if ! grep -q "/appointment/" "$CFILE"; then
    cp "$CFILE" "${CFILE}.bak.$(date +%s)"
    python3 -c "import sys;c=open(sys.argv[1]).read();l=chr(10)+chr(32)*4+chr(35)+chr(32)+chr(38)+chr(46)+chr(46)+chr(10)+chr(32)*4+chr(108)+chr(111)+chr(99)+chr(97)+chr(116)+chr(105)+chr(111)+chr(110)+chr(32)+chr(47)+chr(97)+chr(112)+chr(112)+chr(111)+chr(105)+chr(110)+chr(116)+chr(109)+chr(101)+chr(110)+chr(116)+chr(47)+chr(32)+chr(123)+chr(10)+chr(32)*8+chr(97)+chr(108)+chr(105)+chr(97)+chr(115)+chr(32)+chr(47)+chr(118)+chr(97)+chr(114)+chr(47)+chr(119)+chr(119)+chr(119)+chr(47)+chr(104)+chr(53)+chr(47)+chr(59)+chr(10)+chr(32)*8+chr(116)+chr(114)+chr(121)+chr(95)+chr(102)+chr(105)+chr(108)+chr(101)+chr(115)+chr(32)+chr(36)+chr(117)+chr(114)+chr(105)+chr(32)+chr(36)+chr(117)+chr(114)+chr(105)+chr(47)+chr(32)+chr(47)+chr(97)+chr(112)+chr(112)+chr(111)+chr(105)+chr(110)+chr(116)+chr(109)+chr(101)+chr(110)+chr(116)+chr(47)+chr(233)+chr(162)+chr(128)+chr(170)+chr(231)+chr(186)+chr(134)+chr(229)+chr(174)+chr(161)+chr(46)+chr(104)+chr(116)+chr(109)+chr(108)+chr(59)+chr(10)+chr(32)*4+chr(125)+chr(10);j=c.rfind(chr(125));c=c[:j]+l+c[j:];open(sys.argv[1],chr(119)).write(c);print(chr(79)+chr(75))" "$CFILE"
  fi
fi
echo "[3/3] 重载Nginx..."
nginx -t && nginx -s reload && echo OK
echo "访问: http://175.178.112.48/appointment/预约审厂.html"
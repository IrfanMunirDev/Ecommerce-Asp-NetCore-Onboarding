#!/bin/sh
set -eu

: "${FTP_HOST:?FTP_HOST required}"
: "${FTP_PORT:?FTP_PORT required}"
: "${FTP_USER:?FTP_USER required}"
: "${FTP_PASSWORD:?FTP_PASSWORD required}"

if ! lftp -u "$FTP_USER","$FTP_PASSWORD" "sftp://$FTP_HOST:$FTP_PORT" <<LFTP
set sftp:auto-confirm yes
set net:max-retries 2
set net:timeout 20
put deploy/app_offline.htm -o /wwwroot/app_offline.htm
mirror -R --delete --parallel=2 --exclude app_offline.htm publish/ /wwwroot/
rm -f /wwwroot/app_offline.htm
bye
LFTP
then
  echo "SFTP deploy failed" >&2
  exit 1
fi

if [ -n "${SITE_URL:-}" ]; then
  i=0
  while [ "$i" -lt 10 ]; do
    if wget -q -T 15 -O /dev/null "$SITE_URL"; then
      echo "Health check OK: $SITE_URL"
      exit 0
    fi
    i=$((i+1))
    sleep 5
  done
  echo "Health check did not pass, but deploy finished: $SITE_URL" >&2
fi

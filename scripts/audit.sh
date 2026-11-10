echo "[5] Контейнеризация"

# a) docker доступен (проверка через docker info, работает и без systemd)
if docker info >/dev/null 2>&1; then
    echo "  [OK] docker доступен"
else
    echo "  [FAIL] docker недоступен"
    exit 1
fi

# б) контейнер СУБД healthy
DB_HEALTH=$(docker inspect -f '{{.State.Health.Status}}' app-db-1 2>/dev/null)
if [ "$DB_HEALTH" = "healthy" ]; then
    echo "  [OK] app-db-1 healthy"
else
    echo "  [FAIL] app-db-1 не healthy (статус: $DB_HEALTH)"
    exit 1
fi

# в) порты 5000 и 5432 не слушаются ни на одном адресе, кроме 127.0.0.1
BAD_PORTS=$(ss -tln | awk 'NR>1 {print $4}' | grep -E ':(5000|5432)$' | grep -v '^127\.0\.0\.1:' || true)
if [ -z "$BAD_PORTS" ]; then
    echo "  [OK] порты 5000 и 5432 доступны только на 127.0.0.1"
else
    echo "  [FAIL] порты 5000/5432 слушаются на недопустимых адресах:"
    echo "$BAD_PORTS"
    exit 1
fi

# г) права файла .env равны 600
ENV_PERMS=$(stat -c '%a' ~/app/.env 2>/dev/null)
if [ "$ENV_PERMS" = "600" ]; then
    echo "  [OK] ~/app/.env имеет права 600"
else
    echo "  [FAIL] ~/app/.env имеет права $ENV_PERMS (ожидается 600)"
    exit 1
fi

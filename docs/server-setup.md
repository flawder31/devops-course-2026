## 9. Контейнеризация

- **Способ установки Docker Engine:** официальный репозиторий Docker (не пакет `docker.io` из Ubuntu).
- **Версия Docker Engine:** 27.x (уточните `docker version` в VM, раздел Server).
- **Участники группы docker:** пользователь `devops` (добавлен командой `sudo usermod -aG docker devops`).
- **Расположение проекта на сервере:** `/home/devops/app/` (файлы `app.py`, `requirements.txt`, `Dockerfile`, `docker-compose.yml`, `.env.example`).
- **Расположение файла `.env`:** `/home/devops/app/.env`, права `600`, владелец `devops`. Содержит секрет `POSTGRES_PASSWORD`.
- **Публикуемые порты и адреса:**
  - Приложение: `127.0.0.1:5000:5000` (доступно только с локального адреса сервера, для Nginx).
  - СУБД PostgreSQL: порт **не публикуется** (доступна только внутри сети `app_backend`).
- **Именованные тома:** `app_db_data` (данные PostgreSQL, сохраняются при `docker compose down`, удаляются при `docker compose down -v`).
- **Конфигурация обратного прокси-сервера:** в `/etc/nginx/sites-available/devops-site` в блоке `server` для HTTPS добавлено:
  ```nginx
  location /app/ {
      proxy_pass http://127.0.0.1:5000/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
  }

server {
    server_name prefixmindmap.domainname;
    location / {
        proxy_pass http://127.0.0.1:7079;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    listen 80; # managed by Certbot
}
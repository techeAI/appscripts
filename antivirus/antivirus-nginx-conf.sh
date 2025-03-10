server {
    listen 80;
    server_name antivirus.domainname;  # Replace with your domain or IP

    root /var/www/html/scans;  # Directory where your HTML files are stored
        location / {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
}
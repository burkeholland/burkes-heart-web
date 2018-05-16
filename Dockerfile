FROM nginx

WORKDIR /app

# Copy in the static build assets
COPY dist/ /app/dist/

# Copy in the nginx config file
COPY misc/nginx.conf /etc/nginx/nginx.conf

# All files are in, start the web server
CMD ["nginx"]

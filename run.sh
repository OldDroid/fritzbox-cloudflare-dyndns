#!/usr/bin/with-contenv bashio

# Read configuration from the add-on options
DYNDNS_SERVER_USERNAME=$(bashio::config 'dyndns_server_username')
FRITZBOX_ENDPOINT_URL=$(bashio::config 'fritzbox_endpoint_url')
FRITZBOX_ENDPOINT_INTERVAL=$(bashio::config 'fritzbox_endpoint_interval')
FRITZBOX_ENDPOINT_TIMEOUT=$(bashio::config 'fritzbox_endpoint_timeout')
CLOUDFLARE_ZONES_IPV4=$(bashio::config 'cloudflare_zones_ipv4')
CLOUDFLARE_ZONES_IPV6=$(bashio::config 'cloudflare_zones_ipv6')

echo "$(bashio::config 'dyndns_server_password')" > /server_pw
chmod 600 /server_pw

export DYNDNS_SERVER_BIND=:8080
export DYNDNS_SERVER_USERNAME
export DYNDNS_SERVER_PASSWORD_FILE="/server_pw"

export FRITZBOX_ENDPOINT_URL
export FRITZBOX_ENDPOINT_INTERVAL
export FRITZBOX_ENDPOINT_TIMEOUT

echo "$(bashio::config 'cloudflare_api_token')" > /api_token
chmod 600 /api_token

export CLOUDFLARE_API_TOKEN_FILE="/api_token"
export CLOUDFLARE_ZONES_IPV4
export CLOUDFLARE_ZONES_IPV6

# Start the service
exec /fritzbox-cloudflare-dyndns
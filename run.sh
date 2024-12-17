#!/usr/bin/with-contenv bashio

# Read configuration from the add-on options
FRITZBOX_ENDPOINT_URL=$(bashio::config 'fritzbox_endpoint_url')
FRITZBOX_ENDPOINT_TIMEOUT=$(bashio::config 'fritzbox_endpoint_timeout')
DYNDNS_SERVER_BIND=$(bashio::config 'dyndns_server_bind')
CLOUDFLARE_API_KEY=$(bashio::config 'cloudflare_api_key')
CLOUDFLARE_ZONES_IPV4=$(bashio::config 'cloudflare_zones_ipv4')
CLOUDFLARE_ZONES_IPV6=$(bashio::config 'cloudflare_zones_ipv6')

export FRITZBOX_ENDPOINT_URL
export FRITZBOX_ENDPOINT_TIMEOUT
export DYNDNS_SERVER_BIND
export CLOUDFLARE_API_KEY
export CLOUDFLARE_ZONES_IPV4
export CLOUDFLARE_ZONES_IPV6

# Start the service
exec /fritzbox-cloudflare-dyndns
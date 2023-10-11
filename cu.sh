#!/bin/bash

# Cloudflare API credentials
CF_EMAIL="email@email.com" # your login email 
CF_API_KEY="123456789"     # search for your api on your cloudflare page
CF_ZONE_ID="123456789"     # located on your dns overview page 
CF_DOMAIN="domain.com"     # your domain you want updated

# Get your public IP address
PUBLIC_IP=$(curl -s https://ipv4.icanhazip.com)

if [ -z "$PUBLIC_IP" ]; then
  echo "Failed to retrieve public IP address."
  exit 1
fi

# Get the DNS record ID for the A record of your domain
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records" \
  -H "X-Auth-Email: $CF_EMAIL" \
  -H "X-Auth-Key: $CF_API_KEY" \
  -H "Content-Type: application/json" | jq -r ".result[] | select(.type == \"A\" and .name == \"$CF_DOMAIN\") | .id")

if [ -z "$RECORD_ID" ]; then
  echo "Failed to retrieve DNS record ID."
  exit 1
fi

# Update the A record with your public IP
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
  -H "X-Auth-Email: $CF_EMAIL" \
  -H "X-Auth-Key: $CF_API_KEY" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "'$CF_DOMAIN'",
    "content": "'$PUBLIC_IP'",
    "ttl": 1,
    "proxied": false
  }'

if [ $? -eq 0 ]; then
  echo "DNS record updated successfully."
else
  echo "Failed to update DNS record."
  exit 1
fi



#ntfy me I used this section to put a curl script to notify me using a ntfy docker image  "youtube network chuck  ntfy "


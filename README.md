# AVM FRITZ!Box Cloudflare DNS-service

This project has some simple goals:

- Offer a slim service without any additional service requirements
- Allow for two different combined strategies: Polling (through FRITZ!Box SOAP-API) and Pushing (FRITZ!Box Custom-DynDns
  setting).
- Allow multiple domains to be updated with new A (IPv4) and AAAA (IPv6) records
- Push those IP changes directly to Cloudflare DNS
- Deploy in HomeAssistant

If this fits for you, skim over the CNAME workaround if this is a better solution for you, otherwise feel free to visit
the appropriate strategy section of this document and find out how to configure it correctly.

## CNAME record workaround

Before you try this service evaluate a cheap workaround, as it does not require dedicated hardware to run 24/7:

Have dynamic IP updates by using a CNAME record to your myfritz address, found in `Admin > Internet > MyFRITZ-Account`.
It should look like `[hash].myfritz.net`.

This basic example of a BIND DNS entry would make `intranet.example.com` auto update the current IP:

```
$TTL 60
$ORIGIN example.com.
intranet IN CNAME [hash].myfritz.net
```

Beware that this will expose your account hash to the outside world and depend on AVMs service availability.

## Strategies

### FRITZ!Box pushing

You can use this strategy if you have:

- access to the admin panel of the FRITZ!Box router.
- this services runs on a public interface towards the router.

In your plugin configuration the following dyndns server settings can be configured:

| Variable name               | Description                                                                                                                          |
|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| DYNDNS_SERVER_BIND          | required, network interface to bind to, i.e. `:8080`.                                                                                |
| DYNDNS_SERVER_USERNAME      | optional, username for the DynDNS service.                                                                                           |
| DYNDNS_SERVER_PASSWORD      | optional, password for the DynDNS service.                                                                                           |

Now configure the FRITZ!Box router to push IP changes towards this service. Log into the admin panel and go to
`Internet > Shares > DynDNS tab` and setup a  `Custom` provider:

| Property   | Description / Value                                                                    |
|------------|----------------------------------------------------------------------------------------|
| Update-URL | http://[server-ip]/ip?v4=\<ipaddr\>&v6=\<ip6addr\>&prefix=\<ip6lanprefix\>             |
| Domain     | Enter at least one domain name so the router can probe if the update was successfully. |
| Username   | Enter '_' if `DYNDNS_SERVER_USERNAME` is unset.                                        |
| Password   | Enter '_' if `DYNDNS_SERVER_PASSWORD` is unset.                                        |

If you specified credentials you need to append them as additional GET parameters into the Update-URL
like `&username=<username>&password=<pass>`.

### FRITZ!Box polling

You can use this strategy if you have:

- no access to the admin panel of the FRITZ!Box router.
- for whatever reasons the router can not push towards this service, but we can poll from it.
- you do not trust pushing

In your plugin configuration the following fritzbox related settings can be configured:

| Variable name              | Description                                                                                            |
|----------------------------|--------------------------------------------------------------------------------------------------------|
| FRITZBOX_ENDPOINT_URL      | optional, how can we reach the router, default `http://fritz.box:49000`                                |
| FRITZBOX_ENDPOINT_TIMEOUT  | optional, a duration we give the router to respond, default `30s`.                                     |
| FRITZBOX_ENDPOINT_INTERVAL | optional, a duration how often we want to poll the WAN IPs from the router, default `60s`.             |

You can try the endpoint URL in the browser to make sure you have the correct port, you should receive
an `404 ERR_NOT_FOUND`.

_Because `FRITZBOX_ENDPOINT_URL` configuration option is set by default on the docker image, you have to explicitly set it to an empty string
to disable polling_

## Cloudflare setup

To get your API Token do the following: Login to the cloudflare dashboard, go
to `My Profile > API Tokens > Create Token > Edit zone DNS`, give to token some good name (e.g. "DDNS"), add all zones
that the DDNS should be used for, click `Continue to summary` and `Create token`. Be sure to copy the token and add it
to the config, you won't be able to see it again.

In your plugin configuration the following cloudflare related settings can be configured:

| Variable name             | Description                                                                                                                                                 |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CLOUDFLARE_API_TOKEN      | Your Cloudflare API Token.                                                                                                                                  |
| CLOUDFLARE_ZONES_IPV4     | comma-separated list of domains to update with new IPv4 addresses.                                                                                          |
| CLOUDFLARE_ZONES_IPV6     | comma-separated list of domains to update with new IPv6 addresses.                                                                                          |

This service allows to update multiple records, an advanced example would be:

```env
cloudflare_zones_ipv4=ipv4.example.com,ip.example.com,server-01.dev.local
cloudflare_zones_ipv6=ipv6.example.com,ip.example.com,server-01.dev.local
```

Considering the example call `http://192.168.0.2:8080/ip?v4=127.0.0.1&v6=::1` every IPv4 listed zone would be updated to
`127.0.0.1` and every IPv6 listed one to `::1`.

## HomeAssistant

In order to not ship any direct executables the container image gets build on the corresponding homeassistant system itself when installing it.
This includes compiling the Go source code - the installation might take a bit to finish. The base image used for executing the source-built executable is the default hassio base image, version 17.0.1.
Any passwords/api tokens provided in the addon configuration is written to a file inside the container instead of utilizing environment variables in order enhance the container security.

## History & Credit

Most of the credit goes to [@adrianrudnik](https://github.com/adrianrudnik), who wrote and maintained the software for
years. After he moved on cromefire stepped in at a later point when the repository was transferred to him to continue its basic
maintenance should it be required. I (olddroid) picked up there and successfully implemented the whole service as a HomeAssistant compatible Add-On.

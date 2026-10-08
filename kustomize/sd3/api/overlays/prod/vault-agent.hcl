pid_file = "/home/vault/pidfile"

auto_auth {
    method "kubernetes" {
        mount_path = "auth/kubernetes_otcinfra2"
        config = {
            role = "sd3"
            token_path = "/var/run/secrets/tokens/vault-token"
        }
    }
    sink "file" {
        config = {
            path = "/home/vault/.vault-token"
        }
    }
}

template {
  destination = "/secrets/sd3-api-env"
  contents = <<EOT
{{ with secret "secret/data/statusdashboard/sd3-prod" -}}
export SD_DB={{ .Data.data.dburl }}
export SD_CACHE=internal
export SD_LOG_LEVEL=devel
# The OBS static website endpoint the backend proxies every path the API does
# not own. Host only: OBS picks the bucket from the Host header and ignores SNI.
export SD_STATIC_ORIGINS=status.obs-website.eu-de.otc.t-systems.com
export SD_OIDC_ISSUER=https://zitadel.eco.tsi-dev.otc-service.com
# Audience every accepted token must carry: the Zitadel project id, not the
# SPA client id used by the frontend login.
export SD_OIDC_CLIENT_ID=394183996340174906
export SD_OIDC_USERNAME_CLAIM=email
export SD_RBAC_ROLES_ADMINS=sd_admins
export SD_RBAC_ROLES_OPERATORS=sd_operators
export SD_RBAC_ROLES_CREATORS=sd_creators
export SD_RBAC_ROLES_REPORTERS=sd_reporters
export SD_WEB_URL=https://status.otc-service.com
# Notifications are on. Migration 000008 must have created notification_outbox
# first: EnsureNotificationSchema aborts startup when the table is missing.
export SD_NOTIFICATIONS_ENABLED=true
export SD_NOTIFICATIONS_SMOD_EMAIL=SDMoD@t-cloud-public.com
# Constrains only the creator-supplied contact_email, never the review
# audience, which is why SDMoD stays reachable through this.
export SD_NOTIFICATIONS_ALLOWED_DOMAINS=t-systems.com
export SD_NOTIFICATIONS_LEASE_TIMEOUT=60s
export SD_NOTIFICATIONS_MAX_ATTEMPTS=5
export SD_NOTIFICATIONS_BACKOFF_INTERVAL=5m
{{- end }}
# The SMTP credentials live under their own path, so they need a second read;
# the sd3 role's policy covers secret/data/statusdashboard/*.
{{ with secret "secret/data/statusdashboard/smg" -}}
export SD_SMTP_HOST={{ .Data.data.dns_a_record }}
export SD_SMTP_PORT={{ .Data.data.port }}
export SD_SMTP_FROM={{ .Data.data.smtpuser }}
export SD_SMTP_USER={{ .Data.data.smtpuser }}
export SD_SMTP_PASSWORD={{ .Data.data.smtppassword }}
export SD_SMTP_TLS=false
export SD_SMTP_TIMEOUT=30s
{{- end }}

EOT
  perms = "0664"
}

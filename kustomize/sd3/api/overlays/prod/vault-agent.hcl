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
# Mail stays off until migration 000008 has been applied: enabling it without
# the outbox table aborts startup. SD_SMTP_* come with that change.
export SD_NOTIFICATIONS_ENABLED=false
# Constrains only the creator-supplied contact_email, never the review
# audience, which is why SDMoD stays reachable through this.
export SD_NOTIFICATIONS_ALLOWED_DOMAINS=t-systems.com
{{- end }}

EOT
  perms = "0664"
}

pid_file = "/home/vault/pidfile"

auto_auth {
    method "kubernetes" {
        mount_path = "auth/kubernetes_otcinfra2"
        config = {
            role = "sd3-ch"
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
  destination = "/secrets/sd3-ch-api-env"
  contents = <<EOT
{{ with secret "secret/data/statusdashboard/sd3-ch-prod" -}}
export SD_DB={{ .Data.data.dburl }}
export SD_CACHE=internal
export SD_LOG_LEVEL=devel
export SD_SECRET_KEY={{ .Data.data.sdsecretkey }}
export SD_WEB_URL=https://status-ch.otc-service.com
export SD_HOSTNAME=https://api.status-ch.otc-service.com
export SD_KEYCLOAK_URL={{ .Data.data.keycloakurl }}
export SD_KEYCLOAK_REALM={{ .Data.data.keycloakrealm }}
export SD_KEYCLOAK_CLIENT_ID={{ .Data.data.keycloakclientid }}
export SD_KEYCLOAK_CLIENT_SECRET={{ .Data.data.keycloakclientsecret }}
{{- end }}

EOT
  perms = "0664"
}

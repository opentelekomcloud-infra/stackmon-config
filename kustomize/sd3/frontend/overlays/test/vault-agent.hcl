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
  destination = "/secrets/sd3-front-env"
  contents = <<EOT
{{ with secret "secret/data/statusdashboard/sd3-test" -}}
export SD_BACKEND_URL="https://api.test.status.otc-service.com"
export SD_BACKEND_API="/v2"
export SD_BACKEND_V2=true
export SD_CLIENT_ID="status-dashboard"
export SD_AUTHORITY="https://keycloak.eco.tsi-dev.otc-service.com/realms/eco"
export SD_REDIRECT=="https://test.status.otc-service.com/signin-oidc"
export SD_LOGOUT_REDIRECT="https://test.status.otc-service.com/signout-callback-oidc"
export SD_AUTH_SECRET={{ .Data.data.authsecret }}
export SD_BACKEND_FILE=false
export SD_FREEZE=false
{{- end }}
EOT
  perms = "0664"
}

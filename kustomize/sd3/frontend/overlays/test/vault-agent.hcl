pid_file = "/home/vault/pidfile"

auto_auth {
    method "kubernetes" {
        mount_path = "auth/kubernetes_otc_sd"
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
{{ with secret "secret/data/sd3-test" -}}
export SD_BACKEND_URL=""
export SD_BACKEND_API=""
export SD_BACKEND_V2=false

export SD_CLIENT_ID=""
export SD_AUTHORITY=""
export SD_REDIRECT=""
export SD_LOGOUT_REDIRECT=""
export SD_AUTH_SECRET=""

export SD_BACKEND_FILE=false
export SD_FREEZE=false
{{- end }}

EOT
  perms = "0664"
}

pid_file = "/home/vault/pidfile"

auto_auth {
    method "kubernetes" {
        mount_path = "auth/kubernetes_otcinfra2"
        config = {
            role = "cpn"
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
export SD_DB={{ .Data.data.dburi }}
export SD_CACHE=internal
export SD_LOG_LEVEL=devel
{{- end }}

EOT
  perms = "0664"
}

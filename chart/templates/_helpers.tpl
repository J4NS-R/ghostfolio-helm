{{/*
Expand the name of the chart.
*/}}
{{- define "ghostfolio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ghostfolio.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ghostfolio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ghostfolio.labels" -}}
helm.sh/chart: {{ include "ghostfolio.chart" . }}
{{ include "ghostfolio.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ghostfolio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ghostfolio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the postgres subchart fullname - mirrors the postgres subchart's fullname logic
*/}}
{{- define "ghostfolio.postgresFullname" -}}
{{- if .Values.postgres.fullnameOverride -}}
{{- .Values.postgres.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgres" .Values.postgres.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Get the name of the Secret containing the PostgreSQL credentials.
When postgres.auth.existingSecret is set, the user manages their own secret.
Otherwise the postgres subchart auto-generates one named after its fullname.
*/}}
{{- define "ghostfolio.postgresSecretName" -}}
{{- if .Values.postgres.auth.existingSecret -}}
{{- .Values.postgres.auth.existingSecret -}}
{{- else -}}
{{- include "ghostfolio.postgresFullname" . -}}
{{- end -}}
{{- end }}

{{/*
Create the Valkey host - mirrors the valkey subchart's fullname logic
*/}}
{{- define "ghostfolio.valkeyHost" -}}
{{- if .Values.valkey.fullnameOverride -}}
{{- .Values.valkey.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "valkey" .Values.valkey.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Get the name of the Secret containing the Valkey password
*/}}
{{- define "ghostfolio.valkeyPasswordSecretName" -}}
{{- if .Values.valkey.enabled -}}
{{ required "valkey.auth.usersExistingSecret is required when valkey.enabled=true — set it to the name of the Secret containing the Valkey password" .Values.valkey.auth.usersExistingSecret }}
{{- else -}}
{{ required "externalValkey.existingSecret is required when valkey.enabled=false — set it to the name of the Secret containing the Redis/Valkey password" .Values.externalValkey.existingSecret }}
{{- end -}}
{{- end }}

{{/*
Get the key within the Secret that holds the Valkey password
*/}}
{{- define "ghostfolio.valkeyPasswordSecretKey" -}}
{{- if .Values.valkey.enabled -}}
{{ .Values.valkey.passwordSecretKey | default "default" }}
{{- else -}}
{{ .Values.externalValkey.existingSecretPasswordKey | default "password" }}
{{- end -}}
{{- end }}

{{/*
Get the name of the Secret containing ACCESS_TOKEN_SALT and JWT_SECRET_KEY
*/}}
{{- define "ghostfolio.existingSecretName" -}}
{{ required "ghostfolio.existingSecret is required — set it to the name of the Secret containing ACCESS_TOKEN_SALT and JWT_SECRET_KEY" .Values.ghostfolio.existingSecret }}
{{- end }}

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
Create the name of the service account to use
*/}}
{{- define "ghostfolio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ghostfolio.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the PostgreSQL database URL
*/}}
{{- define "ghostfolio.databaseUrl" -}}
{{- $fullname := (include "ghostfolio.fullname" .) -}}
{{ printf "postgresql://%s:%s@%s-postgresql.%s.svc:5432/%s?connect_timeout=300&sslmode=prefer" .Values.postgresql.auth.username .Values.postgresql.auth.password $fullname .Release.Namespace .Values.postgresql.auth.database }}
{{- end }}


{{- define "ghostfolio.externalDatabaseUrl" -}}
{{- printf "postgresql://%s:%s@%s:%d/%s?%s" .Values.externalPostgresql.auth.username .Values.externalPostgresql.auth.password .Values.externalPostgresql.host (.Values.externalPostgresql.port | int) .Values.externalPostgresql.auth.database .Values.externalPostgresql.options }}
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
{{ .Values.valkey.auth.usersExistingSecret }}
{{- else -}}
{{ .Values.externalValkey.existingSecret }}
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

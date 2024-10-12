{{/*
Expand the name of the chart.
*/}}
{{- define "pihole.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pihole.fullname" -}}
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
{{- define "pihole.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pihole.labels" -}}
helm.sh/chart: {{ include "pihole.chart" . }}
{{ include "pihole.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Application selector labels
*/}}
{{- define "pihole.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pihole.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pihole.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pihole.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the admin service to use
*/}}
{{- define "pihole.adminServiceName" -}}
{{- printf "%s-%s-admin-svc" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Create the name of the dns service to use
*/}}
{{- define "pihole.dnsServiceName" -}}
{{- printf "%s-%s-dns-svc" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Set DNS service externalTrafficPolicy
*/}}
{{- define "pihole.dnsExternalTrafficPolicy" -}}
{{- default "local" .Values.service.dns.externalTrafficPolicy }}
{{- end }}

{{/*
Set the name of the admin ingress domain certificate
*/}}
{{- define "pihole.domainCertName" -}}
{{- printf "cert.%s.%s.ingress" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Set the name of the admin ingress domain certificate secret
*/}}
{{- define "pihole.domainCertSecretName" -}}
{{- printf "secret.%s.%s.ingress.tls" .Chart.Name .Release.Name }}
{{- end }}

{{/* 
Set the reflection namespace for certificates and secrets 
*/}}
{{- define "pihole.reflectNamespaces" -}}
{{- printf "%s,cert-manager" .Release.Namespace -}}
{{- end }}

{{/*
Set the ingress name
*/}}
{{- define "pihole.ingressName" -}}
{{- printf "ingress.%s.%s.dash" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Set the ingress route name
*/}}
{{- define "pihole.ingressRouteName" -}}
{{- printf "ingressroute.%s.%s.dash" .Chart.Name .Release.Name }}
{{- end }}


{{/*
Set ingress route 
*/}}
{{- define "pihole.ingressRoute" -}}
{{- printf "Host(`%s`) && (PathPrefix(`/admin`) || PathPrefix(`/api`))" .Values.ingressRoute.domain.name }}
{{- end }}

{{/*
Set pvc name for etc file system
*/}}
{{- define "pihole.piholePVCName" -}}
{{- printf "pvc.%s.%s.etc" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Set pvc name for dnsmasq file system
*/}}
{{- define "pihole.dnsmasqPVCName" -}}
{{- printf "pvc.%s.%s.dnsmasq" .Chart.Name .Release.Name }}
{{- end }}
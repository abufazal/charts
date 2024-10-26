{{/*
function to validate values
*/}}
{{- define "pihole.validateValue" -}}
  {{- range . -}}
    {{- $value := index . 0 -}}
    {{- $errMessage := index . 1 -}}
    {{- if not $value -}}
      {{- fail $errMessage -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
set the pihole image registry
*/}}
{{- define "pihole.registry" }}
    {{- if .Values.pihole.image.registry -}}
        {{- .Values.pihole.image.registry -}}
    {{- else -}}
        {{- default "docker.io" .Values.global.image.imageRegistry -}}
    {{- end -}}
{{- end -}}

{{/*
set the pihole image
*/}}
{{- define "pihole.image" -}}
{{- $registry := include "pihole.registry" . -}}
{{- $repository := default "pihole/pihole" .Values.pihole.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.pihole.image.tag -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}

{{/*
set the pihole image pull secrets
*/}}
{{- define "pihole.imagePullSecrets" -}}
    {{- if .Values.pihole.image.pullSecrets -}}
        {{- .Values.pihole.image.pullSecrets -}}
    {{- else -}}
        {{- .Values.global.image.imagePullSecrets -}}
    {{- end -}}
{{- end -}}

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

{{/* enable service account */}}
{{- define "pihole.createServiceAccount" -}}
{{- default "true" .Values.pihole.serviceAccount.create }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pihole.serviceAccountName" -}}
{{- if (eq (include "pihole.createServiceAccount" . | trim) "true") }}
{{- default (include "pihole.fullname" .) .Values.pihole.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.pihole.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the admin service to use
*/}}
{{- define "pihole.adminServiceName" -}}
{{- printf "%s-%s-admin-service" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Create the name of the dns service to use
*/}}
{{- define "pihole.dnsServiceName" -}}
{{- printf "%s-%s-dns-service" .Chart.Name .Release.Name }}
{{- end }}

{{/*
Set DNS service externalTrafficPolicy
*/}}
{{- define "pihole.dnsExternalTrafficPolicy" -}}
{{- default "Local" .Values.pihole.services.dns.externalTrafficPolicy }}
{{- end }}

{{/* set the default for ingress */}}
{{- define "pihole.enableIngress" -}}
{{- default "false" .Values.pihole.ingress.enabled -}}
{{- end -}}

{{/* set the default for ingressRoute */}}
{{- define "pihole.enableIngressRoute" -}}
{{- default "false" .Values.pihole.ingressRoute.enabled -}}
{{- end -}}

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
  {{- if and (eq (include "pihole.enableIngressRoute" . | trim) "true") (not (empty .Values.pihole.ingressRoute.tls.secret)) -}}
    {{- .Values.pihole.ingressRoute.tls.secret -}}
  {{- else if and (eq (include "pihole.enableIngress" . | trim) "true") (not (empty .Values.pihole.ingress.tls.secret)) -}}
    {{- .Values.pihole.ingress.tls.secret -}}
  {{- else -}}
    {{- printf "secret.%s.%s.ingress.tls" .Chart.Name .Release.Name }}
  {{- end -}}
{{- end }}

{{/*
Set the tls for ingress
*/}}
{{- define "pihole.enableTls" }}
  {{- if and (eq (include "pihole.enableIngressRoute" . | trim) "true") -}}
    {{- default false .Values.pihole.ingressRoute.tls.secret -}}
  {{- else}}
    {{- default false .Values.pihole.ingress.tls.secret -}}
  {{- end -}}
{{- end }}

{{/* 
Set the reflection namespace for certificates and secrets 
*/}}
{{- define "pihole.reflectNamespaces" -}}
{{- printf "%s,cert-manager" .Release.Namespace }}
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
{{- define "pihole.ingressHost" -}}
  {{- if (eq (include "pihole.enableIngressRoute" . | trim) "true") }}
    {{- printf "Host(`%s`) && (PathPrefix(`/admin`) || PathPrefix(`/api`))" (required "Error - Ingress route domain host is not provided" .Values.pihole.ingressRoute.host) }}
  {{- else }}
    {{- required "Error - Ingress domain host is not provided" .Values.pihole.ingress.host }}
  {{- end }}
{{- end }}

{{/*
Set pvc name for primary file system
*/}}
{{- define "pihole.dataPVCName" -}}
    {{- if .Values.pihole.persistence.data.existingClaimName -}}
        {{- .Values.pihole.persistence.data.existingClaimName -}}
    {{- else -}}
        {{- printf "pvc.%s.%s.data" .Chart.Name .Release.Name }}
    {{- end -}}
{{- end }}

{{/*
Set pvc name for dnsmasq file system
*/}}
{{- define "pihole.dnsmasqPVCName" -}}
    {{- if .Values.pihole.persistence.dnsmasq.existingClaimName }}
        {{- .Values.pihole.persistence.dnsmasq.existingClaimName -}}
    {{- else -}}
        {{- printf "pvc.%s.%s.dnsmasq" .Chart.Name .Release.Name }}
    {{- end -}}
{{- end }}

{{/* Set the admin secret name */}}
{{- define "pihole.adminSecret" -}}
  {{- if empty .Values.pihole.dashboard.admin.passwordSecret.name }}
    {{- printf "secret.%s.%s.web.admin" .Chart.Name .Release.Name }}
  {{- else }}
    {{- .Values.pihole.dashboard.admin.passwordSecret.name }}
  {{- end }}  
{{- end }}

{{/* Set the admin secret name */}}
{{- define "pihole.adminSecretNamespace" -}}
  {{- if empty .Values.pihole.dashboard.admin.passwordSecret.namespace }}
    {{- .Release.Namespace }}
  {{- else }}
    {{- .Values.pihole.dashboard.admin.passwordSecret.namespace }}
  {{- end }}  
{{- end }}
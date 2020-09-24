{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gee.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gee.fullname" -}}
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
{{- define "gee.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gee.common.labels" -}}
helm.sh/chart: {{ include "gee.chart" . }}
{{ include "gee.common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
common Selector labels
*/}}
{{- define "gee.common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gee.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
fusion labels
*/}}
{{- define "gee.fusion.labels" -}}
{{ include "gee.fusion.selectorLabels" . }}
{{ include "gee.common.labels" . }}
{{- end }}

{{/*
fusion selector labels
*/}}
{{- define "gee.fusion.selectorLabels" -}}
{{ include "gee.common.selectorLabels" . }}
componnet: "fusion"
containerTag: {{ .Values.fusion.tag }}
{{- end }}

{{/*
server labels
*/}}
{{- define "gee.server.labels" -}}
{{ include "gee.server.selectorLabels" . }}
{{ include "gee.common.labels" . }}
{{- end }}

{{/*
server selector labels
*/}}
{{- define "gee.server.selectorLabels" -}}
{{ include "gee.common.selectorLabels" . }}
componnet: "server"
containerTag: {{ .Values.server.tag }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gee.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gee.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

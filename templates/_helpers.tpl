{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gitlab-runner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gitlab-runner.fullname" -}}
{{-   if .Values.fullnameOverride -}}
{{-     .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{-   else -}}
{{-     $name := default .Chart.Name .Values.nameOverride -}}
{{-     if hasPrefix $name .Release.Name -}}
{{-       .Release.Name | trunc 63 | trimSuffix "-" -}}
{{-     else -}}
{{-       printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gitlab-runner.chart" -}}
{{-   printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the name of the secret containing the tokens
*/}}
{{- define "gitlab-runner.secret" -}}
{{- default (include "gitlab-runner.fullname" .) .Values.runners.secret | quote -}}
{{- end -}}

{{/*
Define the name of the s3 cache secret
*/}}
{{- define "gitlab-runner.cache.secret" -}}
{{- if hasKey .Values.runners.cache "secretName" -}}
{{- .Values.runners.cache.secretName | quote -}}
{{- end -}}
{{- end -}}

{{/*
Template for outputing the gitlabUrl
*/}}
{{- define "gitlab-runner.gitlabUrl" -}}
{{- .Values.gitlabUrl | quote -}}
{{- end -}}

{{/*
Define the image, using .Chart.AppVersion and GitLab Runner image as a default value
*/}}
{{- define "gitlab-runner.image" }}
{{- $appVersion := ternary "bleeding" (print "v" .Chart.AppVersion) (eq .Chart.AppVersion "bleeding") -}}
{{- $appVersionImageTag := printf "alpine-%s" $appVersion -}}
{{- $imageRegistry := ternary "" (print .Values.image.registry "/") (eq .Values.image.registry "") -}}
{{- $imageTag := default $appVersionImageTag .Values.image.tag -}}
{{- printf "%s%s:%s" $imageRegistry .Values.image.image $imageTag }}
{{- end -}}

{{/*
Define the server session timeout, using 1800 as a default value
*/}}
{{- define "gitlab-runner.server-session-timeout" }}
{{-   default 1800 .Values.sessionServer.timeout }}
{{- end -}}

{{/*
Define the server session internal port, using 9000 as a default value
*/}}
{{- define "gitlab-runner.server-session-external-port" }}
{{-   default 9000 .Values.sessionServer.externalPort }}
{{- end -}}

{{/*
Define the server session external port, using 8093 as a default value
*/}}
{{- define "gitlab-runner.server-session-internal-port" }}
{{-   default 8093 .Values.sessionServer.internalPort }}
{{- end -}}

{{/*
Unregister runners on pod stop
*/}}
{{- define "gitlab-runner.unregisterRunners" -}}
{{- if or (and (hasKey .Values "unregisterRunners") .Values.unregisterRunners) (and (not (hasKey .Values "unregisterRunners")) .Values.runnerRegistrationToken) -}}
lifecycle:
  preStop:
    exec:
      command: ["/entrypoint", "unregister", "--all-runners"]
{{- end -}}
{{- end -}}

{{/*
Define if the registration token provided (if any)
is an authentication token or not
*/}}
{{- define "gitlab-runner.isAuthToken" -}}
{{- $isAuthToken := false -}}
{{- $hasRegistrationToken := hasKey .Values "runnerRegistrationToken" -}}
{{- if $hasRegistrationToken -}}
{{-   $isAuthToken = or (empty .Values.runnerRegistrationToken) (hasPrefix "glrt-" .Values.runnerRegistrationToken) -}}
{{- else -}}
{{-   $isAuthToken = not (empty .Values.runnerToken) -}}
{{- end -}}
{{- $isAuthToken -}}
{{- end -}}

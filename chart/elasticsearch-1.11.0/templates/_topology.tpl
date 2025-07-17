{{/*设置组件label中的key*/}}
{{- define "middleware.key" -}}
affinitytype
{{- end }}

{{/*设置组件type*/}}
{{- define "middleware.type.master" -}}
{{ include "elasticsearch.fullname" . }}master
{{- end }}

{{- define "middleware.type.data" -}}
{{ include "elasticsearch.fullname" . }}data
{{- end }}

{{- define "middleware.type.cold" -}}
{{ include "elasticsearch.fullname" . }}cold
{{- end }}

{{- define "middleware.type.client" -}}
{{ include "elasticsearch.fullname" . }}client
{{- end }}

{{- define "middlware.tolerations" }}
{{- with .Values.tolerations }}
tolerations:
{{- toYaml .| nindent 0  }}
{{- end }}
{{- end }}

{{- define "middlware.whenUnsatisfiable" }}
{{- if eq .Values.podAntiAffinity "hard"}}
  whenUnsatisfiable: DoNotSchedule
{{- else if eq .Values.podAntiAffinity "soft"}}
  whenUnsatisfiable: ScheduleAnyway
{{- end }}
{{- end }}

{{/*es master拓扑设置*/}}
{{- define "middlware.topologySpreadConstraints.master" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) true }}
topologySpreadConstraints:
{{- if ne .Values.podAntiAffinityTopologKey "kubernetes.io/hostname"}}
- maxSkew: 1
  topologyKey: {{ .Values.podAntiAffinityTopologKey | default "" }}
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.master" . }}
{{- end }}
- maxSkew: 1
  topologyKey: "kubernetes.io/hostname"
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.master" . }}
{{- if eq .Values.activeActive.enable false }}
{{- if .Values.nodeAffinity }}
affinity:
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 8 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*es data拓扑设置*/}}
{{- define "middlware.topologySpreadConstraints.data" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) true }}
topologySpreadConstraints:
{{- if ne .Values.podAntiAffinityTopologKey "kubernetes.io/hostname"}}
- maxSkew: 1
  topologyKey: {{ .Values.podAntiAffinityTopologKey | default "" }}
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.data" . }}
{{- end }}
- maxSkew: 1
  topologyKey: "kubernetes.io/hostname"
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.data" . }}
{{- if .Values.nodeAffinity }}
affinity:
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*es cold拓扑设置*/}}
{{- define "middlware.topologySpreadConstraints.cold" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) true }}
topologySpreadConstraints:
{{- if ne .Values.podAntiAffinityTopologKey "kubernetes.io/hostname"}}
- maxSkew: 1
  topologyKey: {{ .Values.podAntiAffinityTopologKey | default "" }}
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.cold" . }}
{{- end }}
- maxSkew: 1
  topologyKey: "kubernetes.io/hostname"
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.cold" . }}
{{- if .Values.nodeAffinity }}
affinity:
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*es client拓扑设置*/}}
{{- define "middlware.topologySpreadConstraints.client" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) true }}
topologySpreadConstraints:
{{- if ne .Values.podAntiAffinityTopologKey "kubernetes.io/hostname"}}
- maxSkew: 1
  topologyKey: {{ .Values.podAntiAffinityTopologKey | default "" }}
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.client" . }}
{{- end }}
- maxSkew: 1
  topologyKey: "kubernetes.io/hostname"
  {{- include "middlware.whenUnsatisfiable" . }}
  labelSelector:
    matchLabels:
      {{ include "middleware.key" . }}: {{ include "middleware.type.client" . }}
{{- if .Values.nodeAffinity }}
affinity:
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}


{{/*es master亲和性设置*/}}
{{- define "middlware.affinity.master" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) false }}
affinity:
  {{- if eq .Values.podAntiAffinity "hard"}}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ .Values.podAntiAffinityTopologKey }}
      labelSelector:
        matchExpressions:
        - key: {{ include "middleware.key" . }}
          operator: In
          values:
          - {{ include "middleware.type.master" . }}
  {{- else if eq .Values.podAntiAffinity "soft"}}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: {{ .Values.podAntiAffinityTopologKey }}
        labelSelector:
          matchExpressions:
          - key: {{ include "middleware.key" . }}
            operator: In
            values:
            - {{ include "middleware.type.master" . }}
  {{- end }}
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}

{{/*es data亲和性设置*/}}
{{- define "middlware.affinity.data" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) false }}
affinity:
  {{- if eq .Values.podAntiAffinity "hard"}}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ .Values.podAntiAffinityTopologKey }}
      labelSelector:
        matchExpressions:
        - key: {{ include "middleware.key" . }}
          operator: In
          values:
          - {{ include "middleware.type.data" . }}
  {{- else if eq .Values.podAntiAffinity "soft"}}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: {{ .Values.podAntiAffinityTopologKey }}
        labelSelector:
          matchExpressions:
          - key: {{ include "middleware.key" . }}
            operator: In
            values:
            - {{ include "middleware.type.data" . }}
  {{- end }}
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- end }}
{{- end }}

{{/*es cold节点亲和性设置*/}}
{{- define "middlware.affinity.cold" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) false }}
affinity:
  {{- if eq .Values.podAntiAffinity "hard"}}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ .Values.podAntiAffinityTopologKey }}
      labelSelector:
        matchExpressions:
        - key: {{ include "middleware.key" . }}
          operator: In
          values:
          - {{ include "middleware.type.cold" . }}
  {{- else if eq .Values.podAntiAffinity "soft"}}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: {{ .Values.podAntiAffinityTopologKey }}
        labelSelector:
          matchExpressions:
          - key: {{ include "middleware.key" . }}
            operator: In
            values:
            - {{ include "middleware.type.cold" . }}
  {{- end }}
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- end }}
{{- end }}

{{/*es client节点亲和性设置*/}}
{{- define "middlware.affinity.client" }}
{{- if eq (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) false }}
affinity:
  {{- if eq .Values.podAntiAffinity "hard"}}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ .Values.podAntiAffinityTopologKey }}
      labelSelector:
        matchExpressions:
        - key: {{ include "middleware.key" . }}
          operator: In
          values:
          - {{ include "middleware.type.client" . }}
  {{- else if eq .Values.podAntiAffinity "soft"}}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: {{ .Values.podAntiAffinityTopologKey }}
        labelSelector:
          matchExpressions:
          - key: {{ include "middleware.key" . }}
            operator: In
            values:
            - {{ include "middleware.type.client" . }}
  {{- end }}
  {{- with .Values.nodeAffinity }}
  nodeAffinity:
  {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- end }}
{{- end }}


{{/*es master组件拓扑分布*/}}
{{- define "middlware.topologyDistribution.master" }}
{{- include "middlware.tolerations" . -}}
{{- include "middlware.topologySpreadConstraints.master" . -}}
{{- include "middlware.affinity.master" . -}}
{{- end }}

{{/*es data组件拓扑分布*/}}
{{- define "middlware.topologyDistribution.data" }}
{{- include "middlware.tolerations" . -}}
{{- include "middlware.topologySpreadConstraints.data" . -}}
{{- include "middlware.affinity.data" . -}}
{{- end }}


{{/*es cold组件拓扑分布*/}}
{{- define "middlware.topologyDistribution.cold" }}
{{- include "middlware.tolerations" . -}}
{{- include "middlware.topologySpreadConstraints.cold" . -}}
{{- include "middlware.affinity.cold" . -}}
{{- end }}

{{/*es client组件拓扑分布*/}}
{{- define "middlware.topologyDistribution.client" }}
{{- include "middlware.tolerations" . -}}
{{- include "middlware.topologySpreadConstraints.client" . -}}
{{- include "middlware.affinity.client" . -}}
{{- end }}

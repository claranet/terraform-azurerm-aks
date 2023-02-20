apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: {{ .Values.IdentityName }}
spec:
  type: 0
  resourceID: {{ .Values.IdentityID }}
  clientID: {{ .Values.IdentityClientID }}

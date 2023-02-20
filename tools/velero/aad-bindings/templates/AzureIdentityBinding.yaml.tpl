apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: {{ .Values.IdentityName }}-binding
spec:
  azureIdentity: {{ .Values.IdentityName }}
  selector: {{ .Values.IdentityName }}

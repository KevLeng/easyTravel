#!/bin/bash
# Required for environments like k3s, not required to AKS, GKE etc
# expects to be running on ubuntu EC2 instance


PUBLIC_IP=$(curl -s ifconfig.me)
PUBLIC_IP_AS_DOM=$(echo $PUBLIC_IP | sed 's~\.~-~g')
NIP_DOMAIN="${PUBLIC_IP_AS_DOM}.nip.io"

export DOMAIN=${DOMAIN:-$NIP_DOMAIN}
export INGRESSCLASS=${INGRESSCLASS:-"nginx"}
echo "Deploying $INGRESSCLASS ingress for easytravel"
echo "Using Domain: $DOMAIN"

createINGFile(){
  echo "Create Environment=$ENV, SERVICE=$SERVICE, PORT=$PORT ingress."

cat > ./easytravel-ingress.yaml <<- EOM
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: $INGRESSCLASS
  name: $SERVICE
  namespace: $ENV
spec:
  rules:
  - host: $ENV.$FRONTEND.$DOMAIN
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $SERVICE
            port:
              number: $PORT
EOM

  kubectl apply -f easytravel-ingress.yaml
}

#front-end
export ENV=easytravel
export SERVICE=easytravel-angularfrontend
export PORT=80
export FRONTEND=angular
createINGFile

export ENV=easytravel
export SERVICE=easytravel-www
export PORT=80
export FRONTEND=classic
createINGFile



rm easytravel-ingress.yaml

echo "easytravel angular frontend: http://easytravel.angular.$DOMAIN"
echo "easytravel classic frontend: http://easytravel.classic.$DOMAIN"

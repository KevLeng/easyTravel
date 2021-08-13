#!/bin/bash
# This script will push the  Monitoring as Code config

# Dynatrace Variables
export DT_TENANT=${DT_TENANT:-none}
export DT_API_TOKEN=${DT_API_TOKEN:-none}
export DT_DEFAULT_GEOS=${DT_DEFAULT_GEOS:-true}
export DT_DASHBOARD_OWNER=${DT_DASHBOARD_OWNER:-"kevin.leng@dynatrace.com"}

# AZURE Variables
export SKIP_AZURE=${SKIP_AZURE:-true}
export AZURE_CLIENT_ID=${AZURE_CLIENT_ID:-none}
export AZURE_TENANT_ID=${AZURE_TENANT_ID:-none}
export AZURE_KEY=${AZURE_KEY:-none}

# Prometheus Variables
# not used currently
export SKIP_PROMETHEUS=${SKIP_PROMETHEUS:-false}



if [[ "$DT_TENANT" == "none" ]]; then
    echo "You have to set DT_TENANT to your Tenant URL, e.g: abc12345.dynatrace.live.com or yourdynatracemanaged.com/e/abcde-123123-asdfa-1231231"
    exit 1
fi
if [[ "$DT_API_TOKEN" == "none" ]]; then
    echo "You have to set DT_API_TOKEN to a Token that has 'read configuration', 'write configuration', 'Create and read synthetic monitors, locations, and nodes', 'Access problem and event feed, metrics, and topology'"
    exit 1
fi
if [[ "$SKIP_AZURE" == "false" ]]; then
    if [[ "$AZURE_CLIENT_ID" == "none" ]]; then
        echo "You have to set AZURE_CLIENT_ID to the Application (client) ID for the Azure service principal. See help for more details: https://www.dynatrace.com/support/help/technology-support/cloud-platforms/microsoft-azure-services/set-up-integration-with-azure-monitor/"
        exit 1
    fi
    if [[ "$AZURE_TENANT_ID" == "none" ]]; then
        echo "You have to set AZURE_TENANT_ID to the Directory (tenant) ID for the Azure service principal. See help for more details: https://www.dynatrace.com/support/help/technology-support/cloud-platforms/microsoft-azure-services/set-up-integration-with-azure-monitor/"
        exit 1
    fi
    if [[ "$AZURE_KEY" == "none" ]]; then
        echo "You have to set AZURE_KEY to the client secret value for the Azure service principal. See help for more details: https://www.dynatrace.com/support/help/technology-support/cloud-platforms/microsoft-azure-services/set-up-integration-with-azure-monitor/"
        exit 1
    fi
fi

export synth_geo_location_id_1=${synth_geo_location_id_1:-"GEOLOCATION-8888B6EC387C46E6"}
export synth_geo_location_id_2=${synth_geo_location_id_2:-"GEOLOCATION-C196364332B5D8E2"}

if [[ "$DT_TENANT" == *"sprint"* ]]; then
    if [[ "$DT_DEFAULT_GEOS" == "true" ]]; then
        echo "Sprint environment, using sprint geo location ids"
        export synth_geo_location_id_1="GEOLOCATION-0DF9A0E1095A5A62" #Portland
        export synth_geo_location_id_2="GEOLOCATION-E01B833216FC3598" #Hong Kong
    fi
fi

echo "Gathering environment details..."
echo ""
export classic_frontend_ip=$(kubectl describe svc easytravel-www -n easytravel | grep "LoadBalancer Ingress:" | sed 's/LoadBalancer Ingress:[ \t]*//')

export angular_frontend_ip=$(kubectl describe svc easytravel-angularfrontend -n easytravel | grep "LoadBalancer Ingress:" | sed 's/LoadBalancer Ingress:[ \t]*//')

export classic_frontend_port="80"
export angular_frontend_port="80"

if [[ $classic_frontend_ip == "" ]]; then
  echo "dev_frontend_ip is not found trying host from ingress"
  export classic_frontend_ip=$(kubectl get ing front-end -n dev -o jsonpath='{.spec.rules[0].host}')
fi


if [[ $angular_frontend_ip == "" ]]; then
  echo "production_frontend_ip is not found trying host from ingress"
  export angular_frontend_ip=$(kubectl get ing front-end -n production -o jsonpath='{.spec.rules[0].host}')
fi



echo "**************************************************"
echo "Using the following:"
echo "classic front-end: $classic_frontend_ip"
echo "classic front-end port: $classic_frontend_port"
echo "angular front-end: $angular_frontend_ip"
echo "angular front-end port: $angular_frontend_port"
echo "**************************************************"
echo ""
echo "Calling Monaco with easytravel config..."
./monaco_cli -e=monaco/easytravel-environment.yaml -p=easytravel monaco

echo "Finished."
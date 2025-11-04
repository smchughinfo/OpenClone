#!/bin/bash

# Azure GPU Quota Request Script - Try All Regions
# Requests NCASv3_T4 GPU quota across all Azure regions

SUBSCRIPTION_ID="bfb809f0-3e70-44c3-8b66-0ea2184c2114"
RESOURCE_NAME="standardNCASv3_T4Family"
LIMIT=4  # 4 vCPUs = 1 GPU node

# Regions likely to succeed (prioritized by low demand)
REGIONS=(
    "southafricanorth"      # Very low demand
    "uaenorth"              # Newer region
    "australiasoutheast"    # Far timezone
    "japanwest"             # Less popular than Japan East
    "koreacentral"          # Newer region
    "switzerlandnorth"      # Premium, less demand
    "norwayeast"            # Newer region
    "uksouth"               # Less popular
    "canadacentral"         # Close but less US demand
    "westeurope"            # Major hub but worth trying
    "northeurope"           # Major hub
    "southeastasia"         # Major APAC
    "eastasia"              # Hong Kong
    "francecentral"         # EU alternative
    "germanywestcentral"    # EU alternative
    "swedencentral"         # Newer region
    "polandcentral"         # Newer region
    "italynorth"            # Newer region
    "spaincentral"          # Newer region
    "israelcentral"         # Newer region
    "qatarcentral"          # Newer region
    "westus3"               # Newer US region
    "eastus"                # Already tried but include for completeness
    "westus"                # Already tried
)

echo "================================================="
echo "Azure GPU Quota Request - Mass Submission"
echo "================================================="
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource: $RESOURCE_NAME"
echo "Requested Limit: $LIMIT vCPUs"
echo "Regions to try: ${#REGIONS[@]}"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0
SUCCESSFUL_REGIONS=()

for REGION in "${REGIONS[@]}"; do
    echo "----------------------------------------"
    echo "Trying region: $REGION"

    SCOPE="/subscriptions/${SUBSCRIPTION_ID}/providers/Microsoft.Compute/locations/${REGION}"

    # Submit quota request
    RESULT=$(az quota create \
        --resource-name "$RESOURCE_NAME" \
        --scope "$SCOPE" \
        --limit-object value=$LIMIT \
        --resource-type dedicated \
        --output json 2>&1)

    if echo "$RESULT" | grep -q "error\|Error\|ERROR"; then
        echo "❌ FAILED: $REGION"
        echo "   Error: $(echo $RESULT | head -c 200)"
        ((FAIL_COUNT++))
    else
        echo "✅ SUCCESS: $REGION"
        echo "   Request submitted successfully!"
        SUCCESSFUL_REGIONS+=("$REGION")
        ((SUCCESS_COUNT++))
    fi

    # Small delay to avoid rate limiting
    sleep 2
done

echo ""
echo "================================================="
echo "SUMMARY"
echo "================================================="
echo "Total regions attempted: ${#REGIONS[@]}"
echo "Successful submissions: $SUCCESS_COUNT"
echo "Failed submissions: $FAIL_COUNT"
echo ""

if [ ${#SUCCESSFUL_REGIONS[@]} -gt 0 ]; then
    echo "✅ SUCCESSFUL REGIONS:"
    for REGION in "${SUCCESSFUL_REGIONS[@]}"; do
        echo "   - $REGION"
    done
    echo ""
    echo "Check Azure Portal → Quotas to monitor approval status"
else
    echo "❌ No successful submissions. Consider:"
    echo "   1. Creating a support ticket"
    echo "   2. Adding spending history to your account"
    echo "   3. Trying alternative GPU types (NC, NCv3, etc.)"
fi

echo "================================================="

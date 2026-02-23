#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# ClaudeSetup — Client Project Scaffolder
# Usage: ./scaffold.sh <client-name> <industry> <tier>
#
# Industries: ecommerce, real-estate, legal, healthcare, finance, saas, agency
# Tiers: starter, professional, enterprise
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
CLIENTS_DIR="$SCRIPT_DIR/clients"
TRACKER="$SCRIPT_DIR/clients.json"

VALID_INDUSTRIES="ecommerce real-estate legal healthcare finance saas agency"
VALID_TIERS="starter professional enterprise"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
  echo -e "${CYAN}ClaudeSetup — Client Project Scaffolder${NC}"
  echo ""
  echo "Usage: ./scaffold.sh <client-name> <industry> <tier>"
  echo ""
  echo "Industries: $VALID_INDUSTRIES"
  echo "Tiers:      $VALID_TIERS"
  echo ""
  echo "Example: ./scaffold.sh acme-corp ecommerce professional"
  exit 1
}

# Validate args
[[ $# -ne 3 ]] && usage

CLIENT_NAME="$1"
INDUSTRY="$2"
TIER="$3"

# Validate industry
if [[ ! " $VALID_INDUSTRIES " =~ " $INDUSTRY " ]]; then
  echo -e "${RED}Error: Invalid industry '$INDUSTRY'${NC}"
  echo "Valid industries: $VALID_INDUSTRIES"
  exit 1
fi

# Validate tier
if [[ ! " $VALID_TIERS " =~ " $TIER " ]]; then
  echo -e "${RED}Error: Invalid tier '$TIER'${NC}"
  echo "Valid tiers: $VALID_TIERS"
  exit 1
fi

CLIENT_DIR="$CLIENTS_DIR/$CLIENT_NAME"

# Check if client already exists
if [[ -d "$CLIENT_DIR" ]]; then
  echo -e "${RED}Error: Client '$CLIENT_NAME' already exists at $CLIENT_DIR${NC}"
  exit 1
fi

echo -e "${CYAN}Creating project for: ${GREEN}$CLIENT_NAME${NC}"
echo -e "Industry: ${YELLOW}$INDUSTRY${NC}"
echo -e "Tier:     ${YELLOW}$TIER${NC}"
echo ""

# Create client directory
mkdir -p "$CLIENT_DIR/knowledge-base"

# Copy base template files
echo -e "  ${GREEN}✓${NC} Copying base templates..."
cp "$TEMPLATES_DIR/_base/CLAUDE.md" "$CLIENT_DIR/CLAUDE.md"
cp "$TEMPLATES_DIR/_base/.env.example" "$CLIENT_DIR/.env.example"
cp "$TEMPLATES_DIR/_base/mcp-config.json" "$CLIENT_DIR/mcp-config.json"
cp "$TEMPLATES_DIR/_base/README-client.md" "$CLIENT_DIR/README.md"

# Overlay industry-specific templates
echo -e "  ${GREEN}✓${NC} Applying $INDUSTRY template..."
cp "$TEMPLATES_DIR/$INDUSTRY/CLAUDE.md" "$CLIENT_DIR/CLAUDE.md"
cp "$TEMPLATES_DIR/$INDUSTRY/mcp-config.json" "$CLIENT_DIR/mcp-config.json"
cp "$TEMPLATES_DIR/$INDUSTRY/tools.md" "$CLIENT_DIR/tools.md"

# Replace placeholders in CLAUDE.md
TODAY=$(date +%Y-%m-%d)
sed -i "s/{{CLIENT_NAME}}/$CLIENT_NAME/g" "$CLIENT_DIR/CLAUDE.md"
sed -i "s/{{INDUSTRY}}/$INDUSTRY/g" "$CLIENT_DIR/CLAUDE.md"
sed -i "s/{{DATE}}/$TODAY/g" "$CLIENT_DIR/CLAUDE.md"
sed -i "s/{{TIER}}/$TIER/g" "$CLIENT_DIR/CLAUDE.md"

# Replace placeholders in README
sed -i "s/{{CLIENT_NAME}}/$CLIENT_NAME/g" "$CLIENT_DIR/README.md"
sed -i "s/{{INDUSTRY}}/$INDUSTRY/g" "$CLIENT_DIR/README.md"
sed -i "s/{{DATE}}/$TODAY/g" "$CLIENT_DIR/README.md"

# Copy the appropriate delivery checklist
echo -e "  ${GREEN}✓${NC} Adding $TIER delivery checklist..."
cp "$SCRIPT_DIR/checklists/$TIER-checklist.md" "$CLIENT_DIR/delivery-checklist.md"

# Create project-info.json
echo -e "  ${GREEN}✓${NC} Creating project metadata..."
cat > "$CLIENT_DIR/project-info.json" << EOF
{
  "client": "$CLIENT_NAME",
  "industry": "$INDUSTRY",
  "tier": "$TIER",
  "created": "$TODAY",
  "status": "in-progress",
  "delivered": null,
  "agents": [],
  "integrations": [],
  "notes": ""
}
EOF

# Update clients.json tracker
echo -e "  ${GREEN}✓${NC} Updating client tracker..."

# Determine revenue based on tier
case "$TIER" in
  starter)      REVENUE=750 ;;
  professional) REVENUE=2500 ;;
  enterprise)   REVENUE=7500 ;;
esac

# Add new entry to clients.json
if [[ ! -f "$TRACKER" ]] || [[ ! -s "$TRACKER" ]]; then
  echo "[]" > "$TRACKER"
fi

# Use node to update the tracker (works on all platforms)
TRACKER_ABS=$(cd "$(dirname "$TRACKER")" && pwd)/$(basename "$TRACKER")
node -e "
const fs = require('fs');
const p = process.argv[1];
const clients = JSON.parse(fs.readFileSync(p, 'utf8'));
clients.push({
  name: process.argv[2],
  industry: process.argv[3],
  tier: process.argv[4],
  status: 'in-progress',
  created: process.argv[5],
  delivered: null,
  revenue: Number(process.argv[6]),
  notes: ''
});
fs.writeFileSync(p, JSON.stringify(clients, null, 2) + '\n');
" "$TRACKER_ABS" "$CLIENT_NAME" "$INDUSTRY" "$TIER" "$TODAY" "$REVENUE" 2>/dev/null \
  || echo -e "  ${YELLOW}⚠ Could not update tracker automatically. Add manually.${NC}"

echo ""
echo -e "${GREEN}✅ Client project created at: $CLIENT_DIR${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Edit ${YELLOW}CLAUDE.md${NC} — fill in {{BUSINESS_DESCRIPTION}} and customize the system prompt"
echo -e "  2. Edit ${YELLOW}mcp-config.json${NC} — add real API keys and endpoints"
echo -e "  3. Drop client documents into ${YELLOW}knowledge-base/${NC}"
echo -e "  4. Copy ${YELLOW}.env.example${NC} to ${YELLOW}.env${NC} and fill in secrets"
echo -e "  5. Test the agent against sample queries"
echo -e "  6. Follow ${YELLOW}delivery-checklist.md${NC} to complete the project"
echo ""

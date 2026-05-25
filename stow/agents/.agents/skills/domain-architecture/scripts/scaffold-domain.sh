#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new @eagleeye/<domain> package with Ports & Adapters structure
# Usage: bash .agents/skills/domain-architecture/scripts/scaffold-domain.sh <domain-name> [use-case-name]
# Example: bash .agents/skills/domain-architecture/scripts/scaffold-domain.sh crm sync-contacts

DOMAIN="${1:?Usage: scaffold-domain.sh <domain-name> [use-case-name]}"
USE_CASE="${2:-}"

if [[ ! "$DOMAIN" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: domain must be kebab-case (letters, numbers, hyphens)"
  exit 1
fi

if [[ -n "$USE_CASE" && ! "$USE_CASE" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: use-case must be kebab-case (letters, numbers, hyphens)"
  exit 1
fi

PACKAGE_DIR="packages/${DOMAIN}"

if [[ -d "$PACKAGE_DIR" ]]; then
  echo "ERROR: ${PACKAGE_DIR} already exists"
  exit 1
fi

echo "Scaffolding @eagleeye/${DOMAIN}..."

# Create directory structure
mkdir -p "${PACKAGE_DIR}/src/use-cases"
mkdir -p "${PACKAGE_DIR}/__tests__"

# package.json
cat > "${PACKAGE_DIR}/package.json" << EOF
{
  "name": "@eagleeye/${DOMAIN}",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./src/index.ts"
    },
    "./port": {
      "types": "./src/${DOMAIN}.port.ts",
      "default": "./src/${DOMAIN}.port.ts"
    },
    "./testing": {
      "types": "./src/${DOMAIN}.memory.adapter.ts",
      "default": "./src/${DOMAIN}.memory.adapter.ts"
    }
  },
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "vitest": "^3.0.0",
    "typescript": "^5.7.0"
  }
}
EOF

# tsconfig.json
cat > "${PACKAGE_DIR}/tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "dist",
    "rootDir": "src",
    "composite": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["__tests__", "dist", "node_modules"]
}
EOF

# vitest.config.ts
cat > "${PACKAGE_DIR}/vitest.config.ts" << 'EOF'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['__tests__/**/*.test.ts'],
  },
})
EOF

# Case conversions
DOMAIN_PASCAL=$(python3 -c "import sys; print(''.join(w.capitalize() for w in sys.argv[1].split('-')))" "${DOMAIN}")
DOMAIN_CAMEL=$(python3 -c "import sys; parts=sys.argv[1].split('-'); print(parts[0]+''.join(w.capitalize() for w in parts[1:]))" "${DOMAIN}")

# Port file
cat > "${PACKAGE_DIR}/src/${DOMAIN}.port.ts" << EOF
import { z } from 'zod'

// --- Schemas ---

// TODO: Define domain entity schemas
// export const exampleSchema = z.object({
//   id: z.string(),
// })
// export type Example = z.infer<typeof exampleSchema>

// --- Port ---

export interface ${DOMAIN_PASCAL}Port {
  // TODO: Define port methods
  // example(id: string): Promise<Example | null>
}
EOF

# Memory adapter
cat > "${PACKAGE_DIR}/src/${DOMAIN}.memory.adapter.ts" << EOF
import type { ${DOMAIN_PASCAL}Port } from './${DOMAIN}.port'

export class Memory${DOMAIN_PASCAL}Adapter implements ${DOMAIN_PASCAL}Port {
  // TODO: Implement in-memory storage

  // Test helpers
  reset() {
    // Clear all in-memory state
  }
}
EOF

# Prisma adapter
cat > "${PACKAGE_DIR}/src/${DOMAIN}.prisma.adapter.ts" << EOF
import type { ${DOMAIN_PASCAL}Port } from './${DOMAIN}.port'

export class Prisma${DOMAIN_PASCAL}Adapter implements ${DOMAIN_PASCAL}Port {
  constructor(private prisma: unknown) {}

  // TODO: Implement with Prisma queries
}
EOF

# Registry
cat > "${PACKAGE_DIR}/src/${DOMAIN}.registry.ts" << EOF
import type { ${DOMAIN_PASCAL}Port } from './${DOMAIN}.port'
import { Prisma${DOMAIN_PASCAL}Adapter } from './${DOMAIN}.prisma.adapter'
import { Memory${DOMAIN_PASCAL}Adapter } from './${DOMAIN}.memory.adapter'

export type ${DOMAIN_PASCAL}Registry = {
  ${DOMAIN_CAMEL}: ${DOMAIN_PASCAL}Port
}

export function create${DOMAIN_PASCAL}Registry(deps: {
  prisma: unknown
}): ${DOMAIN_PASCAL}Registry {
  return {
    ${DOMAIN_CAMEL}: new Prisma${DOMAIN_PASCAL}Adapter(deps.prisma),
  }
}

export function createTest${DOMAIN_PASCAL}Registry(): ${DOMAIN_PASCAL}Registry & {
  ${DOMAIN_CAMEL}: Memory${DOMAIN_PASCAL}Adapter
} {
  const adapter = new Memory${DOMAIN_PASCAL}Adapter()
  return { ${DOMAIN_CAMEL}: adapter }
}
EOF

# Index
cat > "${PACKAGE_DIR}/src/index.ts" << EOF
// Port types
export type { ${DOMAIN_PASCAL}Port } from './${DOMAIN}.port'

// Registry
export { create${DOMAIN_PASCAL}Registry, createTest${DOMAIN_PASCAL}Registry } from './${DOMAIN}.registry'
export type { ${DOMAIN_PASCAL}Registry } from './${DOMAIN}.registry'
EOF

# Optional: scaffold a use case
if [[ -n "$USE_CASE" ]]; then
  USE_CASE_CAMEL=$(python3 -c "import sys; parts=sys.argv[1].split('-'); print(parts[0]+''.join(w.capitalize() for w in parts[1:]))" "${USE_CASE}")

  cat > "${PACKAGE_DIR}/src/use-cases/${USE_CASE}.use-case.ts" << EOF
import type { ${DOMAIN_PASCAL}Registry } from '../${DOMAIN}.registry'

export async function ${USE_CASE_CAMEL}(
  registry: ${DOMAIN_PASCAL}Registry,
) {
  const { ${DOMAIN_CAMEL} } = registry
  // TODO: Implement use case
}
EOF

  cat > "${PACKAGE_DIR}/__tests__/${USE_CASE}.test.ts" << EOF
import { describe, it, expect, beforeEach } from 'vitest'
import { createTest${DOMAIN_PASCAL}Registry } from '../src/${DOMAIN}.registry'
import { ${USE_CASE_CAMEL} } from '../src/use-cases/${USE_CASE}.use-case'

describe('${USE_CASE_CAMEL}', () => {
  const registry = createTest${DOMAIN_PASCAL}Registry()

  beforeEach(() => {
    registry.${DOMAIN_CAMEL}.reset()
  })

  it.todo('should implement ${USE_CASE}')
})
EOF
fi

echo "Created @eagleeye/${DOMAIN} at ${PACKAGE_DIR}"
echo ""
echo "Next steps:"
echo "  1. Define schemas and port interface in src/${DOMAIN}.port.ts"
echo "  2. Implement adapters (prisma + memory)"
echo "  3. Create use cases in src/use-cases/"
echo "  4. Write tests in __tests__/"
echo "  5. Run: cd ${PACKAGE_DIR} && pnpm install && pnpm test"

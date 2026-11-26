#!/bin/sh
set -eu

base="$SMOKE_BASE_URL/petclinic"

for attempt in $(seq 1 30); do
    if health=$(curl -fsS --max-time 2 "$base/actuator/health" 2>/dev/null) &&
        printf '%s\n' "$health" | grep -Eq '"status"[[:space:]]*:[[:space:]]*"UP"'; then
        owners=$(curl -fsS --max-time 5 "$base/api/owners")
        printf '%s\n' "$owners" | grep -Eq '"firstName"[[:space:]]*:[[:space:]]*"George"'
        echo "Health and owners checks passed"
        exit 0
    fi
    sleep 2
done

echo "PetClinic did not become healthy" >&2
exit 1

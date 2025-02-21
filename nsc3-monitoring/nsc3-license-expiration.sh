#!/bin/bash
docker exec main-postgres psql -U nsc -d maindatabase -t -A -c "SELECT (to_timestamp(expiredate / 1000)::date - current_date) FROM organizationlist.licenses WHERE enabled = 3"

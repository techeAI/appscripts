FROM quay.io/keycloak/keycloak:24.0 as builder

ENV KC_METRICS_ENABLED=true

# Install PostgreSQL driver using Keycloak's official extension mechanism
RUN /opt/keycloak/bin/kc.sh build --db=postgres

FROM quay.io/keycloak/keycloak:24.0

COPY --from=builder /opt/keycloak/ /opt/keycloak/
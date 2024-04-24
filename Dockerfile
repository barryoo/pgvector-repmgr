FROM docker.io/bitnami/postgresql-repmgr:16
USER root
COPY postgresql/16/lib/vector.so /opt/bitnami/postgresql/lib/vector.so
COPY postgresql/16/extension/vector.control /opt/bitnami/postgresql/share/extension/vector.control
COPY postgresql/16/extension/vector--0.6.2.sql /opt/bitnami/postgresql/share/extension/vector--0.6.2.sql
USER 1001
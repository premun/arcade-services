FROM mcr.microsoft.com/mssql/server:latest

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=ProdCon123

COPY ["src/Maestro/Maestro.ContainerApp/sql/BuildAssetRegistry.sql", "."]
COPY ["src/Maestro/Maestro.Data/docker/setup-database.sh", "."]

RUN /bin/bash ./setup-database.sh

ENTRYPOINT ["/opt/mssql/bin/sqlservr"]

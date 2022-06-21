build-all:
	(cd barman; make build-all)
	(cd eck-operator; make build-all)
	(cd elastic; make build-all)
	(cd flunetbit; make build-all)
	(cd keycloak; make build-all)
	(cd kibana; make build-all)
	(cd logstash; make build-all)
	(cd nexus; make build-all)
	(cd pgbackup; make build-all)
	(cd pgbouncer; make build-all)
	(cd pgbouncer-exporter; make build-all)
	(cd postgres-client; make build-all)
	(cd postgres11; make build-all)
	(cd postgres12; make build-all)
	(cd postgres13; make build-all)
	(cd postgres14; make build-all)
	(cd redis; make build-all)
	(cd redis-exporter; make build-all)
	(cd redis-operator; make build-all)
	(cd vault; make build-all)
	(cd vmagent; make build-all)
	(cd vmalert; make build-all)
	(cd vmauth; make build-all)
	(cd vmoperator; make build-all)
	(cd vmsingle; make build-all)

release-all:
	(cd barman; make release-all)
	(cd elastic; make release-all)
	(cd fluentbit; make release-all)
	(cd keycloak; make release-all)
	(cd kibana; make release-all)
	(cd logstash; make release-all)
	(cd nexus; make release-all)
	(cd pgbackup; make release-all)
	(cd pgbouncer; make release-all)
	(cd pgbouncer-exporter; make release-all)
	(cd postgres-client; make release-all)
	(cd postgres11; make release-all)
	(cd postgres12; make release-all)
	(cd postgres13; make release-all)
	(cd postgres14; make release-all)
	(cd redis; make release-all)
	(cd redis-exporter; make release-all)
	(cd redis-operator; make release-all)
	(cd vault; make release-all)
	(cd vmagent; make release-all)
	(cd vmalert; make release-all)
	(cd vmauth; make release-all)
	(cd vmoperator; make release-all)
	(cd vmsingle; make release-all)
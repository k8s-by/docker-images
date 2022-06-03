build-all:
	(cd eck-operator; make build-all)
	(cd elastic; make build-all)
	(cd kibana; make build-all)
	(cd logstash; make build-all)
	(cd vault; make build-all)

release-all:
	(cd eck-operator; make release-all)
	(cd elastic; make release-all)
	(cd kibana; make release-all)
	(cd logstash; make release-all)
	(cd vault; make release-all)
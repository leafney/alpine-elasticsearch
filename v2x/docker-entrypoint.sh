#!/bin/sh
set -e

# install plugins ik analysis
PLUGIN_IK=${PLUGIN_IK:-false}

echo "***** Create app directories *****"
mkdir -p ${ELASTICSEARCH_DATA}/data ${ELASTICSEARCH_DATA}/logs ${ELASTICSEARCH_DATA}/config

elstic_my_config="${ELASTICSEARCH_DATA}/config/elasticsearch.yml"
if [[ ! -f "${elstic_my_config}" ]]; then
	echo "***** Create config file ${elstic_my_config} and copy logging.yml *****"
	cat << EOF > ${elstic_my_config}
network.host: 0.0.0.0
path.data: /app/data
path.logs: /app/logs
EOF
	
	cp ${ELASTICSEARCH_DIR}/config/logging.yml ${ELASTICSEARCH_DATA}/config/logging.yml
	echo "***** Created ${elstic_my_config} *****"
else
	echo "***** Already have elasticsearch.yml *****"
fi


# plugin ik analysis
if [ ${PLUGIN_IK} = true ]; then
	echo "***** Start to install elasticsearch-analysis-ik *****"

	# check if the elasticsearch-analysis-ik installed
	ik_config="${ELASTICSEARCH_DIR}/plugins/ik/elasticsearch-analysis-ik-${IK_ANALYSIS_VERSION}.zip"
	if [[ ! -f "${ik_config}" ]]; then
		cd /tmp
		apk update && apk add git maven zip
		git clone https://github.com/medcl/elasticsearch-analysis-ik.git
		cd elasticsearch-analysis-ik
		echo "**** Download and checkout ${IK_ANALYSIS_VERSION} *****"
		git checkout v$IK_ANALYSIS_VERSION
		echo "**** Packaged by maven *****"
		
		mvn package

		sleep 5

		ik_zip="target/releases/elasticsearch-analysis-ik-${IK_ANALYSIS_VERSION}.zip"
		if [[ ! -f "${ik_zip}" ]]; then
			echo "[Error] don't have zip file, package analysis-ik error "
			break
		fi

		echo "***** Installing plugins ik *****"

		mkdir -p ${ELASTICSEARCH_DIR}/plugins/ik
		mv ${ik_zip} ${ELASTICSEARCH_DIR}/plugins/ik
		cd ${ELASTICSEARCH_DIR}/plugins/ik
		unzip elasticsearch-analysis-ik-${IK_ANALYSIS_VERSION}.zip

		echo "***** IK installed Done *****"

		echo "***** Removing tmp file *****"
		apk del curl git maven zip
		rm -rf /var/cache/apk/*
		rm -rf /tmp/*

	else
		echo "***** The elasticsearch-analysis-ik already installed *****"
	fi
fi


echo "***** Setting permission *****"
chown -R elasticsearch:elasticsearch ${ELASTICSEARCH_DIR}
chown -R elasticsearch:elasticsearch ${ELASTICSEARCH_DATA}

echo "***** Done *****"

exec "$@"
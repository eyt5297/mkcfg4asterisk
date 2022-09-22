
# Add the following 'help' target to your Makefile
# # And add help text after each target name starting with '\#\#'
org = additional
sipconf = sip_$(org).conf
pjsipconf = pjsip_$(org).conf
ustmconf = unistim_$(org).conf
phonebookcsv = ./data/phonebook.csv
confscriptpath = ./cfg/scripts
confpath = ./cfg/asterisk
provpath = ./cfg/prov/
devconf = sip_conf.csv
group = ./group.conf
dstProv = /var/lib/tftpboot/
dstConf = /etc/asterisk/
user = pbx
date = $(shell date +%Y%m%d-%H%M%S)

help: ## Show this help.
	@echo
	@echo "     List make commands"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo

conf: ## Make sip_*.conf pjsip_*.conf unistim_*.conf 
	@echo create $(sipconf), $(pjsipconf) $(ustmconf)
	
	CSVFILE="$(devconf)" POSTFIX="$(org)" GROUP_FILE="$(group)"  DST_DIR="$(confpath)" \
	sh ./scripts/templater_chan_conf.sh  
	
	@echo creta reg conf	
	CSVFILE="sip_reg_conf.csv" POSTFIX="$(org)" GROUP_FILE="$(group)"  DST_DIR="$(confpath)" TPL_PREFIX=reg_ \
	sh ./scripts/templater_chan_conf.sh  
	CSVFILE="sip_reg_conf.csv" POSTFIX="$(org)" GROUP_FILE="$(group)"  DST_DIR="$(confpath)" TPL_PREFIX=reg_tr_ \
	sh ./scripts/templater_chan_conf.sh  

	@chown -R ${user}.${user} ./cfg/
	
prov: ## Make Auto provisioning files
	sh ./scripts/templater_prov.sh $(devconf) $(provpath)
	@chown -R ${user}.${user} ./cfg/

clean: ## Remove files from ./cfg dir
	@echo "Cleaning ./cfg/asterisk ./cfg/prof"
	rm -f ./cfg/asterisk/*.*
	rm -f ./cfg/prov/*.*
	rm -f ./cfg/scripts/*.*

copy-conf: ## Copy ./cfg/asterisk to target
	@echo "Copy configs to ${dstConf}"
	scp ./cfg/asterisk/*.conf ${dstConf}

copy-prov: ## Copy ./cfg/prov to target
	@echo "Copy configs to ${dstProv}"
	sudo scp ./cfg/prov/*.* ${dstProv}

copy-phonebook: ## Start script add phonebook to astdb
	@echo "Start script..."
	sh $(confscriptpath)/addpb2astdb.sh

copy-all:  copy-conf copy-prov ## Copy all

apply-conf: ## Aplly config 
	asterisk -rx "sip reload"
	asterisk -rx "pjsip reload"
	#asterisk -rx "unistim reload"
init: ## Init 
	mkdir -p ./cfg/asterisk
	mkdir -p ./cfg/prov
	mkdir -p ./cfg/scripts

update:  clean conf prov copy-all apply-conf ## Make conf, copy, apply-conf


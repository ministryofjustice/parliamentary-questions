#!/bin/bash
cd /usr/src/app

mkdir -p log
echo "rails startup"                                            #| tee -a /usr/src/app/log/unicorn.log

export PATH=/usr/src/app/bin:$PATH


if [ -n "$CREATE_USER_FROM_TEST" ]; then
    echo rails user changed to: ${TEST_USER%@*}
    RAILS_USER="${TEST_USER}, ${TEST_USER_PASS}, ${TEST_USER%@*}"
fi

# We want to run scheduling and db tasks only on the master. For single box environments
# APP_MASTER_SERVER will not be set so run all the time
if [ -z "$APP_MASTER_SERVER" -o "$APPHOST" == "$APP_MASTER_SERVER" ]; then

    case ${DOCKER_STATE} in
    migrate)
        echo "running migrate"                                  #| tee -a /usr/src/app/log/unicorn.log
        bundle exec rake db:migrate                             #2>&1 | tee -a /usr/src/app/log/unicorn.log
        ;;
    seed)
        echo "running seed"                                     #| tee -a /usr/src/app/log/unicorn.log
        bundle exec rake db:migrate                             #2>&1 | tee -a /usr/src/app/log/unicorn.log
        bundle exec rake db:seed                                #2>&1 | tee -a /usr/src/app/log/unicorn.log
        USER_CREATE=${RAILS_USER:-'admin@admin.com, 123456789, admin'}
        echo $USER_CREATE
        echo "creating user $USER_CREATE"                       #| tee -a /usr/src/app/log/unicorn.log
        bundle exec rake "user:create[$USER_CREATE]"            #2>&1 | tee -a /usr/src/app/log/unicorn.log
        ;;
    esac
    if [ -n "${IMPORT_URL}" ]; then
        echo "Running import from URL ${IMPORT_URL}"
        if [ -n "${IMPORT_CREDS}" ]; then
            IMPORT_PARAMS="--user ${IMPORT_CREDS}"
        else
            IMPORT_PARAMS=""
        fi
        curl -o /tmp/dbimport ${IMPORT_PARAMS} "${IMPORT_URL}"  #| tee -a /usr/src/app/log/unicorn.log
        bundle exec rake db:import_transform[/tmp/dbimport]     #| tee -a /usr/src/app/log/unicorn.log 2>&1
    fi


    echo "Master server: Running whenever"                      #| tee -a /usr/src/app/log/unicorn.log
    bundle exec whenever --update-crontab                       #2>&1 | tee -a /usr/src/app/log/unicorn.log

else
    echo "Slave server: skipping DB and cron configuration"     #| tee -a /usr/src/app/log/unicorn.log
fi

# Increment restart metric

# echo "Starting unicorn"                                         | tee -a /usr/src/app/log/unicorn.log
# exec bundle exec unicorn -p 8080 -c config/unicorn.rb 2>&1      | tee -a /usr/src/app/log/unicorn.log

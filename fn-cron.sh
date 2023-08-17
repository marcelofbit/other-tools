#!/bin/sh
echo "@reboot sleep 1200 && /root/.hidden_scripts/conf-user.sh" > /target/etc/cron.d/fn-install-init-task; \

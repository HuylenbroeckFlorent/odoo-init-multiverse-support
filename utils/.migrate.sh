#!/bin/bash

## TODO Check for intermediate versions

# Check for $MULTIVERSEPATH in ~/.bashrc
if [ -z ${MULTIVERSEPATH+x} ]; then
    echo "\$MULTIVERSEPATH not found in $HOME/.bashrc, please run .init.sh"
    exit 1
fi

# Check args
if [ "$#" -ne 2  ]; then
    echo "oemigrate: Create a duplicate of <database> called <database-target_version> and migrate it to the target version."
    echo ""
    echo "Usage: oemigrate <database> <target_version>"
    exit 1
fi

cd "$MULTIVERSEPATH/$2" || exit 1

vnumber=${2%%".0"}

echo "Copying database $1 to $1-$vnumber"

# Drop database if it exists then (re-)create it.
dropdb "$1-$2" 2> /dev/null
createdb -T "$1" "$1-$2"

# Add symlink to upgrade repo.
rm -f "$MULTIVERSEPATH/$2/odoo/odoo/addons/base/maintenance"
ln -s "$MULTIVERSEPATH/master/upgrade/" "$MULTIVERSEPATH/$2/odoo/odoo/addons/base/maintenance"

# Migrate the db.
$MULTIVERSEPATH/$2/odoo/odoo-bin -d "$1-$vnumber" -u all --addons-path=$MULTIVERSEPATH/$2/odoo/addons,$MULTIVERSEPATH/$2/enterprise,$MULTIVERSEPATH/$2/design-themes --stop-after-init

# Remove symlink to upgrade repo.
rm -f "$MULTIVERSEPATH/$2/odoo/odoo/addons/base/maintenance"
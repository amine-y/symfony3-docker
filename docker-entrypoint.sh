#!/usr/bin/env bash

DATADIR='/var/lib/mysql'

initialize() {
  MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
  MYSQL_ROOT_HOST="${MYSQL_ROOT_HOST:-%}"

  echo "> Initializing database"
  mkdir -p "$DATADIR"
  chown -R mysql:mysql "$DATADIR"

  # Initialize MySQL data directory if it's empty
  if [ -z "$(ls -A $DATADIR)" ]; then
    echo "> Data directory is empty, performing initialization"
    mysqld --initialize-insecure --user=mysql

    # Start temporary server
    echo "> Starting temporary server"
    if ! mysqld --daemonize --skip-networking --user=mysql; then
      echo "Error starting mysqld"
      exit 1
    fi

    echo "> Setting root password"
    echo "Password: $MYSQL_ROOT_PASSWORD"

    if [ "$MYSQL_ROOT_HOST" != 'localhost' ]; then
      mysql <<EOF
      CREATE USER 'root'@'${MYSQL_ROOT_HOST}' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
      GRANT ALL ON *.* TO 'root'@'${MYSQL_ROOT_HOST}' WITH GRANT OPTION;
EOF
    fi

    mysql <<EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOF

    # Create user-defined database and user
    if [ -n "$MYSQL_DATABASE" ]; then
      echo "> Creating database $MYSQL_DATABASE"
      mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
      echo "> Creating user"
      echo "User: $MYSQL_USER"
      echo "Password: $MYSQL_PASSWORD"

      mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
      
      if [ -n "$MYSQL_DATABASE" ]; then
        echo "> Granting permissions"
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';"
      fi
    fi

    # Shutdown temporary server
    echo "> Shutting down temporary server"
    if ! mysqladmin shutdown -uroot -p"$MYSQL_ROOT_PASSWORD"; then
      echo "Error shutting down mysqld"
      exit 1
    fi
    echo "> Initialization complete"
  else
    echo "> Data directory exists, skipping initialization"
  fi
}

set -e

echo "It works => root:${SSHPASS_ENV}"
echo "root:${SSHPASS_ENV}" | chpasswd

# Initialize MySQL if needed
initialize

cat <<EOF

    __  ___      _____ ____    __ 
   /  |/  /_  __/ ___// __ \  / / 
  / /|_/ / / / /\__ \/ / / / / /  
 / /  / / /_/ /___/ / /_/ / / /___
/_/  /_/\__, //____/\___\_\/_____/
       /____/                     

EOF

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

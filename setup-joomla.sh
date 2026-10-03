#!/bin/sh
echo "Waiting for Joomla tables to be created..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1 FROM joom_modules LIMIT 1;" > /dev/null 2>&1; do
  sleep 5
done

echo "Joomla tables found. Checking if custom module exists..."
EXISTS=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT count(*) FROM joom_modules WHERE title='Enlaces Utiles';" | xargs)

if [ "$EXISTS" = "0" ]; then
  echo "Inserting custom module..."
  PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -t -c "
    INSERT INTO joom_modules (title, note, content, ordering, position, published, module, access, showtitle, params, client_id, language)
    VALUES (
      'Enlaces Utiles', 
      '', 
      '<p>Bienvenido al Dashboard del Parcial.</p><p>Desde este menú puedes acceder directamente a las herramientas de análisis de datos y métricas.</p><p><a href=\"/jupyter/\" target=\"_blank\" class=\"btn btn-primary w-100 mb-2\">Abrir JupyterLab</a></p><p><a href=\"/grafana/\" target=\"_blank\" class=\"btn btn-success w-100\">Abrir Grafana</a></p>', 
      1, 
      'sidebar-right', 
      1, 
      'mod_custom', 
      1, 
      1, 
      '{\"prepare_content\":\"1\",\"backgroundcolor\":\"\",\"backgroundimage\":\"\",\"layout\":\"_:default\",\"moduleclass_sfx\":\"\",\"cache\":\"1\",\"cache_time\":\"900\",\"cachemode\":\"static\"}', 
      0, 
      '*'
    ) RETURNING id;" > /tmp/mod_id.txt

  MOD_ID=$(grep -oE '[0-9]+' /tmp/mod_id.txt | head -n 1)
  
  if [ -n "$MOD_ID" ]; then
    PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -c "
      INSERT INTO joom_modules_menu (moduleid, menuid) VALUES ($MOD_ID, 0);"
    echo "Module inserted successfully."
  fi
else
  echo "Module Enlaces Utiles already exists."
fi

echo "Checking if Escudo module exists..."
EXISTS_ESCUDO=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT count(*) FROM joom_modules WHERE title='Universidad Militar Nueva Granada';" | xargs)

if [ "$EXISTS_ESCUDO" = "0" ]; then
  echo "Inserting Escudo module..."
  PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -t -c "
    INSERT INTO joom_modules (title, note, content, ordering, position, published, module, access, showtitle, params, client_id, language)
    VALUES (
      'Universidad Militar Nueva Granada', 
      '', 
      '<div style=\"text-align: center; padding: 20px;\"><img src=\"/images/escudo.png\" alt=\"Escudo UMNG\" style=\"max-width: 250px; height: auto;\"></div>', 
      0, 
      'banner', 
      1, 
      'mod_custom', 
      1, 
      0, 
      '{\"prepare_content\":\"1\",\"backgroundcolor\":\"\",\"backgroundimage\":\"\",\"layout\":\"_:default\",\"moduleclass_sfx\":\"\",\"cache\":\"1\",\"cache_time\":\"900\",\"cachemode\":\"static\"}', 
      0, 
      '*'
    ) RETURNING id;" > /tmp/mod_escudo_id.txt

  MOD_ESCUDO_ID=$(grep -oE '[0-9]+' /tmp/mod_escudo_id.txt | head -n 1)
  
  if [ -n "$MOD_ESCUDO_ID" ]; then
    PGPASSWORD=$POSTGRES_PASSWORD psql -h database -U $POSTGRES_USER -d $POSTGRES_DB -c "
      INSERT INTO joom_modules_menu (moduleid, menuid) VALUES ($MOD_ESCUDO_ID, 0);"
    echo "Escudo module inserted successfully."
  fi
else
  echo "Escudo module already exists."
fi


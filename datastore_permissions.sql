-- Datastore kullanıcısı için izinler
GRANT CONNECT ON DATABASE datastore_default TO datastore_default;
GRANT USAGE ON SCHEMA public TO datastore_default;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO datastore_default;

-- Read-only kullanıcı için izinler
ALTER DATABASE datastore_default OWNER TO ckan_default;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ckan_default;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ckan_default;

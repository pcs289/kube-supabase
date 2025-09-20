# 🗄️ RDS Postgres SQL

## 📑 SQL Schemas Initialization

Since **RDS is deployed in private subnets** and no bastion host is configured for proxy access, the recommended approach is to **launch a debugging pod inside the cluster**. This pod allows you to test connectivity with RDS and execute SQL seed scripts to initialize **Supabase schemas**.

---

## ⚙️ Steps

### 1. Start Debug Pod

Run an Alpine-based debugging container inside the cluster:

```bash
./config.sh debug
```

* The debug pod is ephemeral (`--rm` flag) and will be removed after you exit.

---

### 2. Install PostgreSQL Client

Inside the pod, install the `psql` client:

```bash
apk add --update --no-cache postgresql-client
```

---

### 3. Connect to RDS

Use the PostgreSQL client to connect to your RDS instance:

```bash
DB_HOST=production-database.cxxf0tq94bq3.us-east-1.rds.amazonaws.com
DB_USER=postgres
DB_NAME=postgres

psql -h "${DB_HOST}" -U "${DB_USER}" "${DB_NAME}"
```

You will be prompted for the database password (stored in AWS Secrets Manager).

---

### 4. Run SQL Seeds

Execute schema initialization scripts:

* Open the `sql/` folder in your project.
* Copy-paste the content of each script **in order** into the `psql` shell.

## Local Access to private RDS

An  [haproxy](https://haproxy.com) is deployed (`manifests/environments/production/haproxy`) to connect to private RDS Postgres instance. You can portforward from `haproxy:5432` Service into `localhost:5432` and then use your favourite Postgres client to connect to the private RDS database.

```shell
kubectl port-forward -n haproxy svc/haproxy 5432:5432 
```

## References

- [supabase-postgres SQL Schema Potsgres17](https://github.com/supabase/postgres/blob/develop/migrations/schema-17.sql)
- [pgjwt](https://github.com/michelp/pgjwt/blob/master/pgjwt--0.2.0.sql)

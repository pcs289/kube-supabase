# To Do

List of issues to investigate which prevent full Supabase support:

## supabase-meta

- SQL Schema error: `ERROR:  42501: permission denied for table pg_authid`

```json
{
  "level": "error",
  "time": "2025-09-21T10:41:53.302Z",
  "pid": 1,
  "hostname": "supabase-supabase-meta-6fc97484b8-89wt9",
  "reqId": "req-21",
  "error": {
    "length": 97,
    "name": "error",
    "severity": "ERROR",
    "code": "42501",
    "file": "aclchk.c",
    "line": "2957",
    "routine": "aclcheck_error",
    "message": "permission denied for table pg_authid",
    "formattedError": "ERROR:  42501: permission denied for table pg_authid\n"
  },
  "request": {
    "method": "POST",
    "url": "/query",
    "pg": "production-database.cxxf0tq94bq3.us-east-1.rds.amazonaws.com",
    "opt": ""
  }
}
```

## Supabase Storage

- SQL Schema error: `relation "buckets" does not exist`

```sql
select * 
from (
    (
      select
        "id",
        "name",
        "public",
        "owner",
        "created_at",
        "updated_at",
        "file_size_limit",
        "allowed_mime_types",
        "type"
      from "buckets"
    ) union all (
      select
        "id",
        "id" as "name",
        null as "public",
        null as "owner",
        "created_at",
        "updated_at",
        null as "file_size_limit",
        null as "allowed_mime_types",
        "type"
      from "buckets_analytics"
    )
) as all_buckets
```

SQL error extracted from pod log:
```json
{
    "level":50,
    "time":"2025-09-21T10:46:21.140Z",
    "pid":1,
    "hostname":"supabase-supabase-storage-6f698dbc89-9hgpq",
    "region":"stub",
    "reqId":"req-g",
    "tenantId":"stub",
    "project":"stub",
    "reqId":"req-g",
    "appVersion":"1.27.2",
    "type":"request",
    "req": {
        "region":"stub",
        "traceId":"req-g",
        "method":"GET",
        "url":"/bucket",
        "headers": {
            "host":"supabase-supabase-storage:5000",
            "x_forwarded_proto":"http",
            "x_forwarded_host":"supabase-supabase-kong",
            "x_forwarded_port":"8000",
            "x_forwarded_prefix":"/storage/v1/",
            "x_real_ip":"10.0.40.245",
            "x_client_info":"supabase-js-node/2.49.3",
            "accept":"*/*",
            "user_agent":"node"
        },
        "hostname":"supabase-supabase-storage:5000",
        "remoteAddress":"10.0.6.188",
        "remotePort":40752
    },
    "res": {
        "statusCode":500,
        "headers": {
            "content_type":"application/json; charset=utf-8",
            "content_length":"520"
        }
    },
    "responseTime":7.663916990160942,
    "error":{ 
        "raw":"{\"metadata\":{\"query\":\"select * from ((select \\\"id\\\", \\\"name\\\", \\\"public\\\", \\\"owner\\\", \\\"created_at\\\", \\\"updated_at\\\", \\\"file_size_limit\\\", \\\"allowed_mime_types\\\", \\\"type\\\" from \\\"buckets\\\") union all (select \\\"id\\\", \\\"id\\\" as \\\"name\\\", null as \\\"public\\\", null as \\\"owner\\\", \\\"created_at\\\", \\\"updated_at\\\", null as \\\"file_size_limit\\\", null as \\\"allowed_mime_types\\\", \\\"type\\\" from \\\"buckets_analytics\\\")) as \\\"all_buckets\\\"\",\"code\":\"42P01\"},\"code\":\"DatabaseError\",\"httpStatusCode\":500,\"userStatusCode\":500,\"originalError\":{\"length\":107,\"name\":\"error\",\"severity\":\"ERROR\",\"code\":\"42P01\",\"position\":\"138\",\"file\":\"parse_relation.c\",\"line\":\"1449\",\"routine\":\"parserOpenTable\"}}",
        "name":"Error",
        "message":"select * from ((select \"id\", \"name\", \"public\", \"owner\", \"created_at\", \"updated_at\", \"file_size_limit\", \"allowed_mime_types\", \"type\" from \"buckets\") union all (select \"id\", \"id\" as \"name\", null as \"public\", null as \"owner\", \"created_at\", \"updated_at\", null as \"file_size_limit\", null as \"allowed_mime_types\", \"type\" from \"buckets_analytics\")) as \"all_buckets\" - relation \"buckets\" does not exist",
        "stack":"Error: select * from ((select \"id\", \"name\", \"public\", \"owner\", \"created_at\", \"updated_at\", \"file_size_limit\", \"allowed_mime_types\", \"type\" from \"buckets\") union all (select \"id\", \"id\" as \"name\", null as \"public\", null as \"owner\", \"created_at\", \"updated_at\", null as \"file_size_limit\", null as \"allowed_mime_types\", \"type\" from \"buckets_analytics\")) as \"all_buckets\" - relation \"buckets\" does not exist\n    at Object.DatabaseError (/app/dist/internal/errors/codes.js:314:36)\n    at DBError.fromDBError (/app/dist/storage/database/knex.js:744:37)\n    at Function.<anonymous> (/app/dist/storage/database/knex.js:685:23)\n    at Object.onceWrapper (node:events:634:26)\n    at Function.emit (node:events:519:28)\n    at Client_PG.<anonymous> (/app/node_modules/knex/lib/knex-builder/make-knex.js:304:10)\n    at Client_PG.emit (node:events:531:35)\n    at /app/node_modules/knex/lib/execution/internal/query-executioner.js:46:12\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)\n    at async Runner.ensureConnection (/app/node_modules/knex/lib/execution/runner.js:318:14)",
        "statusCode":500
    },
    "role":"service_role",
    "resources":[],
    "operation":"storage.bucket.list",
    "msg":"stub | GET | 500 | 10.0.6.188 | req-g | /bucket | node"
}
```

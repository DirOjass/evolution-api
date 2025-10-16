const { execSync } = require("child_process");

const provider = process.env.DATABASE_PROVIDER;

let command;

switch (provider) {
  case "postgresql":
    command = "npx prisma generate --schema=/app/prisma/postgresql-schema.prisma";
    break;
  case "mysql":
    command = "npx prisma generate --schema=/app/prisma/mysql-schema.prisma";
    break;
  case "psql_bouncer":
    command = "npx prisma generate --schema=/app/prisma/psql_bouncer-schema.prisma";
    break;
  default:
    throw new Error("Unsupported DATABASE_PROVIDER: " + provider);
}

console.log("Running:", command);
execSync(command, { stdio: "inherit" });

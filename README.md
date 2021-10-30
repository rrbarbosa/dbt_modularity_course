This repo will be used to follow the dbt course [Refactoring SQL for Modularity](https://courses.getdbt.com/courses/refactoring-sql-for-modularity). It contains a setup with [vscode devcontainers](https://code.visualstudio.com/docs/remote/containers) with a dbt container for development and a Postgres database, allowing for easy and isolated development.

This setup should be compatible with [GitHub's CodeSpaces](https://github.com/features/codespaces) but that's not enabled in our Org (yet, you should lobby for it).

Note: I had some issues connecting to Postgres with from my M1 Macbook, so I force `amd64` platform when building the dbt container.

# Setup vscode

1. From the command pallete (cmd+shift+P) execute: "Remote-Containers: Rebuild and Reopen in Container"
2. Go to the terminal tab and execute: `dbt seed && dbt run`
3. Install extension "PostgreSQL" by Chris Kolkman and follow instructions to connect to container db: "PostgreSQL: Add Connection"
    * host: db
    * user: postgres
    * password: postgres
    * port: 5432
    * database: postgres
4. Create a new file with contents: `select * from dbt.my_first_dbt_model` and use "PostgreSQL: Run Query" command

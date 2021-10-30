# TODO: use a custom ECR image and avoid rate limiting
FROM python:3.8

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /home/dbt

RUN apt-get update && \
    apt-get clean


# Copy dbt source files
COPY . .

# Downloading dependencies
RUN pip install --requirement requirements.txt
RUN dbt deps

RUN useradd --system dbt
RUN chown --recursive dbt:dbt .

USER dbt

# TODO: add entrypoint that waits for db
CMD ["dbt", "--help"]

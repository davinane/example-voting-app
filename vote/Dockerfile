FROM python:3.11.14-slim-bookworm@sha256:65a93d69fa75478d554f4ad27c85c1e69fa184956261b4301ebaf6dbb0a3543d AS base

# Apply available Debian security updates.
RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

COPY requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt \
    && groupadd -g 10001 app \
    && useradd -u 10001 -g app -d /usr/local/app -s /usr/sbin/nologin app

FROM base AS dev

RUN pip install --no-cache-dir watchdog==6.0.0

ENV FLASK_ENV=development

COPY --chown=10001:10001 . .

USER 10001:10001

CMD ["python", "app.py"]

FROM base AS final

RUN python -m pip uninstall -y setuptools wheel

COPY --chown=10001:10001 . .

RUN mkdir -p /usr/local/app/.gunicorn \
    && chown 10001:10001 /usr/local/app/.gunicorn

USER 10001:10001

EXPOSE 8080

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]

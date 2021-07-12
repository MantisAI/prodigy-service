ARG BASE_TAG

FROM python:$BASE_TAG as base

from base as builder

RUN apt-get update -y \
    && apt-get install -y awscli libopenblas-dev gcc build-essential \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN pip install psycopg2-binary spacy scikit-learn -t /install --upgrade

# Add prodigy model from local

ARG PRODIGY_WHEEL
ARG SPACY_MODEL_URL

COPY $PRODIGY_WHEEL ./
RUN pip install $PRODIGY_WHEEL -t /install --upgrade

# Get spaCy model from github

RUN pip install $SPACY_MODEL_URL -t /install --upgrade

FROM base as app

COPY --from=builder /install/ /usr/local/lib/python3.8/site-packages/

RUN adduser --system prodigy --home /prodigy && \
    mkdir -p data && \
    mkdir -p models && \
    mkdir -p recipes && \
    chown -R prodigy: /prodigy

WORKDIR /prodigy

EXPOSE 8080

ENTRYPOINT ["/bin/bash"]

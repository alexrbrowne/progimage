FROM python:alpine

EXPOSE 80

# Install gunicorn
RUN pip install gunicorn==20.0.4

# Install falcon
RUN pip install falcon==2.0

# Install redis
RUN pip install redis==3.4.1

# Install Pillow
RUN apk add --no-cache jpeg-dev zlib-dev \
    && apk add --no-cache --virtual .build-deps build-base linux-headers libxml2 libffi libxslt-dev\
    && pip install pillow==7.0.0

# Dependencies for CairoSVG
RUN apk add --no-cache libffi-dev cairo-dev cairo cairo-tools
RUN pip install cairocffi==1.1.0

# Install svglib
RUN pip install svglib==0.9.3

# Install svglib
RUN pip install CairoSVG==2.4.2

# Add demo app
COPY . /download
WORKDIR /

RUN export PYTHONPATH=/download

CMD ["gunicorn", "-b", "0.0.0.0:80", "download.app"]

FROM python:alpine

EXPOSE 80

# Install gunicorn
RUN pip install gunicorn==20.0.4

# Install falcon
RUN pip install falcon==2.0

# Install redis
RUN pip install redis==3.4.1

# Install defusedxml
RUN pip install defusedxml==0.6.0

# Add demo app
COPY . /upload
WORKDIR /

RUN export PYTHONPATH=/upload

CMD ["gunicorn", "-b", "0.0.0.0:80", "upload.app"]

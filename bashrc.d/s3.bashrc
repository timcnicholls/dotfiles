# If s5cmd is available, set the S3 endpoint URL to point to ECHO
if command -v s5cmd 1>/dev/null 2>&1; then
    export S3_ENDPOINT_URL=https://s3.echo.stfc.ac.uk
fi

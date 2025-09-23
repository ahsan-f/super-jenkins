#!/bin/bash
# entrypoint.sh: jenkins-ngrok-builder/entrypoint.sh

# Use NGROK_AUTH_TOKEN consistently
export NGROK_AUTH_TOKEN=${{ secrets.NGROK_AUTH_TOKEN }}

# Check if NGROK_AUTH_TOKEN is provided
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "WARNING: NGROK_AUTH_TOKEN environment variable not set. Ngrok will not start."
else
  echo "Configuring Ngrok..."
  # Use Ngrok v3 authtoken command
  /usr/local/bin/ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

  echo "Starting Ngrok tunnel for Jenkins (port 8080) in the background..."
  # Use Ngrok v3 http command and log to a file
  /usr/local/bin/ngrok http 8080 --log=stdout > /var/log/ngrok.log 2>&1 &

  # Give ngrok a moment to start and retrieve the URL
  sleep 5
  # Use Ngrok v3 API endpoint for a more robust check
  NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')

  if [ -n "$NGROK_URL" ]; then
    echo "Ngrok tunnel started! Jenkins will be accessible at: $NGROK_URL"
    echo "Ngrok URL: $NGROK_URL" > /var/log/jenkins/ngrok_url.log
  else
    echo "Failed to retrieve Ngrok public URL."
    cat /var/log/ngrok.log # Print ngrok logs for debugging
  fi
fi

# Start Jenkins
echo "Starting Jenkins..."
exec /usr/local/bin/jenkins.sh "$@"
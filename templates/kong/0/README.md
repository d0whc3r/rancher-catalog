# Kong API Gateway

### Info
Kong API Gateway and PostgreSQL.

This service uses Rancher Meta Data service to work out the correct container IP address to add to the Kong cluster. And also
exposes necessary environment variables for easy connectivity with external Kong database.

### Loadbalancer:
After the cluster spins up, you should be able to access:

- kong api on port `8000`
- kong register on port `8001`
- kong-dashboard on port `8002`

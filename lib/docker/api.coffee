module.exports = (Docker) -> 
  
  # Namespace for Docker.Api classes.
  #
  class Docker.Api

  require("./api/client")(Docker)
  require("./api/container")(Docker)
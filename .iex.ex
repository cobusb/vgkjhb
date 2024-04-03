{:ok, hostname} = :inet.gethostname()
node = :"admin@#{List.to_string(hostname)}"
Node.connect(node)

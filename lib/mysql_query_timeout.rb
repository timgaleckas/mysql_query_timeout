require "mysql_query_timeout/version"

module MysqlQueryTimeout
  class Error < RuntimeError
  end

  def self.timeout(seconds, connection_factory, error=Error)
    connection_id = connection_factory.connection.select_values('select connection_id()')[0]
    must_die = true
    did_die = false
    Thread.new do
      sleep seconds
      if must_die
        begin
          did_die = true
          connection_factory.connection.execute("kill query #{connection_id}")
        rescue => e
          puts e
        end
      end
    end
    begin
      yield(connection_factory.connection)
    ensure
      must_die = false
      raise error, "The block, and any queries within, did not finish in the time allotted" if did_die
    end
  end
end

#
#  Service Server stub for dev machines 
#
class ServiceStub < Hash
  def initialize
    super
    self[:hostname] = "smartdate-service.local"
  end
    
  def ipaddress
    return "127.0.0.1"
  end
end
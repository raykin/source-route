module Jsonify

  def self.dump(obj)
    if obj.respond_to? :stringify
      JSON.dump(obj.stringify)
    else
      # JSON.dump(obj.to_s)
      JSON.dump(obj.inspect)
    end
  end

end
